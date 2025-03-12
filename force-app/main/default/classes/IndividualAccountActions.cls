/**
 * @author Ankit Garg
 * @since  12/2023
 * @description IndividualAccountActions is class to handle the Individual Account Actions
 * @runTests IndividualAccountActionsTest
 */
public with sharing class IndividualAccountActions {
  private static final String PROSPECT = 'Prospect';
  private static final String CUSTOMER_ATTRIBUTE_NONE_SELECTION_ERROR = 'The selection of \'None\' is no longer a valid option.';
  private static final Set<SObjectField> CUSTOMER_ATTRIBUTE_FIELDS = new Set<SObjectField>{
    Account.Disclosure_Indicator__c,
    Account.Advertising_Indicator__c,
    Account.FinServ__MaritalStatus__pc,
    Account.Occupation__c,
    Account.Gender__pc
  };
  private static final Set<SObjectField> BILLING_ADDRESS_FIELDS = new Set<SObjectField>{
    Account.BillingStreet,
    Account.BillingCity,
    Account.BillingState,
    Account.BillingCountry,
    Account.BillingPostalCode
  };
  private static final Set<SObjectField> CUSTOMER_FIELDS = new Set<SObjectField>{
    Account.FirstName,
    Account.MiddleName,
    Account.LastName,
    Account.Salutation,
    Account.Suffix
  };

  private static final AccountActionsRepository ACC_REPOSITORY = (AccountActionsRepository) Lib_InstanceProvider.forType(
    AccountActionsRepository.class
  );

  /**
   * @description CC-5112 && CC-7016 to restrict Date of Birth in Future
   * @name validateDateOfBirth
   * @param records The Account records passed from Trigger.new()
   */
  public static void validateDateOfBirth(List<Account> records) {
    for (Account rec : records) {
      if (
        rec.PersonBirthdate != null &&
        rec.PersonBirthdate >= System.TODAY()
      ) {
        rec.addError(Label.ML_DateOfBirth_ErrorMessage);
      }
    }
  }

  /**
   * @description CC-7698 to revert Billing Address of the Shell Prospect auto populated during lead conversion
   * @name revertShellProspectBillingAddress
   * @param records The Account records passed from Trigger.new()
   */
  public static void revertShellProspectBillingAddress(List<Account> records) {
    if (
      !CCRMLeadConversionActions.manualLeadConversionInitiated ||
      String.isBlank(System.Label.ShellProspectOCVEventVersion)
    ) {
      return;
    }
    List<Account> accountsToRevert = ListUtil.filter(records)
      .equals(Account.FinServ__Status__c, PROSPECT)
      .equals(
        Account.OCV_Event_Version__c,
        Integer.valueOf(System.Label.ShellProspectOCVEventVersion)
      )
      .anyNotNull(BILLING_ADDRESS_FIELDS)
      .toList();
    blankBillingAddress(accountsToRevert);
  }

  /**
   * @description Revert the billing address of the accounts being passed
   * @name blankBillingAddress
   * @param records The Account records to have billing address blanked out
   */
  @TestVisible
  private static void blankBillingAddress(List<Account> records) {
    for (Account account : records) {
      account.BillingStreet = null;
      account.BillingCity = null;
      account.BillingState = null;
      account.BillingCountry = null;
      account.BillingPostalCode = null;
    }
  }

  /**
   * @since  10/2024
   * @group MLCRM (Mobile Lending CRM)
   * @name validateCustomerAttribute
   * @param records List of sObject records
   * @param oldMap map of old sObject records
   * @description  filter Sobjects when user selects value as None and add Error sobject to it
   */
  public static void validateCustomerAttribute(
    List<Account> records,
    Map<Id, SObject> oldMap
  ) {
    if (!ACC_REPOSITORY.isCurrentUserML()) {
      return;
    }
    List<sObject> lstOfInvalidRecords = ListUtil.filter(records, oldMap)
      .anyChangedTo(CUSTOMER_ATTRIBUTE_FIELDS, null)
      .toList();
    CommonUtil.raiseSobjectError(
      lstOfInvalidRecords,
      CUSTOMER_ATTRIBUTE_NONE_SELECTION_ERROR
    );
  }

  /**
   * @description to set Employer Name and Self employed fields empty for applicable employment types
   * @name handleEmploymentTypeChange
   * @param records account records from Trigger.new
   * @param oldMap Map of Id and Accounts from Trigger.oldMap
   */
  public static void handleEmploymentTypeChange(
    List<Account> records,
    Map<Id, Account> oldMap
  ) {
    if (!ACC_REPOSITORY.isCurrentUserML()) {
      return;
    }
    Set<String> applicableEmpTypeSet = new Set<String>{
      'Student',
      'Retired/Pensioner',
      'Homemaker',
      'Unemployed'
    };
    List<Account> filteredRecords = ListUtil.filter(records, oldMap)
      .changedTo(Account.Employment_Type__c, applicableEmpTypeSet)
      .toList();
    for (Account record : filteredRecords) {
      record.Employer_Name__c = null;
      record.Self_Employed__c = null;
    }
  }

  /**
   * @description get set of updated customer's id's who specific fields got updated
   * @name getUpdatedCustomersIds
   * @param oldMap A Map of AccountId and Account.
   * @param records list of updated Account records.
   */
  public static void getUpdatedCustomersIds(
    Map<Id, Account> oldMap,
    List<Account> records
  ) {
    if (System.isFuture() || System.isBatch()) {
      return;
    }
    List<Account> listOfSobjects = ListUtil.filter(records, oldMap)
      .anyChanged(CUSTOMER_FIELDS)
      .toList();

    Set<id> setOfAccountIds = ListUtil.getIds(listOfSobjects, Account.Id);
    if (setOfAccountIds.isEmpty()) {
      return;
    }
    CustomerRelationNotesTriggerActions.updateCustomerNameOnCustomerRelationship(
      setOfAccountIds
    );
  }
}

/**
 * @author Emmanuel Yap
 * @since  05/2022
 * @group CCRM (Commercial CRM)
 * @description CCRMAccountActions is class to handle all the CCRM Account Actions
 * @runTests CCRMAccountActionsTest
 */
public with sharing class CCRMAccountActions {
  private static final List<AccountFieldValidation> ACCOUNT_FIELD_VALIDATION_WRAPPER = new List<AccountFieldValidation>{
    new AccountFieldValidation(
      'Name',
      System.Label.CCRM_NameLengthCheck,
      40,
      false,
      new Set<String>{
        String.valueOf(CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID),
        String.valueOf(CCRMConstants.ACCOUNT_PERSON_RT_ID)
      }
    ),
    new AccountFieldValidation(
      'FinServ__CustomerType__c',
      System.Label.CCRM_CustomerTypeLengthCheck,
      2,
      false,
      new Set<String>{
        String.valueOf(CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID),
        String.valueOf(CCRMConstants.ACCOUNT_PERSON_RT_ID)
      }
    ),
    new AccountFieldValidation(
      'BillingCity',
      System.Label.CCRM_CityLengthCheck,
      15,
      false,
      new Set<String>{
        String.valueOf(CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID),
        String.valueOf(CCRMConstants.ACCOUNT_PERSON_RT_ID)
      }
    ),
    new AccountFieldValidation(
      'BillingState',
      System.Label.CCRM_StateLengthCheck,
      15,
      false,
      new Set<String>{
        String.valueOf(CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID)
      }
    ),
    new AccountFieldValidation(
      'BillingPostalCode',
      System.Label.CCRM_PostalCodeLengthCheck,
      9,
      false,
      new Set<String>{
        String.valueOf(CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID),
        String.valueOf(CCRMConstants.ACCOUNT_PERSON_RT_ID)
      }
    ),
    new AccountFieldValidation(
      'Sic',
      System.Label.CCRM_SicCodeLengthCheck,
      4,
      false,
      new Set<String>{
        String.valueOf(CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID),
        String.valueOf(CCRMConstants.ACCOUNT_PERSON_RT_ID)
      }
    ),
    new AccountFieldValidation(
      'ABN__c',
      System.Label.CCRM_ABNLengthCheck,
      11,
      true,
      new Set<String>{
        String.valueOf(CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID),
        String.valueOf(CCRMConstants.ACCOUNT_PERSON_RT_ID)
      }
    ),
    new AccountFieldValidation(
      'BillingCountry',
      System.Label.CCRM_CountryCodeLengthCheck,
      3,
      true,
      new Set<String>{
        String.valueOf(CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID),
        String.valueOf(CCRMConstants.ACCOUNT_PERSON_RT_ID)
      }
    )
  };
  /**
   * @description This method will update Controlling Post field depending on the CPID provided in Account.
   * @name setControllingPost
   * @param records from the trigger
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in afterUpdate.
   */
  public static void setControllingPost(
    List<Account> records,
    Map<Id, Account> oldMap
  ) {
    Map<String, List<Account>> mappedAccounts = mapAccountsToCPID(
      records,
      oldMap
    );

    Set<String> cpids = mappedAccounts.keySet();

    if (cpids.isEmpty()) {
      return;
    }

    try {
      List<Controlling_Post__c> cps = [
        SELECT Id, CPID__c
        FROM Controlling_Post__c
        WHERE CPID__c != NULL AND CPID__c IN :cpids
        WITH SECURITY_ENFORCED
      ];

      for (Controlling_Post__c cp : cps) {
        List<Account> accounts = mappedAccounts.get(cp.CPID__c);
        for (Account account : accounts) {
          account.Controlling_Post__c = cp.id;
        }
      }
    } catch (System.QueryException qe) {
      Logger.error('InsufficientAccessException', qe);
      Logger.saveLog();
    }
  }

  /**
   * @description Returns a map of Accounts with CPID as key
   * @name mapAccountsToCPID
   * @param records from the trigger
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in afterUpdate.
   * @return `Map<String, List<Account>>` Return map of Accounts with CPID as key
   */
  public static Map<String, List<Account>> mapAccountsToCPID(
    List<Account> records,
    Map<Id, Account> oldMap
  ) {
    Map<String, List<Account>> mappedAccounts = new Map<String, List<Account>>();
    for (Account record : records) {
      Account oldRec = oldMap != null ? oldMap.get(record.id) : null;
      if (oldMap == null || isCPIDChanged(record, oldRec)) {
        if (record.CPID__c == null) {
          record.Controlling_Post__c = null;
          continue;
        }
        if (mappedAccounts.containsKey(record.CPID__c)) {
          mappedAccounts.get(record.CPID__c).add(record);
        } else {
          mappedAccounts.put(record.CPID__c, new List<Account>{ record });
        }
      }
    }
    return mappedAccounts;
  }

  /**
   * @description Returns true if this Account record CPID was changed, returns false otherwise
   * @name isCPIDChanged
   * @param record Account record
   * @param oldRec old Account record from trigger
   * @return `Boolean` True if the CPID is updated otherwise false.
   */
  private static Boolean isCPIDChanged(Account record, Account oldRec) {
    return (oldRec != null && record.CPID__c != oldRec.CPID__c);
  }

  /**
   * @description revertAccountChanges revert any changes on the account that are not from OCV Integration User
   * @name revertAccountChanges
   * @param records The Account records passed from Trigger.new()
   * @param oldMap old trigger values
   */
  public static void revertAccountChanges(
    List<Account> records,
    Map<Id, SObject> oldMap
  ) {
    for (Account rec : records) {
      if (!rec.Is_Prospect__c && !isExistingCustomer(rec)) {
        Account oldRec = (Account) oldMap.get(rec.Id);
        AccountCommonActionsHelper.revertAccountFieldChanges(rec, oldRec);
      }
    }
  }

  /**
   * @description findMatchingLeads finds the leads that have matching details with the newly created account
   * @param newRecs The account records from Trigger.new()
   * @return Map<Id, List<Lead>> A map fo leads to be converted and their corresponding account Ids
   */
  public static Map<Id, List<Lead>> findMatchingLeads(List<Account> newRecs) {
    Map<String, Account> accountByCapcisIdMap = new Map<String, Account>();
    Map<Id, List<Lead>> matchingLeadsByAccIdMap = new Map<Id, List<Lead>>();
    Set<Id> leadIds = new Set<Id>();
    for (Account acc : newRecs) {
      if (isValidCCRMAccount(acc)) {
        accountByCapcisIdMap.put(acc.Source_System_ID__c, acc);
      }
    }
    AccountCommonActionsHelper.LeadRetriever lr = new AccountCommonActionsHelper.LeadRetriever();
    List<Lead> bohLeadsList = new List<Lead>();
    for (
      Lead l : lr.getPotentialMatchingCCRMLeads(accountByCapcisIdMap.keySet())
    ) {
      AccountCommonActionsHelper.putLeadsInMapByAccId(
        l,
        matchingLeadsByAccIdMap,
        bohLeadsList,
        accountByCapcisIdMap.get(l.CAPCIS_ID__c)
      );
      leadIds.add(l.Id);
    }
    if (!leadIds.isEmpty()) {
      CCRMLeadPlatformEventHelper.leadTask = getRelatedTasks(leadIds);
    }

    if (!bohLeadsList.isEmpty() && Schema.sObjectType.Lead.isUpdateable()) {
      Database.update(bohLeadsList);
    }

    return matchingLeadsByAccIdMap;
  }

  /**
   * @description getRelatedTasks get related tasks associated with leads before lead conversion
   * @param leadIds set of related leadids
   * @return List<Task> list of task records associated with leads
   */
  private static List<Task> getRelatedTasks(Set<Id> leadIds) {
    List<Task> taskList = [
      SELECT Response_Type__r.Unica_Lead_SubStatus__c, WhoId, CreatedDate
      FROM Task
      WHERE WhoId = :leadIds
      WITH SECURITY_ENFORCED
      ORDER BY CreatedDate DESC
    ];
    return taskList;
  }

  /**
   * @description Check if the account record is eligible for finding and converting CCRM leads
   * @name isValidCCRMAccount
   * @param record The record from account trigger
   * @return `Boolean` True if the the record source is CAP and not a person account
   */
  private static Boolean isValidCCRMAccount(Account record) {
    return (record.Source_System_Name__c ==
    System.Label.CCRM_Source_System_Name &&
    String.isNotBlank(record.Source_System_ID__c) &&
    !record.IsPersonAccount);
  }

  /**
   * @description This method returns map of account with source system id
   * @name getMapOfSourceSystemIdsByRelatedParties
   * @param leadList List of leads
   * @return Map<Id, Account> Map of account
   */
  public static Map<Id, Account> getMapOfSourceSystemIdsByRelatedParties(
    List<Lead> leadList
  ) {
    Set<Id> accountIds = new Set<Id>();
    for (Lead record : leadList) {
      accountIds.add(record.FinServ__RelatedAccount__c);
    }
    Map<Id, Account> mapOfSourceSystemIds = new Map<Id, Account>(
      [
        SELECT
          Id,
          Source_System_ID__c,
          Source_System_Name__c,
          Name,
          RecordTypeId
        FROM Account
        WHERE
          Source_System_Name__c = :System.Label.CCRM_Source_System_Name
          AND Id IN :accountIds
      ]
    );
    return mapOfSourceSystemIds;
  }

  /**
   * @description Validate and format ABN/ACN/ARBN of prospect customers
   * @name validateAndFormatProspectAbnAcnArbn
   * @param records from the trigger
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in afterUpdate.
   */
  public static void validateAndFormatProspectAbnAcnArbn(
    List<Account> records,
    Map<Id, Account> oldMap
  ) {
    for (Account record : records) {
      Account oldRecord = oldMap?.get(record.Id);
      if (
        !String.isBlank(record.ABN__c) && record.ABN__c != oldRecord?.ABN__c
      ) {
        AbnAcnUtil.validateAndFormatRecordABN(record, 'ABN__c');
      }
      if (
        !String.isBlank(record.ACN__c) && record.ACN__c != oldRecord?.ACN__c
      ) {
        AbnAcnUtil.validateAndFormatRecordACN(record, 'ACN__c');
      }
      if (
        !String.isBlank(record.ARBN__c) && record.ARBN__c != oldRecord?.ARBN__c
      ) {
        AbnAcnUtil.validateAndFormatRecordARBN(record, 'ARBN__c');
      }
    }
  }

  /**
   * @description CC-5050 to restrict or prevent editing of shell prospect
   * @name preventEditShellProspect
   * @param records The Account records passed from Trigger.new()
   * @param oldMap old trigger values
   */
  public static void preventEditShellProspect(
    List<Account> records,
    Map<Id, Account> oldMap
  ) {
    String currUsername = UserInfo.getUserName();
    // bypassed if current user is OCV Integration or this is in context of lead conversion, or is a system admin
    if (
      currUsername.startsWith(Label.CCRM_OCVIntegrationUsername) ||
      CCRMLeadConversionActions.manualLeadConversionInitiated ||
      UserInfo.getProfileId() ==
      CommonUtil.getProfileByName(MLCRMConstants.ADMIN_PROFILE_NAME).Id
    ) {
      return;
    }
    for (Account rec : records) {
      if (isShellAccount(rec)) {
        rec.addError(Label.ML_ShellProspect_Update_ErrorMessage);
      } else if (
        rec.isPersonAccount && rec.OCV_ID__c != oldMap.get(rec.id)?.OCV_ID__c
      ) {
        rec.addError(Label.ML_OCV_ID_Update_ErrorMessage);
      }
    }
  }

  /**
   * @description isExistingCustomer to check if the Account is an active/inactive account or not
   * @param accRec accountRec
   * @return Boolean True if the Account is an active/inactive account otherwise false.
   */
  public static Boolean isExistingCustomer(Account accRec) {
    return ((accRec.RecordTypeId ==
    CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID ||
    accRec.isPersonAccount) &&
    (accRec.FinServ__Status__c == CCRMConstants.ACTIVE_STATUS ||
    accRec.FinServ__Status__c == CCRMConstants.INACTIVE_STATUS) &&
    accRec.Source_System_Name__c == Label.CCRM_Source_System_Name &&
    accRec.ANZx_Customer__c == false);
  }

  /**
   * @description fetchAccounts fetch List of accounts
   * @param accIds Ids of Account
   * @return List<Account> return List of Accounts
   */
  public static List<Account> fetchAccounts(Set<Id> accIds) {
    return [
      SELECT
        Id,
        Is_Prospect__c,
        isPersonAccount,
        RecordTypeId,
        FinServ__Status__c,
        Source_System_Name__c,
        ANZx_Customer__c
      FROM Account
      WHERE Id IN :accIds
    ];
  }

  /**
   * @description fetchAccounts fetch List of accounts
   * @param recordList List of account records,
   * @param oldMap map of old accounts
   */
  public static void validateCustomerInformation(
    List<Account> recordList,
    Map<Id, Account> oldMap
  ) {
    String newFieldValue = '';
    String oldFieldValue = '';

    //iterate over modified customer records
    for (Account iterator : recordList) {
      //iterate of field list for validation
      for (
        AccountFieldValidation accFieldValidationIterator : ACCOUNT_FIELD_VALIDATION_WRAPPER
      ) {
        //skip to next record if not a valid record type
        if (
          !accFieldValidationIterator.customerRecordTypeSet.contains(
            iterator.RecordTypeId
          )
        ) {
          continue;
        }
        //get updated field value and trim extra spaces if required to check length
        newFieldValue = String.isNotBlank(newFieldValue)
          ? accFieldValidationIterator.trimSpaces
              ? (String.valueOf(
                    iterator.get(accFieldValidationIterator.fieldName)
                  ))
                  .replace(' ', '')
              : String.valueOf(
                  iterator.get(accFieldValidationIterator.fieldName)
                )
          : '';
        //get old field value
        oldFieldValue = oldMap != null
          ? String.valueOf(
              oldMap.get(iterator.Id).get(accFieldValidationIterator.fieldName)
            )
          : '';
        //check if length is greater than specified field length
        //and add error
        if (
          (String.isBlank(oldFieldValue) || newFieldValue != oldFieldValue) &&
          newFieldValue.length() > accFieldValidationIterator.fieldLength
        ) {
          iterator.addError(accFieldValidationIterator.validationMessage);
        }
      }
    }
  }

  /**
   * @author Ankita
   * @since  09/2023
   * @group CCRM (Commercial CRM)
   * @description AccountFieldValidation wrapper class to maintain field validation for Account
   * @name AccountFieldValidation
   */
  private class AccountFieldValidation {
    String fieldName;
    String validationMessage;
    Integer fieldLength;
    Boolean trimSpaces;
    Set<String> customerRecordTypeSet;

    /**
     * @description AccountFieldValidation wrapper class to maintain field validation for Account
     * @param fieldName Field Name
     * @param validationMessage Field validation message
     * @param fieldLength Field length
     * @param trimSpaces Replace value
     * @param customerRecordTypeSet list of allowed record types
     */
    private AccountFieldValidation(
      String fieldName,
      String validationMessage,
      Integer fieldLength,
      Boolean trimSpaces,
      Set<String> customerRecordTypeSet
    ) {
      this.fieldName = fieldName;
      this.fieldLength = fieldLength;
      this.validationMessage = validationMessage;
      this.trimSpaces = trimSpaces;
      this.customerRecordTypeSet = new Set<String>(customerRecordTypeSet);
    }
  }

  /**
   * @author Naman Garg
   * @since  09/2023
   * @group CCRM (Commercial CRM)
   * @description AccountWrapper wrapper class to hold Existing and Prospect Account
   * @name AccountWrapper
   */
  public class AccountWrapper {
    public Map<Id, Account> prospectAccounts = new Map<Id, Account>();
    public Map<Id, Account> existingAccounts = new Map<Id, Account>();

    /**
     * @description AccountWrapper constructor to check if the Account is an active/inactive or Prospect account
     * @param accList List of Account
     */
    public AccountWrapper(List<Account> accList) {
      for (Account acc : accList) {
        if (acc.Is_Prospect__c) {
          prospectAccounts.put(acc.Id, acc);
        } else if (isExistingCustomer(acc)) {
          existingAccounts.put(acc.Id, acc);
        }
      }
    }
  }

  /**
   * @description isShellAccount to check if the Account is shell Prospect account or not
   * @param accountRecord Account Record
   * @return Boolean True if the Account is shell Prospect account otherwise false.
   */
  public static Boolean isShellAccount(Account accountRecord) {
    return (accountRecord.FinServ__Status__c == CCRMConstants.PROSPECT &&
    accountRecord.OCV_Event_Version__c == 0);
  }
}

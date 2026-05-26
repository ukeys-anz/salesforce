/**
 * @author       : Mildeep Singh
 * @since        : Aug 2025
 * @description  : This is the action class for CommercialNeedsAnalysisTriggerHandler
 **/
public with sharing class CommercialNeedsAnalysisActions {
  private static final CommercialNeedsAnalysisRepository NEEDS_ANALYSIS_REPOSITORY = (CommercialNeedsAnalysisRepository) Lib_InstanceProvider.forType(
    CommercialNeedsAnalysisRepository.class
  );
  private static final CCRMInteractionActionsRepository IA_REPOSITORY = (CCRMInteractionActionsRepository) Lib_InstanceProvider.forType(
    CCRMInteractionActionsRepository.class
  );
  private static final String INVALID_CLG_SELECTION = 'Please select the correct CLG related to the Customer.';
  private static final String CLG_REMOVAL_NOT_ALLOWED = 'You cannot remove the CLG record from this record as it is the only valid option.';
  @testVisible
  private static final String SELECT_ANY_CLG_ERROR = 'Please select a related CLG';
  @testVisible
  private static final String NO_CLG_FOR_CUSTOMER_ERROR = 'No CLG available for this customer, please leave CLG blank';
  @testVisible
  private static final String SELECT_RELATED_CLG_ERROR = 'Customer is not related to this CLG, please select the correct CLG';

  /**
   * @description : It is used to attach Customer and CLG to NeedsAnalysis record
   * @name : populateCustomerFromOpportunity
   * @param records List of Needs_Analysis__c records
   */
  public static void populateCustomerFromOpportunity(
    List<Needs_Analysis__c> records
  ) {
    // Get List of Needs_Analysis__c records with Opportunity tagged
    List<Needs_Analysis__c> naRecordWithOpp = ListUtil.filter(records)
      .isNotNull(Needs_Analysis__c.Opportunity__c)
      .toList();

    // Early Exit if Needs_Analysis__c records have no Opportunity is tagged
    if (naRecordWithOpp.size() == 0) {
      return;
    }

    // Get Ids of Opportunity tagged to Needs_Analysis__c record
    Set<Id> oppIdsFromNArecords = ListUtil.getIds(
      naRecordWithOpp,
      Needs_Analysis__c.Opportunity__c
    );

    // Get Ids of Customers from Opportunity
    List<Opportunity> oppRecordWithCustomer = NEEDS_ANALYSIS_REPOSITORY.getCustomerRecordUsingOpportunity(
      oppIdsFromNArecords
    );

    // Create Map of OppId to Opportunity
    Map<Id, Opportunity> oppToCustomer = new Map<Id, Opportunity>(
      oppRecordWithCustomer
    );

    // Set Customer Field on Needs Analysis record using Opportunity Map
    setCustomerIdToNeedsAnalysis(records, oppToCustomer);
  }

  /**
   * @description : It is used to attach Opportunity to NeedsAnalysis record
   * @name : setCustomerIdToNeedsAnalysis
   * @param records List of Needs_Analysis__c records
   * @param oppToCustomer Map of Opp Id to customer Id
   */
  @TestVisible
  private static void setCustomerIdToNeedsAnalysis(
    List<Needs_Analysis__c> records,
    Map<Id, Opportunity> oppToCustomer
  ) {
    // Set Customer field on Needs Analysis using AccountId from Opportunity
    for (Needs_Analysis__c eachNa : records) {
      eachNa.Customer__c = oppToCustomer.get(eachNa.Opportunity__c).AccountId;
      eachNa.CLGCustomer__c = oppToCustomer.get(eachNa.Opportunity__c).CLG__c;
    }
  }

  /**
   * @description : It will restrict the user to upload images in rich text fields
   * @name : restrictImagesInRichTextFields
   * @param records List of needs analysis records
   * @param oldMap Map of old needs analysis records
   */
  public static void restrictImagesInRichTextFields(
    List<Needs_Analysis__c> records,
    Map<Id, Needs_Analysis__c> oldMap
  ) {
    List<SObjectField> fieldList = Schema.SObjectType.Needs_Analysis__c.fields.getMap()
      .values();
    Set<SObjectField> richTextFieldSet = CommercialCommonUtil.getRichTextFields(
      fieldList
    );
    CommercialCommonUtil.restrictImages(records, oldMap, richTextFieldSet);
  }

  /**
   * @description handle CLG validation on Update of CLG .
   * @param records The list of List<Needs_Analysis__c>
   * @param oldMap The map of old Needs_Analysis__c records
   */
  public static void validateOnCLGChange(
    List<Needs_Analysis__c> records,
    Map<Id, Needs_Analysis__c> oldMap
  ) {
    List<Needs_Analysis__c> filteredNeedsAnalysisList = ListUtil.filter(
        records,
        oldMap
      )
      .changed(Needs_Analysis__c.CLGCustomer__c)
      .toList();

    Set<Id> accountIds = ListUtil.getIds(
      filteredNeedsAnalysisList,
      Needs_Analysis__c.Customer__c
    );

    List<FinServ__AccountAccountRelation__c> relatedCLGAccounts = IA_REPOSITORY.getRelatedCLGAccounts(
      accountIds
    );

    Map<Id, Set<Id>> customerToCLGsMap = CommercialInteractionActionsHelper.mapCustomerToCLGAccounts(
      relatedCLGAccounts
    );

    validateCLGAccountsAgainstCustomer(
      filteredNeedsAnalysisList,
      customerToCLGsMap
    );
  }

  /**
   * @description Validate CLG account selection against customer.
   * Implements all 3 validation scenarios:
   *   1. CLG blank when related CLGs exist
   *   2. CLG filled when no CLGs exist for customer
   *   3. CLG filled but unrelated to customer
   * @param records The list of NeedsAnalysis records
   * @param customerToCLGsMap The map of customer to CLG accounts
   */
  @TestVisible
  private static void validateCLGAccountsAgainstCustomer(
    List<Needs_Analysis__c> records,
    Map<Id, Set<Id>> customerToCLGsMap
  ) {
    for (Needs_Analysis__c record : records) {
      // Get valid CLG IDs for this customer (default to empty set if null)
      Set<Id> validCLGs = customerToCLGsMap.get(record.Customer__c) ??
        new Set<Id>();

      // SCENARIO 1: CLG is NULL but related CLGs exist
      if (record.CLGCustomer__c == null && !validCLGs.isEmpty()) {
        record.addError(SELECT_ANY_CLG_ERROR);
        continue;
      }

      // SCENARIO 2: CLG is filled but NO CLGs exist for this customer
      if (record.CLGCustomer__c != null && validCLGs.isEmpty()) {
        record.addError(NO_CLG_FOR_CUSTOMER_ERROR);
        continue;
      }

      // SCENARIO 3: CLG is filled but NOT related to customer
      if (
        record.CLGCustomer__c != null &&
        !validCLGs.contains(record.CLGCustomer__c)
      ) {
        record.addError(SELECT_RELATED_CLG_ERROR);
        continue;
      }
    }
  }
}

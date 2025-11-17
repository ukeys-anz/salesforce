/**
 * @author       : Mildeep Singh
 * @since        : Aug 2025
 * @description  : This is the action class for CommercialNeedsAnalysisTriggerHandler
 **/
public with sharing class CommercialNeedsAnalysisActions {
  private static final CommercialNeedsAnalysisRepository NEEDS_ANALYSIS_REPOSITORY = (CommercialNeedsAnalysisRepository) Lib_InstanceProvider.forType(
    CommercialNeedsAnalysisRepository.class
  );

  /**
   * @description : It is used to attach Opportunity to NeedsAnalysis record
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
}

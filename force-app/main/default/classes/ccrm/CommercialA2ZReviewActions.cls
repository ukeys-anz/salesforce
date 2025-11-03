/**
 * @author       : Advait Yermalkar
 * @since        : 05/2024
 * @description  :
 **/
public with sharing class CommercialA2ZReviewActions {
  public static final String STATUS_COMPLETED = 'Completed';

  private static final CommercialA2ZReviewRepository A2ZREVIEW_REPO = (CommercialA2ZReviewRepository) Lib_InstanceProvider.forType(
    CommercialA2ZReviewRepository.class
  );

  private static final LeadActionsRepository LEAD_ACTION_REPOSITORY = (LeadActionsRepository) Lib_InstanceProvider.forType(
    LeadActionsRepository.class
  );
  /**
   * @description This method will update Customer lookup when the A-Z review gets created from Opportunity/Lead having customer linked to it.
   * @name setCustomerOnA2ZReview
   * @param records from the trigger
   */
  public static void setCustomerOnA2ZReview(List<A_Z_Review__c> records) {
    try {
      List<A_Z_Review__c> reviewsWithLeads = ListUtil.filter(records)
        .isNotNull(A_Z_Review__c.Lead__c)
        .toList();

      List<A_Z_Review__c> reviewsWithOpportunities = ListUtil.filter(records)
        .isNotNull(A_Z_Review__c.Opportunity__c)
        .toList();

      Set<Id> leadsId = ListUtil.getIds(records, A_Z_Review__c.Lead__c);
      Set<Id> oppsIds = ListUtil.getIds(records, A_Z_Review__c.Opportunity__c);

      Map<Id, Lead> leadList = new Map<Id, Lead>(
        A2ZREVIEW_REPO.getLeads(leadsId)
      );
      Map<Id, Opportunity> oppsList = new Map<Id, Opportunity>(
        A2ZREVIEW_REPO.getOpportunities(oppsIds)
      );
      CommercialA2ZReviewActionHelper.assignCustomersFromLeads(
        reviewsWithLeads,
        leadList
      );
      CommercialA2ZReviewActionHelper.assignCustomersFromOpportunities(
        reviewsWithOpportunities,
        oppsList
      );
    } catch (Exception e) {
      Logger.error(
          'Errored out while setting Customer on A2Z Review from Opportunity/Lead',
          e
        )
        .save();
      throw e;
    }
  }

  /**
   * @description This method will update Customer lookup when the A-Z review gets created from Opportunity having customer linked to it.
   * @name performRedaction
   * @param records from the trigger
   */
  public static void performRedaction(List<A_Z_Review__c> records) {
    TextUtils.maskSObjectDataANZExtended(records, 'Name');
    TextUtils.maskSObjectDataANZExtended(records, 'Business_Details__c');
    TextUtils.maskSObjectDataANZExtended(records, 'Personal_Banking__c');
    TextUtils.maskSObjectDataANZExtended(records, 'Transaction_Banking__c');
    TextUtils.maskSObjectDataANZExtended(
      records,
      'Borrowing_OFI_Relationship__c'
    );
  }

  /**
   * @description : It will update the completed date as soon as status changes to 'Completed'.
   * @name : updateCompletedDate
   * @param records List of A-Z records
   * @param oldMap Map of old A-Z records
   */

  public static void updateCompletedDate(
    List<A_Z_Review__c> records,
    Map<Id, A_Z_Review__c> oldMap
  ) {
    List<A_Z_Review__c> azRecordList = ListUtil.filter(records, oldMap)
      .changedTo(A_Z_Review__c.Status__c, STATUS_COMPLETED)
      .toList();

    ListUtil.setField(
      azRecordList,
      A_Z_Review__c.Completed_Date__c,
      Date.today()
    );
  }

  /**
   * @description : It will restrict the user to upload images in rich text fields
   * @name : restrictImagesInRichTextFields
   * @param records List of A-Z records
   * @param oldMap Map of old A-Z records
   */
  public static void restrictImagesInRichTextFields(
    List<A_Z_Review__c> records,
    Map<Id, A_Z_Review__c> oldMap
  ) {
    List<SObjectField> fieldList = Schema.SObjectType.A_Z_Review__c.fields.getMap()
      .values();
    Set<SObjectField> richTextFieldSet = CommercialCommonUtil.getRichTextFields(
      fieldList
    );
    CommercialCommonUtil.restrictImages(records, oldMap, richTextFieldSet);
  }

  /**
   * @description : sets business owner field to blank if populated
   * @name : setBusinessOwnerToBlank
   * @param records List of A-Z records
   * @param oldMap Map of old A-Z records
   */
  public static void setBusinessOwnerToBlank(
    List<A_Z_Review__c> records,
    Map<Id, A_Z_Review__c> oldMap
  ) {
    List<A_Z_Review__c> filteredRecords = ListUtil.filter(records, oldMap)
      .isNotNull(A_Z_Review__c.Business_Owner__c)
      .changedTo(A_Z_Review__c.Existing_Business_Owner__c, 'No')
      .toList();
    ListUtil.setField(filteredRecords, A_Z_Review__c.Business_Owner__c, null);
  }

  /**
   * @description : sets business contact field to blank if populated
   * @name : setBusinessContactToBlank
   * @param records List of A-Z records
   * @param oldMap Map of old A-Z records
   */
  public static void setBusinessContactToBlank(
    List<A_Z_Review__c> records,
    Map<Id, A_Z_Review__c> oldMap
  ) {
    List<A_Z_Review__c> filteredRecords = ListUtil.filter(records, oldMap)
      .isNotNull(A_Z_Review__c.Business_Contact__c)
      .changedTo(A_Z_Review__c.Existing_Business_Owner__c, 'Yes')
      .toList();
    ListUtil.setField(filteredRecords, A_Z_Review__c.Business_Contact__c, null);
  }

  /**
   * @description : sets business owner field to individual customer
   * @name : populateBusinessOwner
   * @param records List of A-Z records
   * @param oldMap Map of old A-Z records
   */
  public static void populateBusinessOwner(
    List<A_Z_Review__c> records,
    Map<Id, A_Z_Review__c> oldMap
  ) {
    List<A_Z_Review__c> filteredRecords = ListUtil.filter(records, oldMap)
      .changed(A_Z_Review__c.Business_Owner__c)
      .toList();
    Set<Id> accountIds = ListUtil.getIds(
      filteredRecords,
      A_Z_Review__c.Customer__c
    );
    List<A_Z_Review__c> reviewsWithIndividualCustomers = A2ZREVIEW_REPO.getA2ZRecordsAssociatedWithIndividualCustomers(
      accountIds
    );
    Set<Id> individualAccountIds = ListUtil.getIds(
      reviewsWithIndividualCustomers,
      A_Z_Review__c.Customer__c
    );
    CommercialA2ZReviewActionHelper.setBusinessOwner(
      filteredRecords,
      individualAccountIds
    );
  }

  /**
   * @description : This is used to validate the account and CLG Info
   * @name : validateAndPopulateCLGInfo
   * @param records list of A_Z_Review__c
   * @param oldMap map of Id to A_Z_Review__c record beforeChange
   */
  public static void validateAndPopulateCLGInfo(
    List<A_Z_Review__c> records,
    Map<Id, A_Z_Review__c> oldMap
  ) {
    List<A_Z_Review__c> filteredA2ZList = ListUtil.filter(records)
      .isNotNull(A_Z_Review__c.Customer__c)
      .toList();

    // Early Exit
    if (filteredA2ZList.isEmpty()) {
      return;
    }
    if (oldMap != null) {
      filteredA2ZList = ListUtil.filter(filteredA2ZList)
        .changed(A_Z_Review__c.Customer__c)
        .toList();
    }

    Set<Id> accountIdSet = ListUtil.getIds(
      filteredA2ZList,
      A_Z_Review__c.Customer__c
    );

    Set<Id> clgIdSet = ListUtil.getIds(
      filteredA2ZList,
      A_Z_Review__c.CLGCustomer__c
    );

    Set<Id> combinedAccountIdsSet = new Set<Id>(accountIdSet);
    combinedAccountIdsSet.addAll(clgIdSet);

    Map<Id, Account> accMap = new Map<Id, Account>(
      LEAD_ACTION_REPOSITORY.getAccountList(combinedAccountIdsSet)
    );

    List<Account> clgAccountList = ListUtil.filter(accMap.values())
      .equals(Account.RecordTypeId, RTAccount.clgAccount)
      .toList();

    List<FinServ__AccountAccountRelation__c> aarList = LEAD_ACTION_REPOSITORY.getAccountAccountRelations(
      accountIdSet
    );

    Map<Id, Set<Id>> accIdToClgIdsMap = CommercialLeadActionsHelper.formAccountIdToCLGIdsMap(
      aarList
    );

    CommercialLeadActionsHelper.addCLGAccountToMap(
      accIdToClgIdsMap,
      clgAccountList
    );
    CommercialA2ZReviewActionHelper.validateAndPopulateCLGInfo(
      filteredA2ZList,
      accMap,
      accIdToClgIdsMap
    );
  }

  /**
   * @description : This is used to populate the CLG Info on A_Z_Review__c based on Existing customer
   * @name : populateCLGInfo
   * @param records A_Z_Review__c list
   */
  public static void populateCLGInfo(List<A_Z_Review__c> records) {
    List<A_Z_Review__c> filteredA2ZReviewList = ListUtil.filter(records)
      .isNotNull(A_Z_Review__c.Customer__c)
      .toList();

    // Early Exit
    if (filteredA2ZReviewList.isEmpty()) {
      return;
    }

    Set<Id> accountIdSet = ListUtil.getIds(
      filteredA2ZReviewList,
      A_Z_Review__c.Customer__c
    );

    // Create map of Id to account using Customer Record from A2ZReview
    Map<Id, Account> accMap = new Map<Id, Account>(
      LEAD_ACTION_REPOSITORY.getAccountList(accountIdSet)
    );

    // Get Account Account relation (AAR) records from Customer/Account record
    List<FinServ__AccountAccountRelation__c> aarList = LEAD_ACTION_REPOSITORY.getAccountAccountRelations(
      accountIdSet
    );

    // Create Map of Account Ids to CLGIds using AAR Records
    Map<Id, Map<Id, FinServ__AccountAccountRelation__c>> accIdToClgIdAARMap = CommercialLeadActionsHelper.formAccountIdToCLGIdAARMap(
      aarList
    );

    CommercialA2ZReviewActionHelper.populateClgInfoOnA2ZReview(
      filteredA2ZReviewList,
      accMap,
      accIdToClgIdAARMap
    );
  }
}

/**
 * @author Boobalakrishnan Duraisamy
 * @since 04/2021
 * @description  Controller for IDRRestrictedCases lwc component
 */
public without sharing class IDRRestrictedCasesController {
  /**
   * @description getRestrictedCaseData is used to query the case restricted data based on the search key
   * @param searchKey entered by the user
   * @return List<IDRRestrictedCaseWrapper> to lwc component
   */
  @AuraEnabled
  public static List<IDRRestrictedCaseWrapper> getRestrictedCaseData(
    String searchKey
  ) {
    String key;
    Map<String, String> customerTypeMap = new Map<String, String>();
    List<IDRRestrictedCaseWrapper> restrictedDataList = new List<IDRRestrictedCaseWrapper>();
    List<Case> caseList = new List<Case>();

    Schema.DescribeFieldResult field = Case.IDR_Complainant_Type__c.getDescribe();
    for (Schema.PicklistEntry f : field.getPicklistValues()) {
      customerTypeMap.put(f.getValue(), f.getLabel());
    }

    if (String.isNotBlank(searchKey)) {
      key = '%' + searchKey + '%';
    }

    if (Case.sObjectType.getDescribe().isQueryable()) {
      caseList = [
        SELECT
          Id,
          CaseNumber,
          Status,
          IDR_Customer_Number__c,
          IDR_Complainant_Type__c,
          IDR_NC_First_Name__c,
          IDR_NC_Last_Name__c,
          Owner.Name
        FROM Case
        WHERE
          IDR_Restriction_Level__c = 'Restricted Case'
          AND (RecordTypeId = :IDRConstants.CUSTOMER_COMPLAINT_RT_ID
          OR RecordTypeId = :IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID
          OR RecordTypeId = :IDRConstants.CFMS_MIGRATED_CASE_RT_ID)
          AND (CaseNumber LIKE :key
          OR Status LIKE :key
          OR IDR_Customer_Number__c LIKE :key
          OR IDR_Complainant_Type__c LIKE :key
          OR IDR_NC_First_Name__c LIKE :key
          OR IDR_NC_Last_Name__c LIKE :key
          OR Owner.Name LIKE :key)
        ORDER BY LastModifiedDate DESC
        LIMIT 1000
      ];
    }

    for (Case c : caseList) {
      IDRRestrictedCaseWrapper wrapper = new IDRRestrictedCaseWrapper();
      wrapper.caseId = c.Id;
      wrapper.caseNumber = c.CaseNumber;
      wrapper.customerNumber = c.IDR_Customer_Number__c;
      if (customerTypeMap.containsKey(c.IDR_Complainant_Type__c)) {
        wrapper.customerType = customerTypeMap.get(c.IDR_Complainant_Type__c);
      }
      wrapper.firstName = c.IDR_NC_First_Name__c;
      wrapper.lastName = c.IDR_NC_Last_Name__c;
      wrapper.caseOwner = c.Owner.Name;
      wrapper.status = c.Status;
      restrictedDataList.add(wrapper);
    }
    return restrictedDataList;
  }

  /**
   * @description insertCaseComment for inserting case comment into selected case record
   * @param caseId from selected case
   * @param commentBody from lightning component
   */
  @AuraEnabled
  public static void insertCaseComment(Id caseId, String commentBody) {
    CaseComment cc = new CaseComment();
    cc.ParentId = caseId;
    cc.CommentBody = commentbody;
    if (
      CaseComment.sObjectType.getDescribe().isCreateable() &&
      Schema.sObjectType.CaseComment.fields.CommentBody.isCreateable() &&
      Schema.sObjectType.CaseComment.fields.ParentId.isCreateable()
    ) {
      insert cc;
    } else {
      CommonUtil.logAndThrowIAE(
        'IDRRestrictedCasesController',
        'insertCaseComment',
        'Not enough permissions to create CaseComment.'
      );
    }
  }

  /**
   * @description linkFileToCase is used to create a content document link record which will link the uploaded file with the case.
   * @param caseId caseID from selected case
   * @param contentDocIdList list of uploaded document Ids
   */
  @AuraEnabled
  public static void linkFileToCase(String caseId, List<Id> contentDocIdList) {
    List<ContentDocumentLink> cdLinkList = new List<ContentDocumentLink>();
    for (Id contentDocId : contentDocIdList) {
      ContentDocumentLink contentDocLink = new ContentDocumentLink();
      contentDocLink.ContentDocumentId = contentDocId;
      contentDocLink.LinkedEntityId = caseId;
      contentDocLink.ShareType = 'I';
      cdLinkList.add(contentDocLink);
    }
    if (
      ContentDocumentLink.sObjectType.getDescribe().isCreateable() &&
      Schema.sObjectType.ContentDocumentLink.fields.ContentDocumentId.isCreateable() &&
      Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isCreateable() &&
      Schema.sObjectType.ContentDocumentLink.fields.ShareType.isCreateable()
    ) {
      insert cdLinkList;
    } else {
      CommonUtil.logAndThrowIAE(
        'IDRRestrictedCasesController',
        'linkFileToCase',
        'Not enough permissions to create ContentDocumentLink.'
      );
    }
  }

  /**
   * @description Wrapper class to store restricted case data
   */
  public class IDRRestrictedCaseWrapper {
    @AuraEnabled
    public string caseId;
    @AuraEnabled
    public string caseNumber;
    @AuraEnabled
    public string customerNumber;
    @AuraEnabled
    public string customerType;
    @AuraEnabled
    public string firstName;
    @AuraEnabled
    public string lastName;
    @AuraEnabled
    public string caseOwner;
    @AuraEnabled
    public string status;
  }
}

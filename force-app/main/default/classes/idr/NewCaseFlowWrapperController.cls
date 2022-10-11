/**
 * @author saiero
 * @since 2020
 * @group IDR(Internal Dispute Resolution)
 * @description Controller for the lightning component wrapping the Case creation flow, currently only for Complaints.
 */
public with sharing class NewCaseFlowWrapperController {
  /**
   * @description Get the Developer Name of a Case record type based on its Id
   * @param id Record Type ID
   * @return The RT's Dev Name
   */
  @AuraEnabled
  public static String getCaseRecordTypeDevNameById(Id id) {
    return Schema.SObjectType.Case.getRecordTypeInfosById()
      .get(id)
      .getDeveloperName();
  }

  /**
   * @description Get the IDR_AFCA_Status__c of a Case record based on its Id
   * @param caseId the case record id
   * @param newRecordTypeId id of the new record type selected for the case
   * @return returnIDRAFCAStatus The IDR_AFCA_Status__c of the input case record
   */
  @AuraEnabled
  public static String getCaseDetailsById(Id caseId, String newRecordTypeId) {
    String newRecordTypeName = getCaseRecordTypeDevNameById(newRecordTypeId);
    Map<String, String> caseDetails = new Map<String, String>();
    caseDetails.put('IDR_AFCA_Status__c', '');
    if (
      Case.sObjectType.getDescribe().isQueryable() &&
      (newRecordTypeName == 'Non_Customer_Complaint' ||
      newRecordTypeName == 'Customer_Complaint')
    ) {
      List<Case> caseLst = [
        SELECT
          Id,
          IDR_AFCA_Status__c,
          Origin,
          IDR_Subsequent_Issue__c,
          IDR_Is_Written_Resp_Requested__c,
          IDR_Is_Written_Resp_Required__c,
          IDR_Is_Common__c,
          IDR_Escalation_Reason__c,
          IDR_Complainant_Type__c,
          RecordType.DeveloperName,
          RecordTypeId,
          IDR_Product_Category__c
        FROM case
        WHERE
          Id = :caseid
          AND RecordTypeId = :IDRConstants.GENERAL_INQUIRY_CMOS_RT_ID
        WITH SECURITY_ENFORCED
      ];

      //As we're querying by recordId, only 1 record should be present if the query isn't empty
      if (caseLst[0].Origin == '11') {
        caseDetails.put('IDR_AFCA_Status__c', '10');
      }
      caseDetails.put(
        'IDR_Product_Category__c',
        (caseLst[0].IDR_Product_Category__c != null)
          ? caseLst[0].IDR_Product_Category__c
          : ''
      );
      caseDetails.put(
        'IDR_Subsequent_Issue__c',
        (caseLst[0].IDR_Subsequent_Issue__c != null)
          ? caseLst[0].IDR_Subsequent_Issue__c
          : ''
      );
      caseDetails.put(
        'IDR_Is_Written_Resp_Requested__c',
        (caseLst[0].IDR_Is_Written_Resp_Requested__c != null)
          ? caseLst[0].IDR_Is_Written_Resp_Requested__c
          : ''
      );
      caseDetails.put(
        'IDR_Is_Written_Resp_Required__c',
        (caseLst[0].IDR_Is_Written_Resp_Required__c != null)
          ? caseLst[0].IDR_Is_Written_Resp_Required__c
          : ''
      );
      caseDetails.put(
        'IDR_Is_Common__c',
        (caseLst[0].IDR_Is_Common__c != null) ? caseLst[0].IDR_Is_Common__c : ''
      );
      caseDetails.put(
        'IDR_Escalation_Reason__c',
        (caseLst[0].IDR_Escalation_Reason__c != null)
          ? caseLst[0].IDR_Escalation_Reason__c
          : ''
      );
      caseDetails.put(
        'IDR_Complainant_Type__c',
        (caseLst[0].IDR_Complainant_Type__c != null)
          ? caseLst[0].IDR_Complainant_Type__c
          : ''
      );
    }
    return JSON.serialize(caseDetails);
  }

  /**
   * @description Query for Customer OCV ID by passing in the Account ID
   * @param accountID SF Account ID related to the Customer
   * @return String
   */
  private static String getOCVId(Id accountID) {
    if (Account.sObjectType.getDescribe().isQueryable()) {
      List<Account> accounts = [
        SELECT OCV_ID__c
        FROM Account
        WHERE Id = :accountID
      ];
      if (!accounts.isEmpty()) {
        return accounts[0].OCV_ID__c;
      }
    }
    return null;
  }

  /**
   * @description Get available record types for Case object
   * @return Serialized string of a list of record types
   */
  @AuraEnabled
  public static String getCaseRecordTypes() {
    List<String> recordTypesToExcl = new List<String>();
    for (Case_Record_Type_To_Exclude__mdt mdt : [
      SELECT DeveloperName
      FROM Case_Record_Type_To_Exclude__mdt
      LIMIT 10
    ]) {
      recordTypesToExcl.add(mdt.DeveloperName);
    }
    try {
      List<Id> caseRecordTypeIds = CommonUtil.getAvailableRecordTypeIdsForSObject(
        'Case'
      );
      if (
        caseRecordTypeIds.size() > 0 && Schema.SObjectType.Case.isAccessible()
      ) {
        List<RecordType> rtToDisplay = [
          SELECT Id, Name, Description, DeveloperName
          FROM RecordType
          WHERE
            SobjectType = 'Case'
            AND DeveloperName NOT IN :recordTypesToExcl
            AND Id IN :caseRecordTypeIds
        ];
        return JSON.serialize(rtToDisplay);
      }
      return null;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}

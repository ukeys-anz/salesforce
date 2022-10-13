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
   * @description get/set default values when the record type needs to be changed
   * @param caseId the case record id
   * @param newRecordTypeId id of the new record type selected for the case
   * @return a serialized String out of Map<String,String> of <fieldName, defaultValue>
   */
  @AuraEnabled
  public static String getCaseDetailsById(Id caseId, String newRecordTypeId) {
    Case caseRecord = new Case();
    if (Case.sObjectType.getDescribe().isQueryable()) {
      caseRecord = [
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
          IDR_Product_Category__c,
          RecordType.DeveloperName,
          RecordTypeId,
          Type,
          Priority,
          CaseNumber,
          IDR_Complainant_Desired_Outcome__c,
          Description,
          ANZx_Customer__c
        FROM Case
        WHERE Id = :caseId
        LIMIT 1
      ];
    }
    String newRecordTypeName = getCaseRecordTypeDevNameById(newRecordTypeId);
    Map<String, String> caseDetails = new Map<String, String>();

    if (
      caseRecord.RecordType.DeveloperName ==
      GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT &&
      caseRecord.Origin == GetHelpConstants.ANZ_PLUS_WEB_ORIGIN &&
      caseRecord.ANZx_Customer__c == true
    ) {
      return getCaseDetailsByCaseRecordAEM(caseRecord, newRecordTypeName);
    } else {
      return getCaseDetailsByCaseRecord(caseRecord, newRecordTypeName);
    }
  }

  /**
   * @description get/set default values when the record type needs to be changed | AEM
   * @param caseRecord the case record
   * @param newRecordTypeName the new chosen record type
   * @return a serialized String out of Map<String,String> of <fieldName, defaultValue>
   */

  public static String getCaseDetailsByCaseRecordAEM(
    Case caseRecord,
    String newRecordTypeName
  ) {
    Map<String, String> caseDetails = new Map<String, String>();
    if (newRecordTypeName == GetHelpConstants.GENERAL_INQUIRY_RT) {
      caseDetails.put('Type', '');
      caseDetails.put('Priority', '');
      caseDetails.put(
        'Description',
        'Web Submitted Enquiry\n\nIssue:\n  ' +
        PicklistUtil.getPicklistLabel('Case', 'Type', caseRecord.Type) +
        '\n\n' +
        caseRecord.Description +
        '\n\nCustomer Desired Outcome:\n  ' +
        caseRecord.IDR_Complainant_Desired_Outcome__c +
        '\n\nPriority:\n  ' +
        PicklistUtil.getPicklistLabel('Case', 'Priority', caseRecord.Priority)
      );
    } else if (
      (newRecordTypeName == GetHelpConstants.NON_CUSTOMER_COMPLAINT_RT ||
      newRecordTypeName == GetHelpConstants.COMPLAINT_RT) &&
      caseRecord.Type == PicklistUtil.getPicklistValue('Case', 'Type', 'Other')
    ) {
      caseDetails.put('Type', '');
      caseDetails.put(
        'Description',
        'Web Submitted Enquiry\n\nIssue:\n  Other\n\n' + caseRecord.Description
      );
    }

    if (newRecordTypeName == GetHelpConstants.COMPLAINT_RT) {
      caseDetails.put('Customer_Notification_Consent__c', 'Yes');
    }

    caseDetails.put(
      'IDR_Product_Category__c',
      (caseRecord.IDR_Product_Category__c != null)
        ? caseRecord.IDR_Product_Category__c
        : ''
    );
    return JSON.serialize(caseDetails);
  }

  /**
   * @description get/set default values when the record type needs to be changed | CMOS
   * @param caseRecord the case record
   * @param newRecordTypeName the new chosen record type
   * @return a serialized String out of Map<String,String> of <fieldName, defaultValue>
   */

  public static String getCaseDetailsByCaseRecord(
    Case caseRecord,
    String newRecordTypeName
  ) {
    Map<String, String> caseDetails = new Map<String, String>();
    caseDetails.put('IDR_AFCA_Status__c', '');
    if (
      (newRecordTypeName == GetHelpConstants.NON_CUSTOMER_COMPLAINT_RT ||
      newRecordTypeName == GetHelpConstants.CUSTOMER_COMPLAINT_RT)
    ) {
      //As we're querying by recordId, only 1 record should be present if the query isn't empty
      if (caseRecord.Origin == '11') {
        caseDetails.put('IDR_AFCA_Status__c', '10');
      }
      caseDetails.put(
        'IDR_Product_Category__c',
        (caseRecord.IDR_Product_Category__c != null)
          ? caseRecord.IDR_Product_Category__c
          : ''
      );
      caseDetails.put(
        'IDR_Subsequent_Issue__c',
        (caseRecord.IDR_Subsequent_Issue__c != null)
          ? caseRecord.IDR_Subsequent_Issue__c
          : ''
      );
      caseDetails.put(
        'IDR_Is_Written_Resp_Requested__c',
        (caseRecord.IDR_Is_Written_Resp_Requested__c != null)
          ? caseRecord.IDR_Is_Written_Resp_Requested__c
          : ''
      );
      caseDetails.put(
        'IDR_Is_Written_Resp_Required__c',
        (caseRecord.IDR_Is_Written_Resp_Required__c != null)
          ? caseRecord.IDR_Is_Written_Resp_Required__c
          : ''
      );
      caseDetails.put(
        'IDR_Is_Common__c',
        (caseRecord.IDR_Is_Common__c != null) ? caseRecord.IDR_Is_Common__c : ''
      );
      caseDetails.put(
        'IDR_Escalation_Reason__c',
        (caseRecord.IDR_Escalation_Reason__c != null)
          ? caseRecord.IDR_Escalation_Reason__c
          : ''
      );
      caseDetails.put(
        'IDR_Complainant_Type__c',
        (caseRecord.IDR_Complainant_Type__c != null)
          ? caseRecord.IDR_Complainant_Type__c
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
   * @description Get available record types for Case object | For change Record Type Button
   * @param caseId case Id
   * @return Serialized string of a list of record types
   */
  @AuraEnabled
  public static String getCaseRecordTypesChangeRTBtn(Id caseId) {
    Case caseRecord = new Case();
    if (Case.sObjectType.getDescribe().isQueryable()) {
      caseRecord = [
        SELECT
          Id,
          RecordType.DeveloperName,
          RecordTypeId,
          Origin,
          ANZx_Customer__c
        FROM Case
        WHERE Id = :caseId
        LIMIT 1
      ];
    }

    if (
      caseRecord.RecordTypeId !=
      GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID &&
      caseRecord.Origin != GetHelpConstants.ANZ_PLUS_WEB_ORIGIN &&
      caseRecord.ANZx_Customer__c != true
    ) {
      return getCaseRecordTypes();
    } else {
      return getCaseRecordTypesForAEM();
    }
  }

  /**
   * @description Get available record types for Case object | For AEM Unauthenticated Enquiry Change record type
   * @return Serialized string of a list of record types
   */

  public static String getCaseRecordTypesForAEM() {
    List<String> acceptedRecordTypeForAEMCases = new List<String>{
      GetHelpConstants.NON_CUSTOMER_COMPLAINT_RT,
      GetHelpConstants.GENERAL_INQUIRY_RT,
      GetHelpConstants.COMPLAINT_RT
    };

    try {
      List<Id> caseRecordTypeIds = CommonUtil.getAvailableRecordTypeIdsForSObject(
        'Case'
      );
      if (
        caseRecordTypeIds.size() > 0 && Schema.SObjectType.Case.isAccessible()
      ) {
        List<RecordType> rtToDisplay = new List<RecordType>();

        rtToDisplay = [
          SELECT Id, Name, Description, DeveloperName
          FROM RecordType
          WHERE
            SobjectType = 'Case'
            AND DeveloperName IN :acceptedRecordTypeForAEMCases
            AND Id IN :caseRecordTypeIds
        ];

        List<UserRole> roleList = [
          SELECT Id, Name, DeveloperName
          FROM UserRole
          WHERE Id = :UserInfo.getUserRoleId()
        ];
        return JSON.serialize(rtToDisplay);
      }
      return null;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description Get available record types for Case object | For New Button
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
        List<UserRole> roleList = [
          SELECT Id, Name, DeveloperName
          FROM UserRole
          WHERE Id = :UserInfo.getUserRoleId()
        ];
        return JSON.serialize(rtToDisplay);
      }
      return null;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}

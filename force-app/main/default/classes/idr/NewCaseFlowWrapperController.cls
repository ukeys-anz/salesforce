/**
 * @author saiero
 * @since 2020
 * @group IDR(Internal Dispute Resolution)
 * @description Controller for the lightning component wrapping the Case creation flow, currently only for Complaints.
 */
public with sharing class NewCaseFlowWrapperController {
  // Shell case conversion Change Record type Button
  public static Boolean isShellCaseCRTB = false;
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

    Map<String, String> caseDetails = new Map<String, String>();

    if (CheckCaseRecordType.isAEM(caseRecord)) {
      return getCaseDetailsByCaseRecordAEM(caseRecord, newRecordTypeId);
    } else {
      return getCaseDetailsByCaseRecord(caseRecord, newRecordTypeId);
    }
  }

  /**
   * @description get/set default values when the record type needs to be changed | AEM
   * @param caseRecord the case record
   * @param newRecordTypeId the new chosen record type Id
   * @return a serialized String out of Map<String,String> of <fieldName, defaultValue>
   */

  public static String getCaseDetailsByCaseRecordAEM(
    Case caseRecord,
    String newRecordTypeId
  ) {
    Map<String, String> caseDetails = new Map<String, String>();
    String cDescription = EncodingUtil.URLENCODE(
      caseRecord.Description,
      'UTF-8'
    );
    String cDesiredOutcome = EncodingUtil.URLENCODE(
      caseRecord.IDR_Complainant_Desired_Outcome__c,
      'UTF-8'
    );

    if (newRecordTypeId == GetHelpConstants.GENERAL_INQUIRY_RT_ID) {
      caseDetails.put('Type', '');
      caseDetails.put('Priority', '');
      caseDetails.put(
        'Description',
        'Web Submitted Enquiry\n\nIssue:\n  ' +
        CommonUtil.getSinglePicklistLabel(Case.Type, caseRecord.Type) +
        '\n\n' +
        cDescription +
        '\n\nCustomer Desired Outcome:\n  ' +
        cDesiredOutcome +
        '\n\nPriority:\n  ' +
        CommonUtil.getSinglePicklistLabel(Case.Priority, caseRecord.Priority)
      );
    } else if (
      (newRecordTypeId == GetHelpConstants.NON_CUSTOMER_COMPLAINT_RT_ID ||
      newRecordTypeId == GetHelpConstants.COMPLAINT_RT_ID) &&
      caseRecord.Type == CommonUtil.getSinglePicklistValue(Case.Type, 'Other')
    ) {
      caseDetails.put('Type', '');
      caseDetails.put(
        'Description',
        'Web Submitted Enquiry\n\nIssue:\n  Other\n\n' + cDescription
      );
    }

    if (newRecordTypeId == GetHelpConstants.COMPLAINT_RT_ID) {
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
   * @param newRecordTypeId the new chosen record type Id
   * @return a serialized String out of Map<String,String> of <fieldName, defaultValue>
   */

  public static String getCaseDetailsByCaseRecord(
    Case caseRecord,
    String newRecordTypeId
  ) {
    Map<String, String> caseDetails = new Map<String, String>();
    caseDetails.put('IDR_AFCA_Status__c', '');
    if (
      (newRecordTypeId == GetHelpConstants.NON_CUSTOMER_COMPLAINT_RT_ID ||
      newRecordTypeId == IDRConstants.CUSTOMER_COMPLAINT_RT_ID)
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

    if (CheckCaseRecordType.isAEM(caseRecord)) {
      return getCaseRecordTypesForAEM();
    } else {
      // On click of Shell case conversion Change Record type Button, seeting the variable to true
      isShellCaseCRTB = true;
      String value = getCaseRecordTypes();
      return value;
    }
  }

  /**
   * @description Get available record types for Case object | For AEM Unauthenticated Enquiry Change record type
   * @return Serialized string of a list of record types
   */

  public static String getCaseRecordTypesForAEM() {
    List<Id> acceptedRecordTypeForAEMCases = new List<Id>{
      GetHelpConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
      GetHelpConstants.GENERAL_INQUIRY_RT_ID,
      GetHelpConstants.COMPLAINT_RT_ID
    };

    try {
      if (Schema.SObjectType.Case.isAccessible()) {
        List<RecordType> rtToDisplay = [
          SELECT Id, Name, Description, DeveloperName
          FROM RecordType
          WHERE SobjectType = 'Case' AND Id IN :acceptedRecordTypeForAEMCases
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

    if (!IDRConstants.DISABLE_OMNI_FOR_CMOS && !isShellCaseCRTB) {
      recordTypesToExcl.add(IDRConstants.CUSTOMER_COMPLAINT_RT_NAME);
      recordTypesToExcl.add(IDRConstants.NON_CUSTOMER_COMPLAINT_RT_NAME);
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
        if (!IDRConstants.DISABLE_OMNI_FOR_CMOS && !isShellCaseCRTB) {
          //Fetching 'Customer-Complaint' recodtype Id
          RecordType newrt = new RecordType(
            Id = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
            Name = 'Complaint',
            DeveloperName = 'Complaint',
            Description = 'Record a new complaint for an existing ANZ or non ANZ customer '
          );
          rtToDisplay.add(newrt); //adding new record type picklist for specific Users
        }
        return JSON.serialize(rtToDisplay);
      }
      return null;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}

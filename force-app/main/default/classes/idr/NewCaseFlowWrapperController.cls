/**
 * @author saiero
 * @since 2020
 * @group IDR(Internal Dispute Resolution)
 * @description Controller for the lightning component wrapping the Case creation flow, currently only for Complaints.
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class NewCaseFlowWrapperController {
  public static final String SUPPORT_ARC_ROLE = 'Support_Staff_ARC';
  public static final String COMPLAINT_RT = 'ANZx_Complaint';
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
   * @param id : caseId , newRecordTypeName
   * @return The returnIDRAFCAStatus
   */
  @AuraEnabled
  public static String getCaseDetailsById(Id caseId, String newRecordTypeID) {
    String newRecordTypeName = getCaseRecordTypeDevNameById(newRecordTypeID);
    string returnIDRAFCAStatus = '';
    if (
      Case.sObjectType.getDescribe().isQueryable() &&
      (newRecordTypeName == 'Non_Customer_Complaint' ||
      newRecordTypeName == 'Customer_Complaint')
    ) {
      List<Case> caseLst = [
        SELECT
          ID,
          IDR_AFCA_Status__c,
          Origin,
          RecordType.DeveloperName,
          RecordTypeId
        FROM case
        WHERE
          Id = :caseid
          AND RecordTypeId = :IDRConstants.GENERAL_INQUIRY_CMOS_RT_ID
          AND (Origin = :'Referred from AFCA'
          OR Origin = :'11')
        WITH SECURITY_ENFORCED
      ];
      if (!caseLst.isEmpty()) {
        returnIDRAFCAStatus = '10';
      }
    }
    return returnIDRAFCAStatus;
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
  @SuppressWarnings(
    'PMD.ApexCRUDViolation'
  ) // Already check accessibility below but somehow PMD did not pick up
  @AuraEnabled
  public static String getCaseRecordTypes() {
    List<String> recordTypesToExcl = new List<String>();
    for (Case_Record_Type_To_Exclude__mdt mdt : [
      SELECT DeveloperName
      FROM Case_Record_Type_To_Exclude__mdt
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
        if (
          roleList.size() > 0 &&
          roleList[0].DeveloperName ==
          NewCaseFlowWrapperController.SUPPORT_ARC_ROLE
        ) {
          List<RecordType> filteredRt = new List<RecordType>();
          for (RecordType rt : rtToDisplay) {
            if (rt.DeveloperName == NewCaseFlowWrapperController.COMPLAINT_RT) {
              filteredRt.add(rt);
            }
          }
          rtToDisplay = filteredRt;
        }
        return JSON.serialize(rtToDisplay);
      }
      return null;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}

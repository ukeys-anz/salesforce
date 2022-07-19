/**
 *
 * @author Adnan
 * @since Dec 2021
 * @description Controller class for express CMOS lwc component
 */
public with sharing class IDRExpressComplaintController {
  /**
   * @description retrieves all active known issue records
   * Suppressed 'ApexCRUDViolation' as AccessCheckUtil covers the access check
   * @return List<Known_Issues__c> list of known issue records from query
   */
  @SuppressWarnings('PMD.ApexCRUDViolation')
  @AuraEnabled(cacheable=true)
  public static List<Known_Issues__c> getAllKnownIssues() {
    try {
      List<Known_Issues__c> knownIssuesList = [
        SELECT
          Id,
          Name,
          IDR_Issue_Type__c,
          Product__c,
          IDR_Sub_Issue_Type__c,
          IDR_Description_of_Issue__c,
          IDR_Customer_Desired_Outcome__c,
          IDR_Is_there_another_issue__c,
          IDR_Written_Response_Required__c,
          IDR_REAL_Form_Required__c,
          IDR_Possible_Systemic_Issue__c,
          IDR_Status__c,
          IDR_Complaint_Outcome__c,
          IDR_Description_of_Outcome__c,
          IDR_Complaint_Remedy__c,
          IDR_Non_Financial_Remedy__c,
          Is_Active__c,
          IDR_Channel_Received__c,
          IDR_Priority__c,
          IDR_Written_Response_Requested__c
        FROM Known_Issues__c
        WHERE Is_Active__c = TRUE
      ];

      AccessCheckUtil.AccessCheckWrapper acw = AccessCheckUtil.checkAccess(
        'Known_Issues__c',
        AccessType.READABLE,
        knownIssuesList
      );
      if (acw.inAccessibleFields != null || acw.records.isEmpty()) {
        Lib_SystemLog.createSingleLogAsync(
          IDRExpressComplaintController.class.getName(),
          'getAllKnownIssues',
          'CMOS Express Case Creation Exception',
          'User does not have read access to fields -- ' +
          acw.inAccessibleFields
        );
        String m = 'You dont have enough permission to read CMOS Known Outages, Please contact system administrator.';
        AuraHandledException e = new AuraHandledException(m);
        e.setMessage(m);
        throw e;
      } else {
        return knownIssuesList;
      }
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}

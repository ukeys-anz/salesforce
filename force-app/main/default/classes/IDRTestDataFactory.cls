/**
 * @description This class is to provide generic setups configs for IDR unit tests.
 * @group Utils
 */
@isTest
public class IDRTestDataFactory {
  /**
   * @description Method to create dummy Quality Assessment record
   * @param qaRecordId recordId For Qa record
   * @param oQAUser cq Specialist
   * @return Quality Assessment Object
   */
  public static Quality_Assessment__c createQARecord(
    String qaRecordId,
    User oQAUser
  ) {
    Quality_Assessment__c qaRecord = new Quality_Assessment__c(
      Id = qaRecordId,
      Status__c = 'Complete',
      Case_Manager__c = oQAUser.Id,
      TeamManager__c = oQAUser.Id,
      C_Q_Specialist__c = oQAUser.Id,
      Team_Manager_Response__c = '',
      C_Q_Manager_Response__c = '',
      TM_Response_to_C_Q_Manager_Review__c = '',
      C_Q_Lead_Response__c = '',
      RecordTypeId = IDRConstants.idrtCQQualityAssessment
    );
    return qaRecord;
  }
}

/**
 * @description This class is to provide generic setups configs for IDR unit tests.
 * @group Utils
 */
@isTest
public class IDRTestDataFactory {
  /**
   *@description Create an Afca Case
   * @param priority of the Case
   * @param issueType of the Case
   * @param subIssueType of the Case
   * @return Case
   */

  public static Case createAfcaCustomerComplaintCase(
    String priority,
    String issueType,
    String subIssueType
  ) {
    Case csObj = new Case(
      RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
      Origin = IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED,
      IDR_AFCA_Status__c = '10',
      IDR_AFCA_Due_Date__c = System.TODAY(),
      IDR_Customer_Number__c = '1234567890',
      Priority = priority,
      Type = issueType,
      IDR_Subsequent_Issue__c = subIssueType
    );

    return csObj;
  }

  /**
   * @description Create Case record with different issue types
   * @return Case
   */
  public static Case createComplaint() {
    Case caseRecord = new Case();
    caseRecord.RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID;
    caseRecord.IDR_Customer_Number__c = '1234567890';
    caseRecord.Status = 'Open';
    caseRecord.IDR_Account_Card_Policy_Number__c = 'N/A';
    caseRecord.isEscalated = false;
    caseRecord.IDR_Second_Issue__c = true;
    caseRecord.IDR_Third_Issue__c = true;
    caseRecord.Type = '4';
    caseRecord.IDR_Issue_Type_2__c = '9';
    caseRecord.IDR_Issue_Type_3__c = '17';
    caseRecord.IDR_Subsequent_Issue__c = '20';
    caseRecord.IDR_Subsequent_Issue_2__c = '57';
    caseRecord.IDR_Subsequent_Issue_3__c = '24';
    caseRecord.IDR_Product_Category__c = 'Asset finance';
    caseRecord.IDR_Account_Card_Policy_Number_2__c = 'N/A';
    caseRecord.IDR_Account_Card_Policy_Number_3__c = 'N/A';
    caseRecord.Description = 'Test';
    caseRecord.IDR_Complainant_Desired_Outcome__c = 'Test';
    return caseRecord;
  }

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
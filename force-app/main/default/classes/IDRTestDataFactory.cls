/**
 * @description This class is to provide generic setups configs for IDR unit tests.
 * @group Utils
 */
@isTest
public class IDRTestDataFactory {
  static Faker faker = new Faker('AU');
  static String anzEmail = faker.internet.anzEmail();
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
   *@description Create an Account record with extra care time period and reason
   * @param extraCareTimeperiod ExtraCare flag of the Account
   * @return Account
   */
  public static Account getECFAccount(String extraCareTimeperiod) {
    Account acc = new Account();
    acc.Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    acc.ExtraCareTimePeriod__c = extraCareTimeperiod;
    return acc;
  }

  /**
   *@description Create a Customer complaint Case record with priority and related Account for Mocking framework
   * @param priority Set Priority of Case
   * @param acc Account object to relate with Case
   * @return Case
   */
  public static Case getCaseWithAccount(String priority, Account acc) {
    Integer caseNumber = new Faker('0-9').randomInteger(6);
    Case cs = (Case) TestUtil.setFields(
      new Case(
        Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
        RecordTypeId = RTCase.customerComplaint,
        Status = IDRConstants.OPEN_STATUS,
        CaseNumber__c = String.valueOf(caseNumber),
        Priority = priority,
        AccountId = acc.Id
      ),
      new Map<String, Object>{ 'CaseNumber' => caseNumber, 'Account' => acc }
    );
    return cs;
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
      Status__c = IDRConstants.STATUS_COMPLETE,
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
  /**
   * @description Method to create User record
   * @param name name for User record
   * @return User Object
   */
  public static User getUser(String name) {
    return new User(
      Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      Email = anzEmail,
      LastName = name,
      UserName = anzEmail
    );
  }
  /**
   * @description Method to create Quality Assessment record
   * @param manager User lookup for QA
   * @param relatedCase Case object for QA
   * @param status Status of QA
   * @return Quality_Assessment__c Object
   */
  public static Quality_Assessment__c getQA(
    User manager,
    Case relatedCase,
    String status
  ) {
    return (Quality_Assessment__c) TestUtil.setFields(
      new Quality_Assessment__c(
        Id = Lib_FakeIdGenerator.getMockId(Quality_Assessment__c.SObjectType),
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        Status__c = status,
        TeamManager__c = manager.Id,
        Case_Manager__c = manager.Id,
        Related_Case__c = relatedCase.Id,
        Evaluation_Type__c = IDRConstants.CQ_ASSESSMENT,
        RecordTypeId = RTQualityAssessment.idrCQQualityId
      ),
      new Map<String, Object>{
        'TeamManager__r' => manager,
        'Case_Manager__r' => manager,
        'Related_Case__r' => relatedCase
      }
    );
  }
  /**
   * @description Method to create Task record for QA
   * @param recWhatId Sobject Id which needs to be set as whatId
   * @param subject Subject of the task
   * @return Task Object
   */
  public static Task getTask(Id recWhatId, String subject) {
    return new Task(
      Id = Lib_FakeIdGenerator.getMockId(Task.SObjectType),
      Status = IDRConstants.OPEN_STATUS,
      WhatId = recWhatId,
      Subject = subject,
      RecordTypeId = RTTask.idrTask
    );
  }
  /**
   * @description Method to create Case record
   * @return Case Object
   */
  public static Case getCase() {
    return new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      RecordTypeId = RTCase.customerComplaint,
      Status = IDRConstants.OPEN_STATUS,
      CaseNumber__c = String.valueOf(new Faker('0-9').randomInteger(6))
    );
  }
  /**
   * @description Method to create Quality_Assessment__Share record
   * @param parentId Sobject Id which needs to be set as ParentId
   * @param userId UserOrGroupId of the Share record
   * @return Quality_Assessment__Share Object
   */
  public static Quality_Assessment__Share getQAShare(Id parentId, Id userId) {
    return new Quality_Assessment__Share(
      ParentId = parentId,
      UserOrGroupId = userId,
      RowCause = 'Manual'
    );
  }
}

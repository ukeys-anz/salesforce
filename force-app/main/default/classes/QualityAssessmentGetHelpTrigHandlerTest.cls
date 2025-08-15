/**
 * @description       : Test class for QualityAssessmentGetHelpTriggerHandler
 * @author            : Aman
 * @group             :
 * @last modified on  : 05-08-2025
 **/
@isTest
public with sharing class QualityAssessmentGetHelpTrigHandlerTest {
  public static Lib_MockProvider dmlRepoMock;
  public static final String REQUIREMENTS_NOT_MET = 'Requirements not met';
  public static final String ALMOST_THERE = 'Almost there';
  public static final String EFFECTIVE = 'Effective';
  public static final String REQUIREMENTS_MET = 'Requirements Met';
  public static final String NA_VALUE = 'N/A';
  public static final String ALMOSTTHERE = 'Almost There';
  public static final String NOT_THERE_YET = 'Not There Yet';
  public static final String OUTSTANDING = 'Outstanding';
  public static final String REFERENCE_VALUE = 'TestRef';
  public static final Id GET_HELP_RT_ID = QUeryRT.of(
      Quality_Assessment__c.SObjectType
    )
    .getId('Get_Help');
  public static final Id GET_HELP_APPOINTMENT_RT_ID = QUeryRT.of(
      Quality_Assessment__c.SObjectType
    )
    .getId('Get_Help_Appointment');
  public static final Id FAKER_QA_ASSESS_RECORD_ID = Lib_FakeIdGenerator.getMockId(
    Quality_Assessment__c.getSObjectType()
  );

  private static List<Quality_Assessment__c> getQARecords() {
    List<Quality_Assessment__c> records = new List<Quality_Assessment__c>();
    Quality_Assessment__c qa = new Quality_Assessment__c();
    qa.Advice_Initial_Contact__c = REQUIREMENTS_NOT_MET;
    qa.Advice_Define_Scope__c = ALMOST_THERE;
    qa.Advice_Customer_understanding_of_scope__c = ALMOST_THERE;
    qa.Key_scoping_and_disclaimers__c = ALMOST_THERE;
    qa.Advice_Limit_scope_of_advice__c = ALMOST_THERE;
    qa.Advice_Decline_advice_and_refer__c = ALMOST_THERE;
    qa.Advice_Substantive_Advice_OFSN__c = EFFECTIVE;
    qa.Advice_Fact_Find__c = EFFECTIVE;
    qa.CN_Fact_Find__c = EFFECTIVE;
    qa.Advice_Best_Interest_Duty__c = EFFECTIVE;
    qa.Advice_Dispute_Resolution__c = ALMOST_THERE;
    qa.Advice_Incomplete_Inaccurate_warning__c = NA_VALUE;
    qa.CN_Customers_Focus__c = NA_VALUE;
    qa.CN_Substantive_Advice__c = NA_VALUE;
    qa.CN_Out_of_Scope__c = NA_VALUE;
    qa.CN_OFSN__c = NA_VALUE;
    qa.CN_Scope_Provided__c = NA_VALUE;
    qa.Status__c = 'Complete';
    qa.Sub_Status__c = 'Evaluation Completed';
    qa.CN_Checklist__c = NA_VALUE;
    qa.RecordTypeId = GET_HELP_RT_ID;
    qa.Reference__c = REFERENCE_VALUE;
    qa.Connection_and_Trust__c = EFFECTIVE;
    qa.Energy_and_Adaptability__c = EFFECTIVE;
    qa.Discover_and_Align__c = EFFECTIVE;
    qa.Actions_and_Momentum__c = EFFECTIVE;
    qa.Accountability_and_Next_Steps__c = EFFECTIVE;
    qa.Id = FAKER_QA_ASSESS_RECORD_ID;
    qa.Interaction_Owner__c = UserInfo.getUserId();
    records.add(qa);
    return records;
  }

  private static Map<Id, Quality_Assessment__c> getOldQARecords() {
    Map<Id, Quality_Assessment__c> oldMap = new Map<Id, Quality_Assessment__c>();
    Quality_Assessment__c qa = new Quality_Assessment__c();
    qa.Advice_Initial_Contact__c = REQUIREMENTS_NOT_MET;
    qa.Advice_Define_Scope__c = ALMOST_THERE;
    qa.Advice_Customer_understanding_of_scope__c = ALMOST_THERE;
    qa.Key_scoping_and_disclaimers__c = ALMOST_THERE;
    qa.Advice_Limit_scope_of_advice__c = ALMOST_THERE;
    qa.Advice_Decline_advice_and_refer__c = ALMOST_THERE;
    qa.Advice_Substantive_Advice_OFSN__c = EFFECTIVE;
    qa.Advice_Fact_Find__c = EFFECTIVE;
    qa.CN_Fact_Find__c = EFFECTIVE;
    qa.Advice_Best_Interest_Duty__c = EFFECTIVE;
    qa.Advice_Dispute_Resolution__c = ALMOST_THERE;
    qa.Advice_Incomplete_Inaccurate_warning__c = NA_VALUE;
    qa.CN_Customers_Focus__c = NA_VALUE;
    qa.CN_Substantive_Advice__c = NA_VALUE;
    qa.CN_Out_of_Scope__c = NA_VALUE;
    qa.CN_OFSN__c = NA_VALUE;
    qa.CN_Scope_Provided__c = NA_VALUE;
    qa.CN_Checklist__c = NA_VALUE;
    qa.RecordTypeId = GET_HELP_RT_ID;
    qa.Status__c = 'In Progress';
    qa.Reference__c = REFERENCE_VALUE;
    qa.Connection_and_Trust__c = EFFECTIVE;
    qa.Energy_and_Adaptability__c = EFFECTIVE;
    qa.Discover_and_Align__c = EFFECTIVE;
    qa.Actions_and_Momentum__c = EFFECTIVE;
    qa.Accountability_and_Next_Steps__c = EFFECTIVE;
    qa.Id = FAKER_QA_ASSESS_RECORD_ID;
    oldMap.put(FAKER_QA_ASSESS_RECORD_ID, qa);
    return oldMap;
  }

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  @isTest
  private static void testOnBeforeUpdate() {
    Map<Id, Quality_Assessment__c> oldMap = getOldQARecords();
    List<Quality_Assessment__c> qaRecords = getQARecords();
    qaRecords[0].CX_Criteria_Comments__c = '<img>';
    Test.startTest();
    QualityAssessmentGetHelpTriggerHandler handler = new QualityAssessmentGetHelpTriggerHandler();
    handler.records = qaRecords;
    handler.onBeforeUpdate(oldMap);
    Test.stopTest();

    Assert.isTrue(qaRecords[0].hasErrors(), 'QA Record should have error.');
  }

  @isTest
  private static void testOnBeforeInsert() {
    List<Quality_Assessment__c> qaRecords = getQARecords();
    qaRecords[0].CX_Criteria_Comments__c = '<img>';
    Test.startTest();
    QualityAssessmentGetHelpTriggerHandler handler = new QualityAssessmentGetHelpTriggerHandler();
    handler.records = qaRecords;
    handler.onBeforeInsert();
    Test.stopTest();

    Assert.isTrue(qaRecords[0].hasErrors(), 'QA Record should have error.');
  }

  @isTest
  private static void testOnAfterUpdate() {
    registerMocks();
    Map<Id, Quality_Assessment__c> oldMap = getOldQARecords();
    List<Quality_Assessment__c> qaRecords = getQARecords();

    Test.startTest();
    QualityAssessmentGetHelpTriggerHandler handler = new QualityAssessmentGetHelpTriggerHandler();
    handler.records = qaRecords;
    handler.onAfterUpdate(oldMap);
    Test.stopTest();

    List<Quality_Assessment__share> qaShares = (List<Quality_Assessment__share>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');

    Assert.isTrue(qaShares.size() > 0, 'A share record should be created');
    Assert.isTrue(
      qaShares[0].UserOrGroupId == UserInfo.getUserId(),
      'Share with user should be created'
    );
  }

  @IsTest
  private static void testIsValidRecordNegative() {
    Quality_Assessment__c qaRecord = new Quality_Assessment__c();
    qaRecord.Id = Lib_FakeIdGenerator.getMockId(
      Quality_Assessment__c.SObjectType
    );
    qaRecord.RecordTypeId = RTQualityAssessment.lendingEvaluation;

    Test.startTest();
    QualityAssessmentGetHelpTriggerHandler handler = new QualityAssessmentGetHelpTriggerHandler();
    Boolean isValidQA = handler.isValidRecord(qaRecord);
    Test.stopTest();

    Assert.isFalse(isValidQA, 'Should return true for Get Help');
  }

  @IsTest
  private static void testIsValidRecordPositive() {
    Quality_Assessment__c qaRecord = new Quality_Assessment__c();
    qaRecord.Id = Lib_FakeIdGenerator.getMockId(
      Quality_Assessment__c.SObjectType
    );
    qaRecord.RecordTypeId = RTQualityAssessment.getHelpAppointment;

    Test.startTest();
    QualityAssessmentGetHelpTriggerHandler handler = new QualityAssessmentGetHelpTriggerHandler();
    Boolean isValidQA = handler.isValidRecord(qaRecord);
    Test.stopTest();

    Assert.isTrue(isValidQA, 'Should return true for get help appointments');
  }
}

/**
 * @author cruzb
 * @since May 2023
 * @description Controller test class for Apex remote CreditAssessmentController
 * @group Services
 */
@isTest
public with sharing class CreditAssessmentControllerTest {
  static Lib_MockProvider creditRepoMock;
  static Lib_MockProvider creditAPIMock;

  static void registerMocks() {
    creditRepoMock = Lib_MockProvider.forType(
      CreditAsssessmentRepository.class
    );
    creditAPIMock = Lib_MockProvider.forType(
      CreditAssessmentAPIRepository.class
    );
  }

  static Faker faker = new Faker('AU');

  static Account accnt = new Account(
    OCV_ID__c = faker.randomString(10),
    Id = Lib_FakeIdGenerator.getMockId(Account.getSObjectType())
  );

  static ResidentialLoanApplication loanApp = new ResidentialLoanApplication(
    AccountId = accnt.Id,
    Id = Lib_FakeIdGenerator.getMockId(
      ResidentialLoanApplication.getSObjectType()
    ),
    Status = 'STATE_DECLINED'
  );

  static Case creditRefCase = new Case(
    Id = Lib_FakeIdGenerator.getMockId(Case.getSObjectType()),
    RecordTypeID = GetHelpConstants.CREDIT_REFERRAL_RT_ID,
    Subject = 'Test Credit Referral',
    Status = 'Open',
    AccountId = accnt.Id,
    Credit_Id__c = '000-000-000-001',
    Assessment_Id__c = '123456789'
  );

  static List<Referral_Reason__c> refReasonList = new List<Referral_Reason__c>{
    new Referral_Reason__c(
      Id = Lib_FakeIdGenerator.getMockId(Referral_Reason__c.getSObjectType()),
      Reason_Code__c = 'RE202'
    )
  };

  static List<Reason_Outcome__c> reasonOutcomeList = new List<Reason_Outcome__c>{
    new Reason_Outcome__c(
      Id = Lib_FakeIdGenerator.getMockId(Reason_Outcome__c.getSObjectType()),
      Outcome_Code__c = 'OUT123',
      Referral_Reason__c = refReasonList[0].Id
    )
  };

  static CreditReferralModel creditRefAPIResp = CreditReferralModel.parse(
    Service.getStaticResource('mock_CRListAssessment')
  );

  static List<User> userList = new List<User>{
    new User(
      Alias = faker.person.name(),
      Email = faker.person.name() + '@test.com',
      LastName = faker.person.lastName(),
      FirstName = faker.person.firstName(),
      UserName = faker.person.name() + '@test.com',
      FederationIdentifier = 'charalap' //match mock createdBy
    )
  };

  @isTest
  static void testGetCreditAssessments() {
    registerMocks();
    creditRepoMock.mock('getCaseRecord', creditRefCase);
    creditAPIMock.mock('getCreditAssessments', creditRefAPIResp);
    creditRepoMock.mock('getReferralReasonList', refReasonList);
    creditRepoMock.mock('getReasonOutcomeByOutcomeCode', reasonOutcomeList);
    creditRepoMock.mock('getUserList', userList);

    Test.startTest();
    Map<String, Object> objectMap = new Map<String, Object>();
    CreditAssessmentController crAssessment = new CreditAssessmentController();
    Map<String, Object> inputMap = new Map<String, Object>{
      'creditId' => '1231',
      'recordId' => creditRefCase.Id,
      'ocvId' => accnt.OCV_ID__c
    };

    crAssessment.getCreditAssessments(inputMap, objectMap, null);

    Test.stopTest();
    Assert.isFalse(
      creditRepoMock.getHistories('getCaseRecord').isEmpty(),
      'getCaseRecord should have been called.'
    );

    Assert.isFalse(
      creditAPIMock.getHistories('getCreditAssessments').isEmpty(),
      'getCreditAssessments should have been called.'
    );

    Assert.isFalse(
      creditRepoMock.getHistories('getReferralReasonList').isEmpty(),
      'getReferralReasonList should have been called.'
    );

    Assert.isFalse(
      creditRepoMock.getHistories('getReasonOutcomeByOutcomeCode').isEmpty(),
      'getReasonOutcomeByOutcomeCode should have been called.'
    );

    Assert.isFalse(
      creditRepoMock.getHistories('getUserList').isEmpty(),
      'getUserList should have been called.'
    );

    Object payload = objectMap.get('object');
    Assert.areNotEqual(payload, null, 'Empty JSON');
    Assert.areNotEqual(
      ((Map<String, Object>) payload).get('current'),
      null,
      'Missing `current` node'
    );
    Assert.areNotEqual(
      ((Map<String, Object>) payload).get('history'),
      null,
      'Missing `history` node'
    );
    CreditReferralModel model = CreditReferralModel.parse(
      json.serialize(((Map<String, Object>) payload).get('current'))
    );
    Assert.isTrue(
      !model.assessments[0].outcome.contains('_'),
      'Outcome not transformed'
    );
  }

  @isTest
  static void testGetAssessmentOutcome() {
    registerMocks();
    creditRepoMock.mock('getResidentialLoanApplicationRecord', loanApp);
    creditAPIMock.mock('getCreditAssessments', creditRefAPIResp);

    Test.startTest();
    Map<String, Object> objectMap = new Map<String, Object>();
    CreditAssessmentController crAssessment = new CreditAssessmentController();
    Map<String, Object> inputMap = new Map<String, Object>{
      'ApplicationId' => loanApp.Id
    };

    crAssessment.getAssessmentOutcome(inputMap, objectMap, null);
    Test.stopTest();

    Assert.isFalse(
      creditAPIMock.getHistories('getCreditAssessments').isEmpty(),
      'getCreditAssessments should have been called.'
    );

    Object payload = objectMap.get('object');
    Assert.areNotEqual(payload, null, 'Empty JSON');
    Assert.areNotEqual(
      ((Map<String, Object>) payload).get('lastModified'),
      null,
      'Missing `lastModified` node'
    );
    Assert.areNotEqual(
      ((Map<String, Object>) payload).get('rows'),
      null,
      'Missing `rows` node'
    );
  }

  @isTest
  static void testAssignReasonFields() {
    registerMocks();
    creditRepoMock.mock('getCaseRecord', creditRefCase);
    creditRepoMock.mock('getReferralReasonList', refReasonList);
    creditRepoMock.mock('getReasonOutcomeByOutcomeCode', reasonOutcomeList);
    creditRepoMock.mock('getUserList', userList);

    Test.startTest();
    CreditAssessmentController.assignReasonFields(
      creditRefAPIResp,
      String.valueOf(creditRefCase.Id)
    );
    Test.stopTest();

    Assert.isFalse(
      creditRepoMock.getHistories('getCaseRecord').isEmpty(),
      'getCaseRecord should have been called.'
    );

    Assert.isFalse(
      creditRepoMock.getHistories('getReferralReasonList').isEmpty(),
      'getReferralReasonList should have been called.'
    );

    Assert.isFalse(
      creditRepoMock.getHistories('getReasonOutcomeByOutcomeCode').isEmpty(),
      'getReasonOutcomeByOutcomeCode should have been called.'
    );

    Assert.isFalse(
      creditRepoMock.getHistories('getUserList').isEmpty(),
      'getUserList should have been called.'
    );
  }

  @isTest
  static void testSplitCurrentAndHistory() {
    Test.startTest();
    Map<String, Object> resp = CreditAssessmentController.splitCurrentAndHistory(
      creditRefAPIResp
    );
    Test.stopTest();

    Assert.areNotEqual(
      resp.get('current'),
      null,
      'Current node should have data'
    );
    Assert.areNotEqual(
      resp.get('history'),
      null,
      'History node should have data'
    );
  }

  @isTest
  static void testGetSelectOptions() {
    registerMocks();
    creditRepoMock.mock('getReasonOutcomeByReferralReason', reasonOutcomeList);
    Map<String, Object> input = new Map<String, Object>{
      'reasonCodeId' => refReasonList[0].Id
    };
    Map<String, Object> output = new Map<String, Object>();

    CreditAssessmentController controller = new CreditAssessmentController();

    Test.startTest();
    controller.getSelectOptions(input, output, null);
    Test.stopTest();

    Assert.isNotNull(output.get('options'), 'Option list should not be null');
  }

  @isTest
  static void testSaveReferralChange() {
    registerMocks();
    creditRepoMock.mock('getCaseRecord', creditRefCase);
    creditAPIMock.mock('createCreditEnquiryAssessment', true);

    Map<String, Object> input = new Map<String, Object>{
      'creditId' => '12323@2',
      'refOutcome' => 'OU11',
      'reasonCode' => 'RE102',
      'applicantId' => '123456',
      'recordId' => creditRefCase.Id,
      'propertyId' => '123456789'
    };

    CreditAssessmentController controller = new CreditAssessmentController();
    Test.startTest();
    controller.saveReferralChange(input, null, null);
    Test.stopTest();

    Assert.isFalse(
      creditRepoMock.getHistories('getCaseRecord').isEmpty(),
      'getCaseRecord should have been called.'
    );

    Assert.isFalse(
      creditAPIMock.getHistories('createCreditEnquiryAssessment').isEmpty(),
      'createCreditEnquiryAssessment should have been called.'
    );
  }

  @isTest
  static void testDeleteReferralOutcome() {
    registerMocks();
    creditRepoMock.mock('getCaseRecord', creditRefCase);
    creditAPIMock.mock('deleteReferralOutcome', true);

    Map<String, Object> input = new Map<String, Object>{
      'creditId' => '12323@2',
      'recordId' => creditRefCase.Id,
      'assessmentId' => '123456',
      'outcomeId' => '123456'
    };

    CreditAssessmentController controller = new CreditAssessmentController();
    Test.startTest();
    controller.deleteReferralOutcome(input, null, null);
    Test.stopTest();

    Assert.isFalse(
      creditRepoMock.getHistories('getCaseRecord').isEmpty(),
      'getCaseRecord should have been called.'
    );

    Assert.isFalse(
      creditAPIMock.getHistories('deleteReferralOutcome').isEmpty(),
      'deleteReferralOutcome should have been called.'
    );
  }

  @isTest
  static void testGetReferralReasonMap() {
    registerMocks();
    creditRepoMock.mock('getReferralReasonList', refReasonList);
    Set<String> reasonCodeSet = new Set<String>{ 'RE202' };
    Map<String, Referral_Reason__c> resp = CreditAssessmentController.getReferralReasonMap(
      reasonCodeSet
    );
    Assert.isFalse(
      creditRepoMock.getHistories('getReferralReasonList').isEmpty(),
      'getReferralReasonList should have been called.'
    );

    Assert.isNotNull(
      resp.get('RE202'),
      'Referral reason should be in response'
    );
  }

  @isTest
  static void testGetReferralReasonOutcomeMap() {
    registerMocks();
    creditRepoMock.mock('getReasonOutcomeByOutcomeCode', reasonOutcomeList);
    Set<String> outcomeMap = new Set<String>{ 'OUT123' };
    Map<String, Reason_Outcome__c> resp = CreditAssessmentController.getReferralReasonOutcomeMap(
      outcomeMap
    );
    Assert.isFalse(
      creditRepoMock.getHistories('getReasonOutcomeByOutcomeCode').isEmpty(),
      'getReasonOutcomeByOutcomeCode should have been called.'
    );

    Assert.isNotNull(resp.get('OUT123'), 'Outcome should be in response');
  }
}

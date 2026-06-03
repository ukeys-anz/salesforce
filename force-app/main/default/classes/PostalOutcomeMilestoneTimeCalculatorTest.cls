/**
 * @author Shivam Goyal
 * @date 05/2026
 * @description Test class for {@link PostalOutcomeMilestoneTimeCalculator}
 * @group IDR(Internal Dispute Resolution)
 */

@IsTest
public with sharing class PostalOutcomeMilestoneTimeCalculatorTest {
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider caseMilestoneRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    caseMilestoneRepoMock = Lib_MockProvider.forType(MilestoneRepository.class);
  }

  static Case caseRecord = new Case(
    Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
    IDR_Date_Received__c = Datetime.now()
  );

  static MilestoneType msType1 = new MilestoneType(
    Id = Lib_FakeIdGenerator.getMockId(MilestoneType.SObjectType),
    Name = IDRConstants.MILESTONE_STANDARD
  );

  static MilestoneType msType2 = new MilestoneType(
    Id = Lib_FakeIdGenerator.getMockId(MilestoneType.SObjectType),
    Name = IDRConstants.MILESTONE_PRIORITY
  );

  static CaseMilestone caseMilestoneRecord1 = (CaseMilestone) TestUtil.setFields(
    new CaseMilestone(
      Id = Lib_FakeIdGenerator.getMockId(CaseMilestone.SObjectType)
    ),
    new Map<String, Object>{
      'MilestoneTypeId' => msType1.Id,
      'MilestoneType' => msType1
    }
  );

  static CaseMilestone caseMilestoneRecord2 = (CaseMilestone) TestUtil.setFields(
    new CaseMilestone(
      Id = Lib_FakeIdGenerator.getMockId(CaseMilestone.SObjectType)
    ),
    new Map<String, Object>{
      'MilestoneTypeId' => msType2.Id,
      'MilestoneType' => msType2
    }
  );

  static Case mockCasewithMilestone1 = (Case) TestUtil.setFields(
    caseRecord,
    new Map<String, Object>{
      'CaseMilestones' => new List<CaseMilestone>{ caseMilestoneRecord1 }
    }
  );

  static Case mockCasewithMilestone2 = (Case) TestUtil.setFields(
    caseRecord,
    new Map<String, Object>{
      'CaseMilestones' => new List<CaseMilestone>{ caseMilestoneRecord2 }
    }
  );
  @IsTest
  static void testPostalOutComeMilestonefor30Day() {
    registerMocks();
    PostalOutcomeMilestoneTimeCalculator postalMilestoneCalculator = new PostalOutcomeMilestoneTimeCalculator();
    caseMilestoneRepoMock.mock(
      'queryCaseMilestoneonCase',
      mockCasewithMilestone1
    );
    Test.startTest();
    Integer triggertime = postalMilestoneCalculator.calculateMilestoneTriggerTime(
      mockCasewithMilestone1.Id,
      msType1.Id
    );
    Test.stopTest();
    Assert.areEqual(33120, triggertime, 'trigger Time matched');
  }
  @IsTest
  static void testPostalOutComeMilestonefor21Day() {
    registerMocks();
    PostalOutcomeMilestoneTimeCalculator postalMilestoneCalculator = new PostalOutcomeMilestoneTimeCalculator();
    caseMilestoneRepoMock.mock(
      'queryCaseMilestoneonCase',
      mockCasewithMilestone2
    );
    Test.startTest();
    Integer triggertime = postalMilestoneCalculator.calculateMilestoneTriggerTime(
      mockCasewithMilestone2.Id,
      msType2.Id
    );
    Test.stopTest();
    Assert.areEqual(20160, triggertime, 'trigger Time matched');
  }
  @IsTest
  static void testcalculatePostalOutcomeTimeforNoMilestone() {
    registerMocks();
    PostalOutcomeMilestoneTimeCalculator postalMilestoneCalculator = new PostalOutcomeMilestoneTimeCalculator();
    caseMilestoneRepoMock.mock('queryCaseMilestoneonCase', caseRecord);
    Test.startTest();
    Integer triggertime = postalMilestoneCalculator.calculatePostalOutcomeTime(
      'Invalid',
      mockCasewithMilestone1.IDR_Date_Received__c
    );
    Test.stopTest();
    Assert.areEqual(0, triggertime, 'trigger Time matched');
  }
  @IsTest
  static void testcalculatePostalOutcomeTime30Day() {
    PostalOutcomeMilestoneTimeCalculator postalMilestoneCalculator = new PostalOutcomeMilestoneTimeCalculator();
    Test.startTest();
    Integer triggertime = postalMilestoneCalculator.calculatePostalOutcomeTime(
      msType1.name,
      mockCasewithMilestone1.IDR_Date_Received__c
    );
    Test.stopTest();
    Assert.areEqual(33120, triggertime, 'trigger Time matched');
  }
  @IsTest
  static void testcalculatePostalOutcomeTime21Day() {
    PostalOutcomeMilestoneTimeCalculator postalMilestoneCalculator = new PostalOutcomeMilestoneTimeCalculator();
    Test.startTest();
    Integer triggertime = postalMilestoneCalculator.calculatePostalOutcomeTime(
      msType2.name,
      mockCasewithMilestone2.IDR_Date_Received__c
    );
    Test.stopTest();
    Assert.areEqual(20160, triggertime, 'trigger Time matched');
  }
}

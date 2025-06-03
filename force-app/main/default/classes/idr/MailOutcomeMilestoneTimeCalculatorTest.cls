/**
 * @author Manisha Srilekha
 * @date 05/2025
 * @description Test class for {@link MailOutcomeMilestoneTimeCalculator}
 * @group IDR(Internal Dispute Resolution)
 */
@IsTest
public with sharing class MailOutcomeMilestoneTimeCalculatorTest {
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
  static void testMailOutComeMilestonefor30Day() {
    registerMocks();
    MailOutcomeMilestoneTimeCalculator mailMilestonecalculator = new MailOutcomeMilestoneTimeCalculator();
    caseMilestoneRepoMock.mock(
      'queryCaseMilestoneonCase',
      mockCasewithMilestone1
    );
    Test.startTest();
    Integer triggertime = mailMilestonecalculator.calculateMilestoneTriggerTime(
      mockCasewithMilestone1.Id,
      msType1.Id
    );
    Test.stopTest();
    Assert.areEqual(33120, triggertime, 'Trigger Time matched');
  }
  @IsTest
  static void testMailOutComeMilestonefor21Day() {
    registerMocks();
    MailOutcomeMilestoneTimeCalculator mailMilestonecalculator = new MailOutcomeMilestoneTimeCalculator();
    caseMilestoneRepoMock.mock(
      'queryCaseMilestoneonCase',
      mockCasewithMilestone2
    );
    Test.startTest();
    Integer triggertime = mailMilestonecalculator.calculateMilestoneTriggerTime(
      mockCasewithMilestone2.Id,
      msType2.Id
    );
    Test.stopTest();
    Assert.areEqual(20160, triggertime, 'Trigger Time matched');
  }
  @IsTest
  static void testcalculateMailOutcomeTimeforNoMilestone() {
    registerMocks();
    MailOutcomeMilestoneTimeCalculator mailMilestonecalculator = new MailOutcomeMilestoneTimeCalculator();
    caseMilestoneRepoMock.mock('queryCaseMilestoneonCase', caseRecord);
    Test.startTest();
    Integer triggertime = mailMilestonecalculator.calculateMailOutcomeTime(
      'Invalid Milestone',
      mockCasewithMilestone1.IDR_Date_Received__c
    );
    Test.stopTest();
    Assert.areEqual(0, triggertime, 'Trigger Time matched');
  }
  @IsTest
  static void testcalculateMailOutcomeTime30Day() {
    MailOutcomeMilestoneTimeCalculator mailMilestonecalculator = new MailOutcomeMilestoneTimeCalculator();
    Test.startTest();
    Integer triggertime = mailMilestonecalculator.calculateMailOutcomeTime(
      msType1.name,
      mockCasewithMilestone1.IDR_Date_Received__c
    );
    Test.stopTest();
    Assert.areEqual(33120, triggertime, 'Trigger Time matched');
  }
  @IsTest
  static void testcalculateMailOutcomeTime21Day() {
    MailOutcomeMilestoneTimeCalculator mailMilestonecalculator = new MailOutcomeMilestoneTimeCalculator();
    Test.startTest();
    Integer triggertime = mailMilestonecalculator.calculateMailOutcomeTime(
      msType2.name,
      mockCasewithMilestone2.IDR_Date_Received__c
    );
    Test.stopTest();
    Assert.areEqual(20160, triggertime, 'Trigger Time matched');
  }
}

/**
 * @author Hrushikesh
 * @since 14/2025
 * @description Test class for LendingEvaluationActions.
 */
@isTest
public with sharing class LendingEvaluationActionsTest {
  private static Lib_MockProvider dmlRepoMock;
  private static Lib_MockProvider qaRepoMock;

  private static final String REQUIREMENTS_NOT_MET = 'Requirements not met';
  private static final String ALMOST_THERE = 'Almost there';
  private static final String EFFECTIVE = 'Effective';
  private static final String REQUIREMENTS_MET = 'Requirements Met';
  private static final String NA_VALUE = 'N/A';
  private static final String ALMOSTTHERE = 'Almost There';
  private static final String NOT_THERE_YET = 'Not There Yet';
  private static final String OUTSTANDING = 'Outstanding';
  private static final String REFERENCE_VALUE = 'TestRef';
  private static final String REQUIREMENT_NOT_MEANT_PROCESS_ONLY = 'Requirements Not Met (Process only)';
  private static final String REQUIREMENT_NOT_MEANT_COMPLIANCE = 'Requirements Not Met (Compliance)';
  private static final String REQUIREMENT_MET = 'Requirements Met';
  private static final Id LENDING_RT_ID = QueryRT.of(
      Quality_Assessment__c.SObjectType
    )
    .getId('ANZ_Plus_Governance_Lending_Evaluation');

  private static final Id FAKER_QA_ASSESS_RECORD_ID = Lib_FakeIdGenerator.getMockId(
    Quality_Assessment__c.getSObjectType()
  );

  private static final Id FAKER_ACCOUNT_RECORD_ID = Lib_FakeIdGenerator.getMockId(
    Account.getSObjectType()
  );

  private static final Id FAKER_RLA_RECORD_ID = Lib_FakeIdGenerator.getMockId(
    ResidentialLoanApplication.getSObjectType()
  );

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    qaRepoMock = Lib_MockProvider.forType(QualityAssessmentRepository.class)
      .mock('getRlaByIds', returnGetRlaByIds())
      .mock('getQAShareRecords', returnQAShareToDelete())
      .mock('getRlaByCustomer', new List<AggregateResult>());
  }

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
    qa.RecordTypeId = LENDING_RT_ID;
    qa.Reference__c = REFERENCE_VALUE;
    qa.Connection_and_Trust__c = EFFECTIVE;
    qa.Energy_and_Adaptability__c = EFFECTIVE;
    qa.Discover_and_Align__c = EFFECTIVE;
    qa.Actions_and_Momentum__c = EFFECTIVE;
    qa.Accountability_and_Next_Steps__c = EFFECTIVE;
    qa.Id = FAKER_QA_ASSESS_RECORD_ID;
    qa.Interaction_Owner__c = UserInfo.getUserId();
    qa.Serviceability_Outcome__c = REQUIREMENT_MET;
    qa.Income_Serviceability_Outcome__c = REQUIREMENT_MET;
    qa.Expenses_Serviceability_Outcome__c = REQUIREMENT_MET;
    qa.Debts_Serviceability_Outcome__c = REQUIREMENT_MET;
    qa.Conduct_Outcome__c = REQUIREMENT_MET;
    qa.Purpose_of_Loan_Outcome__c = REQUIREMENT_MET;
    qa.Collateral_Valuation_Outcome__c = REQUIREMENT_MET;
    qa.Material_Change_Outcome__c = REQUIREMENT_MET;
    qa.Hypercare_Focus_Area_Outcome__c = REQUIREMENT_MET;
    qa.Other__c = REQUIREMENT_MET;
    qa.Case_Notes_Outcome__c = REQUIREMENT_MET;
    qa.Application_ID__c = FAKER_RLA_RECORD_ID;
    qa.Application_ID__r = new ResidentialLoanApplication(
      AccountId = FAKER_ACCOUNT_RECORD_ID
    );
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
    qa.RecordTypeId = LENDING_RT_ID;
    qa.Status__c = 'In Progress';
    qa.Reference__c = REFERENCE_VALUE;
    qa.Connection_and_Trust__c = EFFECTIVE;
    qa.Energy_and_Adaptability__c = EFFECTIVE;
    qa.Discover_and_Align__c = EFFECTIVE;
    qa.Actions_and_Momentum__c = EFFECTIVE;
    qa.Accountability_and_Next_Steps__c = EFFECTIVE;
    qa.Id = FAKER_QA_ASSESS_RECORD_ID;
    qa.Serviceability_Outcome__c = REQUIREMENT_MET;
    qa.Income_Serviceability_Outcome__c = REQUIREMENT_MET;
    qa.Expenses_Serviceability_Outcome__c = REQUIREMENT_MET;
    qa.Debts_Serviceability_Outcome__c = REQUIREMENT_MET;
    qa.Conduct_Outcome__c = REQUIREMENT_MET;
    qa.Purpose_of_Loan_Outcome__c = REQUIREMENT_MET;
    qa.Collateral_Valuation_Outcome__c = REQUIREMENT_MET;
    qa.Material_Change_Outcome__c = REQUIREMENT_MET;
    qa.Hypercare_Focus_Area_Outcome__c = REQUIREMENT_MET;
    qa.Other__c = REQUIREMENT_MET;
    qa.Case_Notes_Outcome__c = REQUIREMENT_MET;
    oldMap.put(FAKER_QA_ASSESS_RECORD_ID, qa);
    return oldMap;
  }

  private static List<Quality_Assessment__Share> returnQAShareToDelete() {
    return new List<Quality_Assessment__Share>{
      new Quality_Assessment__Share(
        AccessLevel = 'Read',
        ParentId = FAKER_QA_ASSESS_RECORD_ID,
        UserOrGroupId = FAKER_RLA_RECORD_ID,
        RowCause = Schema.Quality_Assessment__Share.RowCause.ApexSharing__c
      )
    };
  }

  private static List<ResidentialLoanApplication> returnGetRlaByIds() {
    return new List<ResidentialLoanApplication>{
      new ResidentialLoanApplication(
        Id = FAKER_RLA_RECORD_ID,
        AccountId = FAKER_ACCOUNT_RECORD_ID,
        OwnerId = UserInfo.getUserId()
      )
    };
  }

  @isTest
  private static void testSetProcessExecutionOutcome() {
    List<Quality_Assessment__c> records = getQARecords();
    Test.startTest();
    LendingEvaluationActions.setProcessExecutionOutcome(
      records,
      getOldQARecords()
    );
    Test.stopTest();
    Assert.areEqual(
      records[0].Process_Execution_Outcome__c,
      REQUIREMENT_MET,
      'Process Execution Outcome should be requirement met'
    );
  }

  @isTest
  private static void testSetRiskAndComplianceOutcome() {
    List<Quality_Assessment__c> records = getQARecords();
    Test.startTest();
    LendingEvaluationActions.setRiskAndComplianceOutcome(
      records,
      getOldQARecords()
    );
    Test.stopTest();
    Assert.areEqual(
      records[0].Risk_and_Compliance_Outcome__c,
      REQUIREMENT_MET,
      'Risk & Complaince Outcome should be requirement met'
    );
  }

  @isTest
  private static void testSetRiskAndComplianceOutcomeNotMet() {
    List<Quality_Assessment__c> records = getQARecords();
    records[0]
      .Collateral_Valuation_Outcome__c = REQUIREMENT_NOT_MEANT_COMPLIANCE;
    Test.startTest();
    LendingEvaluationActions.setRiskAndComplianceOutcome(
      records,
      getOldQARecords()
    );
    Test.stopTest();
    Assert.areEqual(
      records[0].Risk_and_Compliance_Outcome__c,
      REQUIREMENT_NOT_MEANT_COMPLIANCE,
      'Risk & Complaince Outcome should be requirement met'
    );
  }

  @isTest
  private static void testSetProcessExecutionOutcomeNotMet() {
    List<Quality_Assessment__c> records = getQARecords();
    records[0]
      .Expenses_Serviceability_Outcome__c = REQUIREMENT_NOT_MEANT_PROCESS_ONLY;
    Test.startTest();
    LendingEvaluationActions.setProcessExecutionOutcome(
      records,
      getOldQARecords()
    );
    Test.stopTest();
    Assert.areEqual(
      records[0].Process_Execution_Outcome__c,
      REQUIREMENT_NOT_MEANT_PROCESS_ONLY,
      'Process Execution Outcome should be requirement met'
    );
  }

  @isTest
  private static void testCalculateAndSetNumberOfApplication() {
    registerMocks();
    List<Quality_Assessment__c> records = getQARecords();
    Test.startTest();
    LendingEvaluationActions.calculateAndSetNumberOfApplication(
      records,
      getOldQARecords()
    );
    Test.stopTest();
    Assert.areEqual(
      records[0].Number_of_Applications__c,
      null,
      'Number of application field should be empty'
    );
  }

  @isTest
  private static void createQAShareRecordsForLendingEvaluation() {
    registerMocks();
    Map<Id, Quality_Assessment__c> oldMap = getOldQARecords();
    List<Quality_Assessment__c> qaRecords = getQARecords();

    Test.startTest();
    LendingEvaluationActions.createQAShareRecordsForLendingEvaluation(
      qaRecords,
      oldMap
    );
    Test.stopTest();

    List<Quality_Assessment__share> qaToDelete = (List<Quality_Assessment__share>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');

    Assert.isTrue(
      qaToDelete.size() == 1,
      'A share record should be found to delete'
    );

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

  @isTest
  private static void testSetOutcomesForInProgress() {
    List<Quality_Assessment__c> records = getQARecords();
    records[0].Status__c = 'In Progress';
    records[0].Other__c = null;
    Test.startTest();
    LendingEvaluationActions.setOutcomesForInProgress(
      records,
      getOldQARecords()
    );
    Test.stopTest();
    Assert.isNull(
      records[0].Risk_and_Compliance_Outcome__c,
      'Risk & Complaince Outcome should be null'
    );
  }
}

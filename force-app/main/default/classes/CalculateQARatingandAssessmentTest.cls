@isTest
public with sharing class CalculateQARatingandAssessmentTest {
  public static final String REQUIREMENTS_NOT_MET = 'Requirements not met';
  public static final String ALMOST_THERE = 'Almost there';
  public static final String EFFECTIVE = 'Effective';
  public static final String REQUIREMENTS_MET = 'Requirements Met';
  public static final String NA_VALUE = 'N/A';
  public static final String ALMOSTTHERE = 'Almost There';
  public static final String NOT_THERE_YET = 'Not There Yet';
  public static final String OUTSTANDING = 'Outstanding';

  public static final String GET_HELP_RECORDTYPEID = Schema.SObjectType.Quality_Assessment__c.getRecordTypeInfosByDeveloperName()
    .get('Get_Help')
    .getRecordTypeId();

  @isTest
  static void testComplianceOutcomeReqMet() {
    Quality_Assessment__c qa = new Quality_Assessment__c();
    qa.Risk_and_Compliance_Category__c = 'Yes - Requirements met';
    qa.RecordTypeId = GET_HELP_RECORDTYPEID;
    insert qa;

    Test.startTest();
    CalculateQARatingandAssessment.calculateQA(qa.Id);
    Test.stopTest();

    qa = CalculateQARatingandAssessmentTest.getQARecord();

    //If Risk and Compliance is Yes then Compliance outcome is Requirements met

    System.assertEquals(
      REQUIREMENTS_MET,
      qa.Compliance_Outcome__c,
      'Compliance Outcome should be Requirements met'
    );

    //Calculate should be set to true when calculate button is clicked

    System.assertEquals(
      true,
      qa.Calculated__C,
      'Calculated should be updated to true'
    );
  }

  @isTest
  static void testComplianceOutcomeReqNotMet() {
    Quality_Assessment__c qa = new Quality_Assessment__c();
    qa.Risk_and_Compliance_Category__c = 'ID & Privacy Category';
    qa.RecordTypeId = GET_HELP_RECORDTYPEID;
    insert qa;

    Test.startTest();
    CalculateQARatingandAssessment.calculateQA(qa.Id);
    Test.stopTest();

    qa = CalculateQARatingandAssessmentTest.getQARecord();

    //If Risk and Compliance is not Yes then Compliance outcome should be Requirements not met

    System.assertEquals(
      REQUIREMENTS_NOT_MET,
      qa.Compliance_Outcome__c,
      'Compliance Outcome should be Requirements not met'
    );

    System.assertEquals(
      true,
      qa.Calculated__C,
      'Calculated should be updated to true'
    );
  }

  @isTest
  static void testAdviceOutcomeReqNotMet() {
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
    qa.RecordTypeId = GET_HELP_RECORDTYPEID;

    insert qa;

    Test.startTest();
    CalculateQARatingandAssessment.calculateQA(qa.Id);
    Test.stopTest();

    qa = CalculateQARatingandAssessmentTest.getQARecord();

    /* Condition 
        If one response in any of the above 18 fields is Requirements not met then the Advice outcome should be
        Requirements not met */

    System.assertEquals(
      REQUIREMENTS_NOT_MET,
      qa.Advice_Outcome__c,
      'Advice Outcome should be Requirements not met since there is one answer which is Req not met'
    );
  }

  @isTest
  static void testAdviceOutcomeReqNotMetAlmostThere() {
    Quality_Assessment__c qa = new Quality_Assessment__c();
    qa.Advice_Initial_Contact__c = ALMOST_THERE;
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
    qa.RecordTypeId = GET_HELP_RECORDTYPEID;
    insert qa;

    Test.startTest();
    CalculateQARatingandAssessment.calculateQA(qa.Id);
    Test.stopTest();

    qa = CalculateQARatingandAssessmentTest.getQARecord();

    /* Condition 
        If there are no Requirements not met response but if there are more than 4 Almost there responses
        then the Advice outcome should be marked as Requirements not met */

    //Advice Outcome should be Requirements not met since there are 6 answers in Advice Outcome section
    //where the answer is Almost there.

    System.assertEquals(
      REQUIREMENTS_NOT_MET,
      qa.Advice_Outcome__c,
      'Advice Outcome should be Requirements not met since there are 6 answers which is Almost there'
    );
  }

  @isTest
  static void testAdviceOutcomeAlmostThere() {
    Quality_Assessment__c qa = new Quality_Assessment__c();
    qa.Advice_Initial_Contact__c = EFFECTIVE;
    qa.Advice_Define_Scope__c = NA_VALUE;
    qa.Advice_Customer_understanding_of_scope__c = ALMOST_THERE;
    qa.Key_scoping_and_disclaimers__c = ALMOST_THERE;
    qa.Advice_Limit_scope_of_advice__c = ALMOST_THERE;
    qa.Advice_Decline_advice_and_refer__c = ALMOST_THERE;
    qa.Advice_Substantive_Advice_OFSN__c = EFFECTIVE;
    qa.Advice_Fact_Find__c = EFFECTIVE;
    qa.CN_Fact_Find__c = EFFECTIVE;
    qa.Advice_Best_Interest_Duty__c = EFFECTIVE;
    qa.Advice_Dispute_Resolution__c = NA_VALUE;
    qa.Advice_Incomplete_Inaccurate_warning__c = NA_VALUE;
    qa.CN_Customers_Focus__c = NA_VALUE;
    qa.CN_Substantive_Advice__c = NA_VALUE;
    qa.CN_Out_of_Scope__c = NA_VALUE;
    qa.CN_OFSN__c = NA_VALUE;
    qa.CN_Scope_Provided__c = EFFECTIVE;
    qa.CN_Checklist__c = EFFECTIVE;
    qa.RecordTypeId = GET_HELP_RECORDTYPEID;
    insert qa;

    Test.startTest();
    CalculateQARatingandAssessment.calculateQA(qa.Id);
    Test.stopTest();

    qa = CalculateQARatingandAssessmentTest.getQARecord();

    /* Condition 
        If there are no Requirements not met response but if there are 3 to 4 Almost there responses
        then the Advice outcome should be marked as Almost there */

    //Advice Outcome should be Almost there since there are 4 answers in Advice Outcome section
    //where the answer is Almost there.

    System.assertEquals(
      ALMOST_THERE,
      qa.Advice_Outcome__c,
      'Advice Outcome should be Almost there since there are 4 answers which is Almost there'
    );
  }

  @isTest
  static void testAdviceOutcomeEffective() {
    Quality_Assessment__c qa = new Quality_Assessment__c();
    qa.Advice_Initial_Contact__c = EFFECTIVE;
    qa.Advice_Define_Scope__c = NA_VALUE;
    qa.Advice_Customer_understanding_of_scope__c = NA_VALUE;
    qa.Key_scoping_and_disclaimers__c = NA_VALUE;
    qa.Advice_Limit_scope_of_advice__c = ALMOST_THERE;
    qa.Advice_Decline_advice_and_refer__c = ALMOST_THERE;
    qa.Advice_Substantive_Advice_OFSN__c = EFFECTIVE;
    qa.Advice_Fact_Find__c = EFFECTIVE;
    qa.CN_Fact_Find__c = EFFECTIVE;
    qa.Advice_Best_Interest_Duty__c = EFFECTIVE;
    qa.Advice_Dispute_Resolution__c = NA_VALUE;
    qa.Advice_Incomplete_Inaccurate_warning__c = NA_VALUE;
    qa.CN_Customers_Focus__c = NA_VALUE;
    qa.CN_Substantive_Advice__c = NA_VALUE;
    qa.CN_Out_of_Scope__c = NA_VALUE;
    qa.CN_OFSN__c = NA_VALUE;
    qa.CN_Scope_Provided__c = EFFECTIVE;
    qa.CN_Checklist__c = EFFECTIVE;
    qa.RecordTypeId = GET_HELP_RECORDTYPEID;
    insert qa;

    Test.startTest();
    CalculateQARatingandAssessment.calculateQA(qa.Id);
    Test.stopTest();

    qa = CalculateQARatingandAssessmentTest.getQARecord();

    /* Condition 
        If there are no Requirements not met response but if there are 1 to 2 Almost there responses
        then the Advice outcome should be marked as Effective */

    //Advice Outcome should be Effective since there are 2 answers in Advice Outcome section
    //where the answer is Almost there.

    System.assertEquals(
      EFFECTIVE,
      qa.Advice_Outcome__c,
      'Advice Outcome should be Effective since there are 2 answers which is Effective'
    );
  }

  @isTest
  static void testAdviceOutcomeEffective2() {
    Quality_Assessment__c qa = new Quality_Assessment__c();
    qa.Advice_Initial_Contact__c = EFFECTIVE;
    qa.Advice_Define_Scope__c = NA_VALUE;
    qa.Advice_Customer_understanding_of_scope__c = NA_VALUE;
    qa.Key_scoping_and_disclaimers__c = NA_VALUE;
    qa.Advice_Limit_scope_of_advice__c = NA_VALUE;
    qa.Advice_Decline_advice_and_refer__c = NA_VALUE;
    qa.Advice_Substantive_Advice_OFSN__c = EFFECTIVE;
    qa.Advice_Fact_Find__c = EFFECTIVE;
    qa.CN_Fact_Find__c = EFFECTIVE;
    qa.Advice_Best_Interest_Duty__c = EFFECTIVE;
    qa.Advice_Dispute_Resolution__c = NA_VALUE;
    qa.Advice_Incomplete_Inaccurate_warning__c = NA_VALUE;
    qa.CN_Customers_Focus__c = NA_VALUE;
    qa.CN_Substantive_Advice__c = NA_VALUE;
    qa.CN_Out_of_Scope__c = EFFECTIVE;
    qa.CN_OFSN__c = EFFECTIVE;
    qa.CN_Scope_Provided__c = EFFECTIVE;
    qa.CN_Checklist__c = EFFECTIVE;
    qa.RecordTypeId = GET_HELP_RECORDTYPEID;
    insert qa;

    Test.startTest();
    CalculateQARatingandAssessment.calculateQA(qa.Id);
    Test.stopTest();

    qa = CalculateQARatingandAssessmentTest.getQARecord();

    /* Condition 
        If there are no Requirements not met responses and no Almost there responses then the Advice outcome should be 
        Effective */

    //Advice Outcome should be Effective since there are no answers in Advice Outcome section
    //where the answers are Almost there, Requirements not met.

    System.assertEquals(
      EFFECTIVE,
      qa.Advice_Outcome__c,
      'Advice Outcome should be Effective since there are no answers with values Almost there, Requirements not met'
    );
  }

  @isTest
  static void testAdviceOutcomeAlmostThereNA() {
    Quality_Assessment__c qa = new Quality_Assessment__c();
    qa.Advice_Initial_Contact__c = NA_VALUE;
    qa.Advice_Define_Scope__c = NA_VALUE;
    qa.Advice_Customer_understanding_of_scope__c = NA_VALUE;
    qa.Key_scoping_and_disclaimers__c = NA_VALUE;
    qa.Advice_Limit_scope_of_advice__c = NA_VALUE;
    qa.Advice_Decline_advice_and_refer__c = NA_VALUE;
    qa.Advice_Substantive_Advice_OFSN__c = NA_VALUE;
    qa.Advice_Fact_Find__c = EFFECTIVE;
    qa.CN_Fact_Find__c = EFFECTIVE;
    qa.Advice_Best_Interest_Duty__c = EFFECTIVE;
    qa.Advice_Dispute_Resolution__c = NA_VALUE;
    qa.Advice_Incomplete_Inaccurate_warning__c = NA_VALUE;
    qa.CN_Customers_Focus__c = NA_VALUE;
    qa.CN_Substantive_Advice__c = NA_VALUE;
    qa.CN_Out_of_Scope__c = NA_VALUE;
    qa.CN_OFSN__c = NA_VALUE;
    qa.CN_Scope_Provided__c = ALMOST_THERE;
    qa.CN_Checklist__c = ALMOST_THERE;
    qa.RecordTypeId = GET_HELP_RECORDTYPEID;
    insert qa;

    Test.startTest();
    CalculateQARatingandAssessment.calculateQA(qa.Id);
    Test.stopTest();

    qa = CalculateQARatingandAssessmentTest.getQARecord();

    /* Condition 
       Since there are more than 11 N/A answers, if there are 2 or more Almost there responses then the overall 
       advice outcome should be Almost there*/

    System.assertEquals(
      ALMOST_THERE,
      qa.Advice_Outcome__c,
      'Advice Outcome should be Almost there'
    );
  }

  @isTest
  static void testAdviceOutcomeEffectiveNA() {
    Quality_Assessment__c qa = new Quality_Assessment__c();
    qa.Advice_Initial_Contact__c = NA_VALUE;
    qa.Advice_Define_Scope__c = NA_VALUE;
    qa.Advice_Customer_understanding_of_scope__c = NA_VALUE;
    qa.Key_scoping_and_disclaimers__c = NA_VALUE;
    qa.Advice_Limit_scope_of_advice__c = NA_VALUE;
    qa.Advice_Decline_advice_and_refer__c = NA_VALUE;
    qa.Advice_Substantive_Advice_OFSN__c = NA_VALUE;
    qa.Advice_Fact_Find__c = EFFECTIVE;
    qa.CN_Fact_Find__c = EFFECTIVE;
    qa.Advice_Best_Interest_Duty__c = EFFECTIVE;
    qa.Advice_Dispute_Resolution__c = NA_VALUE;
    qa.Advice_Incomplete_Inaccurate_warning__c = NA_VALUE;
    qa.CN_Customers_Focus__c = NA_VALUE;
    qa.CN_Substantive_Advice__c = NA_VALUE;
    qa.CN_Out_of_Scope__c = NA_VALUE;
    qa.CN_OFSN__c = NA_VALUE;
    qa.CN_Scope_Provided__c = EFFECTIVE;
    qa.CN_Checklist__c = ALMOST_THERE;
    qa.RecordTypeId = GET_HELP_RECORDTYPEID;
    insert qa;

    Test.startTest();
    CalculateQARatingandAssessment.calculateQA(qa.Id);
    Test.stopTest();

    qa = CalculateQARatingandAssessmentTest.getQARecord();

    /* Condition 
       Since there are more than 11 N/A answers, if there is only 1 Almost there response then the overall 
       advice outcome should be Effective */

    System.assertEquals(
      EFFECTIVE,
      qa.Advice_Outcome__c,
      'Advice Outcome should be Effective'
    );
  }

  @istest
  static void testRatingChatOutstanding() {
    Quality_Assessment__c qa = new Quality_Assessment__c();
    qa.Evaluation_Type__c = 'Chat';
    qa.RecordTypeId = GET_HELP_RECORDTYPEID;
    qa.Connection_and_Trust__c = OUTSTANDING; // Score should be 20
    qa.Discover_and_Align__c = EFFECTIVE; // Score should be 17.5
    qa.Actions_and_Momentum__c = ALMOSTTHERE; // Score should be 15
    qa.Accountability_and_Next_Steps__c = OUTSTANDING; // Score should be 20
    qa.Energy_and_Adaptability__c = OUTSTANDING; // Score should be 20
    insert qa;

    Test.startTest();
    CalculateQARatingandAssessment.calculateQA(qa.Id);
    Test.stopTest();

    qa = CalculateQARatingandAssessmentTest.getQARecord();

    // Score should be 92.5, which is sum of all the CX criteria response scores

    System.assertEquals(
      92.5,
      qa.Score__c,
      'Score should be 92.5 which is sum of all the CX criteria response scores'
    );

    // If the score is >= 90 and <= 100, then the rating is Outstanding

    System.assertEquals(
      OUTSTANDING,
      qa.Rating__c,
      'Since the score is 92.5 Rating should be Outstanding'
    );
  }

  @istest
  static void testRatingSimpleEffective() {
    Quality_Assessment__c qa = new Quality_Assessment__c();
    qa.Evaluation_Type__c = 'Simple';
    qa.RecordTypeId = GET_HELP_RECORDTYPEID;
    qa.Connection_and_Trust__c = OUTSTANDING; // Score should be 20
    qa.Discover_and_Align__c = EFFECTIVE; // Score should be 17.5
    qa.Actions_and_Momentum__c = ALMOSTTHERE; // Score should be 15
    qa.Accountability_and_Next_Steps__c = ALMOSTTHERE; // Score should be 15
    qa.Energy_and_Adaptability__c = OUTSTANDING; // Score should be 20
    insert qa;

    Test.startTest();
    CalculateQARatingandAssessment.calculateQA(qa.Id);
    Test.stopTest();

    qa = CalculateQARatingandAssessmentTest.getQARecord();

    // Score should be 87.5, which is sum of all the CX criteria response scores

    System.assertEquals(
      87.5,
      qa.Score__c,
      'Score should be 87.5 which is sum of all the CX criteria response scores'
    );

    // If the score is >= 85 and <= 89.9, then the rating is Effective

    System.assertEquals(
      EFFECTIVE,
      qa.Rating__c,
      'Since the score is 87.5 Rating should be Effective'
    );
  }

  @istest
  static void testRatingEmailNotThereYet() {
    Quality_Assessment__c qa = new Quality_Assessment__c();
    qa.Evaluation_Type__c = 'Email';
    qa.RecordTypeId = GET_HELP_RECORDTYPEID;
    qa.Connection_and_Trust__c = EFFECTIVE; // Score should be 20
    qa.Discover_and_Align__c = EFFECTIVE; // Score should be 20
    qa.Actions_and_Momentum__c = ALMOSTTHERE; // Score should be 5
    qa.Accountability_and_Next_Steps__c = ALMOSTTHERE; // Score should be 5
    qa.Energy_and_Adaptability__c = NOT_THERE_YET; // Score should be 2
    insert qa;

    Test.startTest();
    CalculateQARatingandAssessment.calculateQA(qa.Id);
    Test.stopTest();

    qa = CalculateQARatingandAssessmentTest.getQARecord();

    // Score should be 52, which is sum of all the CX criteria response scores

    System.assertEquals(
      52,
      qa.Score__c,
      'Score should be 52 which is sum of all the CX criteria response scores'
    );

    // If the score is >=0 and <= 69.9, then the rating is Not Yet

    System.assertEquals(
      NOT_THERE_YET,
      qa.Rating__c,
      'Since the score is 52 Rating should be Not There Yet'
    );
  }

  @istest
  static void testRatingComplexAlmostThere() {
    Quality_Assessment__c qa = new Quality_Assessment__c();
    qa.Evaluation_Type__c = 'Complex';
    qa.RecordTypeId = GET_HELP_RECORDTYPEID;
    qa.Preparation_and_Framing__c = OUTSTANDING; // Score should be 12.5
    qa.Insights_and_Focus__c = OUTSTANDING; // Score should be 12.5
    qa.Finishing_Touches__c = EFFECTIVE; // Score should be 11
    qa.Connection_and_Trust__c = EFFECTIVE; // Score should be 11
    qa.Discover_and_Align__c = EFFECTIVE; // Score should be 11
    qa.Actions_and_Momentum__c = ALMOSTTHERE; // Score should be 9.5
    qa.Accountability_and_Next_Steps__c = ALMOSTTHERE; // Score should be 9.5
    qa.Energy_and_Adaptability__c = NOT_THERE_YET; // Score should be 2
    insert qa;

    Test.startTest();
    CalculateQARatingandAssessment.calculateQA(qa.Id);
    Test.stopTest();

    qa = CalculateQARatingandAssessmentTest.getQARecord();
    // Score should be 79, which is sum of all the CX criteria response scores
    System.assertEquals(
      79,
      qa.Score__c,
      'Score should be 79 which is sum of all the CX criteria response scores'
    );

    // If the score is >=70 and <= 84.9, then the rating is Almost There
    System.assertEquals(
      'Almost There',
      qa.Rating__c,
      'Since the score is 79 Rating should be Almost There'
    );
  }

  /**
   * @description Common method to query QA record for assertion
   * @return Quality_Assessment__c QA record for assertion
   */

  public static Quality_Assessment__c getQARecord() {
    Quality_Assessment__c qaRecord = [
      SELECT
        Id,
        Rating__c,
        Score__c,
        Advice_Outcome__c,
        Compliance_Outcome__c,
        Calculated__c,
        Risk_and_Compliance_Category__c
      FROM Quality_Assessment__c
      WHERE RecordTypeId = :GET_HELP_RECORDTYPEID
      LIMIT 1
    ];
    return qaRecord;
  }
}

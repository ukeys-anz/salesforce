/**
 * @description       : Test class for QA rating (Join)calculation class
 * @author            : Lei Fang
 * @group             :
 * @last modified on  : 10-04-2022
 **/

@isTest
public with sharing class CalculateQARatingAssessmentForJoinTest {
  public static final String REQUIREMENTS_MET = 'Requirements Met';
  public static final String REQUIREMENTS_NOT_MET = 'Requirements not met';

  public static final String EV_TYPE_FRAUD = 'Fraud & Dispute';
  public static final String EV_TYPE_IDENTITY = 'Identity & KYC';
  public static final String EV_TYPE_INTERACTION = 'Interaction QI';

  public static final String ALMOST_THERE = 'Almost There';
  public static final String NOT_QUITE_THERE = 'Not Quite There';
  public static final String EFFECTIVE = 'Effective';
  public static final String OUTSTANDING_RATING = 'Outstanding';

  public static final String EXCEED_RATING = 'Exceeded Expectations';
  public static final String MET_RATING = 'Met Expectations';
  public static final String NOT_MET_RATING = 'Did Not Meet Expectations';

  public static final String REFERENCE_VALUE = 'TestRef';

  @TestSetup
  static void createTestData() {
    List<Quality_Assessment__c> qaList = new List<Quality_Assessment__c>();

    Quality_Assessment__c qa = new Quality_Assessment__c();
    qa.Evaluation_Type__c = EV_TYPE_FRAUD;
    qa.Join_Actions_Taken__c = OUTSTANDING_RATING; //12.5
    qa.Join_Blocks_Applied_where_Appropriate__c = OUTSTANDING_RATING; //25
    qa.Join_Case_Data_Field_Accuracy__c = OUTSTANDING_RATING; //12.5
    qa.Join_Case_Record_Accuracy__c = OUTSTANDING_RATING; //12.5
    qa.Join_Financial_Operation_Accuracy__c = OUTSTANDING_RATING; //12.5
    qa.Join_Overall_Decision_Supported__c = OUTSTANDING_RATING; //25
    qa.RecordTypeId = GetHelpConstants.QUALITY_ASSESSMENT_JOIN_RT_ID;
    qa.Reference__c = REFERENCE_VALUE;
    qaList.add(qa);

    Quality_Assessment__c qa1 = new Quality_Assessment__c();
    qa1.Evaluation_Type__c = EV_TYPE_INTERACTION;
    qa1.Interaction_Type__c = 'Chat';
    qa1.Join_Business_Actions_Taken__c = ALMOST_THERE; //7.5
    qa1.Join_Business_Case_Record__c = ALMOST_THERE; //7.5
    qa1.Join_Business_Information__c = ALMOST_THERE; //7.5
    qa1.Join_Customer_Accountable__c = ALMOST_THERE; //7.5
    qa1.Join_Customer_Caring__c = NOT_QUITE_THERE; //5.0
    qa1.Join_Customer_Interested__c = NOT_QUITE_THERE; //5.0
    qa1.Join_Customer_Respect__c = NOT_QUITE_THERE; //5.0
    qa1.Join_Customer_Welcoming__c = NOT_QUITE_THERE; //5.0
    qa1.Join_Compliance_Behaviour__c = EFFECTIVE;
    qa1.Join_Compliance_Disclaimers__c = EFFECTIVE;
    qa1.Join_Compliance_Identification__c = EFFECTIVE;
    qa1.Join_Compliance_Information__c = EFFECTIVE;
    qa1.RecordTypeId = GetHelpConstants.QUALITY_ASSESSMENT_JOIN_RT_ID;
    qa1.Reference__c = REFERENCE_VALUE;
    qaList.add(qa1);

    Quality_Assessment__c qa2 = new Quality_Assessment__c();
    qa2.Evaluation_Type__c = EV_TYPE_INTERACTION;
    qa2.Interaction_Type__c = 'Chat';
    qa2.Join_Business_Actions_Taken__c = ALMOST_THERE; //7.5
    qa2.Join_Business_Case_Record__c = ALMOST_THERE; //7.5
    qa2.Join_Business_Information__c = ALMOST_THERE; //7.5
    qa2.Join_Customer_Accountable__c = ALMOST_THERE; //7.5
    qa2.Join_Customer_Caring__c = NOT_QUITE_THERE; //5.0
    qa2.Join_Customer_Interested__c = NOT_QUITE_THERE; //5.0
    qa2.Join_Customer_Respect__c = NOT_QUITE_THERE; //5.0
    qa2.Join_Customer_Welcoming__c = NOT_QUITE_THERE; //5.0
    qa2.Join_Compliance_Behaviour__c = EFFECTIVE;
    qa2.Join_Compliance_Disclaimers__c = NOT_QUITE_THERE;
    qa2.Join_Compliance_Identification__c = EFFECTIVE;
    qa2.Join_Compliance_Information__c = EFFECTIVE;
    qa2.RecordTypeId = GetHelpConstants.QUALITY_ASSESSMENT_JOIN_RT_ID;
    qa2.Reference__c = REFERENCE_VALUE;
    qaList.add(qa2);

    Quality_Assessment__c qa3 = new Quality_Assessment__c();
    qa3.Evaluation_Type__c = EV_TYPE_IDENTITY;
    qa3.Join_Actions_Taken__c = OUTSTANDING_RATING; //14.0
    qa3.Join_Blocks_Applied_where_Appropriate__c = EFFECTIVE; //23.2
    qa3.Join_Case_Data_Field_Accuracy__c = OUTSTANDING_RATING; //14
    qa3.Join_Case_Record_Accuracy__c = OUTSTANDING_RATING; //14
    qa3.Join_Overall_Decision_Supported__c = EFFECTIVE; //23.2
    qa3.RecordTypeId = GetHelpConstants.QUALITY_ASSESSMENT_JOIN_RT_ID;
    qa3.Reference__c = REFERENCE_VALUE;
    qaList.add(qa3);
    insert qaList;
  }

  /*
    WHEN Compliance Disclaimers is Effective THEN the compliance outcome is Requirements met else
    its Requirements not met
  */

  @isTest
  static void testJoinComplianceOutcome() {
    Id joinRecordTypeId = GetHelpConstants.QUALITY_ASSESSMENT_JOIN_RT_ID;
    Test.startTest();
    List<Quality_Assessment__c> qaList = [
      SELECT Id, Join_Compliance_Disclaimers__c
      FROM Quality_Assessment__c
      WHERE
        RecordTypeId = :joinRecordTypeId
        AND Evaluation_Type__c = :EV_TYPE_INTERACTION
    ];

    CalculateQARatingandAssessment.calculateQA(qaList[0].Id);
    CalculateQARatingandAssessment.calculateQA(qaList[1].Id);
    Test.stopTest();
    List<Quality_Assessment__c> qaListAfterCalc = [
      SELECT
        Id,
        Join_Compliance_Disclaimers__c,
        Compliance_Outcome__c,
        Calculated__c
      FROM Quality_Assessment__c
      WHERE
        RecordTypeId = :joinRecordTypeId
        AND Evaluation_Type__c = :EV_TYPE_INTERACTION
    ];
    for (Quality_Assessment__c qa : qaListAfterCalc) {
      if (qa.Join_Compliance_Disclaimers__c == EFFECTIVE) {
        System.assertEquals(
          REQUIREMENTS_MET,
          qa.Compliance_Outcome__c,
          'Compliance Outcome should be Requirements met'
        );
      } else {
        System.assertEquals(
          REQUIREMENTS_NOT_MET,
          qa.Compliance_Outcome__c,
          'Compliance Outcome should be Requirements not met'
        );
      }
    }
  }

  /*
  WHEN the Score is >= 92 then the Rating should be updated as Exceeded expectations
  */

  @isTest
  static void testJoinScoreAndRatingExceedExpectations() {
    Quality_Assessment__c qa = [
      SELECT Id
      FROM Quality_Assessment__c
      WHERE
        RecordTypeId = :GetHelpConstants.QUALITY_ASSESSMENT_JOIN_RT_ID
        AND Evaluation_Type__c = :EV_TYPE_FRAUD
    ];
    Test.startTest();
    CalculateQARatingandAssessment.calculateQA(qa.Id);
    Test.stopTest();
    Quality_Assessment__c updatedQA = [
      SELECT Id, Score__c, Rating__c, Calculated__c
      FROM Quality_Assessment__c
      WHERE Id = :qa.Id
    ];

    System.assertEquals(
      100.0,
      UpdatedQA.Score__c,
      'Exceeded Expectations Score Calculation Error.'
    );
    System.assertEquals(
      EXCEED_RATING,
      UpdatedQA.Rating__c,
      'Exceeded Expectations Rating Calculation Error.'
    );
  }

  /*
  WHEN the Score is > 85 AND  < 92 then the Rating should be updated as Met expectations
  */

  @isTest
  static void testJoinScoreAndRatingMetExpectations() {
    Quality_Assessment__c qa = [
      SELECT Id
      FROM Quality_Assessment__c
      WHERE
        RecordTypeId = :GetHelpConstants.QUALITY_ASSESSMENT_JOIN_RT_ID
        AND Evaluation_Type__c = :EV_TYPE_IDENTITY
    ];
    Test.startTest();
    CalculateQARatingandAssessment.calculateQA(qa.Id);
    Test.stopTest();
    Quality_Assessment__c updatedQA = [
      SELECT Id, Score__c, Rating__c, Calculated__c
      FROM Quality_Assessment__c
      WHERE Id = :qa.Id
    ];

    System.assertEquals(
      88.4,
      UpdatedQA.Score__c,
      'Join Identity Score Calculation Error.'
    );
    System.assertEquals(
      MET_RATING,
      UpdatedQA.Rating__c,
      'Join Identity Rating Calculation Error.'
    );
  }

  /*
  WHEN the Score is <= 85 then the Rating should be updated as Did not meet expectations
  */

  @isTest
  static void testJoinScoreAndRatingDidNotMetExpectations() {
    Quality_Assessment__c qa = [
      SELECT Id
      FROM Quality_Assessment__c
      WHERE
        RecordTypeId = :GetHelpConstants.QUALITY_ASSESSMENT_JOIN_RT_ID
        AND Evaluation_Type__c = :EV_TYPE_INTERACTION
      LIMIT 1
    ];
    Test.startTest();
    CalculateQARatingandAssessment.calculateQA(qa.Id);
    Test.stopTest();
    Quality_Assessment__c updatedQA = [
      SELECT Id, Score__c, Rating__c, Calculated__c
      FROM Quality_Assessment__c
      WHERE Id = :qa.Id
    ];

    System.assertEquals(
      50.0,
      UpdatedQA.Score__c,
      'Join Interaction Score Calculation Error.'
    );
    System.assertEquals(
      NOT_MET_RATING,
      UpdatedQA.Rating__c,
      'Join Interaction Rating Calculation Error.'
    );
  }
}

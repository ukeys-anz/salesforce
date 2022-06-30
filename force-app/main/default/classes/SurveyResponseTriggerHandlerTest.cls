/**
 *
 * @author Jasmine Nguyen
 * @since 03/2022
 * @description Test class for @link SurveyResponseTriggerHandler
 */
@isTest
public with sharing class SurveyResponseTriggerHandlerTest {
  private static final String OCV_ID_1 = 'QUnLJCCEhB0';
  private static final String OCV_ID_2 = 'ACkdd7292';

  @TestSetup
  static void makeData() {
    Faker faker = new Faker('AU');

    Account accnt = new Account();
    accnt.Name = 'TestAccount';
    accnt.Display_Name__c = 'TestAccount';
    accnt.OCV_ID__c = OCV_ID_1;
    accnt.ANZx_Customer__c = true;
    accnt.External_Id__c = faker.randomString(10);

    insert accnt;

    User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(currentUser) {
      // Create a Qualtrics Integration User
      Profile integrationUserProfile = CommonUtil.getProfileByName(
        'Integration User (External Apps)'
      );
      UserRole anzxRole = CommonUtil.getUserRoleByDevName('ANZx');
      User qualtricsIntegrationUser = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'Qualtrics_Intergration_User',
          'ProfileId' => integrationUserProfile.Id,
          'UserRoleId' => anzxRole.Id
        }
      );
      insert qualtricsIntegrationUser;

      // Add PAM related object permissions on test user
      List<PermissionSetAssignment> psAssigments = new List<PermissionSetAssignment>();
      PermissionSet customerFeedbackPS = CommonUtil.getPermissionSetByName(
        'Customer_Feedback_Read_Write'
      );
      psAssigments.add(
        TestUtil.createPSAssignment(
          qualtricsIntegrationUser.id,
          customerFeedbackPS.Id
        )
      );
      PermissionSet casePS = CommonUtil.getPermissionSetByName(
        'Case_Read_Write_Qualtrics_Integration'
      );
      psAssigments.add(
        TestUtil.createPSAssignment(qualtricsIntegrationUser.id, casePS.Id)
      );
      insert psAssigments;
    }
  }

  @isTest
  static void testSurveyResponseMatchingWithValidOCVID() {
    User qualtricsIntegrationUser = [
      SELECT Id
      FROM User
      WHERE Firstname = 'Qualtrics_Intergration_User'
    ];
    System.runAs(qualtricsIntegrationUser) {
      // Run as Qualtrics Integration User as the matching logic will be executed by this user in reality
      qualtrics__Survey_Response__c sr = new qualtrics__Survey_Response__c();
      sr.OCV_ID__c = OCV_ID_1;
      sr.qualtrics__Net_Promoter_Score__c = 2;
      sr.Customer_Feedback__c = 'Customer Feedback';
      sr.Other_Feedback__c = 'Some other feedback';
      sr.qualtrics__Overall_Satisfaction__c = 'Satisfied';

      Test.startTest();
      insert sr;
      Test.stopTest();

      Account acc = [
        SELECT Id
        FROM Account
        WHERE OCV_ID__c = :OCV_ID_1
        LIMIT 1
      ];
      qualtrics__Survey_Response__c surveyRes = [
        SELECT qualtrics__Account__c
        FROM qualtrics__Survey_Response__c
        WHERE OCV_ID__c = :OCV_ID_1
        LIMIT 1
      ];
      System.assertEquals(
        acc.Id,
        surveyRes.qualtrics__Account__c,
        'Account Id should match.'
      );
    }
  }

  @isTest
  static void testSurveyResponseMatchingWithInvalidOCVID() {
    User qualtricsIntegrationUser = [
      SELECT Id
      FROM User
      WHERE Firstname = 'Qualtrics_Intergration_User'
    ];
    System.runAs(qualtricsIntegrationUser) {
      // Run as Qualtrics Integration User as the matching logic will be executed by this user in reality
      qualtrics__Survey_Response__c sr = new qualtrics__Survey_Response__c();
      sr.OCV_ID__c = '98765';
      sr.qualtrics__Net_Promoter_Score__c = 2;
      sr.Customer_Feedback__c = 'Customer Feedback';
      sr.Other_Feedback__c = 'Some other feedback';
      sr.qualtrics__Overall_Satisfaction__c = 'Satisfied';

      Test.startTest();
      try {
        insert sr;
        System.assert(
          false,
          'Failed to prevent against user creating qualtrics survey response.'
        );
      } catch (DmlException e) {
        System.assertEquals(
          true,
          e.getMessage().contains(SurveyResponseActions.INVALID_OCV_ID_ERROR),
          'Error message should match'
        );
      }
      Test.stopTest();

      System.assertEquals(
        0,
        [SELECT qualtrics__Account__c FROM qualtrics__Survey_Response__c]
          .size(),
        'Survey Response should not have been inserted.'
      );
    }
  }

  @isTest
  static void testBuildCaseFromSurveyResponse() {
    List<qualtrics__Survey_Response__c> responsesRequireCase = new List<qualtrics__Survey_Response__c>();

    Faker faker = new Faker('AU');
    Account accnt = new Account();
    accnt.Name = 'TestAccount2';
    accnt.Display_Name__c = 'TestAccount2';
    accnt.OCV_ID__c = OCV_ID_2;
    accnt.ANZx_Customer__c = true;
    accnt.External_Id__c = faker.randomString(10);

    insert accnt;

    Account accnt1 = [SELECT Id FROM Account WHERE OCV_ID__c = :OCV_ID_1];
    qualtrics__Survey_Response__c sr1 = new qualtrics__Survey_Response__c();
    sr1.qualtrics__Account__c = accnt1.Id;
    sr1.Alerting_Reason__c = 'Test alerting reason - 1';
    sr1.qualtrics__Net_Promoter_Score__c = 2;
    sr1.Customer_Feedback__c = 'Customer Feedback - 1';
    responsesRequireCase.add(sr1);

    Account accnt2 = [SELECT Id FROM Account WHERE OCV_ID__c = :OCV_ID_2];
    qualtrics__Survey_Response__c sr2 = new qualtrics__Survey_Response__c();
    sr2.qualtrics__Account__c = accnt2.Id;
    sr2.Alerting_Reason__c = 'Test alerting reason - 2';
    sr2.qualtrics__Net_Promoter_Score__c = 4;
    sr2.Customer_Feedback__c = 'Customer Feedback - 2';
    responsesRequireCase.add(sr2);

    insert responsesRequireCase;

    Map<Id, Account> accountsMap = new Map<Id, Account>(
      [
        SELECT Id, PersonContactId
        FROM Account
        WHERE OCV_ID__c = :OCV_ID_1 OR OCV_ID__c = :OCV_ID_2
      ]
    );

    Test.startTest();
    List<Case> returnedCases = SurveyResponseActionsHelper.buildCaseList(
      accountsMap,
      responsesRequireCase
    );
    Test.stopTest();

    System.assertEquals(
      2,
      returnedCases.size(),
      '2 cases should have been returned'
    );

    assertCaseFields(accnt1.Id, sr1, returnedCases[0]);
    assertCaseFields(accnt2.Id, sr2, returnedCases[1]);
  }

  @isTest
  static void testCreateCaseForSurveyResponseCaseRequired() {
    User qualtricsIntegrationUser = [
      SELECT Id
      FROM User
      WHERE Firstname = 'Qualtrics_Intergration_User'
    ];
    System.runAs(qualtricsIntegrationUser) {
      // Run as Qualtrics Integration User as the matching logic will be executed by this user in reality
      qualtrics__Survey_Response__c sr = new qualtrics__Survey_Response__c();
      sr.OCV_ID__c = OCV_ID_1;
      sr.qualtrics__Net_Promoter_Score__c = 2;
      sr.Customer_Feedback__c = 'Customer Feedback';
      sr.Other_Feedback__c = 'Some other feedback';
      sr.qualtrics__Overall_Satisfaction__c = 'Satisfied';
      sr.Alerting_Reason__c = 'Some alerting reason';
      sr.Create_Case__c = true;

      Test.startTest();
      insert sr;
      Test.stopTest();

      List<Case> cases = [
        SELECT
          Id,
          AccountId,
          Advocacy_Score__c,
          Alerting_Reason__c,
          Description,
          OwnerId,
          Priority,
          Subject,
          Survey_Response__c
        FROM Case
        WHERE Alerting_Reason__c = 'Some alerting reason'
      ];

      System.assertEquals(1, cases.size(), 'Case should have been inserted');
      Account acc = [SELECT Id FROM Account WHERE OCV_ID__c = :OCV_ID_1];

      assertCaseFields(acc.Id, sr, cases[0]);
    }
  }

  @isTest
  static void testCreateCaseForSurveyResponseCaseNotRequired() {
    User qualtricsIntegrationUser = [
      SELECT Id
      FROM User
      WHERE Firstname = 'Qualtrics_Intergration_User'
    ];
    System.runAs(qualtricsIntegrationUser) {
      // Run as Qualtrics Integration User as the matching logic will be executed by this user in reality
      qualtrics__Survey_Response__c sr = new qualtrics__Survey_Response__c();
      sr.OCV_ID__c = OCV_ID_1;
      sr.qualtrics__Net_Promoter_Score__c = 2;
      sr.Customer_Feedback__c = 'Customer Feedback';
      sr.Other_Feedback__c = 'Some other feedback';
      sr.qualtrics__Overall_Satisfaction__c = 'Satisfied';
      sr.Alerting_Reason__c = 'Some alerting reason';
      sr.Create_Case__c = false;

      Test.startTest();
      insert sr;
      Test.stopTest();

      List<Case> cases = [
        SELECT Id
        FROM Case
        WHERE Alerting_Reason__c = 'Some alerting reason'
      ];

      System.assertEquals(
        0,
        cases.size(),
        'Case should not have been inserted'
      );
    }
  }

  private static void assertCaseFields(
    String accountId,
    qualtrics__Survey_Response__c surveyResponse,
    Case caseRec
  ) {
    System.assertEquals(
      accountId,
      caseRec.AccountId,
      'Account Id should match.'
    );
    System.assertEquals(
      surveyResponse.Alerting_Reason__c,
      caseRec.Alerting_Reason__c,
      'Alerting reason should match.'
    );
    System.assertEquals(
      surveyResponse.qualtrics__Net_Promoter_Score__c,
      caseRec.Advocacy_Score__c,
      'Advocacy score should match.'
    );
    System.assertEquals(
      surveyResponse.Customer_Feedback__c,
      caseRec.Description,
      'Description should match.'
    );
    System.assertEquals(
      surveyResponse.id,
      caseRec.Survey_Response__c,
      'Survey response Id should match.'
    );
    System.assertEquals('Medium', caseRec.Priority, 'Priority should match.');
    System.assertEquals(
      SurveyResponseActionsHelper.coachQueue.Id,
      caseRec.OwnerId,
      'Owner Id should match.'
    );
    System.assertEquals(
      surveyResponse.Alerting_Reason__c +
      ' - ' +
      SurveyResponseActionsHelper.feedbackType,
      caseRec.Subject,
      'Subject should match.'
    );
  }
}

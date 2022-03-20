/**
 *
 * @author Jasmine Nguyen
 * @since 03/2022
 * @description Test class for @link SurveyResponseTriggerHandler
 */
@isTest
public with sharing class SurveyResponseTriggerHandlerTest {
  @TestSetup
  static void makeData() {
    Faker faker = new Faker('AU');

    Account accnt = new Account();
    accnt.Name = 'TestAccount';
    accnt.Display_Name__c = 'TestAccount';
    accnt.OCV_ID__c = 'QUnLJCCEhB0';
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
      sr.OCV_ID__c = 'QUnLJCCEhB0';
      sr.qualtrics__Net_Promoter_Score__c = 2;
      sr.qualtrics__Description__c = 'Customer Feedback';
      sr.qualtrics__Other_Feedback__c = 'Some other feedback';
      sr.qualtrics__Overall_Satisfaction__c = 'Satisfied';

      Test.startTest();
      insert sr;
      Test.stopTest();

      Account acc = [
        SELECT Id
        FROM Account
        WHERE OCV_ID__c = 'QUnLJCCEhB0'
        LIMIT 1
      ];
      qualtrics__Survey_Response__c surveyRes = [
        SELECT qualtrics__Account__c
        FROM qualtrics__Survey_Response__c
        WHERE OCV_ID__c = 'QUnLJCCEhB0'
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
      sr.qualtrics__Description__c = 'Customer Feedback';
      sr.qualtrics__Other_Feedback__c = 'Some other feedback';
      sr.qualtrics__Overall_Satisfaction__c = 'Satisfied';

      Test.startTest();
      try {
        insert sr;
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
}

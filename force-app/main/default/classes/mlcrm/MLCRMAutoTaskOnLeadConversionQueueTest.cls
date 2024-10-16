/**
 * @author Ankit Garg
 * @since July 2023
 * @description test class for MLCRMAutoTaskOnLeadConversionQueueable
 * @group Service
 */
@isTest
public with sharing class MLCRMAutoTaskOnLeadConversionQueueTest {
  @TestSetup
  static void setup() {
    User mlBusinessAdminUser = MLCRMTestDataFactory.createMLBusinessAdminUser();
    User mlUser = MLCRMTestDataFactory.createMLCRMBaseUser();
    User adminUser = MLCRMTestDataFactory.getAdminUser(); //user to insert Account sharing records
    System.runAs(CCRMTestDataFactory.createOCVIntegrationUser()) {
      Faker faker = new Faker('AU');
      Account testAccount = new Account(
        LastName = 'Test Account',
        OCV_ID__c = faker.randomString(10),
        ANZx_Customer__c = false,
        OCV_Event_Version__c = 1,
        RecordTypeId = CCRMConstants.ACCOUNT_PERSON_RT_ID
      );
      insert testAccount;
    }
    System.runAs(mlBusinessAdminUser) {
      Territory__c territoryRecord = MLCRMTestDataFactory.createTerritoryRecords(
        1,
        mlBusinessAdminUser,
        true
      )[0];
      Territory__Share objShare = new Territory__Share();
      objShare.parentId = territoryRecord.Id;
      objShare.accesslevel = 'Edit';
      objShare.userOrgroupid = mlUser.Id;
      insert objShare;
    }
    //update ml user record so that user trigger creates corresponding user territory record
    System.runAs(MLCRMTestDataFactory.createIIQBaseUser()) {
      Test.startTest();
      mlUser.ML_Territories__c = 'Melbourne CBD (VIC)';
      mlUser.ML_Role__c = 'Loan Writer';
      update mlUser;
      Test.stopTest();
    }
    System.runAs(mlUser) {
      Lead leadRec = MLCRMTestDataFactory.createManualLeadRecords(
        1,
        mlUser,
        false
      )[0];
      leadRec.Is_Valid_Address__c = true;
      leadRec.Gender__c = 'M';
      leadRec.Home_Phone__c = '+61533333333';
      leadRec.MobilePhone = '+61533333333';
      leadRec.Work_Phone__c = '+61533333333';
      leadRec.Street = 'Str 123';
      leadRec.City = 'City 123';
      leadRec.Country = 'Australia';
      leadRec.State = 'State 123';
      leadRec.PostalCode = '123';
      insert leadRec;
    }

    System.runAs(adminUser) {
      Account objAcc = [SELECT Id FROM Account LIMIT 1];
      AccountShare objShare = new AccountShare();
      objShare.AccountId = objAcc.Id;
      objShare.Accountaccesslevel = 'Edit';
      objShare.OpportunityAccessLevel = 'Read';
      objShare.userOrgroupid = mlUser.Id;
      insert objShare;
    }

  }

  @IsTest
  static void autoTaskOnLeadConversionQueueTest() {
    User mlUser = [
      SELECT Id
      FROM User
      WHERE LastName = 'MLCRM' AND IsActive = TRUE
    ];
    System.runAs(mlUser) {
      Account testAccount = [
        SELECT id
        FROM Account
        WHERE LastName = 'Test Account'
        LIMIT 1
      ];
      Lead record = [SELECT id FROM Lead LIMIT 1];
      record.FinServ__RelatedAccount__c = testAccount.id;
      record.Expiry_Date__c = DateTimeUtils.getWeekday(
        system.today().addDays(1),
        true,
        true
      );
      update record;
      CCRMLeadConversion.LeadConversionWrapper leadWrapper = CCRMLeadConversion.getLeadRecordForConversion(
        record.id
      );
      record = leadWrapper.leadRecord;
      Test.startTest();
      AccountCommonActions.findAndConvertCCRMLead(testAccount.id, record);
      Test.stopTest();
      // THEN the task has been created against the opportunity.
      Task taskRecord = [
        SELECT Id, Subject, Description
        FROM Task
        WHERE recordtypeId = :MLCRMConstants.MLCRM_TASK_RT_ID
        LIMIT 1
      ];
      System.assertEquals(
        Label.MLCRM_Auto_Task_MistMatch_Subject,
        taskRecord.Subject,
        'Mismatched task not created.'
      );
      System.assert(
        taskRecord.Description.contains('First Name'),
        'First Name is matched.'
      );
      System.assert(
        !taskRecord.Description.contains('Middle Name'),
        'Middle Name is not matched.'
      );
      System.assert(
        taskRecord.Description.contains('Last Name'),
        'Last Name is matched.'
      );
      System.assert(
        taskRecord.Description.contains('Home Phone'),
        'Home Phone is matched.'
      );
      System.assert(
        taskRecord.Description.contains('Work Phone'),
        'Work Phone is matched.'
      );
      System.assert(
        taskRecord.Description.contains('Mobile Phone'),
        'Mobile Phone is matched.'
      );
      System.assert(
        taskRecord.Description.contains('Email'),
        'Email is matched.'
      );
      System.assert(
        taskRecord.Description.contains('Street'),
        'Street is matched.'
      );
      System.assert(
        taskRecord.Description.contains('City'),
        'City is matched.'
      );
      System.assert(
        taskRecord.Description.contains('State'),
        'State is matched.'
      );
      System.assert(
        taskRecord.Description.contains('Country'),
        'Country is matched.'
      );
      System.assert(
        taskRecord.Description.contains('Postal Code'),
        'Postal Code is matched.'
      );
      System.assert(
        taskRecord.Description.contains('Advertising Indicator'),
        'Advertising Indicator is not matched.'
      );
    }
  }
}

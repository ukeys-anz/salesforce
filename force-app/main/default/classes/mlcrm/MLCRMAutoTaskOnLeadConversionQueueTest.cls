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
    User mlUser = MLCRMTestDataFactory.createMLCRMBaseUser();
    System.runAs(mlUser) {
      List<Territory__c> lstOfTerritory = MLCRMTestDataFactory.createTerritoryRecords(
        1,
        mlUser,
        true
      );
      MLCRMTestDataFactory.createUserTerritoryRecords(
        1,
        mlUser.Id,
        lstOfTerritory[0].Id
      );
    }
    System.runAs(mlUser) {
      Lead leadRec = (Lead) FakerFactory.make(new FakerLeadFactory());
      leadRec.Is_Valid_Address__c = true;
      leadRec.Gender__c = 'M';
      leadRec.Home_Phone__c = '+61533333333';
      leadRec.MobilePhone = '+61533333333';
      leadRec.Work_Phone__c = '+61533333333';
      insert leadRec;
    }
  }

  @IsTest
  static void findAndConvertLeadCCRMTest() {
    System.runAs(MLCRMTestDataFactory.createAdminUser()) {
      Id adminProfileId = CommonUtil.getProfileByName('System Administrator')
        .Id;
      USER usr = (USER) FakerFactory.make(new FakerUserFactory());
      usr.Email = 'test@mltest.anz.com';
      usr.ProfileId = adminProfileId;
      usr.UserRoleId = CommonUtil.getUserRoleByDevName('Banker').Id;
      insert usr;
      Faker faker = new Faker('AU');
      Account testAccount = new Account(
        Name = 'Test Account',
        OCV_ID__c = faker.randomString(10),
        ANZx_Customer__c = false,
        OCV_Event_Version__c = 1
      );
      insert testAccount;
      Lead record = [SELECT id FROM Lead LIMIT 1];
      record.FinServ__RelatedAccount__c = testAccount.id;
      update record;
      CCRMLeadConversion.LeadConversionWrapper leadWrapper = CCRMLeadConversion.getLeadRecordForConversion(
        record.id
      );
      record = leadWrapper.leadRecord;

      Test.startTest();
      AccountCommonActions.findAndConvertCCRMLead(testAccount.id, record);
      Test.stopTest();
      // THEN the existing lead is converted into this account
      Lead l = [SELECT Id, Status FROM Lead WHERE id = :record.Id LIMIT 1];
      System.assertEquals(
        'Converted',
        l.Status,
        'Lead should have been converted.'
      );
    }
  }
}

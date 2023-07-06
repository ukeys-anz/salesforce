/**
 * @author Mairaj Haider
 * @since 06/2022
 * @description CCRM Legal Entity Action Test is the test class for CCRM Legal Entity Actions Class.
 */
@isTest
public with sharing class CCRMLegalEntityActionsTest {
  public static final String KYC_STATUS = 'Completed - Valid';
  public static final String ACCOUNT_STATUS = 'Active';
  static User ccrmUser = CCRMTestDataFactory.createCCRMBaseUser();

  @isTest
  static void testLegalEntitiWithCorrectAccountShouldPass() {
    Integer count = 1;
    System.runAs(ccrmUser) {
      //GIVEN
      List<Legal_Entity__c> entitiesList = CCRMTestDataFactory.createLegalEntities(
        count
      );

      //WHEN
      insert entitiesList;

      //THEN
      List<Legal_Entity__c> entitiesCreated = [SELECT ID FROM Legal_Entity__c];
      System.assertEquals(
        entitiesCreated.size(),
        count,
        'Entity created successfully.'
      );
    }
  }

  @isTest
  static void testLegalEntityWithIncorrectAccountShouldFail() {
    Faker faker = new Faker('AU');
    System.runAs(ccrmUser) {
      //GIVEN
      Integer count = 1;
      List<Legal_Entity__c> entitiesList = CCRMTestDataFactory.createLegalEntities(
        count
      );
      Account account = new Account();
      account.Name = faker.person.firstName();
      account.OCV_ID__c = 'OCv1234';
      insert account;
      entitiesList[0].Account__c = account.Id;

      //WHEN
      try {
        insert entitiesList;
      } catch (Exception ex) {
        //THEN
        if (
          ex.getMessage()
            .contains(CCRMLegalEntityActions.INCORRECT_ACCOUNT_ON_LEGAL_ENTITY)
        ) {
          System.assert(true, 'Error message displayed');
        } else {
          System.assert(false, 'Incorrect error message');
        }
      }
    }
  }

  @isTest
  static void testLegalEntityCreatedWithOpportunityId() {
    System.runAs(ccrmUser) {
      //GIVEN
      Integer count = 1;
      List<Legal_Entity__c> entitiesList = CCRMTestDataFactory.createLegalEntities(
        count
      );

      //WHEN
      Test.startTest();
      insert entitiesList;
      Test.stopTest();

      //THEN
      List<Legal_Entity__c> entitiesCreated = [
        SELECT ID, Opportunity_Id__c
        FROM Legal_Entity__c
      ];
      System.assertEquals(
        entitiesCreated.size(),
        count,
        'Entity created successfully.'
      );
      System.assertNotEquals(
        entitiesCreated[0].Opportunity_Id__c,
        null,
        'Entity created with Opportunity Id.'
      );
    }
  }

  @isTest
  static void testOpportunityAccountUpdateWithSingleEntity() {
    System.runAs(ccrmUser) {
      //GIVEN
      List<Opportunity> opps = CCRMTestDataFactory.createOpportunityRecords(
        1,
        null
      );

      OpportunityLineItem oli = CCRMTestDataFactory.createOpportunityLineItem();
      insert oli;

      Legal_Entity__c entity = new Legal_Entity__c();
      entity.Account__c = opps[0].AccountId;
      entity.Opportunity_Product__c = oli.Id;

      //WHEN
      Test.startTest();
      insert entity;
      Test.stopTest();

      //THEN
      Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
      Legal_Entity__c entityCreated = [
        SELECT Id, Account__c
        FROM Legal_Entity__c
        LIMIT 1
      ];
      System.assertEquals(
        entityCreated.Account__c,
        opp.AccountId,
        'Single Entity created with same account as Opportunity'
      );
    }
  }

  @isTest
  static void testOpportunityAccountUpdateWithMultipleEntities() {
    FinServ__ReciprocalRole__c role = new FinServ__ReciprocalRole__c();
    Faker faker = new Faker('AU');
    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      //GIVEN
      role = CCRMTestDataFactory.createReciprocalRole('CG', 'INVCG');
      Test.startTest();
      //Account 2
      Account firstAccount = new Account();
      firstAccount.Name = faker.person.firstName();
      firstAccount.OCV_ID__c = 'OCV7860';
      firstAccount.FinServ__KYCStatus__c = KYC_STATUS;
      firstAccount.FinServ__Status__c = ACCOUNT_STATUS;
      firstAccount.RecordTypeId = CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID;
      insert firstAccount;

      //Create CLG Account
      Account clgAccount = CCRMTestDataFactory.createClgAccount();

      //Associate CLG Account to account on opportunity
      CCRMTestDataFactory.createAccountToAccountWithClgRelationship(
        firstAccount.Id,
        clgAccount.Id,
        role.Id
      );

      //Create Opportunity
      Opportunity objOpportunity = new Opportunity();
      objOpportunity.Name = faker.person.firstName();
      objOpportunity.Accountid = firstAccount.id;
      objOpportunity.StageName = 'Prospecting';
      objOpportunity.CloseDate = system.Today() + 3;
      objOpportunity.Description = faker.text.realText(10, 20);
      objOpportunity.RecordTypeId = CCRMConstants.CCRM_OPP_RT_ID;
      insert objOpportunity;

      OpportunityLineItem oli = CCRMTestDataFactory.createOpportunityLineItem();
      oli.OpportunityId = objOpportunity.id;
      insert oli;

      //Create First Entity using account on opportunity
      Legal_Entity__c entity1 = new Legal_Entity__c();
      entity1.Account__c = firstAccount.Id;
      entity1.Opportunity_Product__c = oli.Id;
      insert entity1;

      //Second Account
      Account secondAccount = new Account();
      secondAccount.Name = faker.person.firstName();
      secondAccount.OCV_ID__c = 'OCV78601';
      secondAccount.FinServ__KYCStatus__c = KYC_STATUS;
      secondAccount.FinServ__Status__c = ACCOUNT_STATUS;
      secondAccount.RecordTypeId = CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID;
      insert secondAccount;

      //Associate CLG Account to new account
      CCRMTestDataFactory.createAccountToAccountWithClgRelationship(
        secondAccount.Id,
        clgAccount.Id,
        role.Id
      );

      //Create Second Entity using new account associated to same CLG account to which account on opportunity is associated
      Legal_Entity__c entity2 = new Legal_Entity__c();
      entity2.Account__c = secondAccount.Id;
      entity2.Opportunity_Product__c = oli.Id;

      //WHEN
      insert entity2;
      Test.stopTest();

      //THEN
      Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
      System.assertEquals(
        opp.AccountId,
        clgAccount.Id,
        'Opportunity account updated to CLG account.'
      );
    }
  }

  @isTest
  static void testFirstLegalEntityWithAccountNotMatchingOpportunityAccount() {
    FinServ__ReciprocalRole__c role = new FinServ__ReciprocalRole__c();
    Faker faker = new Faker('AU');
    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      //GIVEN
      role = CCRMTestDataFactory.createReciprocalRole('CG', 'INVCG');
      //Create Opportunity
      List<Opportunity> opps = CCRMTestDataFactory.createOpportunityRecords(
        1,
        null
      );
      //Create Opportunity product
      OpportunityLineItem oli = CCRMTestDataFactory.createOpportunityLineItem();
      insert oli;

      Test.startTest();
      //Account 2
      Account newAccount = new Account();
      newAccount.Name = faker.person.firstName();
      newAccount.OCV_ID__c = 'OCV7860';
      newAccount.FinServ__KYCStatus__c = KYC_STATUS;
      newAccount.FinServ__Status__c = ACCOUNT_STATUS;
      newAccount.RecordTypeId = CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID;
      insert newAccount;

      //Create First Entity using account on opportunity
      Legal_Entity__c entity1 = new Legal_Entity__c();
      entity1.Account__c = newAccount.Id;
      entity1.Opportunity_Product__c = oli.Id;

      //WHEN
      try {
        insert entity1;
      } catch (Exception ex) {
        System.Debug('ex message=' + ex.getMessage());
        System.Debug(
          'INCORRECT_ACCOUNT_ON_LEGAL_ENTITY=' +
          CCRMLegalEntityActions.INCORRECT_ACCOUNT_ON_LEGAL_ENTITY
        );
        //THEN
        if (
          ex.getMessage()
            .contains(CCRMLegalEntityActions.INCORRECT_ACCOUNT_ON_LEGAL_ENTITY)
        ) {
          System.assert(true, 'Error message displayed');
        } else {
          System.assert(false, 'Incorrect error message');
        }
      }
    }
  }
}

/**
 * @author Mairaj Haider
 * @since 06/2022
 * @description CCRM Legal Entity Action Test is the test class for CCRM Legal Entity Actions Class.
 */
@isTest
public with sharing class CCRMLegalEntityActionsTest {
  public static final String KYC_STATUS = 'Completed - Valid';
  public static final String ACCOUNT_STATUS = 'Active';

  @testSetup
  static void makeData() {
    User ccrmUser = CCRMTestDataFactory.createCCRMBaseUser();
    User ocvUser = CCRMTestDataFactory.getOcvIntegrationUser();
    Account secondAccount;
    Account clgAccount;
    Account firstAccount;
    FinServ__AccountAccountRelation__c actRela1;
    FinServ__AccountAccountRelation__c actRela2;
    System.runAs(ocvUser) {
      Faker faker = new Faker('AU');
      FinServ__ReciprocalRole__c role = new FinServ__ReciprocalRole__c();
      role = CCRMTestDataFactory.createReciprocalRole(
        'CG',
        'INVCG',
        CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
      );
      //Account 2
      firstAccount = new Account();
      firstAccount.Name = faker.person.firstName();
      firstAccount.OCV_ID__c = 'OCV7860';
      firstAccount.FinServ__KYCStatus__c = KYC_STATUS;
      firstAccount.FinServ__Status__c = ACCOUNT_STATUS;
      firstAccount.RecordTypeId = CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID;
      insert firstAccount;

      //Create CLG Account
      clgAccount = CCRMTestDataFactory.createClgAccount();

      //Associate CLG Account to account on opportunity
      actRela1 = CCRMTestDataFactory.createAccountToAccountWithClgRelationship(
        firstAccount.Id,
        clgAccount.Id,
        role.Id
      );

      secondAccount = new Account();
      secondAccount.Name = faker.person.firstName();
      secondAccount.OCV_ID__c = 'OCV78601';
      secondAccount.FinServ__KYCStatus__c = KYC_STATUS;
      secondAccount.FinServ__Status__c = ACCOUNT_STATUS;
      secondAccount.RecordTypeId = CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID;
      insert secondAccount;

      //Associate CLG Account to new account
      actRela2 = CCRMTestDataFactory.createAccountToAccountWithClgRelationship(
        secondAccount.Id,
        clgAccount.Id,
        role.Id
      );
    }
    CCRMTestDataFactory.createAccountAccountRelationShare(
      actRela1.Id,
      ccrmUser.Id
    );
    CCRMTestDataFactory.createAccountAccountRelationShare(
      actRela2.Id,
      ccrmUser.Id
    );
    CCRMTestDataFactory.createAccountShare(firstAccount.Id, ccrmUser.Id);
    CCRMTestDataFactory.createAccountShare(clgAccount.Id, ccrmUser.Id);
    CCRMTestDataFactory.createAccountShare(secondAccount.Id, ccrmUser.Id);
  }

  @isTest
  static void testLegalEntitiWithCorrectAccountShouldPass() {
    User ccrmUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
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
    User ccrmUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
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
    User ccrmUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
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
    User ccrmUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
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
    User ccrmUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    OpportunityLineItem oli;
    Account secondAccount;
    Account clgAccount;
    Account firstAccount;
    Opportunity objOpportunity;
    Faker faker = new Faker('AU');
    System.runAs(ccrmUser) {
      //GIVEN
      Test.startTest();
      firstAccount = [
        SELECT Id
        FROM Account
        WHERE OCV_ID__c = 'OCV7860'
        LIMIT 1
      ];
      clgAccount = [SELECT Id FROM Account WHERE OCV_ID__c = 'OCV7861' LIMIT 1];
      secondAccount = [
        SELECT Id
        FROM Account
        WHERE OCV_ID__c = 'OCV78601'
        LIMIT 1
      ];

      //Create Opportunity
      objOpportunity = new Opportunity();
      objOpportunity.Name = faker.person.firstName();
      objOpportunity.Accountid = firstAccount.id;
      objOpportunity.StageName = 'Opportunity Identified';
      objOpportunity.CloseDate = system.Today() + 3;
      objOpportunity.Description = faker.text.realText(10, 20);
      objOpportunity.RecordTypeId = CCRMConstants.CCRM_OPP_RT_ID;
      insert objOpportunity;

      oli = CCRMTestDataFactory.createOpportunityLineItem();
      oli.OpportunityId = objOpportunity.id;
      insert oli;

      //Create First Entity using account on opportunity
      Legal_Entity__c entity1 = new Legal_Entity__c();
      entity1.Account__c = firstAccount.Id;
      entity1.Opportunity_Product__c = oli.Id;
      insert entity1;

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
    User ccrmUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    Account newAccount;
    OpportunityLineItem oli;
    System.runAs(ccrmUser) {
      //GIVEN
      //Create Opportunity
      Test.startTest();
      List<Opportunity> opps = CCRMTestDataFactory.createOpportunityRecords(
        1,
        null
      );
      //Create Opportunity product
      oli = CCRMTestDataFactory.createOpportunityLineItem();
      insert oli;

      newAccount = [SELECT Id FROM Account WHERE OCV_ID__c = 'OCV7860' LIMIT 1];

      //Create First Entity using account on opportunity
      Legal_Entity__c entity1 = new Legal_Entity__c();
      entity1.Account__c = newAccount.Id;
      entity1.Opportunity_Product__c = oli.Id;
      Test.stopTest();
      //WHEN
      try {
        insert entity1;
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
}

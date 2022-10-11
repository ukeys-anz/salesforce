/**
 * @author Mairaj Haider
 * @since 06/2022
 * @description CCRM Legal Entity Action Test is the test class for CCRM Legal Entity Actions Class.
 */
@isTest
public with sharing class CCRMLegalEntityActionsTest {
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
    System.runAs(ccrmUser) {
      //GIVEN
      Integer count = 1;
      List<Legal_Entity__c> entitiesList = CCRMTestDataFactory.createLegalEntities(
        count
      );
      Account account = new Account();
      account.Name = 'Test Account';
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
            .contains(CCRMLegalEntityActions.INCORRECT_LEGAL_ENTITY)
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
      CCRMTestDataFactory.createOpportunityRecords(1, null);

      OpportunityLineItem oli = CCRMTestDataFactory.createOpportunityLineItem();
      insert oli;

      Account childAccount = [
        SELECT Id
        FROM Account
        WHERE RecordTypeId = :CCRMConstants.ACCOUNT_CLG_RT_ID
        LIMIT 1
      ];
      Legal_Entity__c entity = new Legal_Entity__c();
      entity.Account__c = childAccount.Id;
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
    System.runAs(ccrmUser) {
      //GIVEN
      //Create Opportunity
      CCRMTestDataFactory.createOpportunityRecords(1, null);
      //Create Opportunity product
      OpportunityLineItem oli = CCRMTestDataFactory.createOpportunityLineItem();
      insert oli;
      //Parent Account
      Account parentAccount = [
        SELECT Id
        FROM Account
        WHERE RecordTypeId = :CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID
        LIMIT 1
      ];
      //Child Account 1
      Account childAccount1 = [
        SELECT Id
        FROM Account
        WHERE RecordTypeId = :CCRMConstants.ACCOUNT_CLG_RT_ID
        LIMIT 1
      ];

      Test.startTest();
      //Child Account 2
      Account childAccount2 = new Account();
      childAccount2.Name = 'Child Account';
      childAccount2.OCV_ID__c = 'OCV7860';
      childAccount2.FinServ__KYCStatus__c = 'Completed - Valid';
      childAccount2.ParentId = parentAccount.Id;
      childAccount2.FinServ__Status__c = 'Active';
      insert childAccount2;

      //Create First Entity
      Legal_Entity__c entity1 = new Legal_Entity__c();
      entity1.Account__c = childAccount1.Id;
      entity1.Opportunity_Product__c = oli.Id;
      insert entity1;

      //Create Second Entity
      Legal_Entity__c entity2 = new Legal_Entity__c();
      entity2.Account__c = childAccount2.Id;
      entity2.Opportunity_Product__c = oli.Id;

      //WHEN
      insert entity2;
      Test.stopTest();

      //THEN
      Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];

      System.assertEquals(
        parentAccount.Id,
        opp.AccountId,
        'Opportunity account updated to parent account.'
      );
    }
  }

  @isTest
  static void testFirstLegalEntityWithAccountNotMatchingOpportunityAccount() {
    System.runAs(ccrmUser) {
      //GIVEN
      Integer count = 1;
      List<Legal_Entity__c> entitiesList = CCRMTestDataFactory.createLegalEntities(
        count
      );

      Account parentAccount = [
        SELECT Id
        FROM Account
        WHERE RecordTypeId = :CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID
        LIMIT 1
      ];

      Account childAccount = new Account();
      childAccount.Name = 'Incorrect Account';
      childAccount.OCV_ID__c = 'OCV12345';
      childAccount.ParentId = parentAccount.Id;
      insert childAccount;

      entitiesList[0].Account__c = childAccount.Id;

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
}

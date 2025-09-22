/**
 * @author MLCRM Developer
 * @since 08/2025
 * @description OpportunityContactRoleTriggerTest is the test class for MLOpportunityContactRoleTriggerHandler Class functionality.
 */
@isTest
public with sharing class OpportunityContactRoleTriggerTest {
  /**
   * @description test method for create OCR.
   * @Note : DML is needed in this method since we are writing trigger on OCR for first time and for trigger we need atleast 1% coverage.
   */
  @isTest
  static void testCreateOpportunityContactRole() {
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
        lstOfTerritory[0].id
      );

      Account objAcc = new Account(
        FirstName = 'Test',
        LastName = 'Test',
        Salutation = 'Mrs',
        External_Id__c = 'CAP-CIS_4011643101',
        OCV_Id__c = '1234',
        RecordTypeId = RTAccount.personAccount
      );

      insert objAcc;

      opportunity opp = new opportunity(
        AccountId = objAcc.Id,
        recordTypeId = RTOpportunity.mlOpportunity,
        Name = 'Test',
        StageName = 'Needs Analysis',
        Amount = 5000,
        Customer_Needs__c = 'Asset Finance',
        CloseDate = Date.today() + 5
      );

      insert opp;

      OpportunityContactRole ocr = [
        SELECT Id
        FROM OpportunityContactRole
        LIMIT 1
      ];

      Assert.areNotEqual(
        null,
        ocr.Id,
        'There is some issue while creating OCR record'
      );
    }

  }
}

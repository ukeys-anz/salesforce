/**
 * @author Ankit Garg
 * @since 20/July/2023
 * @description MLCRMOpportunityActionsTest is the test class for MLCRMOpportunityActions Class functionality.
 */
@isTest
public class MLCRMOpportunityActionsTest {
  @testSetup
  static void setup() {
    User mlUser = MLCRMTestDataFactory.createAdminUser();
    //Create Test Lead Records
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
      Account accnt = CCRMTestDataFactory.createPersonAccount();
      List<Opportunity> oppList = MLCRMTestDataFactory.createOpportunityRecords(
        1,
        mlUser,
        accnt.Id,
        true
      );
    }
  }

  @isTest
  static void testvalidateMLCRMOpportunityFailure() {
    User mlUser = MLCRMTestDataFactory.getAdminUser();
    String expMsg = System.Label.CCRM_OpenTasksOnOpportunityCloseError;
    String actualMsg = '';
    System.runAs(mlUser) {
      Opportunity opp = [SELECT id, StageName FROM Opportunity LIMIT 1];
      Account acc = [SELECT id, PersonContactId FROM Account LIMIT 1];
      List<Task> taskList = MLCRMTestDataFactory.createTaskRecords(
        1,
        mlUser,
        opp.Id,
        acc.PersonContactId
      );
      insert taskList;
      Test.startTest();
      try {
        opp.StageName = MLCRMConstants.STAGE_CLOSED;
        update opp;
      } catch (DMLException e) {
        actualMsg = e.getDmlMessage(0);
      }
      Test.stopTest();
      System.assertEquals(expMsg, actualMsg, 'Opp updated successfully');
    }
  }

  @isTest
  static void testvalidateMLCRMOpportunitySuccess() {
    User mlUser = MLCRMTestDataFactory.getAdminUser();
    String expMsg = System.Label.CCRM_OpenTasksOnOpportunityCloseError;
    String actualMsg = '';
    System.runAs(mlUser) {
      Opportunity opp = [SELECT id, StageName FROM Opportunity LIMIT 1];
      Test.startTest();
      opp.StageName = MLCRMConstants.STAGE_CLOSED;
      update opp;
      Opportunity oppt = [
        SELECT Id, StageName
        FROM Opportunity
        WHERE id = :opp.id
      ];
      Test.stopTest();
      System.assertEquals(
        MLCRMConstants.STAGE_CLOSED,
        oppt.StageName,
        'Opp updated successfully'
      );
    }
  }
}

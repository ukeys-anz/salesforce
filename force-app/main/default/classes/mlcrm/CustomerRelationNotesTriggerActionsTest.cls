/**
 * @author Ashish Kumar
 * @since 30 Aug 2023
 * @description CustomerRelationNotesTriggerActionsTest is the test class for CustomerRelationNotesTriggerActions Class functionality.
 */
@isTest
public class CustomerRelationNotesTriggerActionsTest {
  @testSetup
  static void setup() {
    User mlBusinessAdminUser = MLCRMTestDataFactory.createMLBusinessAdminUser();
    User mlUser = MLCRMTestDataFactory.createMLCRMBaseUser();
    User iiQUser = MLCRMTestDataFactory.createIIQBaseUser();

    // creating sample territory record
    System.runAs(mlBusinessAdminUser) {
      List<Territory__c> lstOfTerritory = MLCRMTestDataFactory.createTerritoryRecords(
        1,
        mlBusinessAdminUser,
        true
      );

      Territory__Share objShare = new Territory__Share();
      objShare.parentId = lstOfTerritory[0].Id;
      objShare.accesslevel = 'Edit';
      objShare.userOrgroupid = mlUser.Id;
      insert objShare;
    }

    //update ml user record so that user trigger creates corresponding user territory record
    System.runAs(iiQUser) {
      Test.startTest();
      mlUser.ML_Territories__c = 'Melbourne CBD (VIC)';
      mlUser.ML_Role__c = 'Loan Writer';
      update mlUser;
      Test.stopTest();
    }

    //Create Test customer relationship notes Records
    System.runAs(mlUser) {
      MLCRMTestDataFactory.createCustomerRelationNotes();
    }
  }

  @isTest
  static void testRelationshipNotesCreation() {
    user objUser = [
      SELECT Id
      FROM User
      WHERE
        LastName = 'MLCRM'
        AND FirstName LIKE 'BaseUser%'
        AND IsActive = TRUE
      LIMIT 1
    ];
    System.runAs(objUser) {
      List<Territory__c> lstOfTerritory = [SELECT Id FROM Territory__c LIMIT 1];
      List<Customer_Relationship__c> lstOfCustomerRelation = [
        SELECT Id, Territory__c
        FROM Customer_Relationship__c
      ];
      // asserting territory gets populated via trigger
      Assert.isTrue(lstOfCustomerRelation[0].Territory__c != null);

      // asserting same territory gets assigned to customer relation record to which user is part of
      Assert.areEqual(
        lstOfTerritory[0].Id,
        lstOfCustomerRelation[0].Territory__c
      );
    }
  }
}

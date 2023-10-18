/**
 * @author Ashish Kumar
 * @since 30 Aug 2023
 * @description CustomerRelationNotesTriggerActionsTest is the test class for CustomerRelationNotesTriggerActions Class functionality.
 */
@isTest
public class CustomerRelationNotesTriggerActionsTest {
  @testSetup
  static void setup() {
    User adminUser = MLCRMTestDataFactory.createAdminUser();
    //Create Test customer relationship notes Records
    System.runAs(adminUser) {
      MLCRMTestDataFactory.createCustomerRelationNotes();
    }
  }

  @isTest
  static void testRelationshipNotesCreation() {
    user objUser = [
      SELECT Id
      FROM User
      WHERE LastName = 'Admin' AND IsActive = TRUE
      LIMIT 1
    ];
    System.runAs(objUser) {
      List<Customer_Relationship__c> lstOfCustomerRelation = [
        SELECT Id
        FROM Customer_Relationship__c
        WHERE Name != NULL
      ];
      System.assertEquals(lstOfCustomerRelation.size(), 1);
    }
  }
}

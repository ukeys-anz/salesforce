/**
 * @author Pragya Awasthi
 * @since 05 Aug 2025
 * @description CustomerRelationNotesTriggerTest is the test class for trigger code coverage.
 */
@isTest
public class CustomerRelationNotesTriggerTest {
  /**
   * @description test method for trigger code coverage
   */
  @isTest
  static void testRelationshipNotesCreation() {
    User mlUser = MLCRMTestDataFactory.createMLCRMBaseUser();
    Territory__c terrRecord = new Territory__c(Name = 'Melbourne CBD (VIC)');
    System.runAs(MLCRMTestDataFactory.createMLBusinessAdminUser()) {
      terrRecord.Primary_Franchise_Owner__c = UserInfo.getUserId();
      insert terrRecord;
      Territory__Share objShare = new Territory__Share(
        ParentId = terrRecord.Id,
        AccessLevel = 'Edit',
        UserOrGroupId = mlUser.Id
      );
      insert objShare;
      User_Territory__c userTerrRecord = new User_Territory__c(
        User__c = mlUser.Id,
        Territory__c = terrRecord.id,
        ML_Role__c = 'Loan Writer',
        Status__c = 'Active'
      );
      insert userTerrRecord;
    }
    List<Customer_Relationship__c> lstOfCustRelRecord = new List<Customer_Relationship__c>{
      new Customer_Relationship__c(Territory__c = terrRecord.Id)
    };
    System.runAs(mlUser) {
      insert lstOfCustRelRecord;
    }

    // asserting territory gets populated via trigger
    Assert.isTrue(
      lstOfCustRelRecord[0].Territory__c != null,
      'territory is not getting populated properly via trigger'
    );
  }
}

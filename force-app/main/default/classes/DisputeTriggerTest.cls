/**
 * @author Karen Valeriano
 * @since August 2025
 * @description Tests for {@link DisputeTrigger}
 */

@isTest
private class DisputeTriggerTest {
  static final Faker FAKER = new Faker('AU');
  static User fraudXAgent;
  static Dispute disputeRec = new Dispute();
  static DisputeItem disputeItemRec = new DisputeItem();

  static void makeData() {
    // Create user who has access to the Dispute and DisputeItem objects
    fraudXAgent = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'FraudXAgent_TestUser',
        'ProfileId' => QueryProfile.anzxUser.Id,
        'UserRoleId' => QueryRole.fraudXAgent.Id
      }
    );
    insert fraudXAgent;

    TestUtil.assignPermissionSetGroups(
      new List<String>{ 'FraudX_Agent' },
      new List<User>{ fraudXAgent }
    );

    // Run as FraudXAgent since only this user has access
    // to the Dispute and DisputeItem objects
    System.runAs(fraudXAgent) {
      disputeRec = new Dispute(ReceivedDate = Date.today());
      insert disputeRec;
    }
  }

  @isTest
  static void testUpdate() {
    makeData();

    // Update the Dispute record
    disputeRec.ReceivedDate = disputeRec.ReceivedDate.addDays(-1);

    System.runAs(fraudXAgent) {
      Test.startTest();
      update disputeRec;
      Test.stopTest();
    }

    // Verify the update
    Dispute updatedDispute = [
      SELECT Id, ReceivedDate
      FROM Dispute
      WHERE Id = :disputeRec.Id
    ];

    Assert.areEqual(
      disputeRec.ReceivedDate,
      updatedDispute.ReceivedDate,
      'The Dispute record should be updated'
    );
  }

  @isTest
  static void testDelete() {
    makeData();

    // Update the Dispute record
    System.runAs(fraudXAgent) {
      Test.startTest();
      delete disputeRec;
      Test.stopTest();
    }

    List<Dispute> disputeList = [
      SELECT Id
      FROM Dispute
      WHERE Id = :disputeRec.Id
    ];

    // Verify the deletion
    Assert.areEqual(
      0,
      disputeList.size(),
      'The Dispute record should be deleted'
    );
  }
}

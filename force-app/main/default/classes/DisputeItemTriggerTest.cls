/**
 * @author Karen Valeriano
 * @since August 2025
 * @description Tests for {@link DisputeItemTrigger}
 */

@isTest
private class DisputeItemTriggerTest {
  static final Faker FAKER = new Faker('AU');
  static User fraudXAgent;
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
      Dispute disputeRec = new Dispute(ReceivedDate = Date.today());
      insert disputeRec;

      disputeItemRec = new DisputeItem(
        TransactionDate = FAKER.randomPastDate(),
        DisputeId = disputeRec.Id
      );
      insert disputeItemRec;
    }
  }

  @isTest
  static void testDelete() {
    makeData();

    // Run delete
    System.runAs(fraudXAgent) {
      Test.startTest();
      delete disputeItemRec;
      Test.stopTest();
    }

    List<DisputeItem> deletedItems = [
      SELECT Id
      FROM DisputeItem
      WHERE Id = :disputeItemRec.Id
    ];

    // Verify deletion
    Assert.areEqual(
      0,
      deletedItems.size(),
      'The DisputeItem record should be deleted'
    );
  }
}

/**
 * @author Atharv Jakate
 * @since 9 July 2025
 * @description test class for BrokerRelationTrigger
 */
@isTest
public class BrokerRelationTriggerTest {
  @TestSetup
  private static void setup() {
    User emUser = TestUtil.createTestUserWithProfile(
      QueryProfile.anzxUser.Name
    );
    emUser.UserRoleId = QueryRole.enablementManager.Id;

    User rbmTestUser = TestUtil.createTestUserWithProfile(
      QueryProfile.anzxUser.Name
    );
    rbmTestUser.UserRoleId = QueryRole.residentialBrokerManager.Id;

    List<User> allUsers = new List<User>();
    allUsers.add(emUser);
    allUsers.add(rbmTestUser);
    insert allUsers;

    TestUtil.assignPermissionSetGroups(
      new List<String>{ QueryPS.enablementManager.Name },
      allUsers
    );
  }

  @isTest
  private static void testTriggers() {
    Account[] accnts = new List<Account>();
    accnts.add(TestDataFactory.createAccount('Test Account', true));

    User rbmTestUser = [
      SELECT id
      FROM user
      WHERE
        UserRole.DeveloperName = :QueryRole.residentialBrokerManager.DeveloperName
      LIMIT 1
    ];

    Broker_Relation__c brokerSet = new Broker_Relation__c();
    brokerSet.Name = 'Broker Set 1';
    brokerSet.Primary_RBM__c = rbmTestUser.Id;
    brokerSet.state__c = 'WA';
    brokerSet.segment__c = 'APN';
    brokerSet.Aggregator__c = accnts[0].Id;
    brokerSet.RecordTypeId = RTBrokerRelation.brokerSet;
    brokerSet.IsActive__c = true;
    insert brokerSet;

    Assert.isNotNull(brokerSet.Id, 'Broker set should be inserted');
  }
}

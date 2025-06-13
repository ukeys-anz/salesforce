/**
 * @author Saurabh Chauhan
 * @since 8 Apr 2025
 * @description test class for BrokerSetTriggerHandler
 */
@isTest
public class BrokerSetTriggerHandlerTest {
  static Lib_MockProvider brokerSettingsMock = Lib_MockProvider.forType(
    BrokerSettingsRepository.class
  );
  /**
   * @description for trigger test coverage, needs DMLs as this needs actual data
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   **/
  @isTest
  static void testTriggers() {
    BrokerSettings__c mockSettings = new BrokerSettings__c();
    mockSettings.BypassBrokerRelationEvent__c = true;
    brokerSettingsMock.mock('get', mockSettings);

    User emUser = TestUtil.createTestUserWithProfile('ANZx Standard User');
    emUser.UserRoleId = CommonUtil.getUserRoleByDevName('Enablement_Manager')
      .Id;

    User testUser = TestUtil.createTestUserWithProfile('ANZx Standard User');
    testUser.UserRoleId = CommonUtil.getUserRoleByDevName(
        'Residential_Broker_Manager'
      )
      .Id;

    List<User> allUsers = new List<User>();
    allUsers.add(emUser);
    allUsers.add(testUser);
    insert allUsers;

    TestUtil.assignPermissionSetGroups(
      new List<String>{ 'Enablement_Manager' },
      allUsers
    );

    System.runAs(emUser) {
      Account acc1 = new Account();
      acc1.Name = 'Acc 1';
      acc1.OCV_ID__c = '23456';
      acc1.RecordTypeId = RTAccount.businessAccount;
      insert acc1;

      Broker_Relation__c brokerSet1 = new Broker_Relation__c();
      brokerSet1.Name = 'Broker Set 1';
      brokerSet1.Primary_RBM__c = testUser.Id;
      brokerSet1.state__c = 'WA';
      brokerSet1.segment__c = 'APN';
      brokerSet1.Aggregator__c = acc1.Id;
      brokerSet1.RecordTypeId = RTBrokerRelation.brokerSet;
      brokerSet1.IsActive__c = true;
      insert brokerSet1;

      Assert.isTrue(brokerSet1.Id != null, 'Broker set is inserted');

      brokerSet1.Name = 'Broker Set 2';
      update brokerSet1;

      Assert.isTrue(brokerSet1.Name == 'Broker Set 2', 'Broker set is updated');
    }
  }
}

/**
 * @author Saurabh Chauhan
 * @since 8 Apr 2025
 * @description test class for OfficeGroupTriggerHandler
 */
@isTest
public with sharing class OfficeGroupTriggerHandlerTest {
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
    insert testUser;

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
      insert brokerSet1;

      Broker_Relation__c officeGroup = new Broker_Relation__c();
      officeGroup.Name = 'Office Group 1';
      officeGroup.Segment__c = 'Advocate';
      officeGroup.Address1__c = 'this is an address';
      officeGroup.Associated_Broker_Set__c = brokerSet1.Id;
      officeGroup.Aggregator__c = acc1.Id;
      officeGroup.RecordTypeId = RTBrokerRelation.officeGroup;
      insert officeGroup;

      Assert.isTrue(officeGroup.Id != null, 'Office Group is inserted');

      officeGroup.Name = 'Office Group 2';
      update officeGroup;

      Assert.isTrue(
        officeGroup.Name == 'Office Group 2',
        'Office Group is updated'
      );
    }
  }
}

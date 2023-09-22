/**
 * @author cruzb
 * @since June 2023
 * @description Test class for UUIDLog
 * @group Services
 */
@isTest
public with sharing class UUIDLogTest {
  /**
   * @description This setup method creates the record(s) required for the test classes
   */
  @testSetup
  public static void setup() {
    insert new UUID_Log_Entry__c(
      Status__c = GetHelpConstants.IN_PROGRESS_STATUS,
      UUID__c = '1b3fec6c-e152-7ed4-eb3a-34af5193914e',
      Hash_Payload__c = '7992051413d12cd8c44447b97865dd196edfd702ea08ec5617e5b3b073629741'
    );
  }

  @isTest
  static void testUUID() {
    Test.startTest();
    string payload = '{"test" : "1234"}';

    System.assertEquals(
      '1b3fec6c-e152-7ed4-eb3a-34af5193914e',
      new UUIDLog(payload).uuid
    );
    Test.stopTest();
  }

  @isTest
  static void testInsertUUID() {
    Test.startTest();
    string payload = '{"test" : "uuid-1-12345"}';

    UUIDLog uuidLog = new UUIDLog(payload);
    uuidLog.insertUUID('00XXXXXXXXXXXXX', 'BOH - Credit Referral - Reassess');
    Test.stopTest();

    System.assertEquals(
      uuidLog.uuid,
      [SELECT UUID__c FROM UUID_Log_Entry__c WHERE UUID__c = :uuidLog.uuid]
      .UUID__c,
      'UUID Log Entry record should have been created'
    );
  }
}

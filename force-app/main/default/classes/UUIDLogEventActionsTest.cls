/**
 * @author cruzb
 * @since July 2023
 * @description Test class for {@link UUIDLogEventActions}
 */
@isTest
public with sharing class UUIDLogEventActionsTest {
  @isTest
  static void testProcessUUIDLogEvents() {
    String uuid = '1b3fec6c-e152-7ed4-eb3a-34af5193914e';
    Test.startTest();
    UUIDLogEventActions.processUUIDLogEvents(
      new List<UUID_Log_Event__e>{
        new UUID_Log_Event__e(
          Status__c = GetHelpConstants.IN_PROGRESS_STATUS,
          UUID__c = uuid,
          Hash_Payload__c = '7992051413d12cd8c44447b97865dd196edfd702ea08ec5617e5b3b073629741',
          Reference_Id__c = '00XXXXXXXXXXXXX',
          Type__c = 'BOH - Credit Referral - Reassess'
        )
      }
    );
    Test.stopTest();

    System.assertEquals(
      uuid,
      [SELECT UUID__c FROM UUID_Log_Entry__c WHERE UUID__c = :uuid]
      .UUID__c,
      'UUID Log Entry record should have been created'
    );
  }
}

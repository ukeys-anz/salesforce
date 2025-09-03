/**
 * @author Peter Charalambous
 * @since Tue Apr 16 2024
 * @description trigger handler for Settlement Account object
 */
public with sharing class SettlementAccountTriggerHandler extends Lib_TriggerHandler {
  private static final CustomSettingsRepository BROKER_SETTINGS_REPOSITORY = (CustomSettingsRepository) Lib_InstanceProvider.forType(
    CustomSettingsRepository.class
  );
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public SettlementAccountTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    SettlementAccountActions.populateCustomerName(records);
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions
   */

  public override void onAfterInsert() {
    Boolean bypassSyncEvents = BROKER_SETTINGS_REPOSITORY.brokerSettings()
      .BypassSettlementAccountEvent__c;
    if (bypassSyncEvents) {
      return;
    }
    SettlementAccountActions.publishSettlementAccountCloudEvents(
      records,
      ApplicationEventActions.APPLICATION_EVENT_ADD
    );
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    SettlementAccountActions.populateCustomerName(records);
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    Boolean bypassSyncEvents = BROKER_SETTINGS_REPOSITORY.brokerSettings()
      .BypassSettlementAccountEvent__c;
    if (bypassSyncEvents) {
      return;
    }
    SettlementAccountActions.publishSettlementAccountCloudEvents(
      records,
      ApplicationEventActions.APPLICATION_EVENT_UPDATE
    );
  }
}

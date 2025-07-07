/**
 * @author Nakul Kumar
 * @since 01/2025
 * @description the handler class for trigger on FinServ__FinancialAccount__c corresponding to Broker domain
 * @runTests RetailBrokerFinAccountTriggerHandlerTest
 */

public with sharing class RetailBrokerFinAccountTriggerHandler extends Lib_TriggerHandler {
  private static final BrokerSettingRepository BROKER_SETTINGS_REPOSITORY = (BrokerSettingRepository) Lib_InstanceProvider.forType(
    BrokerSettingRepository.class
  );
  private static Boolean bypassSyncEvents {
    get {
      return BROKER_SETTINGS_REPOSITORY.getBrokerSettings()
        .BypassContractEvent__c;
    }
    set;
  }

  /**
   * @description Contructor to return an instance of RetailBrokerFinAccountTriggerHandler
   */
  public RetailBrokerFinAccountTriggerHandler() {
    super();
  }

  /**
   * @description onAfterInsert to handle after update trigger actions.
   */
  public override void onAfterInsert() {
    if (bypassSyncEvents) {
      return;
    }
    RetailBrokerFinancialAccountAction.publishContractEvents(records, 'add');
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    if (bypassSyncEvents) {
      return;
    }
    RetailBrokerFinancialAccountAction.publishContractEvents(records, 'update');
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions
   */
  public override void onBeforeInsert() {
    RetailBrokerFinancialAccountAction.populateFinancialAccountAssistedBroker(
      records,
      new Map<Id, FinServ__FinancialAccount__c>()
    );
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    RetailBrokerFinancialAccountAction.populateFinancialAccountAssistedBroker(
      records,
      (Map<Id, FinServ__FinancialAccount__c>) oldMap
    );
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of Financial Account records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    FinServ__FinancialAccount__c financialAccount = (FinServ__FinancialAccount__c) record;
    if (financialAccount.RecordTypeId != RTFinancialAccount.bankAccount) {
      return false;
    }
    List<String> homeLoanMarketingCodes = new List<String>{
      'HLVAR01',
      'HLFXD01'
    };
    if (!homeLoanMarketingCodes.contains(financialAccount.Marketing_Code__c)) {
      return false;
    }
    if (financialAccount.Assisted_Broker_TPMI_SAO__c == null) {
      return false;
    }
    return true;
  }
}

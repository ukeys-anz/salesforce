/**
 * @author       : Ashish Kumar
 * @since        : June 2025
 * @description  : MobileLendingResidentialLoanTrgHandler is the handler class for ResidentialLoanApplication Trigger which extends Lib_TriggerHandler from the trigger framework used.
 **/
public with sharing class MobileLendingResidentialLoanTrgHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name MobileLendingResidentialLoanTrgHandler
   */
  public MobileLendingResidentialLoanTrgHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of ResidentialLoanApplication records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    ResidentialLoanApplication rlaRecord = (ResidentialLoanApplication) record;
    return rlaRecord.Assisted_Broker_TPMI_SAO__c != null &&
      rlaRecord.LANID__c != null;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions
   */
  public override void onBeforeInsert() {
    MobileLendingResidentialLoanApplication.populateRetailLoanAssistedLender(
      records,
      new Map<Id, ResidentialLoanApplication>()
    );
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    MobileLendingResidentialLoanApplication.populateRetailLoanAssistedLender(
      records,
      (Map<Id, ResidentialLoanApplication>) oldMap
    );
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions
   */
  public override void onAfterInsert() {
    MobileLendingResidentialLoanApplication.updateOpportunityFromRLA(
      records,
      null
    );
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    MobileLendingResidentialLoanApplication.updateOpportunityFromRLA(
      records,
      (Map<Id, ResidentialLoanApplication>) oldMap
    );
  }
}

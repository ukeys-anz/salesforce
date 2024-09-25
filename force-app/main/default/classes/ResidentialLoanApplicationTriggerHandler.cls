/**
 * @author cruzb
 * @since July 2023
 * @description creates `ResidentialLoanApplication`
 * @group handler
 * @runTests ResidentialLoanAppTriggerHandlerTest, ResidentialLoanApplicationControllerTest
 */
public with sharing class ResidentialLoanApplicationTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onAfterInsert etc.
   */
  public ResidentialLoanApplicationTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions
   */
  public override void onBeforeInsert() {
    //Assign home loan applications queue as owner
    ResidentialLoanApplicationActions.assignHomeLoanAppQueue(records);
    ResidentialLoanApplicationActions.populateRetailLoanAssistedBroker(
      records,
      new Map<Id, ResidentialLoanApplication>()
    );
    ResidentialLoanApplicationActions.setSunsetTimestamp(
      records,
      new Map<Id, ResidentialLoanApplication>()
    );
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    ResidentialLoanApplicationActions.populateRetailLoanAssistedBroker(
      records,
      (Map<Id, ResidentialLoanApplication>) oldMap
    );
    ResidentialLoanApplicationActions.setSunsetTimestamp(
      records,
      (Map<Id, ResidentialLoanApplication>) oldMap
    );
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    ToastAlertService.publishRecordMonitoringEvent(
      ToastAlertService.RLA_MESSAGE,
      ToastAlertService.checkRLAReassessmentRequirement(
        records,
        (Map<Id, ResidentialLoanApplication>) oldMap
      )
    );
    CoachNudgeTaskAction.processCancelledRLARecords(
      records,
      (Map<Id, ResidentialLoanApplication>) oldMap
    );
  }
}

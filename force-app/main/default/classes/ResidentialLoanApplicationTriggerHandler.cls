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
    ResidentialLoanApplicationActions.processTPMIBasedSyncStatus(records);
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
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions
   */
  @TestVisible
  public override void onAfterInsert() {
    ResidentialLoanApplicationActions.synchronizeAndPublishCloudEvents(
      records,
      ResidentialLoanApplicationGCPActions.GCP_EVENT_ADD
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

    ResidentialLoanApplicationActions.synchronizeAndPublishCloudEvents(
      records,
      ResidentialLoanApplicationGCPActions.GCP_EVENT_UPDATE
    );
  }
}
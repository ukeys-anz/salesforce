/**
 * @author Deepro De
 * @since August 2024
 * @description trigger handler for Loan Applicant object
 */
public with sharing class LoanApplicantTriggerHandler extends Lib_TriggerHandler {
    /**
     * @description Constructor to call the trigger framework
     * which will call the appropriate methods such as onBeforeInsert etc.
     */
    public LoanApplicantTriggerHandler() {
      super();
    }
  
    /**
     * @description onBeforeInsert to handle before insert trigger actions.
     */
    public override void onBeforeInsert() {
    }
  
    /**
     * @description onAfterInsert to handle after insert trigger actions
     */
    public override void onAfterInsert() {
        LoanApplicantActions.synchronizeAndUpdateCustomerSyncStatus(Trigger.newMap.keySet());
    }
  
    /**
     * @description onBeforeUpdate to handle before update trigger actions.
     * @param oldMap
     */
    public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    }
  
    /**
     * @description onAfterUpdate to handle after update trigger actions
     * @param oldMap old trigger values
     */
    public override void onAfterUpdate(Map<Id, SObject> oldMap) {
        LoanApplicantActions.synchronizeAndUpdateCustomerSyncStatus(Trigger.newMap.keySet());
    }
  }


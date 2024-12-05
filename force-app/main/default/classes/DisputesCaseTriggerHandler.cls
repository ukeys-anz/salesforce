/**
 * @description Handler for Disputes Cases
 * @author Hrushikesh Pathak
 * @since 08/2024
 */
public with sharing class DisputesCaseTriggerHandler extends Lib_TriggerHandler {
  public static final Set<Id> DISPUTES_RECORD_TYPES = new Set<Id>{
    RTCase.atmDispute,
    RTCase.bpayDispute,
    RTCase.cardDispute,
    RTCase.nppDispute,
    RTCase.directDebitDispute,
    RTCase.directEntryDispute,
    RTCase.payToDispute
  };

  public static final String NPP_NEW_EXTERNAL_STATUS = 'NPP_New';
  public static final String UNAUTHORISED_TRANSACTION_DISPUTE_REASON = 'Unauthorised Transaction';

  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public DisputesCaseTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of disputes Case records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Id caseRTId = ((Case) record).RecordTypeId;
    return DISPUTES_RECORD_TYPES.contains(caseRTId);
  }

  /**
   * @description onAfterInsert to handle after update trigger actions.
   */
  public override void onAfterInsert() {
    List<Case> nppNonFraudDisputes = ListUtil.filter(records)
      .equals(Case.RecordTypeId, RTCase.nppDispute)
      .notEquals(
        Case.Dispute_Reason__c,
        UNAUTHORISED_TRANSACTION_DISPUTE_REASON
      )
      .toList();

    DisputesCaseActions.createExternalCaseStatuses(
      nppNonFraudDisputes,
      NPP_NEW_EXTERNAL_STATUS
    );
  }
}

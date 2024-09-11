/**
 * @description Handler for IDOps and FraudCheck Case Trigger which extends Lib_TriggerHandler framework.
 * @author Karen Valeriano
 * @since 08/2024
 */

public with sharing class COBCaseTriggerHandler extends Lib_TriggerHandler {
  public static final Set<Id> COB_CASE_RT_IDS = new Set<Id>{
    RTCase.fraudCheck,
    RTCase.idOpsAssistance
  };
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public COBCaseTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of Fraud Check and IDOps Case records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Id caseRTId = ((Case) record).RecordTypeId;
    return COB_CASE_RT_IDS.contains(caseRTId);
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    List<Case> idOpsRecords = ListUtil.filter(records)
      .equals(Case.RecordTypeId, RTCase.idOpsAssistance)
      .toList();
    List<Case> fraudCheckRecords = ListUtil.filter(records)
      .equals(Case.RecordTypeId, RTCase.fraudCheck)
      .toList();

    //Create Fraud Check case when ID Ops Assistance case status is changed to 'Potential Fraud'
    COBCaseActions.createFraudCheckCase(idOpsRecords, (Map<Id, Case>) oldMap);
    //Update ID Ops Case's status (parent) following the Fraud Check case's (child) status update. Using afterUpdate context as the child must be closed before the parent's status can be updated.
    COBCaseActions.updateIdOpsCaseStatus(
      fraudCheckRecords,
      (Map<Id, Case>) oldMap
    );
  }
}

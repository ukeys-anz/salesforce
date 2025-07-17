/**
 * @author CMOS
 * @since 03/2025
 * @description  IDRCaseTriggerHandler is the handler class for IDR Case Trigger.
 */
public with sharing class IDRCaseTriggerHandler extends Lib_TriggerHandler {
  public static final Set<Id> IDR_CASE_RECORD_TYPES = new Set<Id>{
    RTCase.customerComplaint,
    RTCase.nonCustomerComplaint,
    RTCase.generalInquiryCmos
  };
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public IDRCaseTriggerHandler() {
    super();
  }
  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of Complaint and Non Complaint record types
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record type  is either Complaint or Non Complaint else false
   */
  public override Boolean isValidRecord(SObject record) {
    Id caseRTId = ((Case) record).RecordTypeId;
    return IDR_CASE_RECORD_TYPES.contains(caseRTId);
  }
  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    IDRCaseAccessActions.restrictL2L3Users(records, (Map<Id, Case>) oldMap);
  }
}

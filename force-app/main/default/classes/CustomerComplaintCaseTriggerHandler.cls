/**
 * @description Handler for Customer Complaint Cases which extends Lib_TriggerHandler framework.
 * @author Shivam Swaraj
 * @since 5/2025
 */
public with sharing class CustomerComplaintCaseTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public CustomerComplaintCaseTriggerHandler() {
    super();
  }

  //Validate the record relevance to this handler based on record type
  public override Boolean isValidRecord(SObject record) {
    return ((Case) record).RecordTypeId == RTCase.customerComplaint;
  }

  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    List<Case> casesStatusChanged = ListUtil.filter(records, oldMap)
      .changedTo(case.Status, GetHelpConstants.ESCALATED_STATUS)
      .toList();
    PushToAppAction.autoExpireCustomerNudgeTask(casesStatusChanged);
  }
}

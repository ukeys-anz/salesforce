/**
 * @author Ankit Garg
 * @since 17/July/2023
 * @description CC-4429 Queueable apex class to auto create Task for mismatch during Lead conversion
 */
public without sharing class MLCRMAutoTaskOnLeadConversionQueueable implements Queueable {
  private Map<Id, Id> mapLeadToOpportunity = new Map<Id, Id>();

  /**
   * @description Constructor
   * @param leadOppMap Map of Lead ID with Opportunity
   */
  public MLCRMAutoTaskOnLeadConversionQueueable(Map<Id, Id> leadOppMap) {
    this.mapLeadToOpportunity = leadOppMap;
  }

  /**
   * @description execute method
   * @param context QueueableContext
   */
  public void execute(QueueableContext context) {
    // auto task to be created on lead conversion if there is mismatching data in the lead in comparison the related customer record
    List<Lead> leads = new List<Lead>();
    Map<Id, String> mismtachLeadsWithFieldsMap = new Map<Id, String>();
    List<Task> taskList = new List<Task>();
    if (!mapLeadToOpportunity.isEmpty()) {
      leads = MLCRMAutoTaskOnLeadConversionHelper.getLeads(
        mapLeadToOpportunity.keySet()
      );
    }
    if (!leads.isEmpty()) {
      mismtachLeadsWithFieldsMap = MLCRMAutoTaskOnLeadConversionHelper.checkLeadMisMatchCustomer(
        leads
      );
    }
    taskList = MLCRMAutoTaskOnLeadConversionHelper.generateTasks(
      leads,
      mapLeadToOpportunity,
      mismtachLeadsWithFieldsMap
    );
    if (Task.sObjectType.getDescribe().isCreateable() && !taskList.isEmpty()) {
      List<Database.SaveResult> results = Database.insert(taskList, false);
      Logger.error('Lead Error', results);
    }
    Logger.saveLog();
  }
}

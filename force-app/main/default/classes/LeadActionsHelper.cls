/**
 * Helper class to manage Lead-related actions, specifically for creating callback tasks.
 * @author Aman Gupta
 * @since 2025-01-16
 * @description Lead Trigger Helper
 */
public with sharing class LeadActionsHelper {
  private static final Set<String> LEAD_SOURCE = new Set<String>{
    'Web explore',
    'Web explore AEM exit page',
    'AEM promo page'
  };

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description Creates a callback task for the provided Lead record.
   * @param newLeads The Lead record from the trigger
   */
  public static void checkAndCreateCallbackTask(List<Lead> newLeads) {
    List<Task> tasksToCreate = new List<Task>();
    try {
      Task_Creation_Mapping__mdt callbackRequestMapping = Task_Creation_Mapping__mdt.getInstance(
        'AEM_BOH_Call_Back_Request'
      );

      List<Lead> bohLeads = ListUtil.filter(newLeads)
        .equals(Lead.Is_BOH_Lead__c, true)
        .equals(Lead.LeadSource, LEAD_SOURCE)
        .toList();

      for (Lead objLead : bohLeads) {
        Task callbackTask = TaskUtils.generateTaskFromMetadata(
          callbackRequestMapping
        );
        callbackTask.WhoId = objLead.Id;
        callbackTask.Pub_Sub_Event_Id__c = objLead.Pub_Sub_Event_Id__c;
        callbackTask.ActivityDate = System.today().addDays(5);
        tasksToCreate.add(callbackTask);
      }

      DML_REPOSITORY.doInsert(tasksToCreate, new DmlConfig().allowPartial());
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    }
  }
}

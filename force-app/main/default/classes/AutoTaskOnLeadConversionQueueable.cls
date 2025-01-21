/**
 * @author Ankit Garg
 * @since 17/July/2023
 * @description CC-4429 Queueable apex class to auto create Task for mismatch during Lead conversion
 */
public without sharing class AutoTaskOnLeadConversionQueueable implements Queueable {
  private Map<Id, Id> mapLeadToOpportunity = new Map<Id, Id>();
  private static final LeadConversionActionsRepository LEADCONV_REPOSITORY = (LeadConversionActionsRepository) Lib_InstanceProvider.forType(
    LeadConversionActionsRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description Constructor
   * @param leadOppMap Map of Lead ID with Opportunity
   */
  public AutoTaskOnLeadConversionQueueable(Map<Id, Id> leadOppMap) {
    this.mapLeadToOpportunity = leadOppMap;
  }

  /**
   * @description execute method
   * @param context QueueableContext
   */
  public void execute(QueueableContext context) {
    // auto task to be created on lead conversion if there is mismatching data in the lead in comparison the related customer record
    try {
      if (mapLeadToOpportunity.isEmpty()) {
        return;
      }
      List<ID> leadIDs = new List<ID>(mapLeadToOpportunity.keySet());
      Lead leadRecord = LEADCONV_REPOSITORY.getLeadsWithCustomerDetails(
        leadIDs[0]
      );
      if (
        leadRecord == null ||
        leadRecord.FinServ__RelatedAccount__c == null ||
        leadRecord.FinServ__RelatedAccount__r.OCV_Event_Version__c == 0
      ) {
        return;
      }
      Map<Id, String> mismtachLeadsWithFieldsMap = AutoTaskOnLeadConversionHelper.checkLeadMisMatchCustomer(
        leadRecord
      );
      List<Task> taskList = AutoTaskOnLeadConversionHelper.generateTasks(
        leadRecord,
        mapLeadToOpportunity.values()[0],
        mismtachLeadsWithFieldsMap
      );
      DmlConfig dmlConfigRecord = new DmlConfig();
      dmlConfigRecord.allowPartial();
      dmlConfigRecord.withoutSharing();
      DML_REPOSITORY.doInsert(taskList, dmlConfigRecord);
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
      return;
    }
  }
}

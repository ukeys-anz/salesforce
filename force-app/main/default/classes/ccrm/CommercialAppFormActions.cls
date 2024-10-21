/**
 * @author Ayushi Gupta
 * @since 08/2024
 * @description  CommercialAppFormActions is the orchestrator class for commercial app form Trigger handler.
 */
public with sharing class CommercialAppFormActions {
  private static final CommercialAppFormProductActionsRepo AFP_REPOSITORY = (CommercialAppFormProductActionsRepo) Lib_InstanceProvider.forType(
    CommercialAppFormProductActionsRepo.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description setTotalAmountOnOpp which sets total amount on opp
   * @param records list of new app form products records
   * @param oldMap old map of app form records
   */
  public static void setTotalAmountOnOpp(
    List<ApplicationForm> records,
    Map<Id, ApplicationForm> oldMap
  ) {
    try {
      Set<Id> oppIds = getOppIdsRelatedToAmountUpdatedAppForms(
        records,
        (Map<Id, ApplicationForm>) oldMap
      );
      List<Map<String, Object>> appForms = AFP_REPOSITORY.getCommercialAppFormsWithAggregatedAmount(
        oppIds
      );

      List<Opportunity> updatedOpps = updateOpportunityWithTotalAmount(
        appForms
      );
      DML_REPOSITORY.doUpdate(updatedOpps);
    } catch (Exception e) {
      Logger.error('Error in setting amount on opportunity', e).save();
    }
  }

  @testVisible
  private static Set<Id> getOppIdsRelatedToAmountUpdatedAppForms(
    List<ApplicationForm> records,
    Map<Id, ApplicationForm> oldMap
  ) {
    List<ApplicationForm> appFormsWithAmountUpdated = ListUtil.filter(
        records,
        oldMap
      )
      .changed(ApplicationForm.Application_Amount__c)
      .toList();

    Set<Id> oppIds = ListUtil.getIds(
      appFormsWithAmountUpdated,
      ApplicationForm.OpportunityId
    );
    return oppIds;
  }

  @testVisible
  private static List<Opportunity> updateOpportunityWithTotalAmount(
    List<Map<String, Object>> appForms
  ) {
    List<Opportunity> updatedOpps = new List<Opportunity>();
    for (Map<String, Object> appForm : appForms) {
      Opportunity opp = new Opportunity(
        Id = (Id) appForm.get('OpportunityId'),
        Total_Application_Amount__c = (Decimal) appForm.get('Amount')
      );
      updatedOpps.add(opp);
    }
    return updatedOpps;
  }
}

/**
 * @author Ian Huang
 * @since April 2026
 * @description AgentActionHistory LWC controller class
 * @group Platform
 */
public with sharing class AgentActionHistoryController {
  /**
   * Repository wrapper for DML operations to centralize error handling and user-mode execution.
   */
  private static final DmlRepository DML_REPO = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @param objectType related object name
   * @param agentName name of Agent
   * @param action Action type: created, updated
   * @param recordIds list of related record Id
   * @description insert a new AgentActionHistory record
   */
  public void createAgentActionHistory(
    String objectType,
    String agentName,
    String action,
    List<String> recordIds
  ) {
    List<Agent_Action_History__c> agentActionHistoriesToInsert = new List<Agent_Action_History__c>();

    for (String recordId : recordIds) {
      Agent_Action_History__c agentActionHistory = new Agent_Action_History__c();
      agentActionHistory.Related_Object_Type__c = objectType;
      agentActionHistory.Agent_Name__c = agentName;
      agentActionHistory.Action__c = action;
      agentActionHistory.Related_Record_Id__c = recordId;
      agentActionHistoriesToInsert.add(agentActionHistory);
    }

    try {
      DML_REPO.doInsert(agentActionHistoriesToInsert);
    } catch (Exception e) {
      Logger.error('Error creating Agent action history', e);
      Logger.saveLog();
    }
  }

  /**
   * Repository for Agent Action History.
   */
  private static final CCRMAgentforceActionRepository AGENT_ACTION_REPO = (CCRMAgentforceActionRepository) Lib_InstanceProvider.forType(
    CCRMAgentforceActionRepository.class
  );

  /**
   * @description AgentActionHistory wrapper class
   **/
  public class AgentActionHistoryWrapper {
    @AuraEnabled
    public String createdBy;
    @AuraEnabled
    public DateTime createdAt;
    @AuraEnabled
    public String lastModifiedBy;
    @AuraEnabled
    public DateTime lastModifiedAt;
    @AuraEnabled
    public List<Agent_Action_History__c> histories;
  }

  /**
   * @param recordId related record Id
   * @param displayMode lwc displayMode
   * @return AgentActionHistory for detail and list view
   * @description query agent action history with record Id
   **/
  @AuraEnabled(cacheable=true)
  public static AgentActionHistoryWrapper getAgentActionHistory(
    Id recordId,
    String displayMode
  ) {
    AgentActionHistoryWrapper result = new AgentActionHistoryWrapper();
    List<Agent_Action_History__c> histories = AGENT_ACTION_REPO.getAgentActionHistory(
      recordId
    );

    if (displayMode == 'Detail View') {
      result = getAgentActionHistoryWrapper(histories);
    }
    result.histories = histories;

    return result;
  }

  /**
   * @param histories list of history records
   * @return AgentActionHistory for detail and list view
   * @description query agent action history with record Id
   */
  private static AgentActionHistoryWrapper getAgentActionHistoryWrapper(
    List<Agent_Action_History__c> histories
  ) {
    AgentActionHistoryWrapper result = new AgentActionHistoryWrapper();

    if (histories == null || histories.isEmpty()) {
      return result;
    }

    List<Agent_Action_History__c> createdList = ListUtil.filter(histories)
      .equals(Agent_Action_History__c.Action__c, 'Created')
      .toList();

    List<Agent_Action_History__c> updatedList = ListUtil.filter(histories)
      .equals(Agent_Action_History__c.Action__c, 'Updated')
      .toList();

    if (!createdList.isEmpty()) {
      Agent_Action_History__c createdRecord = createdList[0];

      result.createdBy = createdRecord.Agent_Name__c;
      result.createdAt = createdRecord.CreatedDate;

      // Default last modified to created values
      result.lastModifiedBy = createdRecord.Agent_Name__c;
      result.lastModifiedAt = createdRecord.CreatedDate;
    }

    if (!updatedList.isEmpty()) {
      Agent_Action_History__c updatedRecord = updatedList[0];

      result.lastModifiedBy = updatedRecord.Agent_Name__c;
      result.lastModifiedAt = updatedRecord.CreatedDate;
    }
    return result;
  }
}

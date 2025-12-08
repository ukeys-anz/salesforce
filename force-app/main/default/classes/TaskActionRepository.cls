/**
 * @author Ashish Kumar
 * @since 12/2024
 * @description This class provide SOQL for Task related queries.
 */
public with sharing class TaskActionRepository {
  /**
   * @description getTaskResponse method return Task associated to the given whoids
   * @param whoids Id of the object records(e.g lead)
   * @return List<Task> Task List
   */
  public List<Task> getTaskResponse(Set<ID> whoids) {
    if (whoids.isEmpty()) {
      return new List<Task>();
    }
    return [
      SELECT ActivityDate, WhoId, Response_Status__c
      FROM Task
      WHERE whoId = :whoids
      WITH USER_MODE
      ORDER BY createddate ASC
    ];
  }

  /**
   * @description Returns a list of response type records for the give set of Ids
   * @param responseTypeIds Set of Id of the record
   * @return  List<Response_Type__c> List of Response Types
   */
  public List<Response_Type__c> getResponseTypeData(Set<Id> responseTypeIds) {
    if (responseTypeIds.isEmpty()) {
      return new List<Response_Type__c>();
    }
    return [
      SELECT Id, Response_Status__c, Create_Opportunity__c
      FROM Response_Type__c
      WHERE Id IN :responseTypeIds
      WITH USER_MODE
    ];
  }

  /**
   * @description get lead records for related log response tasks
   * query is running in system mode as Lead outcome permission not needed for ML user
   * @param leadIds Set of Id of the record
   * @param leadStatuses Set of lead statuses
   * @return  List<Lead> List of Lead records
   */
  public List<Lead> getLeadRecords(Set<Id> leadIds, Set<String> leadStatuses) {
    if (leadIds.isEmpty() || leadStatuses.isEmpty()) {
      return new List<Lead>();
    }
    return [
      SELECT
        Id,
        Status,
        SubStatus__c,
        RecordType.DeveloperName,
        Lead_Quality__c,
        Lead_Outcome__c,
        Followup_Date__c,
        Skip_Validations__c
      FROM Lead
      WHERE Id IN :leadIds AND Status IN :leadStatuses
      WITH SYSTEM_MODE
    ];
  }

  /**
   * @description get campaign records for related leads
   * @param leadIds Set of Id of the leads
   * @return  List<CampaignMember> List of Campaign Member records
   */
  public List<CampaignMember> getCampaignMemberRecords(Set<Id> leadIds) {
    if (leadIds.isEmpty()) {
      return new List<CampaignMember>();
    }
    return [
      SELECT Campaign.EndDate, LeadId
      FROM CampaignMember
      WHERE LeadId IN :leadIds
      WITH USER_MODE
    ];
  }

  /**
   * @description get lead records with ABN ACN data
   * @param leadIds Set of Id of the record
   * @return  List<Lead> List of Lead records
   */
  public List<Lead> getLeadRecordsWithABNACN(Set<Id> leadIds) {
    if (leadIds.isEmpty()) {
      return new List<Lead>();
    }
    return [
      SELECT
        Id,
        ABN__c,
        ACN__c,
        ABN_Validation_Status__c,
        ACN_Validation_Status__c
      FROM Lead
      WHERE Id IN :leadIds
      WITH USER_MODE
    ];
  }

  /**
   * @description getOpenTasks method return Tasks associated to the given WhatId
   * @param accountId Id of the object record(e.g account)
   * @return List<Task> Task List
   */
  public List<Task> getOpenTasks(Id accountId) {
    if (accountId == null) {
      return new List<Task>();
    }
    return [
      SELECT Id, Subject, ActivityDate, Description, Priority, Status
      FROM Task
      WHERE WhatId = :accountId AND Status IN ('Open')
      WITH USER_MODE
      ORDER BY ActivityDate ASC
    ];
  }
}

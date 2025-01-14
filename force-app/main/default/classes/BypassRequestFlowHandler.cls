/**
 * @author Sochy Heng
 * @since July 2024
 * @description Handler class related to 'Bypass Automation Request - Grant/Revoke Access' flow invocable actions
 * without sharing on DML : used to allow executing user to update User Salesforce custom library settings related to the Bypass Automation flow
 */
public with sharing class BypassRequestFlowHandler {
  private static final String STATUS_GRANTED = 'Granted';
  private static final String STATUS_REVOKED = 'Revoked';
  private static final String PROCESS_TYPE_GRANT = 'grant';
  private static final String PROCESS_TYPE_REVOKE = 'revoke';

  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description Process the requests sent from 'Bypass Automation Request - Grant/Revoke Access' flow to update custom salesforce library settings
   * Note: Informed decision to compromise the Golden Rule of no DMLs/Qeries inside for loops.
   * There is only a little chance of having multiple PAR/user records in a single flow instance (multiple users requesting Bypass access to start at the same time).
   * So even if it does, it would only be a couple of records.
   * @param requests list of LibraryUpdateWrapper instances sent from Bypass Automation Request - Grant/Revoke Access flow
   * @return List<Boolean> returning result status to support unit testing
   */
  @InvocableMethod(
    label='Update Custom Salesforce Library Settings'
    description='Update disabled triggers, flows and validation rules'
    category='Apex'
  )
  public static List<Boolean> updateUserSFLibSetting(
    List<LibraryUpdateWrapper> requests
  ) {
    List<Boolean> resultStatus = new List<Boolean>();
    Map<LibraryUpdateWrapper, Privileged_Access_Request__c> libraryUpdateWrapperPARsMap = getLibraryWrapperPARsMap(
      requests
    );
    if (libraryUpdateWrapperPARsMap.isEmpty()) {
      resultStatus.add(false);
    }
    try {
      List<Salesforce_Library_Settings__c> grantedSettings = bypassGrantHandler(
        libraryUpdateWrapperPARsMap
      );
      DML.doInsert(grantedSettings, new DmlConfig().withoutSharing());
      List<Salesforce_Library_Settings__c> revokedSettings = bypassRevokeHandler(
        libraryUpdateWrapperPARsMap
      );
      DML.doDelete(revokedSettings, new DmlConfig().withoutSharing());
      List<Privileged_Access_Request__c> parsToUpdate = updatePARs(
        libraryUpdateWrapperPARsMap,
        resultStatus
      );
      DML.doUpdate(parsToUpdate, new DmlConfig().withoutSharing());
    } catch (Exception e) {
      logFailures(libraryUpdateWrapperPARsMap, resultStatus, e.getMessage());
    }

    Logger.saveLog();
    return resultStatus;
  }

  /**
   * @description Create a Map<LibraryUpdateWrapper, Privileged_Access_Request__c> from all flowInstances and PARs
   * @param requests list of LibraryUpdateWrapper instances sent from Bypass Automation Request - Grant/Revoke Access flow
   * @return Map<LibraryUpdateWrapper, Privileged_Access_Request__c>
   */
  private static Map<LibraryUpdateWrapper, Privileged_Access_Request__c> getLibraryWrapperPARsMap(
    List<LibraryUpdateWrapper> requests
  ) {
    Map<LibraryUpdateWrapper, Privileged_Access_Request__c> libraryUpdateWrapperPARsMap = new Map<LibraryUpdateWrapper, Privileged_Access_Request__c>();
    if (
      Schema.sObjectType.Privileged_Access_Request__c.isQueryable() == false
    ) {
      return libraryUpdateWrapperPARsMap;
    }

    Set<Id> requestsMapPARIds = new Set<Id>();
    for (LibraryUpdateWrapper flowInstance : requests) {
      requestsMapPARIds.add(flowInstance.privilegedAccReqId);
    }
    Map<Id, Privileged_Access_Request__c> parsMap = new Map<Id, Privileged_Access_Request__c>();
    for (Privileged_Access_Request__c par : [
      SELECT
        Id,
        Actual_Access_Granted_Time__c,
        Actual_Access_Revoked_Time__c,
        Access_Request__r.Name,
        Access_Request__r.Trace_Id__c,
        Access_Request__r.Automations_to_Bypass__c
      FROM Privileged_Access_Request__c
      WHERE Id IN :requestsMapPARIds
    ]) {
      parsMap.put(par.Id, par);
    }

    for (LibraryUpdateWrapper flowInstance : requests) {
      Id flowPARId = flowInstance.privilegedAccReqId;
      if (!parsMap.containsKey(flowPARId)) {
        continue;
      }
      libraryUpdateWrapperPARsMap.put(flowInstance, parsMap.get(flowPARId));
    }
    return libraryUpdateWrapperPARsMap;
  }

  /**
   * @description Create a List<Salesforce_Library_Settings__c> for all granted flowInstances
   * @param libraryUpdateWrapperPARsMap Map<LibraryUpdateWrapper, Privileged_Access_Request__c> from getLibraryWrapperPARsMap
   * @return List<Salesforce_Library_Settings__c>
   */
  private static List<Salesforce_Library_Settings__c> bypassGrantHandler(
    Map<LibraryUpdateWrapper, Privileged_Access_Request__c> libraryUpdateWrapperPARsMap
  ) {
    List<Salesforce_Library_Settings__c> customSettings = new List<Salesforce_Library_Settings__c>();
    for (
      LibraryUpdateWrapper flowInstance : libraryUpdateWrapperPARsMap.keySet()
    ) {
      if (flowInstance.processType != PROCESS_TYPE_GRANT) {
        continue;
      }

      Privileged_Access_Request__c par = libraryUpdateWrapperPARsMap.get(
        flowInstance
      );
      logDisabledFlow(flowInstance, par);
      List<String> disabledFields = par.Access_Request__r.Automations_to_Bypass__c.split(
        ';'
      );
      Salesforce_Library_Settings__c libsetting = new Salesforce_Library_Settings__c();
      libsetting.SetupOwnerId = flowInstance.userId;
      libsetting.Disable_Flows__c = disabledFields.contains('Flows');
      libsetting.Disable_Triggers__c = disabledFields.contains('Triggers');
      libsetting.Disable_VRs__c = disabledFields.contains('Validation_rules');
      customSettings.add(libsetting);
    }
    return customSettings;
  }

  /**
   * @description Create a List<Salesforce_Library_Settings__c> for all revoked flowInstances
   * @param libraryUpdateWrapperPARsMap Map<LibraryUpdateWrapper, Privileged_Access_Request__c> from getLibraryWrapperPARsMap
   * @return List<Salesforce_Library_Settings__c>
   */
  private static List<Salesforce_Library_Settings__c> bypassRevokeHandler(
    Map<LibraryUpdateWrapper, Privileged_Access_Request__c> libraryUpdateWrapperPARsMap
  ) {
    List<Salesforce_Library_Settings__c> existingCustomSettings = new List<Salesforce_Library_Settings__c>();
    if (
      Schema.sObjectType.Salesforce_Library_Settings__c.isQueryable() == false
    ) {
      return existingCustomSettings;
    }
    Set<Id> flowInstanceUserIds = new Set<Id>();
    for (
      LibraryUpdateWrapper flowInstance : libraryUpdateWrapperPARsMap.keySet()
    ) {
      if (flowInstance.processType != PROCESS_TYPE_REVOKE) {
        continue;
      }
      logDisabledFlow(
        flowInstance,
        libraryUpdateWrapperPARsMap.get(flowInstance)
      );
      flowInstanceUserIds.add(flowInstance.userId);
    }

    return [
      SELECT Id
      FROM Salesforce_Library_Settings__c
      WHERE SetupOwnerId IN :flowInstanceUserIds
    ] ?? existingCustomSettings;
  }

  /**
   * @description Log failures related to 'modifyBypassAutomationAccess' method
   * @param libraryUpdateWrapperPARsMap Map<LibraryUpdateWrapper, Privileged_Access_Request__c> libraryUpdateWrapperPARsMap from getLibraryWrapperPARsMap
   * @param resultStatus List<Boolean> flowInstances status results.
   * @param errorMessage additional details about the error
   */
  @TestVisible
  private static void logFailures(
    Map<LibraryUpdateWrapper, Privileged_Access_Request__c> libraryUpdateWrapperPARsMap,
    List<Boolean> resultStatus,
    String errorMessage
  ) {
    for (
      LibraryUpdateWrapper flowInstance : libraryUpdateWrapperPARsMap.keySet()
    ) {
      Privileged_Access_Request__c par = libraryUpdateWrapperPARsMap.get(
        flowInstance
      );
      Logger.error(
        'Error occured in Bypass ' +
          flowInstance.processType +
          ' flow. Related to' +
          ' request ' +
          par.Access_Request__r.Name +
          ' requesting ' +
          par.Access_Request__r.Automations_to_Bypass__c +
          ' Bypass.' +
          ' More details: ' +
          errorMessage
      );
      resultStatus.add(false);
    }
  }

  /**
   * @description Log error if the Disable Flow is enabled
   * @param flowInstance LibraryUpdateWrapper
   * @param par Privileged_Access_Request__c
   */
  private static void logDisabledFlow(
    LibraryUpdateWrapper flowInstance,
    Privileged_Access_Request__c par
  ) {
    if (!flowInstance.disableFlows) {
      return;
    }
    Logger.error(
      'Error occured in Bypass ' +
        flowInstance.processType +
        ' flow. Related to' +
        ' request ' +
        par.Access_Request__r.Name +
        ' requesting ' +
        par.Access_Request__r.Automations_to_Bypass__c +
        ' Bypass.' +
        ' More details: Disable Flow is true on Salesforce_Library_Settings custom settings for approver.'
    );
  }

  /**
   * @description UpdatePARs to update PARs
   * @param libraryUpdateWrapperPARsMap Map<LibraryUpdateWrapper, Privileged_Access_Request__c> libraryUpdateWrapperPARsMap from getLibraryWrapperPARsMap
   * @param resultStatus List<Boolean> flowInstances status results.
   * @return List<Privileged_Access_Request__c> List of PARs to be updated.
   */
  private static List<Privileged_Access_Request__c> updatePARs(
    Map<LibraryUpdateWrapper, Privileged_Access_Request__c> libraryUpdateWrapperPARsMap,
    List<Boolean> resultStatus
  ) {
    List<Privileged_Access_Request__c> pars = new List<Privileged_Access_Request__c>();
    for (
      LibraryUpdateWrapper flowInstance : libraryUpdateWrapperPARsMap.keySet()
    ) {
      Privileged_Access_Request__c par = libraryUpdateWrapperPARsMap.get(
        flowInstance
      );
      par.Actual_Access_Granted_Time__c = System.now();
      String processType = flowInstance.processType;
      logSuccess(processType, par);
      pars.add(par);
      resultStatus.add(true);
    }
    return pars;
  }

  /**
   * @description Add success logs related to Bypass request Grant or Revoke actions
   * @param processType process action type 'grant' or 'revoke'
   * @param par Privileged Access Request being processed
   * @return String returning Trace Id used for unit testing
   */
  public static String logSuccess(
    String processType,
    Privileged_Access_Request__c par
  ) {
    Logger.info(
      'Bypass request (' +
        processType +
        ') ' +
        par.Access_Request__r.Name +
        ' requesting ' +
        par.Access_Request__r.Automations_to_Bypass__c +
        ' bypass has been done successfully.',
      par
    );
    return par.Access_Request__r.Trace_Id__c;
  }

  /**
   * @description get the privileged access request associated
   * @param recordId id of the privileged access request that need to be retrieved
   * @return Privileged_Access_Request__c the privileged access request
   */
  @testVisible
  private static Privileged_Access_Request__c getPrivilegedAccessRequest(
    String recordId
  ) {
    if (
      Schema.sObjectType.Privileged_Access_Request__c.isQueryable() == false
    ) {
      return null;
    }
    return [
      SELECT
        Id,
        Actual_Access_Granted_Time__c,
        Actual_Access_Revoked_Time__c,
        Access_Request__r.Name,
        Access_Request__r.Trace_Id__c,
        Access_Request__r.Automations_to_Bypass__c
      FROM Privileged_Access_Request__c
      WHERE Id = :recordId
      LIMIT 1
    ] ?? null;
  }

  /**
   * @description Wrapper class to hold context information from Bypass Automation Request - Grant/Revoke Access flow
   */
  public class LibraryUpdateWrapper {
    @InvocableVariable
    public Id userId;

    @InvocableVariable
    public Id privilegedAccReqId;

    @InvocableVariable
    public String processType;

    @InvocableVariable
    public Boolean disableFlows;
  }
}

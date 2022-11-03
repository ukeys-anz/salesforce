/**
 * @author Qing Wang
 * @since 07/2022
 * @description ExternalCaseStatusActions class is to handle all the External Case Status Actions
 */

public with sharing class ExternalCaseStatusActions {
  /**
   * @description Method to update the master Case status based on External Case Status
   * @param records The External Case Status records
   */
  public static void updateCaseStatusFromLatestExternalStatus(
    List<External_Case_Status__c> records
  ) {
    List<External_Case_Status__c> externalStatuses = ExternalCaseStatusActionsHelper.getValidExternalStatuses(
      records
    );

    Map<String, Case> relatedCases = ExternalCaseStatusActionsHelper.getRelatedCases(
      externalStatuses
    );

    Map<String, External_Case_Status__c> latestExternalStatusByCaseIdMap = ExternalCaseStatusActionsHelper.getLatestExternalStatusByCaseIdMap(
      externalStatuses
    );

    List<Case> casesToUpdate = ExternalCaseStatusActionsHelper.getCasesToUpdate(
      relatedCases,
      latestExternalStatusByCaseIdMap
    );

    if (!casesToUpdate.isEmpty()) {
      if (
        PermissionUtils.canUpdate('Case') &&
        Schema.sObjectType.Case.fields.Status.isUpdateable()
      ) {
        SystemModeActions actions = new SystemModeActions(
          'ExternalCaseStatusActions',
          'updateCaseStatusFromLatestExternalStatus'
        );
        actions.updateRecords(casesToUpdate, 'External_Case_Status__c');
      } else {
        CommonUtil.logAndThrowIAE(
          'ExternalCaseStatusActions',
          'updateCaseStatusFromLatestExternalStatus',
          'Not enough permissions to update Case.'
        );
      }
    }
  }
}

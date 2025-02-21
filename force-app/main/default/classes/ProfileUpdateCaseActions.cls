/**
 * @author Mani
 * @since 12/2024
 * @description This acts as a action class profile update case types to perform the business process and automations
 */
public with sharing class ProfileUpdateCaseActions {
  @TestVisible
  private static Group idOpsQueue = QueryQueue.get('ID_Ops_Queue');
  public static final string CASE_TYPE_LEGAL_NAME = 'Legal Name QA';
  public static final string PASS = 'Pass';
  public static final string FAILED_DOCUMENT_INVALID = 'Failed - Document Provided Invalid';
  public static final string FAILED_DOCUMENT_QUALITY = 'Failed - Document Quality Issue';
  private static final Set<String> LEGALNAME_NOTIFICATION_STATUSES = new Set<String>{
    PASS,
    FAILED_DOCUMENT_INVALID,
    FAILED_DOCUMENT_QUALITY
  };
  private static final ProfileUpdateCaseRepository REPOSITORY = (ProfileUpdateCaseRepository) Lib_InstanceProvider.forType(
    ProfileUpdateCaseRepository.class
  );
  private static final ProfileStagingHandler PROFILE_STAGING = (ProfileStagingHandler) Lib_InstanceProvider.forType(
    ProfileStagingHandler.class
  );
  /**
   * @description Assign newly created Profile Update Cases to ID Ops Queue
   * @param records Case records being inserted by trigger
   */
  public static void setOwnerToIDOpsQueue(List<Case> records) {
    ListUtil.setField(records, Case.OwnerId, idOpsQueue.Id);
  }

  /**
   * @description when a legal name cases are closed, cloud events will be published to send email communications
   * @param records Case records being updated by trigger
   * @param oldMap old instaces Case records being updated by trigger
   */
  public static void legalNameNotifications(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> validCases = ListUtil.filter(records, oldMap)
      .equals(Case.Type, CASE_TYPE_LEGAL_NAME)
      .changedTo(Case.Status, GetHelpConstants.CLOSED_STATUS)
      .equals(Case.Fraud_Review_Outcome__c, LEGALNAME_NOTIFICATION_STATUSES)
      .toList();
    Set<Id> caseIds = ListUtil.getIds(validCases, Case.Id);
    List<Case> caseToSendNotification = REPOSITORY.getLegalNameCaseForNotification(
      caseIds
    );
    List<CloudEventModel> cloudEventModels = new List<CloudEventModel>();
    for (Case theCase : caseToSendNotification) {
      cloudEventModels.add(new LegalNameCaseCloudEventModel(theCase));
    }
    CloudEventController.publishCloudEvents(cloudEventModels);
  }

  /**
   * @description when case's Review Outcome is set to 'Pass', a staging record will be created and a Cloud Event will be published
   * @param records Case records being updated by trigger
   * @param oldMap old instaces Case records being updated by trigger
   */
  public static void sendLegalNameUpdateToOCV(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> validCases = ListUtil.filter(records, oldMap)
      .equals(Case.Type, CASE_TYPE_LEGAL_NAME)
      .changedTo(Case.Fraud_Review_Outcome__c, PASS)
      .toList();

    Map<Id, Case> accIdToCaseMap = (Map<Id, Case>) ListUtil.mapBy(
      validCases,
      Case.AccountId
    );
    List<Account> acctRecords = REPOSITORY.getAccounts(accIdToCaseMap.keySet());

    PROFILE_STAGING.process(
      new ProfileUpdateCaseStagingConfig(accIdToCaseMap),
      acctRecords,
      null
    );
  }
}

/**
 * @description controller class for CaseNotificationConfirmation lwc
 * @author Duc Nam Le
 * @since 08/2023
 */
public with sharing class CaseSendCommunicationController {
  private static final String STATUS_PENDING_DOCUMENTS = 'status.pending_documents';
  private static final String KYC_QA_EMAIL_COMMUNICATION_CHATTER_MSG = 'Automated KYC QA Email Communication has been successfully sent to the customer.';

  private static final CaseSendCommunicationRepository CASE_SEND_COMM_REPOSITORY = (CaseSendCommunicationRepository) Lib_InstanceProvider.forType(
    CaseSendCommunicationRepository.class
  );

  /**
   * @description method to send email notification to customer by case record ID
   * @param recordId Salesforce ID of the Case record from the lwc component
   */
  @AuraEnabled
  public static void sendCommunication(String recordId) {
    List<CloudEventModel> cloudEventModels = generateCloudEventModel(
      new List<String>{ recordId }
    );
    List<sObject> publishingResults = CloudEventController.publishCloudEvents(
      cloudEventModels
    );
    if (publishingResults.isEmpty()) {
      throw new AuraHandledException(
        'Email notification request could not be sent.'
      );
    }
    ChatterUtils.makeAPost(
      recordId,
      KYC_QA_EMAIL_COMMUNICATION_CHATTER_MSG,
      ChatterUtils.POST_TYPE_TEXT
    );
  }

  /**
   * @description generate Cloud Event Models for send email notification
   * @param caseIds List of case record ids
   * @return List<CloudEventModel> List of Case Cloud Event Model
   */
  @TestVisible
  private static List<CloudEventModel> generateCloudEventModel(
    List<String> caseIds
  ) {
    List<Case> cases = CASE_SEND_COMM_REPOSITORY.getRelatedCases(caseIds);
    Set<Id> ownerIds = ListUtil.getIds(cases, Case.OwnerId);
    Map<Id, User> ownerUsers = new Map<Id, User>(
      CASE_SEND_COMM_REPOSITORY.getUsers(ownerIds)
    );
    Map<Id, Group> ownerGroups = new Map<Id, Group>(
      CASE_SEND_COMM_REPOSITORY.getGroups(ownerIds)
    );
    return getCloudEventModel(cases, ownerUsers, ownerGroups);
  }

  /**
   * @description generate Cloud Event Models for send email notification
   * @param cases List of case records
   * @param ownerUsers Map of cases' owners users
   * @param ownerGroups Map of cases' owners' groups
   * @return List<CloudEventModel> List of Case Cloud Event Model
   */
  @TestVisible
  private static List<CloudEventModel> getCloudEventModel(
    List<Case> cases,
    Map<Id, User> ownerUsers,
    Map<Id, Group> ownerGroups
  ) {
    List<CloudEventModel> cloudEventModels = new List<CloudEventModel>();
    for (Case caseItem : cases) {
      CloudEventModel.UserModel ownerModel = CloudEventModel.getCaseOwnerModel(
        caseItem.OwnerId,
        ownerUsers,
        ownerGroups
      );
      cloudEventModels.add(
        new AutoKYCQACaseCloudEventModel(
          caseItem,
          caseItem.Account,
          STATUS_PENDING_DOCUMENTS,
          caseItem.LastModifiedBy,
          ownerModel,
          caseItem.CustomerOnboardingApplication__r
        )
      );
    }
    return cloudEventModels;
  }
}

/**
 * @author Lance Shi
 * @since  01/2023
 * @description Class to generate Cloud Event Model objects
 * witout sharing: to allow trigger publish Clound Event when users create/update Case/ExternalCaseStatus
 */
public without sharing class ExternalCaseStatusCEController {
  private static final DisputeExternalCaseStatusRepository DISPUTE_EXTERNALCASESTATUS_REPOSITORY = (DisputeExternalCaseStatusRepository) Lib_InstanceProvider.forType(
    DisputeExternalCaseStatusRepository.class
  );

  /**
   * @description method to be called in afterInsert, publish cloud event for External Case Status insertion
   * @param externalCaseStatuses list of External Case Status records
   */
  public static void publishCloudEvents(
    List<External_Case_Status__c> externalCaseStatuses
  ) {
    List<CloudEventModel> cloudEventModels = generateCloudEventModel(
      externalCaseStatuses
    );
    CloudEventController.publishCloudEvents(cloudEventModels);
  }

  /**
   * @description generate Cloud Event Models for External Case Status
   * @param externalCaseStatuses External Case Status records
   * @return List<CloudEventModel> List of External Case Status Cloud Event Model
   */
  public static List<CloudEventModel> generateCloudEventModel(
    List<External_Case_Status__c> externalCaseStatuses
  ) {
    String action = 'created';
    List<CloudEventModel> cloudEventModels = new List<CloudEventModel>();
    Set<Id> relatedCaseIds = new Set<Id>();
    Set<Id> relatedUserIds = new Set<Id>();
    for (External_Case_Status__c externalCaseStatus : externalCaseStatuses) {
      relatedCaseIds.add(externalCaseStatus.Case__c);
      relatedUserIds.add(externalCaseStatus.LastModifiedById);
    }
    List<Case> relatedCaseList = DISPUTE_EXTERNALCASESTATUS_REPOSITORY.getRelatedCasesByCaseId(
      relatedCaseIds
    );
    Map<Id, Case> relatedCases = (Map<Id, Case>) ListUtil.mapBy(
      relatedCaseList,
      Case.Id
    );
    List<User> relatedUserList = DISPUTE_EXTERNALCASESTATUS_REPOSITORY.getRelatedUsersByUserId(
      relatedUserIds
    );
    Map<Id, User> relatedusers = (Map<Id, User>) ListUtil.mapBy(
      relatedUserList,
      User.Id
    );

    for (External_Case_Status__c externalCaseStatus : externalCaseStatuses) {
      Id relatedCaseId = externalCaseStatus.Case__c;
      Case relatedCase = relatedCases.get(relatedCaseId);
      User relatedUser = relatedusers.get(externalCaseStatus.LastModifiedById);
      CloudEventModel cloudEventModel = new ExternalCaseStatusCloudEventModel(
        externalCaseStatus,
        relatedCase,
        action,
        relatedUser
      );
      CloudEventModel cloudEventModelV2 = new ExternalCaseStatusCloudEventModelV2(
        externalCaseStatus,
        relatedCase,
        action,
        relatedUser
      );
      cloudEventModels.add(cloudEventModel);
      cloudEventModels.add(cloudEventModelV2);
    }
    return cloudEventModels;
  }
}

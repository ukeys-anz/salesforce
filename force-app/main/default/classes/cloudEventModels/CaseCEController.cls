/**
 * @author Lance Shi
 * @since  01/2023
 * @description Class to generate Cloud Event Model objects
 * without sharing: to allow trigger to publish cloud event on afterInsert
 */
public without sharing class CaseCEController {
  public static set<Id> caseCloudSet = new Set<Id>();
  private static set<Id> cloudEventCaseRecordTypes = new Set<Id>{
    RTCase.atmDispute,
    RTCase.cardDispute,
    RTCase.directDebitDispute,
    RTCase.directEntryDispute,
    RTCase.nppDispute,
    RTCase.bpayDispute,
    RTCase.payToDispute
  };
  private static set<Id> caseRecordTypesForAlpha1 = new Set<Id>{
    RTCase.atmDispute,
    RTCase.cardDispute
  };

  private static final CaseDisputesRepository CASE_DISPUTES_REPOSITORY = (CaseDisputesRepository) Lib_InstanceProvider.forType(
    CaseDisputesRepository.class
  );
  /**
   * @description method to be called to clear the current set cache. In case of multiple dml to same element need to call this
   */
  public static void clearCloudset() {
    caseCloudSet = new Set<Id>();
  }
  /**
   * @description method to be called in afterInsert, publish cloud event for Case insertion
   * @param theCases list of Case records
   */
  public static void publishCloudEvents(List<Case> theCases) {
    List<CloudEventModel> cloudEventModels = generateCloudEventModel(
      getValidCloudEventCase(theCases)
    );
    CloudEventController.publishCloudEvents(cloudEventModels);
  }

  /**
   * @description method to be called in afterUpdate, publish cloud event for Case update
   * @param theCasesNew Case records with new values
   * @param theCasesOld Case records with old values
   */
  public static void publishCloudEvents(
    List<Case> theCasesNew,
    Map<Id, Case> theCasesOld
  ) {
    List<CloudEventModel> cloudEventModels = generateCloudEventModel(
      getValidCloudEventCase(theCasesNew),
      getValidCloudEventCase(theCasesOld)
    );
    CloudEventController.publishCloudEvents(cloudEventModels);
  }

  /**
   * @description Filters the Case records valid for Cloud Event
   * @param caseList Case records List
   * @return List<Case> List of valid Case for Cloud Event
   */
  private static List<Case> getValidCloudEventCase(List<Case> caseList) {
    List<Case> validCases = new List<Case>();
    for (Case rec : caseList) {
      if (cloudEventCaseRecordTypes.contains(rec.RecordTypeId)) {
        validCases.add(rec);
      }
    }
    return validCases;
  }

  /**
   * @description Filters the Case records valid for Cloud Event
   * @param caseMap Case records Map
   * @return Map<Id, Case> Map of valid Case for Cloud Event
   */
  private static Map<Id, Case> getValidCloudEventCase(Map<Id, Case> caseMap) {
    List<Case> validCases = getValidCloudEventCase(caseMap.values());
    return new Map<Id, Case>(validCases);
  }

  /**
   * @description get related accounts map for the case list
   * @param theCases Case records
   * @return Map<Id, Account> Map of Account Id and related Accounts
   */
  private static Map<Id, Account> getRelatedAccounts(List<Case> theCases) {
    Set<Id> relatedAccountIds = ListUtil.getIds(theCases, Case.AccountId);
    Map<Id, Account> relatedAccounts = CASE_DISPUTES_REPOSITORY.getAccountDetailsFromId(
      relatedAccountIds
    );
    return relatedAccounts;
  }

  /**
   * @description get related users map for the case list
   * @param theCases Case records
   * @return Map<Id, User> Map of user Id and related Users
   */
  private static Map<Id, User> getRelatedUsers(List<Case> theCases) {
    Set<Id> relatedUserIds = ListUtil.getIds(theCases, Case.LastModifiedById);
    Map<Id, User> relatedUsers = CASE_DISPUTES_REPOSITORY.getUserDetailsFromId(
      relatedUserIds
    );
    return relatedUsers;
  }

  /**
   * @description get related owners map for the case list
   * @param theCases Case records
   * @param theCasesOld Old case records
   * @return Map<Id, User> Map of user Id and related case Owners
   */
  private static Map<Id, CloudEventModel.UserModel> getRelatedOwners(
    List<Case> theCases,
    List<Case> theCasesOld
  ) {
    Set<Id> relatedUserOrQueueIds = new Set<Id>();
    for (Case theCase : theCases) {
      relatedUserOrQueueIds.add(theCase.OwnerId);
    }
    for (Case theCase : theCasesOld) {
      relatedUserOrQueueIds.add(theCase.OwnerId);
    }
    Map<Id, CloudEventModel.UserModel> relatedUsers = new Map<Id, CloudEventModel.UserModel>();

    for (
      User userRec : CASE_DISPUTES_REPOSITORY.getUserDetailsFromId(
          relatedUserOrQueueIds
        )
        .values()
    ) {
      relatedUsers.put(userRec.Id, new CloudEventModel.UserModel(userRec));
    }
    for (
      Group groupRec : CASE_DISPUTES_REPOSITORY.getGroupDetails(
        relatedUserOrQueueIds
      )
    ) {
      relatedUsers.put(groupRec.Id, new CloudEventModel.UserModel(groupRec));
    }

    return relatedUsers;
  }

  /**
   * @description generate Cloud Event Models for Case
   * @param theCases Case records
   * @return List<CloudEventModel> List of Case Cloud Event Model
   */
  public static List<CloudEventModel> generateCloudEventModel(
    List<Case> theCases
  ) {
    return generateCloudEventModel(theCases, new Map<Id, Case>());
  }

  /**
   * @description generate Cloud Event Models for Case only when there is a change in the data
   * @param theCasesNew Case records with new values
   * @param theCasesOld Case records with old values
   * NcssMethodCount Suppressed : To have all the code lines together in one place. Code generates cloud event models on insert, update and status change
   * @return List<CloudEventModel> List of Case Cloud Event Model
   */
  @SuppressWarnings('PMD.CognitiveComplexity')
  public static List<CloudEventModel> generateCloudEventModel(
    List<Case> theCasesNew,
    Map<Id, Case> theCasesOld
  ) {
    List<CloudEventModel> cloudEventModels = new List<CloudEventModel>();
    if (theCasesNew.isEmpty()) {
      return cloudEventModels;
    }

    Map<Id, Account> relatedAccounts = getRelatedAccounts(theCasesNew);
    Map<Id, User> relatedUsers = getRelatedUsers(theCasesNew);
    Map<Id, CloudEventModel.UserModel> relatedOwners = getRelatedOwners(
      theCasesNew,
      theCasesOld.values()
    );

    for (Case theCaseNew : theCasesNew) {
      if (caseCloudSet.contains(theCaseNew.Id)) {
        continue;
      }
      String caseRecordType = QueryRT.of(Case.SObjectType)
        .get(theCaseNew.RecordTypeId)
        .getDeveloperName();
      Id relatedAccountId = theCaseNew.AccountId;
      Account relatedAccount = relatedAccounts.get(relatedAccountId);
      User relatedUser = relatedUsers.get(theCaseNew.LastModifiedById);
      CloudEventModel.UserModel relatedOwner = relatedOwners.get(
        theCaseNew.OwnerId
      );
      Case theCaseOld = theCasesOld.get(theCaseNew.Id);

      if (theCaseOld == null) {
        CloudEventModel ceModel = CloudEventBuildHelper.createCloudEvent(
          theCaseNew,
          relatedAccount,
          'created',
          relatedUser,
          relatedOwner
        );
        cloudEventModels.add(ceModel);
        if (caseRecordTypesForAlpha1.contains(theCaseNew.RecordTypeId)) {
          cloudEventModels.add(
            CloudEventBuildHelper.createCloudEventForAlpha1(
              theCaseNew,
              relatedAccount,
              'created',
              relatedUser,
              relatedOwner
            )
          );
        }
        caseCloudSet.add(theCaseNew.Id);
        continue;
      }
      CloudEventModel.UserModel oldOwner = relatedOwners.get(
        theCaseOld.OwnerId
      );

      String caseNewDataPayload = CloudEventBuildHelper.getCloudEventDataPayload(
        theCaseNew,
        relatedAccount,
        relatedOwner,
        relatedUser
      );
      String caseOldDataPayload = CloudEventBuildHelper.getCloudEventDataPayload(
        theCaseOld,
        relatedAccount,
        oldOwner,
        relatedUser
      );
      if (caseNewDataPayload != caseOldDataPayload) {
        CloudEventModel ceModel = CloudEventBuildHelper.createCloudEvent(
          theCaseNew,
          relatedAccount,
          'updated',
          relatedUser,
          relatedOwner
        );
        cloudEventModels.add(ceModel);
        if (caseRecordTypesForAlpha1.contains(theCaseNew.RecordTypeId)) {
          cloudEventModels.add(
            CloudEventBuildHelper.createCloudEventForAlpha1(
              theCaseNew,
              relatedAccount,
              'updated',
              relatedUser,
              relatedOwner
            )
          );
        }
        caseCloudSet.add(theCaseNew.Id);
      }
      if (theCaseNew.Status != theCaseOld.Status) {
        CloudEventModel ceModel = CloudEventBuildHelper.createCloudEvent(
          theCaseNew,
          relatedAccount,
          'status.' + theCaseNew.Status.toLowerCase().replace(' ', '_'),
          relatedUser,
          relatedOwner
        );
        cloudEventModels.add(ceModel);
        if (caseRecordTypesForAlpha1.contains(theCaseNew.RecordTypeId)) {
          cloudEventModels.add(
            CloudEventBuildHelper.createCloudEventForAlpha1(
              theCaseNew,
              relatedAccount,
              'status.' + theCaseNew.Status.toLowerCase().replace(' ', '_'),
              relatedUser,
              relatedOwner
            )
          );
        }
      }
    }

    return cloudEventModels;
  }
}

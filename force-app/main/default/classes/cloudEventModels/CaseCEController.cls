/**
 * @author Lance Shi
 * @since  01/2023
 * @description Class to generate Cloud Event Model objects
 * without sharing: to allow trigger to publish cloud event on afterInsert
 */
public without sharing class CaseCEController {
  public static set<Id> caseCloudSet = new Set<Id>();
  private static set<Id> cloudEventCaseRecordTypes = new Set<Id>{
    GetHelpConstants.ATM_DISPUTE_RT_ID,
    GetHelpConstants.CARD_DISPUTE_RT_ID
  };
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
    Set<Id> relatedAccountIds = new Set<Id>();
    for (Case theCase : theCases) {
      relatedAccountIds.add(theCase.AccountId);
    }
    Map<Id, Account> relatedAccounts = new Map<Id, Account>(
      [
        SELECT
          Id,
          FirstName,
          LastName,
          OCV_ID__c,
          Source_System_ID__c,
          Source_System_Name__c,
          PersonEmail,
          PersonMobilePhone
        FROM Account
        WHERE Id IN :relatedAccountIds
      ]
    );

    return relatedAccounts;
  }

  /**
   * @description get related users map for the case list
   * @param theCases Case records
   * @return Map<Id, User> Map of user Id and related Users
   */
  private static Map<Id, User> getRelatedUsers(List<Case> theCases) {
    Set<Id> relatedUserIds = new Set<Id>();
    for (Case theCase : theCases) {
      relatedUserIds.add(theCase.LastModifiedById);
    }
    Map<Id, User> relatedUsers = new Map<Id, User>(
      [SELECT Id, Email, UserName FROM User WHERE Id IN :relatedUserIds]
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

    for (User userRec : [
      SELECT Id, Email, UserName
      FROM User
      WHERE Id IN :relatedUserOrQueueIds
    ]) {
      relatedUsers.put(userRec.Id, new CloudEventModel.UserModel(userRec));
    }
    for (Group groupRec : [
      SELECT Id, Email, Name
      FROM Group
      WHERE Id IN :relatedUserOrQueueIds
    ]) {
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
   * @return List<CloudEventModel> List of Case Cloud Event Model
   */
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

    List<CloudEventModel> ceList = new List<CloudEventModel>();
    for (Case theCaseNew : theCasesNew) {
      if (caseCloudSet.contains(theCaseNew.Id)) {
        continue;
      }

      Id relatedAccountId = theCaseNew.AccountId;
      Account relatedAccount = relatedAccounts.get(relatedAccountId);
      User relatedUser = relatedUsers.get(theCaseNew.LastModifiedById);
      CloudEventModel.UserModel relatedOwner = relatedOwners.get(
        theCaseNew.OwnerId
      );
      Case theCaseOld = theCasesOld.get(theCaseNew.Id);

      if (theCaseOld == null) {
        CloudEventModel ceModel = getCloudEventModel(
          theCaseNew,
          relatedAccount,
          'created',
          relatedUser,
          relatedOwner
        );
        cloudEventModels.add(ceModel);
        caseCloudSet.add(theCaseNew.Id);
        continue;
      }
      CloudEventModel.UserModel oldOwner = relatedOwners.get(
        theCaseOld.OwnerId
      );

      String caseNewDataPayload = getCloudEventDataPayload(
        theCaseNew,
        relatedAccount,
        relatedOwner
      );
      String caseOldDataPayload = getCloudEventDataPayload(
        theCaseOld,
        relatedAccount,
        oldOwner
      );
      if (caseNewDataPayload != caseOldDataPayload) {
        CloudEventModel ceModel = getCloudEventModel(
          theCaseNew,
          relatedAccount,
          'updated',
          relatedUser,
          relatedOwner
        );
        cloudEventModels.add(ceModel);
        caseCloudSet.add(theCaseNew.Id);
      }
      if (theCaseNew.Status != theCaseOld.Status) {
        CloudEventModel ceModel = getCloudEventModel(
          theCaseNew,
          relatedAccount,
          'status.' + theCaseNew.Status.toLowerCase().replace(' ', '_'),
          relatedUser,
          relatedOwner
        );
        cloudEventModels.add(ceModel);
      }
    }

    return cloudEventModels;
  }

  /**
   * @description get Cloud Event Models for Case
   * @param theCase Case record
   * @param theAccount related Account record
   * @param action created, or updated
   * @param theUser related last modifed user
   * @param theOwner related owner user
   * @return CloudEventModel Case Cloud Event Model
   */
  private static CloudEventModel getCloudEventModel(
    Case theCase,
    Account theAccount,
    String action,
    User theUser,
    CloudEventModel.UserModel theOwner
  ) {
    CloudEventModel cloudEventModel;
    if (theCase.RecordTypeId == GetHelpConstants.ATM_DISPUTE_RT_ID) {
      cloudEventModel = new ATMDisputeCaseCloudEventModel(
        theCase,
        theAccount,
        action,
        theUser,
        theOwner
      );
    } else if (theCase.RecordTypeId == GetHelpConstants.CARD_DISPUTE_RT_ID) {
      cloudEventModel = new CardDisputeCaseCloudEventModel(
        theCase,
        theAccount,
        action,
        theUser,
        theOwner
      );
    }
    return cloudEventModel;
  }

  /**
   * @description get ce_data payload for Case, to be used in comparing the new data model with the old data model
   * @param theCase Case record
   * @param theAccount related Account record
   * @param theOwner related owner user record
   * @return String ce_data payload for cloud event
   */
  private static String getCloudEventDataPayload(
    Case theCase,
    Account theAccount,
    CloudEventModel.UserModel theOwner
  ) {
    String cloudEventDataPayload;
    if (theCase.RecordTypeId == GetHelpConstants.ATM_DISPUTE_RT_ID) {
      ATMDisputeCaseCloudEventModel.ATMDisputeCaseCloudEventDataModel cloudEventDataModel = new ATMDisputeCaseCloudEventModel.ATMDisputeCaseCloudEventDataModel(
        theCase,
        theAccount,
        theOwner
      );
      cloudEventDataPayload = JSON.serialize(cloudEventDataModel);
    } else if (theCase.RecordTypeId == GetHelpConstants.CARD_DISPUTE_RT_ID) {
      CardDisputeCaseCloudEventModel.CardDisputeCaseCloudEventDataModel cloudEventDataModel = new CardDisputeCaseCloudEventModel.CardDisputeCaseCloudEventDataModel(
        theCase,
        theAccount,
        theOwner
      );
      cloudEventDataPayload = JSON.serialize(cloudEventDataModel);
    }
    return cloudEventDataPayload;
  }
}

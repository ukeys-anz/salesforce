/**
 * @author Kopal Goswami
 * @since 11/2024
 * @description AccountClosureCaseActionsHelper class is to handle all the Account Closure Case Actions
 */

public with sharing class AccountClosureCaseActionsHelper {
  public static Group accountClosureQueue = QueryQueue.get(
    'Account_Closure_Queue'
  );

  /**
   * @description This method sets the field to create new case group record if the Case Group(Parent case) is not found .
   * @param cases List of account closure cases
   * @param accountIdToExistingParentCaseMap  map of account id and case details of the Parent case
   * @return List of new parent cases to be inserted.
   */

  public static List<Case> setFieldsForNewParentCase(
    List<Case> cases,
    Map<Id, Case> accountIdToExistingParentCaseMap
  ) {
    List<Case> newCaseGroupList = new List<Case>();
    for (Case closureCase : cases) {
      if (
        (accountIdToExistingParentCaseMap == null) ||
        accountIdToExistingParentCaseMap != null &&
        !accountIdToExistingParentCaseMap.containsKey(closureCase.AccountId)
      ) {
        Case newCaseGroup = new Case();
        newCaseGroup.RecordTypeId = RTCase.caseGroup;
        newCaseGroup.AccountId = closureCase.AccountId;
        newCaseGroup.Status = GetHelpConstants.OPEN_STATUS;
        newCaseGroup.Type = GetHelpConstants.ACCOUNT_CLOSURE;
        newCaseGroupList.add(newCaseGroup);
      }
    }
    return newCaseGroupList;
  }

  /**
   * @description This method sets the field to create new case group record if the Case Group(Parent case) is not found .
   * @param cases List of account closure cases
   * @param accountIdToExistingParentCaseMap  map of account id and case details of the Existing Parent case
   * @param accountIdToNewParentCaseMap map of account id and case details of the New Parent case
   * @return List of new parent cases to be inserted.
   */
  public static List<Case> assignClosureCasesToParentCase(
    List<Case> cases,
    Map<Id, Case> accountIdToExistingParentCaseMap,
    Map<Id, Case> accountIdToNewParentCaseMap
  ) {
    List<Case> assignedCasesList = new List<Case>();
    for (Case caseRecord : cases) {
      Case parentCaseRecord = accountIdToExistingParentCaseMap.get(
          caseRecord.AccountId
        ) != null
        ? accountIdToExistingParentCaseMap.get(caseRecord.AccountId)
        : accountIdToNewParentCaseMap.get(caseRecord.AccountId);

      if (parentCaseRecord != null) {
        caseRecord.ParentId = parentCaseRecord.Id;
      }

      if (parentCaseRecord.OwnerId != null) {
        caseRecord.OwnerId = parentCaseRecord.OwnerId;
      }
      assignedCasesList.add(caseRecord);
    }
    return assignedCasesList;
  }

  /**
   * @description This method sets the fields of child case similar as parent case.
   * @param childCaseRecords list of child case records linked to parent cases
   * @param oldMap holds the field values of old record
   * @param parentIdAndCaseDetailsMap map of parent case id and the parent case details
   * @param fields name of the fields to be updated
   * @return list of child case records with OwnerId field value similar as parent case.
   */
  public static List<Case> setChildCaseField(
    List<Case> childCaseRecords,
    Map<Id, Case> oldMap,
    Map<Id, Case> parentIdAndCaseDetailsMap,
    Set<SObjectField> fields
  ) {
    for (Case childCase : childCaseRecords) {
      Case parentCase = parentIdAndCaseDetailsMap.get(childCase.ParentId);

      for (SObjectField fieldName : fields) {
        if (
          RecordComparisonUtil.fieldWasChanged(
            parentCase,
            oldMap.get(parentCase.Id),
            fieldName
          )
        ) {
          Object fieldValue = parentCase.get(fieldName);
          childCase.put(fieldName, fieldValue);
        }
      }
    }
    return childCaseRecords;
  }

  /**
   * @description Assign Owner as Account Closure Queue for escalated cases
   * @param escalatedCases List of Cases with status updated as Escalated.
   */
  public static void assignOwnerAsQueue(List<Case> escalatedCases) {
    for (Case escalatedCase : escalatedCases) {
      escalatedCase.OwnerId = accountClosureQueue.Id;
    }
  }

  /**
   * @description Assign Case subject
   * @param cases list of cases for which subject need to updated
   * @param accountIdToAccountInfoMap Map of accountId with account details
   */
  public static void assignCaseSubject(
    List<Case> cases,
    Map<Id, Account> accountIdToAccountInfoMap
  ) {
    if (accountIdToAccountInfoMap == null) {
      return;
    }

    for (Case caserecord : cases) {
      if (CheckCaseRecordType.isAccountClosure(caserecord, null)) {
        caserecord.Subject =
          'Account Closure' +
          ' - ' +
          accountIdToAccountInfoMap.get(caserecord.AccountId).Name;
        continue;
      }

      if (CheckCaseRecordType.isCaseGroup(caserecord, null)) {
        caserecord.Subject =
          'Case Group' +
          ' - ' +
          accountIdToAccountInfoMap.get(caserecord.AccountId).Name;
      }
    }
  }

  /**
   * @description Set Flags on the Parent Case
   * @param parentCaseIds set of parent case Ids for the account closure cases which are inserted , updated or deleted
   * @param parentIdsForInitiatingClosure set of parent Id for the account closure cases which are in escalated status and substatus as failure or null
   * @param parentIdsForAccountClosure set of parent Id for the account closure cases which are in escalated status and substatus as Success
   * @return list of parent case records with set flag values
   */
  public static List<Case> setParentFieldValues(
    Set<Id> parentCaseIds,
    Set<Id> parentIdsForInitiatingClosure,
    Set<Id> parentIdsForAccountClosure
  ) {
    List<Case> parentCasestoUpdate = new List<Case>();

    for (Id parentId : parentCaseIds) {
      Boolean initiateFlag = false;
      Boolean closeFlag = false;

      if (parentIdsForInitiatingClosure.contains(parentId)) {
        initiateFlag = true;
      }

      if (parentIdsForAccountClosure.contains(parentId)) {
        closeFlag = true;
      }

      parentCasestoUpdate.add(
        new Case(
          Id = parentId,
          Show_Initiate_Account_Closure__c = initiateFlag,
          Show_Account_Closure__c = closeFlag
        )
      );
    }
    return parentCasesToUpdate;
  }
}

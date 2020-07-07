/**
 *
 * @author Pavan Kumar Ananta
 * @since 02/2020
 * @description Common Case Action methods
 */

public with sharing class CaseCommonActions {
  /**
   * @description completeAfterInsertActions is called after onAfterInsert is finished to complete any pending actions
   * @param updateCaseList updateCaseList to be cleared after insert
   * <p>
   * <b>Note:</b> It is important to clear {@link CheckRecursive.#setOfIDs setOfIDs} as we are updating the same object (Case) in onAfterInsert
   * and we don't want the update to interfere with the update DML if it were in same transaction.
   */
  public static void completeAfterInsertActions(List<Case> updateCaseList) {
    //It is improtant to clear the CheckRecursive Set of Ids here as the onAfterInsert has already updated its records above
    //and shouldn't interfere with the records which are meant for update DML.
    CheckRecursive.setOfIDs.clear();
    updateCaseList.clear();
  }

  /**
   * @description completeAfterUpdateActions method is called after finishing all the necessary steps for update. So, clear the list if
   * something needs to be done in same transaction
   * @param updateCaseList list that needs to be cleared
   */
  public static void completeAfterUpdateActions(List<Case> updateCaseList) {
    updateCaseList.clear();
  }

  /**
   * @description  Copy case Number to Original Case Number(CaseNumber__c) if CaseNumber__c is empty
   * @param records The actual case record List
   * @param caseToBeChanged The record List that needs to be changed
   */
  public static void copyCaseNumber(
    List<Case> records,
    List<Case> caseToBeChanged
  ) {
    for (Integer i = 0; i < caseToBeChanged.size(); i++) {
      if (String.isBlank(records.get(i).CaseNumber__c)) {
        caseToBeChanged.get(i).CaseNumber__c = records.get(i).CaseNumber;
      }
    }
  }

  /**
   * @description general method to handle case duration record generation and update
   * @param newList new trigger list values
   * @param newMap new trigger values
   * @param oldMap old trigger values
   */
  public static void handleCaseDurationGeneration(
    List<SObject> newList,
    Map<Id, SObject> newMap,
    Map<Id, SObject> oldMap
  ) {
    List<Case> caseToInsertDurations = new List<Case>();
    List<Id> caseToUpdateDurations = new List<Id>();

    for (Case c : (List<Case>) newList) {
      Case oldCase = (Case) oldMap.get(c.Id);
      if (oldCase.Status != c.Status) {
        if (oldCase.Status != 'Closed') {
          caseToUpdateDurations.add(c.Id);
        }
        if (c.Status != 'Closed') {
          caseToInsertDurations.add(c);
        }
      }
    }
    if (!caseToInsertDurations.isEmpty()) {
      generateCaseDurationList(caseToInsertDurations);
    }
    if (!caseToUpdateDurations.isEmpty()) {
      updateCaseDurationList(
        caseToUpdateDurations,
        (Map<Id, Case>) newMap,
        (Map<Id, Case>) oldMap
      );
    }
  }

  /**
   * @description generate initial case duration record
   * @param caseList The related case list to generatee case durations
   */
  public static void generateCaseDurationList(List<Case> caseList) {
    List<Case_Duration__c> cdToCreateList = new List<Case_Duration__c>();
    for (Case c : caseList) {
      Case_Duration__c cd = new Case_Duration__c();
      cd.Initial_Status__c = c.Status;
      cd.Start_Time__c = DateTime.now();
      cd.Case__c = c.Id;

      cdToCreateList.add(cd);
    }
    if (Case_Duration__c.sObjectType.getDescribe().isCreateable()) {
      insert cdToCreateList;
    }
  }

  /**
   * @description generate initial case duration record
   * @param relatedCaseList The related case list to update case durations
   * @param caseMap the trigger new map
   * @param oldCaseMap the trigger old map
   */
  public static void updateCaseDurationList(
    List<String> relatedCaseList,
    Map<Id, Case> caseMap,
    Map<Id, Case> oldCaseMap
  ) {
    List<Case_Duration__c> cdRelatedList = [
      SELECT
        Id,
        Initial_Status__c,
        End_Time__c,
        Start_Time__c,
        End_Status__c,
        Case__c,
        Case__r.BusinessHoursId
      FROM Case_Duration__c
      WHERE Case__c IN :relatedCaseList AND End_Time__c = NULL
    ];

    for (Case_Duration__c cd : cdRelatedList) {
      String oldStatus = oldCaseMap.get(cd.Case__c).Status;
      if (oldStatus == cd.Initial_Status__c) {
        cd.End_Status__c = caseMap.get(cd.Case__c).Status;
        cd.End_Time__c = DateTime.now();
        Decimal timeDifferenceInHours = DateTimeUtils.calculateHoursBetween(
          cd.Start_Time__c,
          cd.End_Time__c,
          cd.Case__r.BusinessHoursId
        );
        cd.Business_Hours_Age_Hours__c = timeDifferenceInHours.intValue();
        cd.Business_Hours_Age_Minutes__c =
          (timeDifferenceInHours - cd.Business_Hours_Age_Hours__c) *
          SFConstants.MIN_IN_HOUR;
      }
    }

    if (Case_Duration__c.sObjectType.getDescribe().isUpdateable()) {
      update cdRelatedList;
    }
  }
}

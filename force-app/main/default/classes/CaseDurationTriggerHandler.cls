/**
 * @author Lance Shi
 * @since 04/2020
 * @description  CaseDurationTriggerHandler is the handler class for Case Duration Trigger which extends Lib_TriggerHandler the trigger framework used.
 * We are checking recursion in after update so that update doesnt get called repeatedly for the same transaction.
 * Recursion is checked based on https://help.salesforce.com/articleView?id=000332407&type=1&mode=1
 */
public with sharing class CaseDurationTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public CaseDurationTriggerHandler() {
    super();
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    rollupDuration();
  }

  /**
   * @description roll up the business duration hours and minutes into Case object
   */
  private void rollupDuration() {
    List<Case_Duration__c> relatedCdList = retrieveCdList();
    if (!relatedCdList.isEmpty()) {
      Map<Id, List<Case_Duration__c>> caseToDurationMap = retrieveCaseDurationMap(
        relatedCdList
      );
      updateCaseDurationTime(caseToDurationMap);
    }
  }

  /**
   * @description retrieve the related case duration list for further calculation
   * @return `List<Case_Duration__c>`
   */
  private List<Case_Duration__c> retrieveCdList() {
    List<String> relatedCaseIdList = new List<String>();
    for (Case_Duration__c cd : (List<Case_Duration__c>) Trigger.New) {
      relatedCaseIdList.add(cd.Case__c);
    }

    List<Case_Duration__c> relatedCdList;
    if (Case_Duration__c.sObjectType.getDescribe().isQueryable()) {
      relatedCdList = [
        SELECT
          Id,
          Initial_Status__c,
          Case__c,
          Business_Hours_Age_Hours__c,
          Business_Hours_Age_Minutes__c
        FROM Case_Duration__c
        WHERE
          Business_Hours_Age_Hours__c != NULL
          AND Case__c IN :relatedCaseIdList
          AND Business_Hours_Age_Minutes__c != NULL
          AND Initial_Status__c != 'On Hold'
          AND Initial_Status__c != 'Closed'
      ];
    }

    return relatedCdList;
  }

  /**
   * @description retrieve the related case to case duration list map for further calculation
   * @param relatedCdList the list of case Ids to be considered
   * @return `Map<Id, List<Case_Duration__c>>`
   */
  private Map<Id, List<Case_Duration__c>> retrieveCaseDurationMap(
    List<Case_Duration__c> relatedCdList
  ) {
    Map<Id, List<Case_Duration__c>> caseToDurationMap = new Map<Id, List<Case_Duration__c>>();

    for (Case_Duration__c cd : relatedCdList) {
      if (!caseToDurationMap.containsKey(cd.Case__c)) {
        caseToDurationMap.put(cd.Case__c, new List<Case_Duration__c>());
      }
      caseToDurationMap.get(cd.Case__c).add(cd);
    }

    return caseToDurationMap;
  }

  /**
   * @description rollup case duration time to case record
   * @param caseToDurationMap the map of case to case duration list
   */
  private void updateCaseDurationTime(
    Map<Id, List<Case_Duration__c>> caseToDurationMap
  ) {
    List<Case> caseToUpdateList = new List<Case>();
    for (Id caseId : caseToDurationMap.keySet()) {
      decimal statusChangeDuration = 0;
      for (Case_Duration__c cd : caseToDurationMap.get(caseId)) {
        statusChangeDuration += (decimal) (cd.Business_Hours_Age_Hours__c +
          (cd.Business_Hours_Age_Minutes__c / 60))
          .setScale(2, RoundingMode.HALF_UP);
      }
      Case c = new Case();
      c.Id = caseId;
      c.Status_Change_Duration__c = statusChangeDuration;
      caseToUpdateList.add(c);
    }
    if (Case.sObjectType.getDescribe().isUpdateable()) {
      update caseToUpdateList;
    }
  }
}

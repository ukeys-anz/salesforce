/**
 *
 * @author Pavan Kumar Ananta
 * @since 02/2020
 * @description Common Case Action methods
 */

public with sharing class CaseCommonActions {
  /**
   * @description completeAfterInsertActions is called after onAfterInsert is finished to complete any pending actions
   * <p>
   * <b>Note:</b> It is important to clear {@link CheckRecursive.#setOfIDs setOfIDs} as we are updating the same object (Case) in onAfterInsert
   * and we don't want the update to interfere with the update DML if it were in same transaction.
   */
  public static void completeAfterInsertActions() {
    //It is improtant to clear the CheckRecursive Set of Ids here as the onAfterInsert has already updated its records above
    //and shouldn't interfere with the records which are meant for update DML.
    CheckRecursive.setOfIDs.clear();
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
}

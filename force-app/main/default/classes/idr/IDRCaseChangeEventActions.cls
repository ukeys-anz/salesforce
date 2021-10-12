/**
 * @description CMOS Handler class for the Case asynchronous trigger.
 * This fires after all database transactions on case completed, avoiding problems when a banker marks a case as restricted and looses access to it.
 * @author Olivier Saier
 * @since 06/2021
 * @group IDR(Internal Dispute Resolution)
 */
public with sharing class IDRCaseChangeEventActions {
  /**
   * @description Restricts or unrestricts cases
   * @param records The published Case change events
   */
  public static void updateCaseRestrictions(CaseChangeEvent[] records) {
    if (
      Case.sObjectType.getDescribe().isQueryable() &&
      Case.sObjectType.getDescribe().isUpdateable() &&
      Schema.sObjectType.Case.fields.IDR_Is_Restricted__c.isUpdateable()
    ) {
      Set<String> caseIdsToRestrict = getChangeCaseIds(records)
        .get('ToRestrict');
      Set<String> caseIdsToUnRestrict = getChangeCaseIds(records)
        .get('ToUnRestrict');
      Case[] casesToRestrict = new List<Case>();
      Case[] casesToUnRestrict = new List<Case>();
      Case[] casesToUpdate = new List<Case>();

      if (caseIdsToRestrict.size() != 0) {
        casesToRestrict = [
          SELECT IDR_Is_Restricted__c
          FROM Case
          WHERE Id IN :caseIdsToRestrict AND IDR_Is_Restricted__c = FALSE
        ];
        for (Case c : casesToRestrict) {
          c.IDR_Is_Restricted__c = true;
        }
      }
      if (caseIdsToUnRestrict.size() != 0) {
        casesToUnRestrict = [
          SELECT IDR_Is_Restricted__c
          FROM Case
          WHERE Id IN :caseIdsToUnRestrict AND IDR_Is_Restricted__c = TRUE
        ];
        for (Case c : casesToUnRestrict) {
          c.IDR_Is_Restricted__c = false;
        }
      }
      casesToUpdate.addAll(casesToRestrict);
      casesToUpdate.addAll(casesToUnRestrict);
      if (CasesToUpdate.size() != 0) {
        update casesToUpdate;
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'IDRCaseChangeEventActions',
        'updateCaseRestrictions',
        'Not enough permissions to query or update Case.'
      );
    }
  }

  /**
   * @description Finds the Ids of the cases that changed and need to be updated
   * @param records The published Case change events
   * @return A map containing several sets of case Ids, one set per type of update to be performed.
   */
  private static Map<String, Set<String>> getChangeCaseIds(
    CaseChangeEvent[] records
  ) {
    Set<String> caseIdsToRestrict = new Set<String>();
    Set<String> caseIdsToUnRestrict = new Set<String>();
    Map<String, Set<String>> caseIds = new Map<String, Set<String>>();

    for (CaseChangeEvent change : (CaseChangeEvent[]) records) {
      //if either case's restriction was updated, or case was inserted as restricted
      if (
        (change.ChangeEventHeader.getChangeType() == 'UPDATE' &&
        change.ChangeEventHeader.getChangedFields()
          .contains('IDR_Restriction_Level__c')) ||
        (change.ChangeEventHeader.getChangeType() == 'CREATE' &&
        change.IDR_Restriction_Level__c == 'Restricted Case')
      ) {
        if (change.IDR_Restriction_Level__c == 'Restricted Case') {
          // Get all Record Ids for this change and add to the set
          List<String> recordIds = change.ChangeEventHeader.getRecordIds();
          caseIdsToRestrict.addAll(recordIds);
        } else if (change.IDR_Restriction_Level__c == 'No Restriction') {
          // Get all Record Ids for this change and add to the set
          List<String> recordIds = change.ChangeEventHeader.getRecordIds();
          caseIdsToUnRestrict.addAll(recordIds);
        }
      }
    }
    caseIds.put('ToRestrict', caseIdsToRestrict);
    caseIds.put('ToUnRestrict', caseIdsToUnRestrict);
    return caseIds;
  }
}

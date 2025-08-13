/**
 * @description CMOS Handler class for the Case asynchronous trigger.
 * This fires after all database transactions on case completed, avoiding problems when a banker marks a case as restricted and looses access to it.
 * @author Olivier Saier
 * @since 06/2021
 * @group IDR(Internal Dispute Resolution)
 */
public with sharing class IDRCaseChangeEventActions {
  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  /**
   * @description Updates the case IDR_Is_Restricted__c field value based on the Restriction level field value.
   * @param records The published Case change events
   */
  public static void updateCaseRestrictions(List<CaseChangeEvent> records) {
    List<CaseChangeEvent> filteredEvents = validEvents(records);
    List<Case> restrictedCases = getRestrictedCases(filteredEvents);
    List<Case> nonRestrictedCases = getNonRestrictedCases(filteredEvents);
    ListUtil.setField(restrictedCases, Case.IDR_Is_Restricted__c, true);
    ListUtil.setField(nonRestrictedCases, Case.IDR_Is_Restricted__c, false);
    List<Case> caseToUpdate = new List<Case>(restrictedCases);
    caseToUpdate.addAll(nonRestrictedCases);
    DML.doUpdate(caseToUpdate, new DmlConfig().systemMode());
  }
  /**
   * @description Returns list of case records where IDR_Restriction_Level__c is 'Restricted Case'.
   * @param listOfEvents List of CaseChangeEvent.
   * @return `List<Case>` return list of restricted cases.
   */
  @TestVisible
  private static List<Case> getRestrictedCases(
    List<CaseChangeEvent> listOfEvents
  ) {
    List<Case> restrictedCases = new List<Case>();
    for (CaseChangeEvent change : listOfEvents) {
      if (
        !change.IDR_Restriction_Level__c.equalsIgnoreCase('Restricted Case')
      ) {
        continue;
      }
      restrictedCases.add(
        new Case(Id = change.ChangeEventHeader.getRecordIds()[0])
      );
    }
    return restrictedCases;
  }
  /**
   * @description Returns list of case records where IDR_Restriction_Level__c is 'No Restriction'.
   *  @param listOfEvents List of CaseChangeEvent.
   * @return `List<Case>` return list of no restricted cases.
   */
  @TestVisible
  private static List<Case> getNonRestrictedCases(
    List<CaseChangeEvent> listOfEvents
  ) {
    List<Case> nonRestrictedCases = new List<Case>();
    for (CaseChangeEvent change : listOfEvents) {
      if (!change.IDR_Restriction_Level__c.equalsIgnoreCase('No Restriction')) {
        continue;
      }
      nonRestrictedCases.add(
        new Case(Id = change.ChangeEventHeader.getRecordIds()[0])
      );
    }
    return nonRestrictedCases;
  }
  /**
   * @description Return valid event records.
   * @param records List of CaseChangeEvent to process.
   * @return `List<CaseChangeEvent>` return valid event records.
   */
  @TestVisible
  private static List<CaseChangeEvent> validEvents(
    List<CaseChangeEvent> records
  ) {
    List<CaseChangeEvent> filteredEvents = new List<CaseChangeEvent>();
    for (CaseChangeEvent record : records) {
      if (record.IDR_Restriction_Level__c == null) {
        continue;
      }
      if (
        !record.ChangeEventHeader.getChangedFields()
          .contains('IDR_Restriction_Level__c') &&
        record.ChangeEventHeader.getChangeType() == 'UPDATE'
      ) {
        continue;
      }
      if (
        record.IDR_Restriction_Level__c != 'Restricted Case' &&
        record.ChangeEventHeader.getChangeType() == 'CREATE'
      ) {
        continue;
      }
      filteredEvents.add(record);
    }
    return filteredEvents;
  }
}

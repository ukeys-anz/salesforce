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
  public static void updateCaseRestrictions(CaseChangeEvent[] records) {
    Map<String, List<Case>> mapOfRestrictionStatusToCase = getChangeCaseIds(
      records
    );
    List<Case> restrictedCases = mapOfRestrictionStatusToCase.get('restricted');
    List<Case> nonRestrictedCases = mapOfRestrictionStatusToCase.get(
      'nonRestricted'
    );
    ListUtil.setField(restrictedCases, Case.IDR_Is_Restricted__c, true);
    ListUtil.setField(nonRestrictedCases, Case.IDR_Is_Restricted__c, false);
    List<Case> caseToUpdate = new List<Case>(restrictedCases);
    caseToUpdate.addAll(nonRestrictedCases);
    DML.doUpdate(caseToUpdate, new DmlConfig().systemMode());
  }

  /**
   * @description Returns a map of case Ids that need to be updated to the corresponding restriction status.
   * @param records The published Case change events.
   * @return `Map<String,List<Case>>` return Map of restricted cases and non Restricted cases.
   */
  @TestVisible
  private static Map<String, List<Case>> getChangeCaseIds(
    CaseChangeEvent[] records
  ) {
    Map<String, List<Case>> mapOfRestrictionStatusToCase = new Map<String, List<Case>>{
      'nonRestricted' => new List<Case>(),
      'restricted' => new List<Case>()
    };
    for (CaseChangeEvent change : (CaseChangeEvent[]) records) {
      if (!checkIfValidRecord(change)) {
        continue;
      }
      if (change.IDR_Restriction_Level__c == null) {
        continue;
      }

      if (change.IDR_Restriction_Level__c.equalsIgnoreCase('Restricted Case')) {
        mapOfRestrictionStatusToCase.get('restricted')
          .add(new Case(Id = change.ChangeEventHeader.getRecordIds()[0]));
        continue;
      }
      if (change.IDR_Restriction_Level__c.equalsIgnoreCase('No Restriction')) {
        mapOfRestrictionStatusToCase.get('nonRestricted')
          .add(new Case(Id = change.ChangeEventHeader.getRecordIds()[0]));
      }
    }
    return mapOfRestrictionStatusToCase;
  }
  /**
   * @description Boolean for check valid record to process.
   * @param record of CaseChangeEvent to process.
   * @return Boolean return if record is valid or not.
   */
  private static Boolean checkIfValidRecord(CaseChangeEvent record) {
    List<String> dmlOperation = new List<String>{ 'CREATE', 'UPDATE' };
    if (!dmlOperation.contains(record.ChangeEventHeader.getChangeType())) {
      return false;
    }
    if (
      !record.ChangeEventHeader.getChangedFields()
        .contains('IDR_Restriction_Level__c') &&
      dmlOperation[1] == record.ChangeEventHeader.getChangeType()
    ) {
      return false;
    }
    if (
      !(record.IDR_Restriction_Level__c == 'Restricted Case') &&
      dmlOperation[0] == record.ChangeEventHeader.getChangeType()
    ) {
      return false;
    }
    return true;
  }
}

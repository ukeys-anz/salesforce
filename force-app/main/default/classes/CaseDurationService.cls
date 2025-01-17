/**
 *
 * @author David Dawson
 * @since 11/2020
 * @description CaseDurationService exposes the CaseDurationObject as a service, and returning specific aspects of the object
 */
public with sharing class CaseDurationService {
  /**
   *
   * @description The getCaseDurationTime method returns the DurationTime object, which contains an hours and a minutes value
   * @param caseId The Case record ID
   * @return `DurationTime`
   */
  @AuraEnabled
  public static CaseDurationObject.DurationTime getCaseDurationTime(Id caseId) {
    CaseDurationObject caseDurationObj = new CaseDurationObject(caseId);
    return caseDurationObj.caseDuration;
  }

  /**
   *
   * @description The getCaseDurationTime method returns the DurationTime object, which contains an hours and a minutes value
   * @param records The Case records
   * @param oldMap The Case records
   * @return `Map<Id, CaseDurationObject.DurationTime>`
   */
  public static Map<Id, CaseDurationObject.DurationTime> getCaseDurationTime(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    CaseDurationObject caseDurationObj = new CaseDurationObject(
      records,
      oldMap
    );
    return caseDurationObj.caseIdToDurationMap;
  }
}

/**
 *
 * @author David Dawson
 * @since 11/2020
 * @description CaseDurationTest is the test class to cover tests for {@link CaseDurationObject} and {@link CaseHistoryObject} and {@link CaseDurationService}
 */

@isTest
public class CaseDurationTest {
  /**
   * @description This setup method creates the record(s) required for the test classes
   */
  @testSetup
  static void setup() {
    List<RecordType> rtList = new List<RecordType>(
      [
        SELECT Id
        FROM RecordType
        WHERE SObjectType = 'Case' AND DeveloperName = 'General_Inquiry'
      ]
    );
    Case newCase = new Case(Status = 'Open', RecordTypeId = rtList[0].Id);
    insert newCase;
  }

  /**
   * @description testCaseDurationObject tests that a duration has been calculated for the open case
   */
  @isTest
  public static void testCaseDurationObject() {
    // GIVEN A case exists
    Case newCase = [SELECT ID FROM Case LIMIT 1];

    // WHEN the case duration is calculated
    CaseDurationObject caseDurationObj = new CaseDurationObject(newCase.Id);

    // THEN the duration values should not be null
    // These values can't be asserted as they require at least 60 seconds to pass for the minutes variable to hold a value greater than 0
    system.assert(
      caseDurationObj.caseDuration.hours != null,
      'The hours have not been calculated'
    );
    system.assert(
      caseDurationObj.caseDuration.minutes != null,
      'The hours have not been calculated'
    );
  }

  @isTest
  public static void testCaseDurationService() {
    // GIVEN A case exists
    Case newCase = [SELECT ID FROM Case LIMIT 1];

    // WHEN the case duration is calculated
    CaseDurationObject.DurationTime durationTime = CaseDurationService.getCaseDurationTime(
      newCase.Id
    );

    // THEN the duration values should not be null
    // These values can't be asserted as they require at least 60 seconds to pass for the minutes variable to hold a value greater than 0
    system.assert(
      durationTime.hours != null,
      'The hours have not been calculated'
    );
    system.assert(
      durationTime.minutes != null,
      'The hours have not been calculated'
    );
  }
}

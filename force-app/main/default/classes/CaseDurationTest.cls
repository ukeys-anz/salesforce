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
   * @description testCaseDurationObject tests default scenario where use dummy caseHistory
   */
  @isTest
  public static void testCaseDurationObject() {
    // GIVEN A case exists
    Case newCase = [SELECT ID FROM Case LIMIT 1];

    CaseHistory history = new CaseHistory();
    history.Field = 'Status';
    history.CaseId = newCase.Id;
    insert history;

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

  /**
   * @description testCaseDurationWithOneTime tests scenario with two case statuses
   */
  @isTest
  public static void testCaseDurationWithOneTime() {
    Case newCase = [SELECT ID FROM Case LIMIT 1];
    List<BusinessHours> bhs = [
      SELECT id
      FROM BusinessHours
      WHERE Name = 'ANZx Case Business Hours'
    ];
    CaseDurationObject caseDurationObj = new CaseDurationObject(newCase.Id);

    List<CaseHistoryObject> historyList = new List<CaseHistoryObject>();
    CaseHistoryObject history1 = new CaseHistoryObject(
      'New',
      Datetime.newInstance(2020, 12, 7, 9, 0, 0),
      Datetime.newInstance(2020, 12, 8, 9, 0, 0),
      bhs[0].Id
    );
    historyList.add(history1);
    caseDurationObj.history = historyList;
    caseDurationObj.calculateCaseDuration();

    CaseDurationObject.DurationTime durationTime = caseDurationObj.caseDuration;
    System.assertEquals(
      8,
      durationTime.hours,
      'Case duration time should be as expected.'
    );
  }

  /**
   * @description testCaseDurationWithTwoTimes tests scenario with one case of status changes
   */
  @isTest
  public static void testCaseDurationWithTwoTimes() {
    Case newCase = [SELECT ID FROM Case LIMIT 1];
    List<BusinessHours> bhs = [
      SELECT id
      FROM BusinessHours
      WHERE Name = 'ANZx Case Business Hours'
    ];
    CaseDurationObject caseDurationObj = new CaseDurationObject(newCase.Id);

    List<CaseHistoryObject> historyList = new List<CaseHistoryObject>();
    CaseHistoryObject history1 = new CaseHistoryObject(
      'New',
      Datetime.newInstance(2020, 12, 7, 9, 0, 0),
      Datetime.newInstance(2020, 12, 8, 9, 0, 0),
      bhs[0].Id
    );
    CaseHistoryObject history2 = new CaseHistoryObject(
      'Open',
      Datetime.newInstance(2020, 12, 8, 9, 0, 0),
      Datetime.newInstance(2020, 12, 9, 9, 0, 0),
      bhs[0].Id
    );
    historyList.add(history1);
    historyList.add(history2);
    caseDurationObj.history = historyList;
    caseDurationObj.calculateCaseDuration();

    CaseDurationObject.DurationTime durationTime = caseDurationObj.caseDuration;
    System.assertEquals(
      16,
      durationTime.hours,
      'Case duration time should be as expected.'
    );
  }

  /**
   * @description testCaseDurationWithDetailedMinutes tests case Duration with detailed seconds to test the precision
   */
  @isTest
  public static void testCaseDurationWithDetailedMinutes() {
    Case newCase = [SELECT ID FROM Case LIMIT 1];
    List<BusinessHours> bhs = [
      SELECT id
      FROM BusinessHours
      WHERE Name = 'ANZx Case Business Hours'
    ];
    CaseDurationObject caseDurationObj = new CaseDurationObject(newCase.Id);

    List<CaseHistoryObject> historyList = new List<CaseHistoryObject>();
    CaseHistoryObject history1 = new CaseHistoryObject(
      'New',
      Datetime.newInstance(2020, 12, 7, 9, 0, 0),
      Datetime.newInstance(2020, 12, 7, 9, 0, 15),
      bhs[0].Id
    );
    CaseHistoryObject history2 = new CaseHistoryObject(
      'Open',
      Datetime.newInstance(2020, 12, 7, 9, 1, 0),
      Datetime.newInstance(2020, 12, 7, 9, 1, 15),
      bhs[0].Id
    );
    CaseHistoryObject history3 = new CaseHistoryObject(
      'Open',
      Datetime.newInstance(2020, 12, 7, 9, 2, 0),
      Datetime.newInstance(2020, 12, 7, 9, 2, 15),
      bhs[0].Id
    );
    CaseHistoryObject history4 = new CaseHistoryObject(
      'Open',
      Datetime.newInstance(2020, 12, 7, 9, 3, 0),
      Datetime.newInstance(2020, 12, 7, 9, 3, 15),
      bhs[0].Id
    );
    historyList.add(history1);
    historyList.add(history2);
    historyList.add(history3);
    historyList.add(history4);
    caseDurationObj.history = historyList;
    caseDurationObj.calculateCaseDuration();

    CaseDurationObject.DurationTime durationTime = caseDurationObj.caseDuration;
    System.assertEquals(
      1,
      durationTime.minutes,
      'Case duration time should be as expected.'
    );
  }

  /**
   * @description testCaseDurationWithClosedTime tests case Duration for a closed case
   */
  @isTest
  public static void testCaseDurationWithClosedTime() {
    Case newCase = [SELECT ID FROM Case LIMIT 1];
    List<BusinessHours> bhs = [
      SELECT id
      FROM BusinessHours
      WHERE Name = 'ANZx Case Business Hours'
    ];
    CaseDurationObject caseDurationObj = new CaseDurationObject(newCase.Id);

    List<CaseHistoryObject> historyList = new List<CaseHistoryObject>();
    CaseHistoryObject history1 = new CaseHistoryObject(
      'New',
      Datetime.newInstance(2020, 12, 7, 9, 0, 0),
      Datetime.newInstance(2020, 12, 8, 9, 0, 0),
      bhs[0].Id
    );
    CaseHistoryObject history2 = new CaseHistoryObject(
      'Closed',
      Datetime.newInstance(2020, 12, 8, 9, 0, 0),
      Datetime.newInstance(2020, 12, 9, 9, 0, 0),
      bhs[0].Id
    );
    historyList.add(history1);
    historyList.add(history2);
    caseDurationObj.history = historyList;
    caseDurationObj.calculateCaseDuration();

    CaseDurationObject.DurationTime durationTime = caseDurationObj.caseDuration;
    System.assertEquals(
      8,
      durationTime.hours,
      'Case duration time should be as expected.'
    );
  }

  /**
   * @description testCaseDurationService tests case Duration service class
   */
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

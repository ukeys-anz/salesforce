/**
 * @author Boobalakrishnan Duraisamy
 * @since 05/2020
 * @description  To test ScheduleUpdateCaseDuration and BatchUpdateCaseDuration classes.
 */
@isTest
private class TestScheduleUpdateCaseDuration {
  /**
   * @description testSchedulerClass is to test the Case duration update scheduler and batch class
   */
  @isTest
  static void testSchedulerClass() {
    Account accnt = new Account();
    accnt.Name = 'TestAccount';
    accnt.OCV_ID__c = '1';
    accnt.ANZx_Customer__c = true;
    insert accnt;

    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = GetHelpCaseActions.GENERAL_INQUIRY_RT_ID,
          Status = 'Open',
          Type = 'Card',
          Additional_Type__c = 'App Support;Coaching',
          AccountId = accnt.Id
        )
      );
    }

    insert newCases;

    //update start time to 2.5 hours earlier than the current time
    List<Case_Duration__c> cd = [
      SELECT Id, Start_Time__c
      FROM Case_Duration__c
      WHERE Case__c = :newCases[0].Id
    ];
    cd[0].Start_Time__c = DateTime.now().addHours(-2).addMinutes(-30);
    update cd;

    newCases[0].Status = 'Under Investigation';
    update newCases;

    Test.startTest();

    ScheduleUpdateCaseDuration sc = new ScheduleUpdateCaseDuration();
    String jobId = System.schedule(
      'Test Batch Update Case Duration',
      '0 0 * * * ?',
      sc
    );

    //Executing the batch seperately to make sure it finishes in Test.stopTest()
    BatchUpdateCaseDuration b = new BatchUpdateCaseDuration();
    Database.executeBatch(b);

    Test.stopTest();

    CronTrigger ct = [
      SELECT Id, CronExpression, TimesTriggered, NextFireTime
      FROM CronTrigger
      WHERE id = :jobId
    ];

    Case updatedCase = [
      SELECT Duration_Hours__c, Duration_Minutes__c, BusinessHoursId
      FROM Case
      WHERE Id = :newCases[0].Id
    ];

    Decimal expectedDuration = DateTimeUtils.calculateHoursBetween(
      cd[0].Start_Time__c,
      DateTime.now(),
      updatedCase.BusinessHoursId
    );
    long expectedDurationHours = expectedDuration.longValue();
    long expectedDurationMinutes = ((expectedDuration - expectedDurationHours) *
      SFConstants.MIN_IN_HOUR)
      .longValue();

    system.assertEquals(ScheduleUpdateCaseDuration.cronExp, ct.CronExpression);
    system.assertEquals(expectedDurationHours, updatedCase.Duration_Hours__c);
    system.assertEquals(
      expectedDurationMinutes,
      updatedCase.Duration_Minutes__c
    );
  }
}

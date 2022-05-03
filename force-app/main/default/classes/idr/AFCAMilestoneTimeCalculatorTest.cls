/**
 * @author Greg Shaw
 * @since 2022
 * @description Test AFCAMilestoneTriggerTimeCalculator
 */

@IsTest
public with sharing class AFCAMilestoneTimeCalculatorTest {
  @IsTest
  static void testAFCAMilestoneTimeCalculator() {
    // Select an existing milestone type to test with
    MilestoneType[] mtLst = [SELECT Id, Name FROM MilestoneType LIMIT 1];
    if (mtLst.size() == 0) {
      return;
    }
    MilestoneType mt = mtLst[0];

    // Create case data.
    // Typically, the milestone type is related to the case,
    // but for simplicity, the case is created separately for this test.
    Case c = new Case(
      Priority = 'High',
      IDR_Date_Received__c = Datetime.now(),
      IDR_AFCA_Due_Date__c = Date.today().addDays(5)
    );
    insert c;

    AFCAMilestoneTimeCalculator calculator = new AFCAMilestoneTimeCalculator();
    Integer actualTriggerTime = calculator.calculateMilestoneTriggerTime(
      c.Id,
      mt.Id
    );

    System.assertEquals(5 * 60 * 24, actualTriggerTime);

    c.IDR_AFCA_Due_Date__c = Date.today().addDays(11);
    update c;
    actualTriggerTime = calculator.calculateMilestoneTriggerTime(c.Id, mt.Id);
    System.assertEquals(11 * 60 * 24, actualTriggerTime);
  }
}

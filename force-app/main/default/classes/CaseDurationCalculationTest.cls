/**
 *
 * @author Lance Shi
 * @since 04/2020
 * @description CaseDurationCalculationTest is the test class to cover tests for {@link CaseDurationTriggerHandler}
 */

@isTest
public class CaseDurationCalculationTest {
  /**
   * @description testCaseDurationGenerate is to test the generation of case duration object during case insertion
   */
  @isTest
  public static void testCaseDurationGenerate() {
    Case newCase = new Case();
    newCase.Status = 'Open';
    insert newCase;

    Case_Duration__c cd = [SELECT Id, Initial_Status__c FROM Case_Duration__c];
    System.assertEquals('Open', cd.Initial_Status__c);
  }

  /**
   * @description testCaseDurationCalculation is to test the generation of case duration object during case insertion
   * and update. Also test the accumulation of case duration time
   */
  @isTest
  public static void testCaseDurationCalculation() {
    Case newCase = new Case();
    newCase.Status = 'Open';
    insert newCase;

    //update start time to 2 hours earlier than the current time
    List<Case_Duration__c> cd = [
      SELECT Id, Start_Time__c
      FROM Case_Duration__c
      WHERE Case__c = :newCase.Id
    ];
    cd[0].Start_Time__c = DateTime.now().addHours(-2);
    update cd;

    newCase.Status = 'Under Investigation';
    update newCase;

    List<Case_Duration__c> cdList = [
      SELECT Id, Initial_Status__c
      FROM Case_Duration__c
    ];
    System.assertEquals(2, cdList.size());

    Case updatedCase = [
      SELECT Status_Change_Duration__c
      FROM Case
      WHERE Id = :newCase.Id
    ];
    System.assertEquals(2.00, updatedCase.Status_Change_Duration__c);
  }
}

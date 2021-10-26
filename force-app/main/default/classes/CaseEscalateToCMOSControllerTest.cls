/**
 * @author Mouhamed "Mo" Assafiri
 * @since Sept 2021
 * @description Tests for Case Escalation Aura Controller
 */

@isTest
public class CaseEscalateToCMOSControllerTest {
  @testSetup
  static void setup() {
    List<RecordType> rtList = new List<RecordType>(
      [
        SELECT Id
        FROM RecordType
        WHERE SObjectType = 'Case' AND DeveloperName = 'ANZx_Complaint'
      ]
    );
    Case newCase = new Case(
      Subject = 'Test',
      Status = 'Open',
      RecordTypeId = rtList[0].Id
    );
    insert newCase;
  }

  /**
   * @description testCaseEscalatetoCMOS to see if ANZx to
   * CMOS Escalation converts Chatter to CaseComments correctly
   */
  @isTest
  public static void testCaseEscalationViaAuraController() {
    Test.startTest();
    List<Case> newCase = [
      SELECT
        Id,
        Customer_Notification_Consent__c,
        AccountID,
        Account.Source_System_ID__c
      FROM Case
    ];

    Boolean result = CaseEscalateToCMOSController.escalateCaseToCMOS(
      newCase[0].Id
    );
    Test.stopTest();

    system.assert(result, 'Escalation to CRC failed via Aura Controller');
  }
}

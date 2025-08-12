/**
 * @author CMOS
 * @since 08/2025
 * @description test class for CaseChangeEventTrigger
 */
@isTest
private class CaseChangeEventTriggerTest {
  @isTest
  static void triggerCoverage() {
    Test.enableChangeDataCapture();
    Case caseRecord = (Case) TestUtil.setFields(
      new Case(
        RecordTypeId = RTCase.nonCustomerComplaint,
        Status = IDRConstants.OPEN_STATUS,
        IDR_Additional_Correspondence_reviewed__c = false,
        IDR_Document_Count__c = null,
        IDR_Restriction_Level__c = 'Restricted Case'
      ),
      new Map<String, Object>{
        'CaseNumber' => new Faker('0-9').randomInteger(6)
      }
    );
    Test.getEventBus().deliver();
    Test.startTest();
    insert caseRecord;
    Test.stopTest();
    Assert.isNotNull(caseRecord.Id, 'Case record should be inserted');
  }
}

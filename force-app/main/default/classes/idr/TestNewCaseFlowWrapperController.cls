@isTest
private with sharing class TestNewCaseFlowWrapperController {
  @isTest
  static void testRecordTypeDevNameFromId() {
    RecordType rt = [
      SELECT DeveloperName
      FROM RecordType
      WHERE DeveloperName = 'Customer_Complaint'
    ];
    System.assertEquals(
      'Customer_Complaint',
      NewCaseFlowWrapperController.getCaseRecordTypeDevNameById(rt.Id),
      'Developer name should be Customer_Complaint'
    );
  }
}

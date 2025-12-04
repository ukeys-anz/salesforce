/**
 * @author Dhanashree Deshmukh
 * @since 04/2025
 * @description test class for ValidateABNACNController
 */
@isTest
private class ValidateABNACNControllerTest {
  static Lib_MockProvider leadRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    leadRepoMock = Lib_MockProvider.forType(LeadActionsRepository.class);
  }

  @isTest
  static void testUpdateWithInvalidACN() {
    registerMocks();
    Lead leadRec = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      RecordTypeId = RTLead.commercialLead,
      ABN__c = '11005 357 522',
      ACN__c = '004085616',
      LeadSource = 'Individual',
      Registered_Company__c = 'Yes',
      ABN_Validation_Status__c = 'Active',
      ACN_Validation_Status__c = 'Active',
      Skip_Validations__c = 'copyLeadId'
    );
    leadRepoMock.mock('getLead', leadRec);
    Test.startTest();
    ValidateABNACNController.validateAbnAcnForCallout(leadRec.Id);
    Test.stoptest();
    Assert.areEqual(
      'Active',
      leadRec.ABN_Validation_Status__c,
      'ABN status should get updated to active'
    );
  }
}

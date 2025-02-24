/**
 * @author Prahlad Bhadani
 * @since  09/2024
 * @group CCRM, ML
 * @description Test class of OCRRelatedListController
 */
@isTest
private class OCRRelatedListControllerTest {
  static Lib_MockProvider controllerRepoMock;
  static void registerMocks() {
    controllerRepoMock = Lib_MockProvider.forType(
      OCRRelatedListRepository.class
    );
  }

  /**
   * @description test method for getOcrListForCustomer
   */
  @isTest
  static void getOcrListForCustomerTest() {
    registerMocks();
    Id newConId = Lib_FakeIdGenerator.getMockId(
      Schema.Contact.getSObjectType()
    );
    Id newAccId = Lib_FakeIdGenerator.getMockId(
      Schema.Account.getSObjectType()
    );
    Id newOppId = Lib_FakeIdGenerator.getMockId(
      Schema.Opportunity.getSObjectType()
    );
    Account cust = (Account) TestUtil.setFields(
      new Account(
        Id = newAccId,
        FirstName = 'Test',
        LastName = 'Test',
        Salutation = 'Mrs',
        External_Id__c = 'CAP-CIS_4011643101',
        Name = 'Test Test',
        RecordTypeId = CCRMConstants.ACCOUNT_PERSON_RT_ID
      ),
      new Map<String, Object>{ 'PersonContactId' => newConId }
    );
    OpportunityContactRole ocr = new OpportunityContactRole(
      OpportunityId = newOppId,
      ContactId = newConId,
      Role = 'Applicant'
    );
    controllerRepoMock.mock('getCustomer', cust);
    controllerRepoMock.mock(
      'getRecordsList',
      new List<OpportunityContactRole>{ ocr }
    );
    controllerRepoMock.mock('countRecords', 1);
    Test.startTest();
    OCRRelatedListController.OCRParamsWrapper inputWrapper = new OCRRelatedListController.OCRParamsWrapper();
    inputWrapper.recordId = newAccId;
    inputWrapper.pageSize = 50;
    inputWrapper.sortByField = 'CreatedDate';
    inputWrapper.sortOrder = 'desc';
    OCRRelatedListController.OcrResultWrapper result = OCRRelatedListController.getOcrListForCustomer(
      inputWrapper
    );
    inputWrapper.pageSize = null;
    OCRRelatedListController.OcrResultWrapper resultNoPageSize = OCRRelatedListController.getOcrListForCustomer(
      inputWrapper
    );
    inputWrapper.recordId = null;
    OCRRelatedListController.OcrResultWrapper resultNoRecId = OCRRelatedListController.getOcrListForCustomer(
      inputWrapper
    );
    Test.stopTest();
    Assert.areEqual(
      result.relatedRecordList.size(),
      1,
      'There should be 1 record'
    );
    Assert.areEqual(
      resultNoPageSize.countOfRecords,
      1,
      'There should be 1 record'
    );
    Assert.areEqual(resultNoRecId, null, 'Result should be null');
  }
}

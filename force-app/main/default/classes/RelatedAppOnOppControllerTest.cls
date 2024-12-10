/**
 * @author       : Advait Yermalkar
 * @since        : 09-04-2024
 * @description  : Test class for RelatedAppOnOppController
 **/
@isTest
private class RelatedAppOnOppControllerTest {
  static Lib_MockProvider appRepoMock;

  static void registerMocks() {
    // Register mocks for the repositories
    appRepoMock = Lib_MockProvider.forType(
      RelatedAppOnOppControllerRepository.class
    );
  }

  @isTest
  static void getApplicationFormsWithProductsTest() {
    registerMocks();

    // Generate mock IDs using Lib_FakeIdGenerator
    Id opportunityId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id productId = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);
    Id applicationFormId = Lib_FakeIdGenerator.getMockId(
      ApplicationForm.SObjectType
    );

    // Create mock data for Product2
    Product2 product = new Product2(Id = productId, Name = 'Test Product');

    // Create mock data for ApplicationFormProduct
    ApplicationFormProduct formProduct = new ApplicationFormProduct(
      Id = Lib_FakeIdGenerator.getMockId(ApplicationFormProduct.SObjectType),
      Stage = 'Initiated',
      Close_date__c = Date.Today(),
      ProductId = productId,
      Product = product,
      ApplicationFormId = applicationFormId,
      Amount__c = 10
    );

    // Create mock data for ApplicationForm
    ApplicationForm form = new ApplicationForm(
      Id = applicationFormId, // Generate a mock Application Form ID
      Stage = 'Submitted',
      SubmissionDate = Date.today(),
      Application_Number__c = '123456',
      Application_Status__c = 'Pending',
      OpportunityId = opportunityId
    );

    // Use utility method to set child records
    ApplicationForm mockForm = (ApplicationForm) TestUtil.setFields(
      form,
      new Map<String, Object>{
        'Name' => 'Test Form',
        'ApplicationFormProducts' => new List<ApplicationFormProduct>{
          formProduct
        }
      }
    );

    // Mock the getApplicationFormsWithProducts method
    appRepoMock.mock(
      'getApplicationForms',
      new List<ApplicationForm>{ mockForm }
    );

    Test.startTest();
    List<RelatedAppOnOppController.ApplicationFormWrapper> wrappers = RelatedAppOnOppController.getApplicationFormsWithProducts(
      opportunityId,
      3,
      1
    );
    Test.stopTest();

    // Assertions
    Assert.areNotEqual(null, wrappers, 'Expected non-null result');
    Assert.areEqual(1, wrappers.size(), 'Expected one ApplicationFormWrapper');
    RelatedAppOnOppController.ApplicationFormWrapper wrapper = wrappers[0];
    Assert.areEqual(
      'Test Form',
      wrapper.Name,
      'Application Form Name should match'
    );
  }
}

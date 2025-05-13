/**
 * @author Raman Gupta
 * @since Nov 2024
 * @description Test class for SOPViewModel
 */
@isTest
public with sharing class SOPViewModelTest {
  @isTest
  static void testGetSOPViewModel() {
    String resBody = Service.getStaticResource('mock_sop');
    Test.startTest();
    SOPViewModel viewModel = SOPViewModel.parse(resBody.toString());
    SOPViewModel viewModelblank = new SOPViewModel();
    Test.stopTest();

    Assert.areEqual(
      viewModel.dependantsCount,
      0,
      'dependantsCount should be as expected.'
    );
    Assert.isNull(viewModelblank.name, 'model should has values.');
  }

  @isTest
  static void testUpdateSOPViewModel() {
    SOPUpdateSOPAndPartyResponseModel responseModel = setupUpdatedSOPandPartyResponseModel();
    Test.startTest();
    SOPViewModel viewModel = new SOPViewModel(responseModel);
    Test.stopTest();

    Assert.areEqual(
      viewModel.dependantsCount,
      2,
      'dependantsCount should be as expected.'
    );
  }

  private static SOPUpdateSOPAndPartyResponseModel setupUpdatedSOPandPartyResponseModel() {
    String resBody = Service.getStaticResource('mock_updateSOPAndParty');
    SOPUpdateSOPAndPartyResponseModel testModel = SOPUpdateSOPAndPartyResponseModel.parse(
      resBody.toString()
    );
    return testModel;
  }
}

/**
 * @author Raman Gupta
 * @since Nov 2024
 * @description Test class for SOPUpdateSOPAndPartyResponseModel
 */
@isTest
public with sharing class SOPUpdateSOPAndPartyResponseModelTest {
  @isTest
  static void testSOPUpdateSOPAndPartyResponseModel() {
    String resBody = Service.getStaticResource('mock_updateSOPAndParty');
    Test.startTest();
    SOPUpdateSOPAndPartyResponseModel viewModel = SOPUpdateSOPAndPartyResponseModel.parse(
      resBody.toString()
    );
    Test.stopTest();

    Assert.areEqual(
      viewModel?.sopData?.dependantsCount,
      2,
      'dependantsCount should be as expected.'
    );
  }
}

/**
 * @author Raman Gupta
 * @since Nov 2024
 * @description Test class for SOPUpdateSOPAndPartyRequestModel
 */
@isTest
public with sharing class SOPUpdateSOPAndPartyRequestModelTest {
  @isTest
  static void testSOPUpdateSOPAndPartyRequestModel() {
    Test.startTest();
    SOPUpdateSOPAndPartyRequestModel updateModel = new SOPUpdateSOPAndPartyRequestModel(
      getSOPViewModel
    );
    SOPUpdateSOPAndPartyRequestModel updateModelWithoutParameters = new SOPUpdateSOPAndPartyRequestModel();
    Test.stopTest();
    // Assert the result
    Assert.isNotNull(updateModel.sopData, 'Values should populate');
    // Assert the blank constructor result
    Assert.isNull(updateModelWithoutParameters.sopData, 'Values are null');
    //Assert to check value
    Assert.isFalse(
      updateModel.partyData?.party?.spouseEarnsIncome,
      'spouseEarnsIncome should be as expected.'
    );
  }

  /**
   * @description Static method to return SOPViewModel Record
   */
  static SOPViewModel getSOPViewModel {
    get {
      SOPViewModel sopViewModel = new SOPViewModel();
      sopViewModel.name = 'e6782045-b850-46a6-8b13-ffb8839633c9';
      sopViewModel.parties = new List<SOPViewModel.Parties>();
      SOPViewModel.Parties party = new SOPViewModel.Parties();
      party.id = 'e6782045-b850-46a6-8b13-ffb8839633c9';
      party.ocvId = '123456';
      party.spouseEarnsIncome = false;
      party.soleIncomeEarner = 'Yes';
      party.partyDependantsCount = 2;
      party.relationshipState = 'Single';
      sopViewModel.parties.add(party);
      sopViewModel.dependantsCount = 2;
      sopViewModel.isSOPDataUpdated = true;
      sopViewModel.isPartyDataUpdated = true;
      sopViewModel.etag = '13243356664';
      return sopViewModel;
    }
  }
}

/**
 * @author Jaya Srivastava
 * @since Nov 2024
 * @description Test class for {@link LoanPreferenceEditModel}
 */
@isTest
public class LoanPreferenceEditModelTest {
  @isTest
  static void testLoanPreferenceEditModel() {
    Test.startTest();
    LoanPreferenceEditModel requestModel = new LoanPreferenceEditModel(
      getUpdateLoanViewModelData,
      getAdditionalFundsData
    );
    Test.stopTest();
    Assert.areEqual(true, requestModel.offset, 'Request Body');
  }

  @isTest
  static void testLoanPreferenceEditModelWithNoInputs() {
    Test.startTest();
    LoanPreferenceEditModel requestModel = new LoanPreferenceEditModel();
    Test.stopTest();
    Assert.areEqual(null, requestModel.uid, 'Request Body');
  }

  /**
   * @description Static method to return LoanPreferenceViewModel Record
   */
  static LoanPreferenceViewModel getUpdateLoanViewModelData {
    get {
      LoanPreferenceViewModel updateLoanData = new LoanPreferenceViewModel();
      updateLoanData.borrowAdditionalFunds = 'yes';
      updateLoanData.loanTermInMonths = 10;
      updateLoanData.currentLoanBalance = 4262.00;
      updateLoanData.loanRepaymentFrequency = 'REPAYMENT_FREQUENCY_BI_ANNUAL';
      updateLoanData.propertyUse = 'LOAN_PRODUCT_TYPE_INVESTOR';
      updateLoanData.offset = 'Yes';
      updateLoanData.loanRepaymentType = 'REPAYMENT_TYPE_PRINCIPAL_INTEREST';
      updateLoanData.interestRateType = 'INTEREST_RATE_TYPE_VARIABLE';
      updateLoanData.percentDeductible = 80;
      updateLoanData.uid = '7479fe3d-f0b8-4739-a4cd-7fb334bf3451';
      updateLoanData.etag = '1732683675717';
      updateLoanData.ocvId = '11111231';
      return updateLoanData;
    }
  }

  static AdditionalFundsViewModel getAdditionalFundsData {
    get {
      AdditionalFundsViewModel updateAddFundsData = new AdditionalFundsViewModel();
      updateAddFundsData.additionalFunds = new List<AdditionalFundsViewModel.AdditionalFunds>();
      AdditionalFundsViewModel.AdditionalFunds addFundRec = new AdditionalFundsViewModel.AdditionalFunds();
      addFundRec.purpose = 'LENDING_PURPOSE_ALTERATIONS_DWELLING_EXISTING';
      addFundRec.amount = 362.65;
      addFundRec.otherReason = '';
      updateAddFundsData.additionalFunds.add(addFundRec);
      return updateAddFundsData;
    }
  }
}

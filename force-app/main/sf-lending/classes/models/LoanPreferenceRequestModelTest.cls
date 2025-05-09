/**
 * @author Pooja Kirtishahi
 * @since Nov 2024
 * @description Test class for LoanPreferenceRequestModel
 */
@isTest
public class LoanPreferenceRequestModelTest {
  @isTest
  static void testLoanPreferenceRequestModel() {
    Test.startTest();
    LoanPreferenceRequestModel model = new LoanPreferenceRequestModel(getLAF);

    Test.stopTest();

    Assert.areEqual(
      model.termMonths,
      getLAF.Loan_Term_in_Months__c,
      'Loan Application data converted to request model'
    );
  }

  static ResidentialLoanApplication getRLA {
    get {
      return new ResidentialLoanApplication(
        Id = Lib_FakeIdGenerator.getMockId(
          ResidentialLoanApplication.SObjectType
        ),
        Name = 'Test Loan Application',
        Property_Use__c = 'LOAN_PRODUCT_TYPE_INVESTOR'
      );
    }
  }

  static LoanApplicationFinancial getLAF {
    get {
      LoanApplicationFinancial laf = new LoanApplicationFinancial();
      laf.Id = Lib_FakeIdGenerator.getMockId(
        LoanApplicationFinancial.SObjectType
      );
      laf.Name = 'Test Loan Application Financial';
      laf.LoanExclFinMortInsAmt = 11000;
      laf.Loan_Term_in_Months__c = 24;
      laf.Loan_Repayment_Frequency__c = 'REPAYMENT_FREQUENCY_UNSPECIFIED';
      laf.LoanApplication = getRLA;
      return laf;
    }
  }
}

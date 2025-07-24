/**
 *
 * @author Pooja Kirtishahi
 * @since Nov 2024
 * @description Test class for {@link LoanPreferenceController)
 */

@isTest
public with sharing class LoanPreferenceControllerTest {
  static Lib_MockProvider loanPrefMock;
  static Lib_MockProvider loanPrefAPIRepoMock;
  static void registerMocks() {
    loanPrefMock = Lib_MockProvider.forType(
        LoanApplicationFinancialRepository.class
      )
      .mock('queryLAFByRLAId', getLAF);
    loanPrefAPIRepoMock = Lib_MockProvider.forType(
      LoanPreferenceAPIRepository.class
    );
  }

  static LoanPreferenceResponseModel mockGetLoanPref = LoanPreferenceResponseModel.parse(
    Service.getStaticResource('mock_GetLoanPreference')
  );

  @isTest
  static void testGetCalculateLoanRepaymentSuccess() {
    Id recordId = Lib_FakeIdGenerator.getMockId(
      ResidentialLoanApplication.SObjectType
    );
    registerMocks();
    loanPrefAPIRepoMock.mock('getCalculateLoanRepayment', mockGetLoanPref);
    Test.startTest();
    LoanPreferenceResponseModel response = LoanPreferenceController.getCalculateLoanRepayment(
      recordId
    );
    Test.stopTest();
    Assert.isNotNull(response, 'Success Response');
  }

  @isTest
  static void testGetCalculateLoanRepaymentFailure() {
    try {
      registerMocks();
      loanPrefMock.mock('queryLAFByRLAId', null);
      Test.startTest();
      LoanPreferenceController.getCalculateLoanRepayment(null);
      Test.stopTest();
      Assert.fail('An Exception should be thrown');
    } catch (Exception ex) {
      Assert.isInstanceOfType(
        ex,
        AuraHandledException.class,
        'Exception should be an instanceof AuraHandledException.'
      );
    }
  }

  /**
   * @description Test Success scenarios with valid data for Update Loan Preference
   */
  @isTest
  static void testUpdateLoanPreferenceSuccess() {
    registerMocks();
    loanPrefAPIRepoMock.mock('updateLoanPreference', true);
    Test.startTest();
    Boolean response = LoanPreferenceController.updateLoanPreference(
      getUpdateLoanViewModelData,
      getAdditionalFundsData
    );
    Test.stopTest();
    Assert.isTrue(response, 'Successful Response');
  }
  /**
   * @description Test Error scenarios with Invalid data for Update Loan Preference
   */

  @isTest
  static void testUpdateLoanPreferenceFailure() {
    try {
      Test.startTest();
      LoanPreferenceController.updateLoanPreference(
        null,
        getAdditionalFundsData
      );
      Test.stopTest();
      Assert.fail('An Exception should be thrown');
    } catch (Exception ex) {
      Assert.isInstanceOfType(
        ex,
        AuraHandledException.class,
        'Exception should be an instanceof AuraHandledException.'
      );
    }
  }
  /**
   * @description Test Error scenarios with Invalid response for Update Loan Preference
   */
  @isTest
  static void testUpdateLoanPreferenceFailureResponse() {
    try {
      HttpCalloutResponse errorResponse = new HttpCalloutResponse();
      errorResponse.successful = false;
      errorResponse.statusCode = 500;
      errorResponse.error = new CalloutException('callout failed');
      registerMocks();

      loanPrefAPIRepoMock.mockException(
        'updateLoanPreference',
        new LoanPreferenceAPIRepository.ServerErrorLoanPreferenceException(
          errorResponse,
          'updateLoanPreference'
        )
      );

      Test.startTest();
      LoanPreferenceController.updateLoanPreference(
        getUpdateLoanViewModelData,
        getAdditionalFundsData
      );
      Test.stopTest();
      Assert.fail('An Exception should be thrown');
    } catch (Exception ex) {
      Assert.isInstanceOfType(
        ex,
        AuraHandledException.class,
        'Exception should be an instanceof AuraHandledException.'
      );
    }
  }

  @isTest
  static void testGetLoanPreferenceSuccess() {
    Id recordId = Lib_FakeIdGenerator.getMockId(
      ResidentialLoanApplication.SObjectType
    );
    registerMocks();
    Test.startTest();
    LoanPreferenceViewModel response = LoanPreferenceController.getLoanPreference(
      recordId
    );
    Test.stopTest();
    Assert.isNotNull(response, 'Success Response');
  }

  @isTest
  static void testGetLoanPreferenceFailure() {
    try {
      registerMocks();
      loanPrefMock.mock('queryLAFByRLAId', null);
      Test.startTest();
      LoanPreferenceController.getLoanPreference(null);
      Test.stopTest();
      Assert.fail('An Exception should be thrown');
    } catch (Exception ex) {
      Assert.isInstanceOfType(
        ex,
        AuraHandledException.class,
        'Exception should be an instanceof AuraHandledException.'
      );
    }
  }

  static ResidentialLoanApplication getRLA {
    get {
      return new ResidentialLoanApplication(
        Id = Lib_FakeIdGenerator.getMockId(
          ResidentialLoanApplication.SObjectType
        ),
        Name = 'Test Loan Application',
        Property_Use__c = 'LOAN_PRODUCT_TYPE_INVESTOR',
        ApplicationExtIdentifier = '1234',
        Account = new Account(
          Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
          FirstName = 'FakeNameB',
          OCV_ID__c = '11111231'
        )
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
      laf.E_Tag__c = '1252617';
      laf.FinancialExtIdentifier = 'ufghdms-gsgshsjik-svshjj';
      laf.Last_Updated_Date__c = DateTime.now();
      laf.Current_Loan_Balance__c = 25;
      laf.Borrow_Additional_Funds__c = 'No';
      laf.Interest_Rate_Type__c = 'INTEREST_RATE_TYPE_FIXED';
      laf.Loan_Repayment_Type__c = 'REPAYMENT_TYPE_UNSPECIFIED';
      laf.Loan_Margin__c = 20;
      laf.Offset__c = 'Yes';
      laf.LoanApplication = getRLA;
      return laf;
    }
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
      updateLoanData.offset = 'Yes';
      updateLoanData.loanRepaymentType = 'REPAYMENT_TYPE_PRINCIPAL_INTEREST';
      updateLoanData.interestRateType = 'INTEREST_RATE_TYPE_VARIABLE';
      updateLoanData.uid = '7479fe3d-f0b8-4739-a4cd-7fb334bf3451';
      updateLoanData.etag = '1732683675717';
      updateLoanData.ocvId = '11111231';
      updateLoanData.percentDeductible = 80;
      return updateLoanData;
    }
  }

  /**
   * @description Static method to return AdditionalFundsViewModel Record
   */
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

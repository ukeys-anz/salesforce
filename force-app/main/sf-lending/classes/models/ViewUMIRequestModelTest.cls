/**
 * @author Pooja Kirtishahi
 * @since May 2025
 * @description Test class for ViewUMIRequestModel
 */
@isTest
public class ViewUMIRequestModelTest {
  @isTest
  static void testViewUMIRequestModel() {
    Test.startTest();
    ViewUMIRequestModel model = new ViewUMIRequestModel(getRLA);

    Test.stopTest();

    Assert.areEqual(
      model.creditEnquiryId,
      getRLA.Credit_ID__c,
      'Residential Loan Application data converted to request model'
    );
  }

  /**
   * @description Static method to return Account
   */
  static Account getAccount {
    get {
      return new Account(
        Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        Name = 'Test Loan Account',
        OCV_Id__c = '11111231'
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
        Property_Use__c = 'LOAN_PRODUCT_TYPE_OWNER_OCCUPIED',
        SOP_Id__c = '123456789',
        Credit_ID__c = '12345',
        Account = getAccount,
        AmortizationTerm = 60,
        LotOriginalCost = 123.12
      );
    }
  }
}

/**
 * @description Test class for {@link AdditionalFundsController}
 * @author Arpit Pittie
 * @since Nov 2024
 */
@isTest
public class AdditionalFundsControllerTest {
  static Lib_MockProvider additionalFundRepoMock;

  static void registerMocks() {
    additionalFundRepoMock = Lib_MockProvider.forType(
        AdditionalFundsRepository.class
      )
      .mock('queryAddFundByRLAWithoutRefinance', getAddFund);
  }

  @isTest
  static void testGetAdditionalFundsSuccess() {
    Id recordId = Lib_FakeIdGenerator.getMockId(
      ResidentialLoanApplication.SObjectType
    );
    registerMocks();
    Test.startTest();
    AdditionalFundsViewModel addFundRecords = AdditionalFundsController.getAdditionFundsForLoanPreference(
      recordId
    );
    Test.stopTest();
    Assert.areEqual(
      addFundRecords.additionalFunds[0].amount,
      1234.00,
      'Addition Funds Data fetched'
    );
  }

  @isTest
  static void testGetAdditionalFundsFailure() {
    Test.startTest();
    AdditionalFundsViewModel addFundRecords = AdditionalFundsController.getAdditionFundsForLoanPreference(
      null
    );
    Test.stopTest();
    Assert.isTrue(addFundRecords.additionalFunds.isEmpty(), 'No records');
  }

  @isTest
  public static void testGetCategoryToPurposeMapping() {
    registerMocks();

    Test.startTest();
    List<AdditionalFundsCategoryPurposeViewModel> categoryPurposeModel = AdditionalFundsController.getCategoryToPurposeMapping();
    Test.stopTest();

    Assert.areEqual(
      'Renovation',
      categoryPurposeModel[0].category,
      'Renovation Fund should be in the category'
    );
    Assert.isTrue(
      categoryPurposeModel[0].purpose.size() == 3,
      'It should return renovation list size 3'
    );
  }

  /**
   * @description Static method to return Additional Fund Record
   */
  static List<Additional_Fund__c> getAddFund {
    get {
      List<Additional_Fund__c> addFundList = new List<Additional_Fund__c>();
      Additional_Fund__c addFund = new Additional_Fund__c();
      addFund.Id = Lib_FakeIdGenerator.getMockId(
        Additional_Fund__c.SObjectType
      );
      addFund.Amount__c = 1234.00;
      addFund.Other_Reason__c = 'Testing';
      addFund.Purpose__c = 'LENDING_PURPOSE_PERSONAL_MOTOR_VEHICLE_NEW';
      addFundList.add(addFund);
      return addFundList;
    }
  }
}

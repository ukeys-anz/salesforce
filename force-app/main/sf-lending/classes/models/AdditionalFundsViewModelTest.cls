/**
 * @author Jaya Srivastava
 * @since Nov 2024
 * @description Test class for {@link AdditionalFundsViewModel}
 */
@isTest
public class AdditionalFundsViewModelTest {
  @isTest
  static void testAdditionalFundsViewModel() {
    Test.startTest();
    AdditionalFundsViewModel requestModel = new AdditionalFundsViewModel(
      getAddFund
    );
    Test.stopTest();
    Assert.areEqual(
      1234.00,
      requestModel.additionalFunds[0].amount,
      'Request Body has Amount details'
    );
  }

  @isTest
  static void testAdditionalFundsViewModelWithoutInput() {
    Test.startTest();
    AdditionalFundsViewModel requestModel = new AdditionalFundsViewModel();
    Test.stopTest();
    Assert.isNull(requestModel.additionalFunds, 'Request Body is null');
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

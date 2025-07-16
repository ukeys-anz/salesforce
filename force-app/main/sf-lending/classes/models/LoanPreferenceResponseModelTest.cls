/**
 * @author Pooja Kirtishahi
 * @since Nov 2024
 * @description Test class for LoanPreferenceResponseModel
 */
@isTest
public class LoanPreferenceResponseModelTest {
  @isTest
  static void testLoanPreferenceResponseModel() {
    String resBody = Service.getStaticResource('mock_GetLoanPreference');
    Test.startTest();
    LoanPreferenceResponseModel resModel = LoanPreferenceResponseModel.parse(
      resBody.toString()
    );

    Test.stopTest();

    Assert.areEqual(
      resModel.interestRate,
      545,
      'Interest Rate should be as expected.'
    );
  }
}

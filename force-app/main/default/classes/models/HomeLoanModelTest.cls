/**
 * @author Vidhya Raghavan
 * @since January 2023
 * @description Test class for Home Loan model
 */

@IsTest
public class HomeLoanModelTest {
  @isTest
  static void testAmountValue() {
    StaticResource sr = [
      SELECT body
      FROM StaticResource
      WHERE Name = 'mock_homeloanaccounts'
    ];
    HomeLoanModel.HomeLoanAccount obj = null;
    HomeLoanModel homeLoan = HomeLoanModel.parse(sr.body.toString());
    for (HomeLoanModel.HomeLoanAccount acc : homeLoan.accounts) {
      if (
        acc.product_details.marketing_code.equals('HLVAR01') ||
        acc.product_details.marketing_code.equals('HLFXD01')
      ) {
        obj = acc;
      }
    }
    Test.startTest();
    System.assertEquals(
      3277.39,
      obj.loan_details.repayment_amount.value,
      'Values should be equal'
    );
    System.assertEquals(
      2821.2,
      obj.loan_details.redraw_amount.value,
      'Values should be equal'
    );

    obj.balances.current_balance.nanos = 200000000;
    obj.balances.current_balance.currency_code = 'AUD';
    obj.balances.current_balance.units = '525873';

    obj.loan_details.loan_amount.nanos = 200000000;
    obj.loan_details.loan_amount.currency_code = 'AUD';
    obj.loan_details.loan_amount.units = '125221';
    Decimal finalValue = obj.getPaidOff();
    System.assertEquals(
      525873.20,
      obj.balances.current_balance.value,
      'Current balance value should be as expected'
    );
    System.assertEquals(
      651094.4,
      finalValue,
      'Current balance value should be as expected'
    );
    obj.balances.current_balance.currency_code = 'AUD';
    obj.balances.current_balance.units = '525873';
    obj.balances.current_balance.nanos = null;
    System.assertEquals(
      525873,
      obj.balances.current_balance.value,
      'Current balance value should be as expected'
    );
    Test.stopTest();
  }
}

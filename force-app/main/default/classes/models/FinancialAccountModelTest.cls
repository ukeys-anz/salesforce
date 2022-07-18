/**
 * @author Peter Charalambous
 * @since December 2021
 * @description Test class for financial account model
 */
@IsTest
public class FinancialAccountModelTest {
  @isTest
  static void testParse() {
    StaticResource sr = [
      SELECT body
      FROM StaticResource
      WHERE Name = 'mock_financialAccounts'
    ];
    FinancialAccountModel obj = FinancialAccountModel.parse(sr.body.toString());
    System.assert(
      obj.account_list.size() == 2,
      'The Account list size should be as expected.'
    );
  }
}

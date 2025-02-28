/**
 * @author Kopal Goswami
 * @since August 2023
 * @description Test class for financial account model V1
 */
@IsTest
public class FinancialAccountModelV1Test {
  @isTest
  static void testParse() {
    StaticResource sr = [
      SELECT body
      FROM StaticResource
      WHERE Name = 'mock_FinancialAccountMappingv1'
    ];
    FinancialAccountModel obj = FinancialAccountModelV1.parse(
      sr.body.toString()
    );
    Assert.areEqual(
      obj.account_list.size(),
      3,
      'The Account list size should be as expected.'
    );

    Assert.areEqual(
      '000000000',
      obj.account_list[1].account_number,
      'Account number should be as expected.'
    );
  }
}

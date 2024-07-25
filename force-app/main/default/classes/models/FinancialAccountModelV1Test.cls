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
    System.assert(
      obj.account_list.size() == 3,
      'The Account list size should be as expected.'
    );

    System.assertEquals(
      '000000000',
      obj.account_list[0].account_number,
      'Account number should be as expected.'
    );
  }
}

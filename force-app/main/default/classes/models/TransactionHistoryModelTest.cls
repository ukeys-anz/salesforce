/**
 * @author Peter Charalambous
 * @since April 2021
 * @description Test class for transaction history model
 */
@IsTest
public class TransactionHistoryModelTest {
  static testMethod void testParse() {
    StaticResource sr = [
      SELECT body
      FROM StaticResource
      WHERE Name = 'mock_transactionHistory'
    ];
    TransactionHistoryModel obj = TransactionHistoryModel.parse(
      sr.body.toString()
    );
    System.assert(obj.embedded.transactions != null);
    System.assert(obj.embedded.tags != null);
    System.assert(obj.embedded.merchants != null);
    System.assert(obj.embedded.categories != null);
    System.assert(obj.count == '14');
  }
}

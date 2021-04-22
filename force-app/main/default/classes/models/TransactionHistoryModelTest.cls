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
    System.assert(obj.transactions != null);
    System.assert(obj.count == '20');
  }
}

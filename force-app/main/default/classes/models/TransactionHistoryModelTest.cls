/**
 * @author Peter Charalambous
 * @since April 2021
 * @description Test class for transaction history model
 */
@IsTest
public class TransactionHistoryModelTest {
  @isTest
  static void testParse() {
    StaticResource sr = [
      SELECT body
      FROM StaticResource
      WHERE Name = 'mock_transactionHistory'
    ];
    TransactionHistoryModel obj = TransactionHistoryModel.parse(
      sr.body.toString()
    );
    System.assert(
      obj.embedded.transactions != null,
      'Transaction should not be null.'
    );
    System.assert(obj.embedded.tags != null, 'Tags should not be null');
    System.assert(
      obj.embedded.merchants != null,
      'Merchants should not be null.'
    );
    System.assert(
      obj.embedded.categories != null,
      'Catergories should not be null.'
    );
    System.assert(
      obj.count == '14',
      'The TransactionHistoryModel count should be as expected.'
    );
  }
}

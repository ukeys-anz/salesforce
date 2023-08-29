/**
 * @author Kopal Goswami
 * @since Aug 2023
 * @description Test class for transaction history model V1
 */
@IsTest
public class TransactionHistoryModelV1Test {
  @isTest
  static void testParse() {
    String responseJson = [
        SELECT body
        FROM staticresource
        WHERE name = 'mock_transactionHistoryV1'
      ]
      .body.toString();

    TransactionHistoryModel obj = TransactionHistoryModelV1.parse(responseJson);

    String transactionid = obj.embedded.transactions[0].transaction_id;
    DateTime expectedDatetime = DateTime.newInstanceGMT(
      2021,
      11,
      12,
      2,
      57,
      58
    );
    String testTransactionDateLocal = obj.embedded.transactions[0]
      .transactionDateLocal;
    String testTransactionPostedDate = obj.embedded.transactions[0]
      .transaction_posted_date;
    Decimal testValue = obj.embedded.transactions[0].Amount.value;
    System.assert(
      obj.embedded.transactions != null,
      'Transaction should not be null.'
    );
    System.assert(obj.embedded.tags != null, 'Tags should not be null');
    System.assert(
      obj.embedded.merchants != null,
      'Merchants should not be null.'
    );

    System.assertEquals(1, testValue, 'Value should not be null.');
  }
}

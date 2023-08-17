/**
 * @author Peter Charalambous
 * @since April 2021
 * @description Test class for transaction history model
 */
@IsTest
public class TransactionHistoryModelTest {
  @isTest
  static void testParse() {
    String staticResourceName;
    if (Label.TransactionAPIUpliftedToV1 == 'True') {
      staticResourceName = 'mock_transactionHistoryV1';
    } else {
      staticResourceName = 'mock_transactionHistory';
    }

    StaticResource sr = [
      SELECT body
      FROM StaticResource
      WHERE Name = :staticResourceName
    ];

    //Call the method to be Tested
    Test.startTest();
    TransactionHistoryModel obj = TransactionHistoryModel.parse(
      sr.body.toString()
    );
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
    Test.stopTest();
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

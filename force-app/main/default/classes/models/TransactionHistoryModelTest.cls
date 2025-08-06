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
      WHERE Name = 'mock_transactionHistory1'
    ];

    //Call the method to be Tested
    Test.startTest();
    TransactionHistoryModel obj = TransactionHistoryModel.parse(
      sr.body.toString()
    );
    String transactionid = obj.embedded.transactions[0].transaction_id;
    String testTransactionDateLocal = obj.embedded.transactions[0]
      .transactionDateLocal;
    String testTransactionPostedDate = obj.embedded.transactions[0]
      .transaction_posted_date;
    Decimal amount = obj.embedded.transactions[0].amount.value;
    Test.stopTest();
    Assert.isNotNull(
      obj.embedded.transactions,
      'Transaction should not be null.'
    );
    Assert.isNotNull(obj.embedded.tags, 'Tags should not be null');
    Assert.isNotNull(obj.embedded.merchants, 'Merchants should not be null.');
    Assert.isNotNull(
      obj.embedded.categories,
      'Catergories should not be null.'
    );
    Assert.areEqual(
      obj.count,
      '21',
      'The TransactionHistoryModel count should be as expected.'
    );
    Assert.areEqual(
      amount,
      -19.0012,
      'Value should match amout.value and nanos from 1st transaction of mock_transactionHistory1.json.'
    );
    Assert.areEqual(
      transactionid,
      '4313ds-51d2-4ve2-ba7e-0b339p157da1',
      'Value should match transaction id from 1st transaction of mock_transactionHistory1.json.'
    );
    Assert.areEqual(
      testTransactionDateLocal,
      '2021-11-12 13:57:58.000 +1100',
      'Value should match transaction_time from 1st transaction of mock_transactionHistory1.json.'
    );
    Assert.areEqual(
      testTransactionPostedDate,
      '2021-08-22 10:00:00.000 +1000',
      'Value should match transaction_posted_time from 1st transaction of mock_transactionHistory1.json.'
    );
  }
  @isTest
  static void testParseNullReturns() {
    StaticResource sr = [
      SELECT body
      FROM StaticResource
      WHERE Name = 'mock_transactionHistory1'
    ];

    //Call the method to be Tested
    Test.startTest();
    TransactionHistoryModel obj = TransactionHistoryModel.parse(
      sr.body.toString()
    );
    Decimal amount = obj.embedded.transactions[1].amount.value;
    String testTransactionPostedDate = obj.embedded.transactions[1]
      .transaction_posted_date;
    Test.stopTest();

    Assert.areEqual(
      obj.count,
      '21',
      'The TransactionHistoryModel count should be as expected.'
    );
    Assert.areEqual(
      amount,
      0,
      'Value should match amout.value and nanos from 2nd transaction of mock_transactionHistory1.json.'
    );
    Assert.isNull(
      testTransactionPostedDate,
      'transaction_posted_time must be null in 2nd transaction of mock_transactionHistory1.json.'
    );
  }
}

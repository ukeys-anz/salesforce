/**
 * @author Kopal Goswami
 * @since Aug 2023
 * @description Test class for transaction history model V1
 */
@IsTest
public class TransactionHistoryModelV1Test {
  @isTest
  static void testParse() {
    String responseJson;
    Map<String, String> mapPersonaIdAndCustomerName;

    responseJson = [
        SELECT body
        FROM staticresource
        WHERE name = 'mock_transactionHistoryV1'
      ]
      .body.toString();
    mapPersonaIdAndCustomerName = new Map<String, String>();
    mapPersonaIdAndCustomerName.put(
      'ab621652-de45-4008-9650-14f6557d13a3',
      'Grimes'
    );

    TransactionHistoryModel obj = TransactionHistoryModelV1.parse(
      responseJson,
      mapPersonaIdAndCustomerName
    );
    Assert.isNotNull(
      obj.embedded.transactions,
      'Transaction should not be null.'
    );
    Assert.isNotNull(obj.embedded.tags, 'Tags should not be null');
    Assert.isNotNull(obj.embedded.merchants, 'Merchants should not be null.');

    // Find VicRoads transaction by transaction_id instead of using index
    Decimal testValue = null;
    for (TransactionHistoryModel.Transactions txn : obj.embedded.transactions) {
      if (txn.transaction_id == '82bfc211-b647-4440-9463-edbf356f5d25') {
        testValue = txn.amount.value;
        break;
      }
    }

    Assert.areEqual(
      1,
      testValue,
      'Value should match amount.value for VicRoads transaction (UID: 82bfc211-b647-4440-9463-edbf356f5d25) from mock_transactionHistoryV1.json.'
    );
  }
}

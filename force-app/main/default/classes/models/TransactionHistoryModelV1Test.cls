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
    Decimal testValue = obj.embedded.transactions[0].Amount.value;
    Assert.isNotNull(
      obj.embedded.transactions,
      'Transaction should not be null.'
    );
    Assert.isNotNull(obj.embedded.tags, 'Tags should not be null');
    Assert.isNotNull(obj.embedded.merchants, 'Merchants should not be null.');

    Assert.areEqual(-64.19, testValue, 'Value should not be null.');
  }
}

/**
 * @author Peter Charalambous
 * @since December 2021
 * @description Test class for account buckets model
 */
@IsTest
public class AccountBucketsModelTest {
  @isTest
  static void testParse() {
    StaticResource sr = [
      SELECT body
      FROM StaticResource
      WHERE Name = 'mock_accountBuckets'
    ];
    AccountBucketsModel obj = AccountBucketsModel.parse(sr.body.toString());
    System.assert(
      obj.account_buckets.size() == 7,
      'The Account buckets size should be as expected.'
    );
  }
}

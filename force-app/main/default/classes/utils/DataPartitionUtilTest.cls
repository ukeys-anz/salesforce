/**
 * @author Hannah Sainumkheaw
 * @since 01/2023
 * @description Test class for {@link DataPartitionUtil}
 * @group Utils
 */
@isTest
public with sharing class DataPartitionUtilTest {
  private final static String SESSION_KEY = 'ocvIdTest';
  private final static String DATAPARTITION_CACHE = 'local.DataPartition';

  /**
   * @description test session cache storage
   */
  @isTest
  static void testStoreH1AccountDetailsCache() {
    //GIVEN dataPartition
    Cache.SessionPartition dataPartition = Cache.Session.getPartition(
      DATAPARTITION_CACHE
    );

    //WHEN
    //The session cache storage is called
    Test.startTest();
    DataPartitionUtil.storeH1AccountDetailsCache(SESSION_KEY, setupModel());
    Test.stopTest();

    //THEN
    //Check if the key is available in cache
    System.assert(
      dataPartition.contains(SESSION_KEY),
      'No data stored under provided key'
    );
  }

  @isTest
  static void testGetH1AccountDetailsCache() {
    //GIVEN
    //The h1details stored in the session cache
    Cache.SessionPartition dataPartition = Cache.Session.getPartition(
      DATAPARTITION_CACHE
    );
    dataPartition.put(SESSION_KEY, setupModel());

    //WHEN
    Test.startTest();
    HomeLoanModel cachedData = DataPartitionUtil.getH1AccountDetailsCache(
      SESSION_KEY
    );
    String cachedAcc = cachedData.accounts.get(0)?.account_number;
    Test.stopTest();

    //THEN
    //Check if value retriving from getH1AccountDetailsCache matahes with inserted data
    HomeLoanModel retrievedData = (HomeLoanModel) dataPartition.get(
      SESSION_KEY
    );
    String retrievedAcc = retrievedData.accounts.get(0)?.account_number;

    System.assertEquals(
      cachedAcc,
      retrievedAcc,
      'The cached and retrieved account number should be identical.'
    );
  }

  private static HomeLoanModel setupModel() {
    StaticResource mockH1 = [
      SELECT body
      FROM StaticResource
      WHERE Name = 'mock_homeloanaccounts'
    ];

    HomeLoanModel testModel = HomeLoanModel.parse(mockH1.body.toString());
    return testModel;
  }
}

/**
 * @author Hannah Sainumkheaw
 * @since 01/2023
 * @description Test class for {@link DataPartitionUtil}
 * @group Utils
 */
@isTest
public with sharing class DataPartitionUtilTest {
  private final static String SESSION_KEY = 'ocvIdTest';
  private final static String SOP_SESSION_KEY = 'sopId1234';
  private final static String DATAPARTITION_CACHE = 'local.DataPartition';

  /**
   * @description test session cache storage
   */
  @isTest
  static void testStoreDetailsCache() {
    //GIVEN dataPartition
    Cache.SessionPartition dataPartition = Cache.Session.getPartition(
      DATAPARTITION_CACHE
    );

    //WHEN
    //The session cache storage is called
    Test.startTest();
    DataPartitionUtil.storeH1AccountDetailsCache(SESSION_KEY, setupModel());
    DataPartitionUtil.storeSOPDetailsCache(SOP_SESSION_KEY, setupSOPModel());
    Test.stopTest();

    //THEN
    //Check if the key is available in cache
    System.assert(
      dataPartition.contains(SESSION_KEY),
      'No data stored under provided key'
    );
    System.assert(
      dataPartition.contains(SOP_SESSION_KEY),
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
    dataPartition.put(SOP_SESSION_KEY, setupSOPModel());

    //WHEN
    Test.startTest();
    HomeLoanModel cachedData = DataPartitionUtil.getH1AccountDetailsCache(
      SESSION_KEY
    );
    String cachedAcc = cachedData.accounts.get(0)?.account_number;

    /** SOP */
    SOPModel cachedSOPData = DataPartitionUtil.getSOPDetailsCache(
      SOP_SESSION_KEY
    );
    String cachedSOP = JSON.serialize(cachedSOPData);
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

    SOPModel retrievedSOPData = (SOPModel) dataPartition.get(SOP_SESSION_KEY);
    String retrievedSOP = JSON.serialize(retrievedSOPData);

    System.assertEquals(
      cachedSOP,
      retrievedSOP,
      'The cached and retrieved account number should be identical.'
    );
  }

  /**
   * @return `HomeLoanModel` mock response
   * @description returns mock response from the static resources
   */
  private static HomeLoanModel setupModel() {
    StaticResource mockH1 = [
      SELECT body
      FROM StaticResource
      WHERE Name = 'mock_homeloanaccounts'
    ];

    HomeLoanModel testModel = HomeLoanModel.parse(mockH1.body.toString());
    return testModel;
  }

  /**
   * @return `SOPModel` mock response
   * @description returns mock response from the static resources
   */
  private static SOPModel setupSOPModel() {
    StaticResource mocksop = [
      SELECT body
      FROM StaticResource
      WHERE Name = 'mock_sop'
    ];

    SOPModel testModel = SOPModel.parse(mocksop.body.toString());
    return testModel;
  }
}

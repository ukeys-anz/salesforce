/**
 * @author Hannah Sainumkheaw
 * @since  December 2022
 * @description DataPartition stores H1 account details to the session cache
 * @group Utils
 */
public with sharing class DataPartitionUtil {
  private static Integer ttlSecs = 300;
  /**
   * @description DataPartition is returned the existing DataPartition or creating one.
   * @return Session Cache Partition - DataPartition
   */
  public static Cache.SessionPartition dataPartition {
    get {
      if (dataPartition != null) {
        return dataPartition;
      }
      DataPartition = Cache.Session.getPartition('local.DataPartition');
      return dataPartition;
    }
    set;
  }
  /**
   * @description storing the first call out of 'home loan account (H1) details' from HomeLoanAPIRepository
   * @param sessionCacheKey the key is the ocvID. Therefore the session cache stores homeloan details based on ocvID
   * @param value - value that is added to the cache
   */
  public static void storeH1AccountDetailsCache(
    String sessionCacheKey,
    HomeLoanModel value
  ) {
    dataPartition.put(sessionCacheKey, value, ttlSecs);
  }

  /**
   * @description retrieving 'home loan account (H1 Account) details' from the session cache
   * @param ocvId retrieve Session Cache data based on ocvId
   * @return accountDetails, all details under the given ocvId
   *
   */
  @AuraEnabled
  public static HomeLoanModel getH1AccountDetailsCache(String ocvId) {
    HomeLoanModel accountDetails = (HomeLoanModel) DataPartition.get(ocvId);
    if (accountDetails != null) {
      Logger.debug('Home Loan Caching hit: ')
        .setPayload(json.serialize(accountDetails));
      Logger.saveLog();
    }
    return accountDetails;
  }
}

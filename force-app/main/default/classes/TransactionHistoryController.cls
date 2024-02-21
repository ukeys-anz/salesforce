/**
 *
 * @author Lance Shi
 * @since 2020
 * @description TransactionHistoryController is apex side controller for Transaction history LWC
 */
public with sharing class TransactionHistoryController {
  /**
   * @author Jasmine Nguyen
   * @since 02/2021
   * @description Get a map of dispute record types and their Ids
   * @return Serialized string of dispute record type map
   */
  @AuraEnabled
  public static String getDisputeRecordTypeMap() {
    if (Schema.sObjectType.Case.isAccessible()) {
      if (!Cache.Org.contains('local.Utility.disputeRecordTypeMap')) {
        Map<String, RecordType> disputeRecordTypeMap = new Map<String, RecordType>();
        for (RecordType rt : [
          SELECT Id, Name, DeveloperName
          FROM RecordType
          WHERE SobjectType = 'Case' AND DeveloperName LIKE '%Dispute%'
          ORDER BY DeveloperName DESC
        ]) {
          disputeRecordTypeMap.put(rt.DeveloperName, rt);
        }
        Cache.Org.put(
          'local.Utility.disputeRecordTypeMap',
          JSON.serialize(disputeRecordTypeMap)
        );
        return JSON.serialize(disputeRecordTypeMap);
      }
      return String.valueOf(
        Cache.Org.get('local.Utility.disputeRecordTypeMap')
      );
    }
    return null;
  }

  /**
   * @description Get the data from the person account
   * @param customerOCVId OCV Id of the Customer from where the dispute get raised
   * @return Map<String, Object> field-value map of the person account used as the owner of this financial account
   * Added changes for the parameters in order to handle Person Account details for Joint Account as well as Single Account
   */
  @AuraEnabled
  public static Map<String, Object> getPersonAccount(String customerOCVId) {
    Map<String, Object> returnMap = new Map<String, Object>();
    PermissionUtils.canQuery('Account');
    Account personAccount = [
      SELECT
        Id,
        BillingStreet,
        BillingCity,
        BillingState,
        BillingPostalCode,
        BillingCountry,
        OCV_ID__c
      FROM Account
      WHERE OCV_ID__c = :customerOCVId AND ANZx_Customer__c = TRUE
      LIMIT 1
    ];
    returnMap.put('AccountId', personAccount.Id);
    returnMap.put('BillingStreet', personAccount.BillingStreet);
    returnMap.put('BillingCity', personAccount.BillingCity);
    returnMap.put('BillingState', personAccount.BillingState);
    returnMap.put('BillingPostalCode', personAccount.BillingPostalCode);
    returnMap.put('BillingCountry', personAccount.BillingCountry);
    returnMap.put('OCV_ID__c', personAccount.OCV_ID__c);
    Logger.debug('Person Account retrieved with Id: ' + personAccount.Id);
    Logger.saveLog();
    return returnMap;
  }

  /**
   * @description Add a log for when a record type isn't automatically inferred when raising a dispute
   * @param logDetails map containing information for log
   */
  @AuraEnabled
  public static void logMissedTransaction(Map<String, String> logDetails) {
    //Get the developer name of the record type
    String recordTypeName = Schema.SObjectType.Case.getRecordTypeInfosById()
      .get(logDetails.get('selectedRecordType'))
      .getName();
    Logger.error(
      'Failed to automatically infer dispute type for transaction ' +
      logDetails.get('transactionId') +
      ' of type ' +
      logDetails.get('transactionType') +
      '. Using ' +
      recordTypeName +
      ' as a result. Financial account: ' +
      logDetails.get('financialAccountId') +
      ' | User Id: ' +
      UserInfo.getUserId()
    );
    Logger.saveLog();
  }
}

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
   * @param financialAccountId Financial Account Id related
   * @return Map<String, Object> field-value map of the person account used as the primary owner of this financial account
   */
  @AuraEnabled
  public static Map<String, Object> getPersonAccount(
    String financialAccountId
  ) {
    Map<String, Object> returnMap = new Map<String, Object>();
    Lib_SystemLog log = new Lib_SystemLog(
      'TransactionHistoryController',
      'getPersonAccount'
    );

    if (
      Account.SObjectType.getDescribe().isAccessible() &&
      FinServ__FinancialAccount__c.SObjectType.getDescribe().isAccessible()
    ) {
      FinServ__FinancialAccount__c financialAccount = [
        SELECT
          Id,
          FinServ__PrimaryOwner__r.Id,
          FinServ__PrimaryOwner__r.BillingStreet,
          FinServ__PrimaryOwner__r.BillingCity,
          FinServ__PrimaryOwner__r.BillingState,
          FinServ__PrimaryOwner__r.BillingPostalCode,
          FinServ__PrimaryOwner__r.BillingCountry,
          FinServ__PrimaryOwner__r.OCV_ID__c
        FROM FinServ__FinancialAccount__c
        WHERE Id = :financialAccountId
        LIMIT 1
      ];
      returnMap.put('AccountId', financialAccount.FinServ__PrimaryOwner__r.Id);
      returnMap.put(
        'BillingStreet',
        financialAccount.FinServ__PrimaryOwner__r.BillingStreet
      );
      returnMap.put(
        'BillingCity',
        financialAccount.FinServ__PrimaryOwner__r.BillingCity
      );
      returnMap.put(
        'BillingState',
        financialAccount.FinServ__PrimaryOwner__r.BillingState
      );
      returnMap.put(
        'BillingPostalCode',
        financialAccount.FinServ__PrimaryOwner__r.BillingPostalCode
      );
      returnMap.put(
        'BillingCountry',
        financialAccount.FinServ__PrimaryOwner__r.BillingCountry
      );
      returnMap.put(
        'OCV_ID__c',
        financialAccount.FinServ__PrimaryOwner__r.OCV_ID__c
      );
      log.trace(
        'Person Account retrieved with Id: ' +
        financialAccount.FinServ__PrimaryOwner__c
      );
      log.publishEvent();
      return returnMap;
    }
    log.trace('Unable to retrieve person account');
    log.insertLogAsync();
    return null;
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
    Lib_SystemLog.createSingleLog(
      TransactionHistoryController.class.getName(),
      'logMissedTransaction',
      '',
      'Failed to automatically infer dispute type for transaction ' +
      logDetails.get('transactionId') +
      ' of type ' +
      logDetails.get('transactionType') +
      '. Using ' +
      recordTypeName +
      ' as a result. Financial account: ' +
      logDetails.get('financialAccountId') +
      ' | User Id: ' +
      UserInfo.getUserId(),
      Lib_SystemLog.Severity.ERROR
    );
  }
}

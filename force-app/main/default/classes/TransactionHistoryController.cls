/**
 *
 * @author Lance Shi
 * @since 2020
 * @description TransactionHistoryController is apex side controller for Transaction history LWC
 */
@SuppressWarnings('PMD.ApexCRUDViolation,PMD.ApexSuggestUsingNamedCred')
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
   * @author Jasmine Nguyen
   * @since 02/2021
   * @description Get the contact Id of the person account that will linked to the case
   * @param financialAccountId Financial Account Id related
   * @return the Id of the person account used as the primary owner of this financial account
   */
  @AuraEnabled
  public static String getPersonAccountId(String financialAccountId) {
    Lib_SystemLog log = new Lib_SystemLog(
      'TransactionHistoryController',
      'getPersonAccountId'
    );

    if (Account.SObjectType.getDescribe().isAccessible()) {
      FinServ__FinancialAccount__c financialAccount = [
        SELECT Id, FinServ__PrimaryOwner__c
        FROM FinServ__FinancialAccount__c
        WHERE Id = :financialAccountId
        LIMIT 1
      ];

      log.trace(
        'Person Account retrieved with Id: ' +
        financialAccount.FinServ__PrimaryOwner__c
      );
      log.publishEvent();
      return financialAccount.FinServ__PrimaryOwner__c;
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

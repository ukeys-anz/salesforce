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
      Map<String, RecordType> disputeRecordTypeMap = new Map<String, RecordType>();
      for (RecordType rt : [
        SELECT Id, Name, DeveloperName
        FROM RecordType
        WHERE SobjectType = 'Case' AND DeveloperName LIKE '%Dispute%'
      ]) {
        disputeRecordTypeMap.put(rt.DeveloperName, rt);
      }
      return JSON.serialize(disputeRecordTypeMap);
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
      for (FinServ__FinancialAccount__c financialAccount : [
        SELECT Id, FinServ__PrimaryOwner__c
        FROM FinServ__FinancialAccount__c
        WHERE Id = :financialAccountId
      ]) {
        log.trace(
          'Person Account retrieved with Id: ' +
          financialAccount.FinServ__PrimaryOwner__c
        );
        log.insertLogAsync();
        return financialAccount.FinServ__PrimaryOwner__c;
      }
    }
    log.trace('Unable to retrieve person account');
    log.insertLogAsync();
    return null;
  }
}

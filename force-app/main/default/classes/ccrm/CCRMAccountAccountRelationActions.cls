/**
 * @author Boobalakrishnan Duraisamy
 * @since  05/2023
 * @group CCRM (Commercial CRM)
 * @description to handle all commercial CRM Account to Account actions
 * @runTests CCRMAccountAccountRelationActionsTest
 */
public with sharing class CCRMAccountAccountRelationActions {
  private static final String EXTERNAL_ID_TEMPLATE = '{0}_{1}_{2}';
  private static Map<Id, FinServ__ReciprocalRole__c> mapRoles;
  private static Map<String, FinServ__ReciprocalRole__c> mapOcvRoles;

  static {
    List<FinServ__ReciprocalRole__c> roles = [
      SELECT Id, Name, FinServ__InverseRelationship__c, OCV_Role__c
      FROM FinServ__ReciprocalRole__c
      WHERE
        OCV_Role__c != NULL
        AND RecordTypeId = :CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
      WITH SECURITY_ENFORCED
    ];
    mapRoles = new Map<Id, FinServ__ReciprocalRole__c>(roles);
    mapOcvRoles = new Map<String, FinServ__ReciprocalRole__c>();
    for (FinServ__ReciprocalRole__c reciprocalRole : roles) {
      mapOcvRoles.put(reciprocalRole.OCV_Role__c, reciprocalRole);
    }
  }

  /**
   * @description set External Id of FinServ__AccountAccountRelation__c object based on OCV Role ID from Finserv__ReciprocalRole__c
   * @name setExternalId
   * @param records The Account to accounts records passed from beforeInsert()
   */
  public static void setExternalId(
    List<FinServ__AccountAccountRelation__c> records
  ) {
    Map<Id, Account> mapAccounts = getMapAccounts(records);
    for (FinServ__AccountAccountRelation__c record : records) {
      populateRoleId(record);
      populateExternalId(record, mapAccounts);
      checkPersonAccountInvolement(record, mapAccounts);
    }
  }

  /**
   * @description get related account records
   * @name getMapAccountIdToExtId
   * @param records The Account to accounts records passed from beforeInsert()
   * @return Map<Id, Account>
   */
  private static Map<Id, Account> getMapAccounts(
    List<FinServ__AccountAccountRelation__c> records
  ) {
    Set<Id> accountIds = new Set<Id>();
    for (FinServ__AccountAccountRelation__c record : records) {
      accountIds.add(record.FinServ__Account__c);
      accountIds.add(record.FinServ__RelatedAccount__c);
    }
    return new Map<Id, Account>(
      [
        SELECT Id, External_Id__c, IsPersonAccount
        FROM Account
        WHERE Id IN :accountIds
        WITH USER_MODE
      ]
    );
  }

  /**
   * @description check and update System_Individual_Relationship__c
   * @name checkPersonAccountInvolement
   * @param record FinServ__AccountAccountRelation__c record from trigger
   * @param mapAccounts map of account related to FinServ__AccountAccountRelation__c
   */
  private static void checkPersonAccountInvolement(
    FinServ__AccountAccountRelation__c record,
    Map<Id, Account> mapAccounts
  ) {
    record.System_Individual_Relationship__c =
      mapAccounts.get(record.FinServ__Account__c)?.IsPersonAccount == true ||
      mapAccounts.get(record.FinServ__RelatedAccount__c)?.IsPersonAccount ==
      true;
  }

  /**
   * @description populates FinServ__Role__c or OCV_Role__c based on FinServ__ReciprocalRole__c table
   * @name populateRoleId
   * @param record FinServ__AccountAccountRelation__c record from trigger
   */
  private static void populateRoleId(
    FinServ__AccountAccountRelation__c record
  ) {
    if (record.FinServ__Role__c == null) {
      record.FinServ__Role__c = mapOcvRoles.get(record.OCV_Role__c)?.Id;
    } else {
      record.OCV_Role__c = mapRoles.get(record.FinServ__Role__c)?.OCV_Role__c;
    }
    if (!mapOcvRoles.containsKey(record.OCV_Role__c)) {
      record.addError(CCRMConstants.INVALID_OCV_ROLE_ERROR_MESSAGE);
    }
  }

  /**
   * @description populates External_Id__c when salesforce automatically creates a FinServ__AccountAccountRelation__c record
   * @name populateExternalId
   * @param record FinServ__AccountAccountRelation__c record from trigger
   * @param mapAccounts map of account related to FinServ__AccountAccountRelation__c
   */
  private static void populateExternalId(
    FinServ__AccountAccountRelation__c record,
    Map<Id, Account> mapAccounts
  ) {
    if (
      record.External_Id__c == null ||
      record.FinServ__InverseRelationship__c == null
    ) {
      return;
    }
    String party1 = mapAccounts.get(record.FinServ__Account__c).External_Id__c;
    String party2 = mapAccounts.get(record.FinServ__RelatedAccount__c)
      .External_Id__c;
    String role = mapRoles.get(record.FinServ__Role__c).Name.replace(' ', '');
    record.External_Id__c = String.format(
      EXTERNAL_ID_TEMPLATE,
      new List<String>{ party1, party2, role }
    );
  }

  /**
   * @description check if a relationship is enddated and set to inactive, then delete it and the inverse relationship
   * @name checkRelationshipStatus
   * @param records records from the trigger
   */
  public static void checkRelationshipStatus(
    List<FinServ__AccountAccountRelation__c> records
  ) {
    Set<Id> recordIdsToDelete = new Set<Id>();
    for (FinServ__AccountAccountRelation__c record : records) {
      if (
        !String.isBlank(record.External_Id__c) &&
        record.FinServ__EndDate__c != null &&
        !record.FinServ__Active__c
      ) {
        recordIdsToDelete.add(record.Id);
        if (record.FinServ__InverseRelationship__c != null) {
          recordIdsToDelete.add(record.FinServ__InverseRelationship__c);
        }
      }
    }
    if (!recordIdsToDelete.isEmpty()) {
      deleteRelationshipsAsync(recordIdsToDelete);
    }
  }

  /**
   * @description delete the provided relationships
   * @name deleteRelationships
   * @param recordIds list of relationship record ID
   */
  @future
  private static void deleteRelationshipsAsync(Set<Id> recordIds) {
    try {
      DMLUtilHelper.processDeleteResults(
        Database.delete(new List<Id>(recordIds), false, AccessLevel.USER_MODE)
      );
    } catch (Exception e) {
      DMLUtilHelper.logException(e);
    }
  }
}

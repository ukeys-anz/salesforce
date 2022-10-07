/**
 * @author Emmanuel Yap
 * @since  05/2022
 * @group CCRM (Commercial CRM)
 * @description CCRMOpportunityActions is class to handle all the CCRM Account Actions
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class CCRMOpportunityActions {
  /**
   * @description This method will update Controlling Post field depending on the CPID provided in Account.
   * @name populateFields
   * @param records from the trigger
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in afterUpdate.
   */
  public static void populateFields(
    List<Opportunity> records,
    Map<Id, Opportunity> oldMap
  ) {
    Set<Id> accountIds = new Set<Id>();
    for (Opportunity opp : records) {
      Opportunity oldRec = oldMap != null ? oldMap.get(opp.id) : null;
      maskDescription(opp);
      accountIds.add(opp.AccountId);
    }
    populateParentAccount(records, accountIds);
    checkAccountIsProspect(accountIds, records);
  }

  /**
   * @description This method will populate CLG filed with opportunity account parent field.
   * @param records List of Opportunities
   * @param accountIds Set of Account Ids
   */
  private static void populateParentAccount(
    List<Opportunity> records,
    Set<Id> accountIds
  ) {
    Map<Id, Id> mapOfAccountWithParentAccount = new Map<Id, Id>();
    if (Schema.sObjectType.Account.isQueryable()) {
      for (Account account : [
        SELECT Id, ParentId
        FROM Account
        WHERE Id IN :accountIds
      ]) {
        mapOfAccountWithParentAccount.put(account.Id, account.ParentId);
      }
    }
    for (Opportunity opp : records) {
      Id parentAccount = mapOfAccountWithParentAccount.get(opp.AccountId);
      opp.CLG__c = parentAccount != null ? parentAccount : opp.AccountId;
    }
  }

  /**
   * @description This method will update Controlling Post field depending on the CPID provided in Account.
   * @name populateFieldsAfterInsert
   * @param records from the trigger
   */
  public static void populateFieldsAfterInsert(List<Opportunity> records) {
    Set<Id> accountIds = new Set<Id>();
    Set<Id> oppIds = new Set<Id>();
    for (Opportunity opp : records) {
      accountIds.add(opp.AccountId);
      oppIds.add(opp.Id);
    }
    try {
      List<Opportunity> opps = [
        SELECT Id, AccountId, Lead_Converted__c, Name, Opp_Id__c
        FROM Opportunity
        WHERE Id IN :oppIds
        WITH SECURITY_ENFORCED
      ];
      setNameForOpportunityFromLead(accountIds, opps);
    } catch (System.QueryException e) {
      lib_systemLog log = new lib_systemLog(
        CCRMOpportunityActions.class.getName(),
        'populateFieldsAfterInsert'
      );
      log.error('InsufficientAccessException', e.getMessage(), e.getTypeName());
      log.publishEvent();
    }
  }

  /**
   * @description This method will validate that close date should be updated on first opportunity update.
   * @name validateCloseDate
   * @param records New opportunity records
   * @param oldMap Map of old Opportunity record
   */
  public static void validateCloseDate(
    List<Opportunity> records,
    Map<Id, Opportunity> oldMap
  ) {
    for (Opportunity opp : records) {
      Date oldOppCloseDate = oldMap.get(opp.Id).CloseDate;
      //Display message if:
      //It is lead converted opportunity AND
      //Close date is not updated by using flag - Has_Close_Date_Changed__c
      String oldName = oldMap.get(opp.Id).Name;
      if (
        oldName != 'placeholder' &&
        opp.Lead_Converted__c &&
        !opp.Has_Close_Date_Changed__c &&
        oldOppCloseDate == opp.CloseDate
      ) {
        opp.addError(
          'CloseDate',
          'Please select a Closing Date (i.e. expected settlement date)'
        );
      } else if (oldOppCloseDate != opp.CloseDate) {
        opp.Has_Close_Date_Changed__c = true;
      }
    }
  }

  /**
   * @description Retrieve accounts mapped with Id as Key
   * @name getMappedAccounts
   * @param accountIds List of Accounts used by Opportunities
   * @return `Map<Id,Account>`
   */
  private static Map<Id, Account> getMappedAccounts(Set<Id> accountIds) {
    try {
      return new Map<Id, Account>(
        [
          SELECT Id, Name, FinServ__Status__c
          FROM Account
          WHERE Id IN :accountIds
          WITH SECURITY_ENFORCED
        ]
      );
    } catch (System.QueryException e) {
      lib_systemLog log = new lib_systemLog(
        CCRMOpportunityActions.class.getName(),
        'getMappedAccounts'
      );
      log.error('InsufficientAccessException', e.getMessage(), e.getTypeName());
      log.publishEvent();
    }
    return new Map<Id, Account>();
  }

  /**
   * @description This method will Loop through Accounts mapped with Opportunity and determine if Account is a Prospect
   * @name checkAccountIsProspect
   * @param accountIds List of Accounts used by Opportunities
   * @param records List of Opportunities in transaction
   */
  private static void checkAccountIsProspect(
    Set<Id> accountIds,
    List<Opportunity> records
  ) {
    Map<Id, Account> accounts = getMappedAccounts(accountIds);

    for (Opportunity record : records) {
      if (accounts.containsKey(record.AccountId)) {
        Account acc = accounts.get(record.AccountId);
        if (acc.FinServ__Status__c != 'Active' && !record.Lead_Converted__c) {
          record.addError(
            'AccountId',
            'Error Message - Lead process to be followed for prospect opportunity creation'
          );
        }
      }
    }
  }

  /**
   * @description This method will Loop through Accounts mapped with Opportunity and set Opportunity Name
   * @name setNameForOpportunityFromLead
   * @param accountIds List of Accounts used by Opportunities
   * @param records List of Opportunities in transaction
   */
  private static void setNameForOpportunityFromLead(
    Set<Id> accountIds,
    List<Opportunity> records
  ) {
    List<Opportunity> updatedRecords = new List<Opportunity>();
    Map<Id, Account> mappedAccounts = getMappedAccounts(accountIds);

    for (Opportunity record : records) {
      if (
        mappedAccounts.containsKey(record.AccountId) && record.Lead_Converted__c
      ) {
        Account acc = mappedAccounts.get(record.AccountId);
        record.Name = record.Opp_Id__c + ' ' + acc.Name;
        updatedRecords.add(record);
      }
    }
    if (
      Schema.sObjectType.Opportunity.fields.Name.isUpdateable() &&
      !updatedRecords.isEmpty()
    ) {
      List<Database.saveResult> results = Database.update(
        updatedRecords,
        false
      );
      //log errors to application log
      lib_systemLog log = new lib_systemLog(
        CCRMOpportunityActions.class.getName(),
        'setNameForOpportunityFromLead'
      );
      log.addDatabaseSaveResult('Opportunity', results, updatedRecords);
      log.insertLogAsync();
    }
  }

  /**
   * @description Check if this Opportunity AccountId has changed
   * @name isAccountIdChanged
   * @param record Opportunity record
   * @param oldRec old Opportunity
   * @return `Boolean` True if AccountId is updated otherwise false.
   */
  private static Boolean isAccountIdChanged(
    Opportunity record,
    Opportunity oldRec
  ) {
    if (oldRec != null && record.Account.Id != oldRec.Account.Id) {
      return true;
    }
    return false;
  }

  /**
   * @description Check if this Opportunity Amount has changed
   * @name isAccountNameChanged
   * @param record Opportunity record
   * @param oldRec old Opportunity
   * @return `Boolean` True if the Amount is updated otherwise false.
   */
  private static Boolean isAmountChanged(
    Opportunity record,
    Opportunity oldRec
  ) {
    if (oldRec != null && record.Amount != oldRec.Amount) {
      return true;
    }
    return false;
  }

  /**
   * @description Mask Description of Opportunity
   * @name maskDescription
   * @param record Opportunity to mask
   */
  private static void maskDescription(Opportunity record) {
    if (record.Description != null) {
      record.Description = TextUtils.maskData(record.Description);
    }
  }
}

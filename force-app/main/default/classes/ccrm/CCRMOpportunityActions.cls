/**
 * @author Emmanuel Yap
 * @since  05/2022
 * @group CCRM (Commercial CRM)
 * @description CCRMOpportunityActions is class to handle all the CCRM Account Actions
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class CCRMOpportunityActions {
  public static final String CLOSE_DATE_FIELD_NAME = 'CloseDate';
  public static final String INVALID_CLOSE_DATE_ERROR = 'Please select a Closing Date (i.e. expected settlement date)';
  public static final String ACCOUNT_ID_FIELD_NAME = 'AccountId';
  public static final String LEAD_PROCESS_FOR_PROSPECT_ERROR = 'Error Message - Lead process to be followed for prospect opportunity creation';
  public static final String RECIPROCAL_ROLE_FOR_CLG = 'CG';
  /**
   * @description Define custom exceptions
   */
  public class CustomException extends Exception {
  }

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
      maskDescription(opp);
      accountIds.add(opp.AccountId);
    }
    checkAccountIsProspect(accountIds, records);
  }

  /**
   * @description This method will populate CLG filed with opportunity account parent field.
   * @name populateClgAccount
   * @param records from the trigger
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in afterUpdate.
   */
  public static void populateClgAccount(
    List<Opportunity> records,
    Map<Id, Opportunity> oldMap
  ) {
    Set<Id> accountIds = new Set<Id>();
    for (Opportunity opp : records) {
      accountIds.add(opp.AccountId);
    }
    Map<Id, Id> mapOfAccountWithClgAccount = getMapOfAccountWithClgAccount(
      accountIds
    );

    for (Opportunity opp : records) {
      Id clgAccount = mapOfAccountWithClgAccount.get(opp.AccountId);
      opp.CLG__c = clgAccount != null ? clgAccount : null;
    }
  }

  /**
   * @description This method will get CLG account associated to accounts
   * @name getMapOfAccountWithClgAccount
   * @param accountIds Account Ids
   * @return Map<Id,Id> Account Ids with associated CLG Account Ids
   */
  public static Map<Id, Id> getMapOfAccountWithClgAccount(Set<Id> accountIds) {
    Map<Id, Id> mapOfAccountWithClgAccount = new Map<Id, Id>();
    if (Schema.sObjectType.FinServ__ReciprocalRole__c.isQueryable()) {
      List<FinServ__ReciprocalRole__c> roleId = [
        SELECT Id
        FROM FinServ__ReciprocalRole__c
        WHERE Name = :RECIPROCAL_ROLE_FOR_CLG
        LIMIT 1
      ];
      if (
        Schema.sObjectType.FinServ__AccountAccountRelation__c.isQueryable() &&
        roleId.size() > 0
      ) {
        for (FinServ__AccountAccountRelation__c relatedaccount : [
          SELECT FinServ__Account__c, FinServ__RelatedAccount__c
          FROM FinServ__AccountAccountRelation__c
          WHERE
            FinServ__Account__c IN :accountIds
            AND FinServ__Role__c = :roleId[0].Id
        ]) {
          mapOfAccountWithClgAccount.put(
            relatedaccount.FinServ__Account__c,
            relatedaccount.FinServ__RelatedAccount__c
          );
        }
      }
    }
    return mapOfAccountWithClgAccount;
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
        SELECT Id, AccountId, Lead_Converted__c, Name, Opp_Id__c, recordtypeId
        FROM Opportunity
        WHERE Id IN :oppIds
        WITH SECURITY_ENFORCED
      ];
      setNameForOpportunityFromLead(accountIds, opps);
    } catch (System.QueryException e) {
      Logger.error(
        'InsufficientAccessException' +
        e.getMessage() +
        e.getTypeName(),
        e
      );
      Logger.savelog();
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
    String strRecordTypeId = MLCRMConstants.MLCRM_OPPORTUNITY_RT_ID;
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
        oldOppCloseDate == opp.CloseDate &&
        opp.recordTypeId != strRecordTypeId
      ) {
        opp.addError(CLOSE_DATE_FIELD_NAME, INVALID_CLOSE_DATE_ERROR);
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
      Logger.error(
        'InsufficientAccessException' +
        e.getMessage() +
        e.getTypeName(),
        e
      );
      Logger.saveLog();
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
            ACCOUNT_ID_FIELD_NAME,
            LEAD_PROCESS_FOR_PROSPECT_ERROR
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
        //CC-5603 Opportunity name should be account name for Mobile Leniding Opportunity
        if (record.recordtypeId == MLCRMConstants.MLCRM_OPPORTUNITY_RT_ID) {
          record.Name = acc.Name;
        } else {
          record.Name = record.Opp_Id__c + ' ' + acc.Name;
        }
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
      Logger.error('', results);
      Logger.saveLog();
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

  /**
   * @description Validate Mandatory field when move to next stage and can't skip stage.
   * @name mandatoryFieldAndSkipStageCheck
   * @param newOppList list of new records
   * @param oldOppMap map of old records
   * @param isInsert when record is insert
   * @param isUpdate when record is update
   */

  public static void mandatoryFieldAndSkipStageCheck(
    List<Opportunity> newOppList,
    Map<Id, Opportunity> oldOppMap,
    Boolean isInsert,
    Boolean isUpdate
  ) {
    Map<Id, Opportunity> closingOppoIdMap = new Map<Id, Opportunity>();
    Map<Id, Opportunity> oppoIdMap = new Map<Id, Opportunity>();

    for (Opportunity oppIterator : newOppList) {
      if (oppIterator.RecordTypeId != CCRMConstants.CCRM_OPP_RT_ID) {
        continue;
      }
      if (oldOppMap == null && isInsert) {
        if (oppIterator.StageName != CCRMConstants.OPP_IDENTIFIED) {
          oppIterator.addError(CCRMConstants.STAGE_CAN_BE_OPP_IDENTIFIED);
        }
      } else if (
        oldOppMap != null &&
        isUpdate &&
        oppIterator.StageName != oldOppMap.get(oppIterator.Id).StageName
      ) {
        if (oppIterator.StageName.equalsIgnoreCase(CCRMConstants.OPP_WON)) {
          closingOppoIdMap.put(oppIterator.Id, oppIterator);
        } else {
          oppoIdMap.put(oppIterator.Id, oppIterator);
        }
        if (
          (oldOppMap.get(oppIterator.Id).StageName ==
          CCRMConstants.OPP_IDENTIFIED &&
          oppIterator.StageName != CCRMConstants.NEED_ANALYSIS) ||
          (oldOppMap.get(oppIterator.Id).StageName ==
          CCRMConstants.NEED_ANALYSIS &&
          oppIterator.StageName != CCRMConstants.SOL_DEV) ||
          (oldOppMap.get(oppIterator.Id).StageName == CCRMConstants.SOL_DEV &&
          oppIterator.StageName != CCRMConstants.APPROVED_OFFERED) ||
          (oldOppMap.get(oppIterator.Id).StageName ==
          CCRMConstants.APPROVED_OFFERED &&
          oppIterator.StageName != CCRMConstants.CUST_ACCEPT) ||
          (oldOppMap.get(oppIterator.Id).StageName ==
          CCRMConstants.CUST_ACCEPT &&
          oppIterator.StageName != CCRMConstants.OPP_WON &&
          oppIterator.StageName != CCRMConstants.OPP_LOST) ||
          (oldOppMap.get(oppIterator.Id).StageName == CCRMConstants.OPP_WON) ||
          (oldOppMap.get(oppIterator.Id).StageName == CCRMConstants.OPP_LOST)
        ) {
          oppIterator.addError(CCRMConstants.SKIP_STAGE);
        } else if (
          oppIterator.StageName == CCRMConstants.APPROVED_OFFERED &&
          (String.isBlank(oppIterator.BBD_Application_Number__c) ||
          String.isBlank(oppIterator.CLP_Credit_Case_Number__c))
        ) {
          oppIterator.addError(CCRMConstants.BBD_CLP_MANDATORY);
        } else if (
          oppIterator.StageName == CCRMConstants.OPP_LOST &&
          String.isBlank(oppIterator.Lost_Reason__c)
        ) {
          oppIterator.addError(CCRMConstants.LOST_REASON);
        } else if (
          (oppIterator.StageName == CCRMConstants.OPP_LOST ||
          oppIterator.StageName == CCRMConstants.OPP_WON) &&
          String.isBlank(oppIterator.Won_from_Lost_to__c)
        ) {
          oppIterator.addError(CCRMConstants.WON_LOST_MANDATORY);
        }
      }
      if (
        oppIterator.recordTypeId == CCRMConstants.CCRM_OPP_RT_ID &&
        oppIterator.LeadSource == 'Other' &&
        String.isBlank(oppIterator.Other_Source_Detail__c)
      ) {
        oppIterator.addError(CCRMConstants.OTHER_SOURCE_DETAIL_MANDATORY);
      }
    }
    checkOpportunityHasOpenTaskBeforeStageChange(closingOppoIdMap, oppoIdMap);
  }

  /**
   * @description Validate open task when moving to next stage.
   * @name checkOpportunityHasOpenTaskBeforeStageChange
   * @param closingOppoIdMap map of id and closing opportunity id
   * @param oppoIdMap map of id and stage change opportunity id
   */
  public static void checkOpportunityHasOpenTaskBeforeStageChange(
    Map<Id, Opportunity> closingOppoIdMap,
    Map<Id, Opportunity> oppoIdMap
  ) {
    if (!closingOppoIdMap.isEmpty()) {
      //get open tasks on opportunity being closed
      for (AggregateResult iterator : [
        SELECT WhatId
        FROM Task
        WHERE
          WhatId IN :closingOppoIdMap.keySet()
          AND Status != :CCRMConstants.STATUS_COMPLETED
          AND Status != :CCRMConstants.STATUS_NOT_REQUIRED
        GROUP BY WhatId
      ]) {
        closingOppoIdMap.get(String.valueOf(iterator.get('WhatId')))
          .addError(System.Label.CCRM_OpenTasksOnOpportunityCloseError);
      }
    }

    if (!oppoIdMap.isEmpty()) {
      //get open tasks on opportunity stage change
      for (AggregateResult iterator : [
        SELECT ActionPlan.TargetId whatId
        FROM ActionPlanItem
        WHERE
          ActionPlan.TargetId IN :oppoIdMap.keySet()
          AND Item.Status != :CCRMConstants.STATUS_COMPLETED
          AND Item.Status != :CCRMConstants.STATUS_NOT_REQUIRED
          AND IsRequired = TRUE
        GROUP BY ActionPlan.TargetId
      ]) {
        oppoIdMap.get(String.valueOf(iterator.get('whatId')))
          .addError(System.Label.CCRM_OpenTasksOnOpportunityError);
      }
    }
  }

  /**
   * @description populate opportunity name with auto number + Customer need value
   * @name populateOppNameOnInsert
   * @param oppList list of new records
   * @param oldOppMap map of old records
   * @param isInsert to check if it is insert operation
   * @param isUpdate to check if it is update operation
   */

  public static void populateOppName(
    List<Opportunity> oppList,
    Map<Id, Opportunity> oldOppMap,
    Boolean isInsert,
    Boolean isUpdate
  ) {
    try {
      if (isInsert && oldOppMap == null) {
        List<Opportunity> opptoUpdate = new List<Opportunity>();
        for (Opportunity oppIter : oppList) {
          if (oppIter.recordTypeId == CCRMConstants.CCRM_OPP_RT_ID) {
            Opportunity opp = new Opportunity();
            opp.Id = oppIter.Id;
            opp.Name = oppIter.Opp_Id__c + ' ' + oppIter.Customer_Needs__c;
            opptoUpdate.add(opp);
          }
        }
        if (!opptoUpdate.isEmpty()) {
          List<Database.saveResult> results = Database.update(
            opptoUpdate,
            false
          );
        }
      } else if (isUpdate) {
        for (Opportunity oppIter : oppList) {
          if (
            oppIter.recordTypeId == CCRMConstants.CCRM_OPP_RT_ID &&
            oppIter.Customer_Needs__c !=
            oldOppMap.get(oppIter.Id).Customer_Needs__c
          ) {
            oppIter.Name = oppIter.Opp_Id__c + ' ' + oppIter.Customer_Needs__c;
          }
        }
      }
    } catch (Exception ex) {
      Logger.error(
        'Error occured during updating opportunity name from lead',
        ex
      );
      Logger.saveLog();
      throw new CustomException(ex.getMessage());
    }
  }
}

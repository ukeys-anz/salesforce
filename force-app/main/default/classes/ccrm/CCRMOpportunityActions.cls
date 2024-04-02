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
  public static Boolean insertOpportunityContext = false;
  private static final String OPPORTUNITY_OWNERSHIP_ERROR = 'Opportunity can only be transferred within your segment.';

  private static final Profile CURRENT_USER_PROFILE = MLCRMCommonUtils.getProfileById(
    UserInfo.getProfileId()
  );
  private static final Boolean IS_CCRM_USER = (CURRENT_USER_PROFILE?.Name ==
  Label.CCRM_Profile_Name);

  private static Map<String, CCRM_Commercial_Stage_Action_Plan__mdt> stageActionPlanMapping = new Map<String, CCRM_Commercial_Stage_Action_Plan__mdt>();

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
        SELECT
          Id,
          AccountId,
          Lead_Converted__c,
          Name,
          Opp_Id__c,
          recordtypeId,
          Customer_Needs__c
        FROM Opportunity
        WHERE Id IN :oppIds
        WITH SECURITY_ENFORCED
      ];
      setNameForOpportunityFromLead(accountIds, opps);
    } catch (System.QueryException e) {
      Logger.error(
        'InsufficientAccessException' + e.getMessage() + e.getTypeName(),
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
        'InsufficientAccessException' + e.getMessage() + e.getTypeName(),
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
        if (
          acc.FinServ__Status__c != 'Active' &&
          !record.Lead_Converted__c &&
          record.RecordTypeId != MLCRMConstants.MLCRM_OPPORTUNITY_RT_ID
        ) {
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
   * @description Validates opportunity while stage changes
   * @name mandatoryFieldAndSkipStageCheck
   * @param oppWrapper CCRMOpportunityWrapper
   * @param oldOppMap map of old recordsList
   * @param isInsert when record is insert
   */
  public static void mandatoryFieldAndSkipStageCheck(
    CCRMOpportunityWrapper oppWrapper,
    Map<Id, Opportunity> oldOppMap,
    Boolean isInsert
  ) {
    try {
      //retrieve filtered CCRM Opps
      stageActionPlanMapping = getStageActionPlanMetadata(
        oppWrapper.filteredOpps
      );

      oppWrapper = getStageSegmentOrTemplateMap(
        oppWrapper,
        oldOppMap,
        stageActionPlanMapping
      );

      //checks for validations on opportunities
      CCRMOpportunityActionsSkipStageHelper.validateCCRMOpportunity(
        oppWrapper.filteredOpps,
        oppWrapper.stageUpdatedOpps,
        isInsert
      );

      //adds error for skipped stages
      CCRMOpportunityActionsSkipStageHelper.addErrorForSkippedStage(
        oppWrapper.stageUpdatedOpps.values(),
        oldOppMap,
        stageActionPlanMapping,
        oppWrapper.oppsStageSegmentMap
      );
      //Adds error for mandatory tasks
      CCRMOpportunityActionsSkipStageHelper.displayErrorForMandatoryTask(
        oppWrapper.oppsWithMandatoryTaskToTemplateMap,
        oppWrapper.oppWithMandatoryTaskMap
      );

      //checks if opp has any open tasks on closed stage
      CCRMOpportunityActionsSkipStageHelper.checkOpenTaskForClosedOpportunities(
        oppWrapper.closingOppoIdMap
      );
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    }
  }

  /**
   * @description gets filtered CCRM Opportunities
   * @name getFilteredCCRMOpps
   * @param newOppList list of new records
   * @param oldOppMap map of old recordsList
   * @param isUpdate when record is update
   * @return CCRMOpportunityWrapper wrapper object
   */
  public static CCRMOpportunityWrapper getFilteredCCRMOpps(
    List<Opportunity> newOppList,
    Map<Id, Opportunity> oldOppMap,
    Boolean isUpdate
  ) {
    CCRMOpportunityWrapper oppWrapper = new CCRMOpportunityWrapper();

    for (Opportunity oppIterator : newOppList) {
      if (oppIterator.RecordTypeId != CCRMConstants.CCRM_OPP_RT_ID) {
        continue;
      }
      oppWrapper.filteredOpps.add(oppIterator);

      if (
        isUpdate &&
        oppIterator.StageName != oldOppMap.get(oppIterator.Id).StageName &&
        oppIterator.StageName.equalsIgnoreCase(CCRMConstants.OPP_WON)
      ) {
        oppWrapper.closingOppoIdMap.put(oppIterator.Id, oppIterator);
      }
      if (
        isUpdate &&
        oppIterator.StageName != oldOppMap.get(oppIterator.Id).StageName
      ) {
        oppWrapper.stageUpdatedOpps.put(oppIterator.Id, oppIterator);
      }

      oppWrapper.oppIdToOwnerIdMap.put(oppIterator.Id, oppIterator.OwnerId);
    }

    Map<Id, User> userMap = new Map<Id, User>(
      [
        SELECT Id, Commercial_Segment__c
        FROM User
        WHERE Id IN :oppWrapper.oppIdToOwnerIdMap.values()
      ]
    );

    oppWrapper.oppOwnerIdToSegmentMap = userMap;

    return oppWrapper;
  }

  /**
   * @description get custom metadata records
   * @name getStageActionPlanMetadata
   * @param filteredOpps list of new CCRM Opportunity records
   * @return Map<Id, CCRM_Commercial_Stage_Action_Plan__mdt> map of string and metadata
   */
  public static Map<String, CCRM_Commercial_Stage_Action_Plan__mdt> getStageActionPlanMetadata(
    List<Opportunity> filteredOpps
  ) {
    if (filteredOpps.isEmpty()) {
      return null;
    }

    for (
      CCRM_Commercial_Stage_Action_Plan__mdt metadata : CCRM_Commercial_Stage_Action_Plan__mdt.getAll()
        .values()
    ) {
      String key =
        metadata.Current_Stage__c +
        '-' +
        metadata.Commercial_Segment__c;
      stageActionPlanMapping.put(key, metadata);
    }
    return stageActionPlanMapping;
  }

  /**
   * @description get stage segment map
   * @name getStageSegmentOrTemplateMap
   * @param oppWrapper wrapper having map of id and new opportunity having stage changes
   * @param oldOppMap map of id and old opportunity
   * @param stageActionPlanMapping custom metadata records containing stage and template
   * @return CCRMOpportunityWrapper opportunity wrapper
   */
  public static CCRMOpportunityWrapper getStageSegmentOrTemplateMap(
    CCRMOpportunityWrapper oppWrapper,
    Map<Id, Opportunity> oldOppMap,
    Map<String, CCRM_Commercial_Stage_Action_Plan__mdt> stageActionPlanMapping
  ) {
    for (Opportunity oppIterator : oppWrapper.stageUpdatedOpps.values()) {
      String ownerSegment = oppWrapper.oppOwnerIdToSegmentMap.get(
          oppWrapper.oppIdToOwnerIdMap.get(oppIterator.Id)
        )
        .Commercial_Segment__c;

      String oldValueKey =
        oldOppMap.get(oppIterator.Id).StageName +
        '-' +
        ownerSegment;

      String newValueKey = oppIterator.StageName + '-' + ownerSegment;

      oppWrapper.oppsStageSegmentMap.put(oppIterator.Id, oldValueKey);

      if (
        stageActionPlanMapping.containsKey(newValueKey) &&
        stageActionPlanMapping.get(newValueKey).Template_Name__c != null &&
        stageActionPlanMapping.get(newValueKey).Previous_Stage__c ==
        oldOppMap.get(oppIterator.Id).StageName
      ) {
        oppWrapper.oppIdToTemplateNameMap.put(
          oppIterator.Id,
          stageActionPlanMapping.get(newValueKey).Template_Name__c
        );
      }

      CCRM_Commercial_Stage_Action_Plan__mdt oldStageMetadata = stageActionPlanMapping.get(
        oldValueKey
      );

      if (
        oldStageMetadata != null &&
        (oldOppMap.get(oppIterator.Id).StageName ==
        oldStageMetadata.Current_Stage__c &&
        oppIterator.StageName == oldStageMetadata.Next_Stage__c &&
        !oppIterator.IsClosed &&
        oldStageMetadata.Template_Name__c != null)
      ) {
        oppWrapper.oppWithMandatoryTaskMap.put(oppIterator.Id, oppIterator);
        oppWrapper.oppsWithMandatoryTaskToTemplateMap.put(
          oppIterator.Id,
          oldStageMetadata.Template_Name__c
        );
      }
    }
    return oppWrapper;
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
        if (!IS_CCRM_USER) {
          return;
        }
        for (Opportunity oppIter : oppList) {
          if (oppIter.recordTypeId == CCRMConstants.CCRM_OPP_RT_ID) {
            Opportunity opp = new Opportunity();
            opp.Id = oppIter.Id;
            opp.Name = oppIter.Lead_Converted__c
              ? oppIter.Opp_Id__c + ' ' + oppIter.Customer_Needs__c
              : oppIter.Opp_Id__c +
                ' ' +
                oppIter.Customer_Needs__c +
                ' ' +
                oppIter.Name;
            opptoUpdate.add(opp);
          }
        }
        if (!opptoUpdate.isEmpty()) {
          CCRMOpportunityActions.insertOpportunityContext = true;
          List<Database.saveResult> results = Database.update(
            opptoUpdate,
            false
          );
        }
      } else if (isUpdate) {
        String oppoName = '';
        for (Opportunity oppIter : oppList) {
          if (oppIter.recordTypeId == CCRMConstants.CCRM_OPP_RT_ID) {
            if (
              oppIter.Customer_Needs__c !=
              oldOppMap.get(oppIter.Id).Customer_Needs__c ||
              oppIter.Name != oldOppMap.get(oppIter.Id).Name
            ) {
              oppoName = (oldOppMap.get(oppIter.Id)
                  .Name.replace(oppIter.Opp_Id__c, ''))
                .replace(oldOppMap.get(oppIter.Id).Customer_Needs__c, '');
              oppIter.Name = oppIter.Lead_Converted__c
                ? oppIter.Opp_Id__c + ' ' + oppIter.Customer_Needs__c
                : oppIter.Opp_Id__c +
                  ' ' +
                  oppIter.Customer_Needs__c +
                  ' ' +
                  oppoName;
            }
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

  /**
   * @description Throw error if we try to transfer the Opportunity ownership from BB to SBB/SBB-NBC and vice versa
   * - ownerID: throw error when try to change between segment.
   * @name transferOpportunityOwnership
   * @param newOppList List of new lead records.
   * @param oldOppMap Map of old lead records.
   */
  public static void transferOpportunityOwnership(
    List<Opportunity> newOppList,
    Map<Id, Opportunity> oldOppMap
  ) {
    Map<Id, User> userMap = new Map<Id, User>();
    Set<Id> ownerIdSet = new Set<Id>();
    if (
      System.UserInfo.getProfileId() !=
      CommonUtil.getProfileByName('ANZ CCRM Standard User').Id
    ) {
      return;
    }
    updateBulkOppOwnership(newOppList, oldOppMap);
    userMap = getOwnerCommercialSegment(newOppList, oldOppMap);
    validateOwnerChange(newOppList, oldOppMap, userMap);
  }

  /**
   * @description update the Opportunity_Owner__c with the OwnerId field
   * @name updateBulkOppOwnership
   * @param opportunityList list of new records
   * @param oldOppMap map of old recordsList
   */
  @TestVisible
  private static void updateBulkOppOwnership(
    List<Opportunity> opportunityList,
    Map<Id, Opportunity> oldOppMap
  ) {
    for (Opportunity opportunityRec : opportunityList) {
      if (opportunityRec.RecordTypeId != CCRMConstants.CCRM_OPP_RT_ID) {
        continue;
      }
      if (
        opportunityRec.Opportunity_Owner__c !=
        oldOppMap.get(opportunityRec.Id).Opportunity_Owner__c
      ) {
        opportunityRec.OwnerId = opportunityRec.Opportunity_Owner__c;
      }
    }
  }

  /**
   * @description Get the commercial segment of New and Old Owner
   * @name getOwnerCommercialSegment
   * @param opportunityList list of new records
   * @param oldOppMap map of old recordsList
   * @return Map<Id, User> User map containing the Id and Commerical Segment
   */
  @TestVisible
  private static Map<Id, User> getOwnerCommercialSegment(
    List<Opportunity> opportunityList,
    Map<Id, Opportunity> oldOppMap
  ) {
    Set<Id> ownerIdsSet = new Set<Id>();
    Map<Id, User> userMap;
    for (Opportunity opportunityRec : opportunityList) {
      if (opportunityRec.RecordTypeId != CCRMConstants.CCRM_OPP_RT_ID) {
        continue;
      }
      if (opportunityRec.OwnerId != oldOppMap.get(opportunityRec.Id).OwnerId) {
        ownerIdsSet.add(opportunityRec.OwnerId);
        ownerIdsSet.add(oldOppMap.get(opportunityRec.Id).OwnerId);
      }
    }
    if (!ownerIdsSet.isEmpty()) {
      try {
        userMap = new Map<Id, User>(
          [
            SELECT Id, Commercial_Segment__c
            FROM User
            WHERE Id IN :ownerIdsSet
            WITH SECURITY_ENFORCED
          ]
        );
      } catch (System.QueryException e) {
        Logger.error(
          'InsufficientAccessException' + e.getMessage() + e.getTypeName(),
          e
        );
        Logger.savelog();
      }
    }
    return userMap;
  }

  /**
   * @description Validate if the ownerChange within segment
   * @name validateOwnerChange
   * @param opportunityList list of new records
   * @param oldOppMap map of old recordsList
   * @param userMap map of User to get its Commercial Segment
   */
  private static void validateOwnerChange(
    List<Opportunity> opportunityList,
    Map<Id, Opportunity> oldOppMap,
    Map<Id, User> userMap
  ) {
    String newCommercialSegment = '';
    String oldCommercialSegment = '';
    String newOppOwner = '';
    String oldOppOwner = '';

    for (Opportunity opportunityRec : opportunityList) {
      if (opportunityRec.RecordTypeId != CCRMConstants.CCRM_OPP_RT_ID) {
        continue;
      }
      newOppOwner = opportunityRec.OwnerId;
      oldOppOwner = oldOppMap.get(opportunityRec.Id).OwnerId;
      newCommercialSegment = userMap
        ?.get(opportunityRec.OwnerId)
        .Commercial_Segment__c;
      oldCommercialSegment = userMap
        ?.get(oldOppMap.get(opportunityRec.Id).OwnerId)
        .Commercial_Segment__c;
      if (
        newOppOwner != oldOppOwner &&
        (String.isBlank(newCommercialSegment) ||
        (newCommercialSegment != oldCommercialSegment))
      ) {
        opportunityRec.addError(OPPORTUNITY_OWNERSHIP_ERROR);
      }
      if (opportunityRec.Opportunity_Owner__c != opportunityRec.OwnerId) {
        opportunityRec.Opportunity_Owner__c = opportunityRec.OwnerId;
      }
    }
  }

  /**
   * @description wrapper class for CCRM Opportunity
   */
  public class CCRMOpportunityWrapper {
    public Map<Id, Opportunity> closingOppoIdMap = new Map<Id, Opportunity>();
    public Map<Id, Opportunity> stageUpdatedOpps = new Map<Id, Opportunity>();
    public List<Opportunity> filteredOpps = new List<Opportunity>();
    public Map<Id, String> oppsStageSegmentMap = new Map<Id, String>();
    public Map<Id, String> oppIdToTemplateNameMap = new Map<Id, String>();
    public Map<Id, Id> oppIdToOwnerIdMap = new Map<Id, Id>();
    public Map<Id, User> oppOwnerIdToSegmentMap = new Map<Id, User>();
    public Map<Id, Opportunity> oppWithMandatoryTaskMap = new Map<Id, Opportunity>();
    public Map<Id, String> oppsWithMandatoryTaskToTemplateMap = new Map<Id, String>();
  }
}

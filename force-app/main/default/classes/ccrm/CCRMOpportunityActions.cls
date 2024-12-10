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
  private static final String MULTIPLE_CUSTOMER_NEEDS = 'Multiple Customer Needs';

  private static final Profile CURRENT_USER_PROFILE = MLCRMCommonUtils.getProfileById(
    UserInfo.getProfileId()
  );
  private static final Boolean IS_CCRM_USER = (CURRENT_USER_PROFILE?.Name ==
  Label.CCRM_Profile_Name);

  private static final CommercialOpportunityRepository COMMERCIALOPP_REPOSITORY = (CommercialOpportunityRepository) Lib_InstanceProvider.forType(
    CommercialOpportunityRepository.class
  );

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
      Logger.error('InsufficientAccessException', e).save();
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
      Logger.error('InsufficientAccessException', e).save();
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
      oppWrapper = getStageSegmentMap(oppWrapper, oldOppMap);

      //checks for validations on opportunities
      CommercialOpportunityHelper.validateCCRMOpportunity(oppWrapper, isInsert);

      //adds error for skipped stages
      CommercialOpportunityHelper.addErrorForSkippedStage(
        oppWrapper.stageUpdatedOpps.values(),
        oldOppMap,
        oppWrapper.oppsStageSegmentMap
      );

      //checks if opp has any open tasks on closed stage
      CommercialOpportunityHelper.checkOpenTaskForClosedOpportunities(
        oppWrapper.closingOppoIdMap
      );
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    }
  }

  /**
   * @description sets opportunity wrapper
   * @name setOpportunityWrapper
   * @param newOppList list of new records
   * @param oldOppMap map of old recordsList
   * @param isUpdate when record is update
   * @return CCRMOpportunityWrapper wrapper object
   */
  public static CCRMOpportunityWrapper setOpportunityWrapper(
    List<Opportunity> newOppList,
    Map<Id, Opportunity> oldOppMap,
    Boolean isUpdate
  ) {
    CCRMOpportunityWrapper oppWrapper = new CCRMOpportunityWrapper();

    oppWrapper.filteredOpps = ListUtil.filter(newOppList)
      .equals(Opportunity.RecordTypeId, RTOpportunity.commercialOpportunity)
      .toList();

    if (isUpdate) {
      List<Opportunity> stageUpdatedOppsList = ListUtil.filter(
          newOppList,
          oldOppMap
        )
        .equals(Opportunity.RecordTypeId, RTOpportunity.commercialOpportunity)
        .changed(Opportunity.StageName)
        .toList();

      oppWrapper.stageUpdatedOpps = (Map<Id, Opportunity>) ListUtil.mapBy(
        stageUpdatedOppsList,
        Opportunity.Id
      );

      List<Opportunity> oppsWonList = ListUtil.filter(stageUpdatedOppsList)
        .changedTo(Opportunity.StageName, CCRMConstants.OPP_WON)
        .toList();

      oppWrapper.closingOppoIdMap = (Map<Id, Opportunity>) ListUtil.mapBy(
        oppsWonList,
        Opportunity.Id
      );
    }

    for (Opportunity oppIterator : newOppList) {
      oppWrapper.oppIdToOwnerIdMap.put(oppIterator.Id, oppIterator.OwnerId);
    }

    oppWrapper.oppOwnerIdToSegmentMap = (Map<Id, User>) ListUtil.mapBy(
      COMMERCIALOPP_REPOSITORY.getUsers(oppWrapper.oppIdToOwnerIdMap.values()),
      User.Id
    );

    return oppWrapper;
  }

  /**
   * @description get stage segment map
   * @name getStageSegmentMap
   * @param oppWrapper wrapper having map of id and new opportunity having stage changes
   * @param oldOppMap map of id and old opportunity
   * @return CCRMOpportunityWrapper opportunity wrapper
   */
  public static CCRMOpportunityWrapper getStageSegmentMap(
    CCRMOpportunityWrapper oppWrapper,
    Map<Id, Opportunity> oldOppMap
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

      oppWrapper.oppsStageSegmentMap.put(oppIterator.Id, oldValueKey);
    }
    return oppWrapper;
  }

  /**
   * @description update opportunity name on insert
   * @name updateOpportunityNameOnInsert
   * @param filteredOpps filtered CCRM opps
   */
  public static void updateOpportunityNameOnInsert(
    List<Opportunity> filteredOpps
  ) {
    try {
      Map<Id, String> updatedOppsNameMap = new Map<Id, String>();

      updatedOppsNameMap = getMapWithUpdatedOpportunitiesName(
        filteredOpps,
        null
      );

      updateOpportunityListOnInsert(filteredOpps, updatedOppsNameMap);
    } catch (Exception ex) {
      Logger.error(ex.getMessage(), ex);
      Logger.saveLog();
      throw new CustomException(ex.getMessage());
    }
  }

  /**
   * @description update opportunity name on update
   * @name updateOpportunityNameOnUpdate
   * @param filteredOpps filtered CCRM opps
   * @param oldMap  old map of id and opportunity
   * @return  List<Opportunity>
   */
  public static List<Opportunity> updateOpportunityNameOnUpdate(
    List<Opportunity> filteredOpps,
    Map<Id, Opportunity> oldMap
  ) {
    try {
      List<Opportunity> oppList;
      Map<Id, String> updatedOppsNameMap;

      oppList = getFilteredOpportunities(filteredOpps, oldMap);

      updatedOppsNameMap = getMapWithUpdatedOpportunitiesName(oppList, oldMap);

      oppList = updateOpportunityListOnUpdate(oppList, updatedOppsNameMap);

      return oppList;
    } catch (Exception ex) {
      Logger.error(ex.getMessage(), ex);
      Logger.saveLog();
      throw new CustomException(ex.getMessage());
    }
  }

  @testVisible
  private static Map<Id, String> getMapWithUpdatedOpportunitiesName(
    List<Opportunity> filteredOpps,
    Map<Id, Opportunity> oldMap
  ) {
    Map<Id, String> updatedOppsNameMap = new Map<Id, String>();

    for (Opportunity opp : filteredOpps) {
      String oppName;
      String customerNeeds;
      String updatedOppName;

      customerNeeds = opp.Secondary_Customer_Needs__c != null
        ? MULTIPLE_CUSTOMER_NEEDS
        : opp.Customer_Needs__c;

      oppName = getOpportunityOldName(opp, oldMap);

      updatedOppName = generateOpportunityName(
        opp.Opp_Id__c,
        customerNeeds,
        oppName
      );
      updatedOppsNameMap.put(opp.Id, updatedOppName);
    }
    return updatedOppsNameMap;
  }

  @testVisible
  private static String generateOpportunityName(
    String oppId,
    String customerNeeds,
    String oppName
  ) {
    String opportunityName;

    opportunityName = oppId + ' ';
    if (String.isNotBlank(customerNeeds)) {
      opportunityName += customerNeeds + ' ';
    }
    if (String.isNotBlank(oppName)) {
      opportunityName += oppName + ' ';
    }
    return opportunityName;
  }

  @testVisible
  private static List<Opportunity> getFilteredOpportunities(
    List<Opportunity> filteredOpps,
    Map<Id, Opportunity> oldMap
  ) {
    List<Opportunity> updatedOpps = new List<Opportunity>();

    for (Opportunity opp : filteredOpps) {
      Boolean isCustomerNeedsChanged;
      Boolean isSecNeedsChanged;
      Boolean isNameChanged;
      Opportunity oldOpp;

      oldOpp = oldMap.get(opp.Id);

      isCustomerNeedsChanged = RecordComparisonUtil.fieldWasChanged(
        opp,
        oldOpp,
        Opportunity.Customer_Needs__c.getDescribe().getSObjectField()
      );
      isSecNeedsChanged = RecordComparisonUtil.fieldWasChanged(
        opp,
        oldOpp,
        Opportunity.Secondary_Customer_Needs__c.getDescribe().getSObjectField()
      );
      isNameChanged = RecordComparisonUtil.fieldWasChanged(
        opp,
        oldOpp,
        Opportunity.Name.getDescribe().getSObjectField()
      );

      if (!isSecNeedsChanged && !isCustomerNeedsChanged && !isNameChanged) {
        continue;
      }
      updatedOpps.add(opp);
    }
    return updatedOpps;
  }

  private static List<Opportunity> updateOpportunityListOnUpdate(
    List<Opportunity> filteredOpps,
    Map<Id, String> updatedOppsNameMap
  ) {
    for (Opportunity opp : filteredOpps) {
      opp.Name = updatedOppsNameMap.containsKey(opp.Id)
        ? updatedOppsNameMap.get(opp.Id)
        : '';
    }
    return filteredOpps;
  }

  @testVisible
  private static String getOpportunityOldName(
    Opportunity opp,
    Map<Id, Opportunity> oldMap
  ) {
    String oppoName = '';
    Opportunity oldOpp;
    String oldOppName;
    String oldCustomerNeeds;

    if (opp.Lead_Converted__c) {
      return null;
    }
    if (oldMap == null && !opp.Lead_Converted__c) {
      return opp.Name;
    }
    oldOpp = oldMap.get(opp.Id);
    oldOppName = oldOpp?.Name;
    oldCustomerNeeds = oldOpp?.Customer_Needs__c;

    //Replace old customer needs and opp Id with blank
    oppoName = (oldOppName.replace(oldCustomerNeeds, ''))
      .replace(opp?.Opp_Id__c, '');

    oppoName = oppoName.contains(MULTIPLE_CUSTOMER_NEEDS)
      ? oppoName.replace(MULTIPLE_CUSTOMER_NEEDS, '')
      : oppoName;

    return oppoName;
  }

  @testVisible
  private static List<Database.saveResult> updateOpportunityListOnInsert(
    List<Opportunity> filteredOpps,
    Map<Id, String> updatedOppsNameMap
  ) {
    List<Opportunity> updatedOpps = new List<Opportunity>();
    for (Opportunity opps : filteredOpps) {
      Opportunity opp = new Opportunity(Id = opps.Id);
      opp.Name = updatedOppsNameMap.containsKey(opps.Id)
        ? updatedOppsNameMap.get(opps.Id)
        : '';
      updatedOpps.add(opp);
    }
    if (updatedOpps.isEmpty()) {
      return new List<Database.saveResult>();
    }
    CCRMOpportunityActions.insertOpportunityContext = true;
    List<Database.saveResult> results = Database.update(updatedOpps, false);
    return results;
  }

  /**
   * @description update the OwnerId with the  Opportunity_Owner__c field
   * @name transferOpportunityOwnership
   * @param newOppList List of new lead records.
   * @param oldOppMap Map of old lead records.
   */
  public static void transferOpportunityOwnership(
    List<Opportunity> newOppList,
    Map<Id, Opportunity> oldOppMap
  ) {
    if (
      COMMERCIALOPP_REPOSITORY.getUserProfileId() !=
      QueryProfile.anzCCRMStandardUser.id
    ) {
      return;
    }

    List<Opportunity> filterOppList = ListUtil.filter(newOppList, oldOppMap)
      .changed(Opportunity.Opportunity_Owner__c)
      .toList();

    for (Opportunity opportunityRec : filterOppList) {
      opportunityRec.OwnerId = opportunityRec.Opportunity_Owner__c;
    }
  }

  /**
   * @description check if secondary customer needs contains customer needs
   * @name checkIfSecondaryCustomerNeedsContainsCustomerNeeds
   * @param ccrmOpps ccrm opps
   * @param oldOppsMap old map of opportunities
   * @param isInsert if the operation is insert
   */
  public static void checkIfSecondaryCustomerNeedsContainsCustomerNeeds(
    List<Opportunity> ccrmOpps,
    Map<Id, Opportunity> oldOppsMap,
    Boolean isInsert
  ) {
    for (Opportunity oppIterator : ccrmOpps) {
      Opportunity oldOpp;
      Boolean isCustomerNeedsChanged;
      Boolean isSecNeedsChanged;
      SObjectType objType;
      Boolean hasSameValue;

      objType = Schema.Opportunity.getSObjectType();

      hasSameValue = RecordComparisonUtil.picklistContainSameValue(
        oppIterator,
        Opportunity.Secondary_Customer_Needs__c.getDescribe().getSObjectField(),
        Opportunity.Customer_Needs__c.getDescribe().getSObjectField(),
        objType
      );

      if (!isInsert && !oldOppsMap.isEmpty()) {
        oldOpp = oldOppsMap.get(oppIterator.Id);

        isCustomerNeedsChanged =
          oldOpp != null &&
          RecordComparisonUtil.fieldWasChanged(
            oppIterator,
            oldOpp,
            Opportunity.Customer_Needs__c.getDescribe().getSObjectField()
          );
        isSecNeedsChanged =
          oldOpp != null &&
          RecordComparisonUtil.fieldWasChangedAndNotEqualNull(
            oppIterator,
            oldOpp,
            Opportunity.Secondary_Customer_Needs__c.getDescribe()
              .getSObjectField()
          );
      }

      // if secondary customer needs has value same as customer needs
      // throw error
      if (
        (isInsert || isCustomerNeedsChanged || isSecNeedsChanged) &&
        hasSameValue
      ) {
        oppIterator.Secondary_Customer_Needs__c.addError(
          CCRMConstants.CUSTOMER_NEEDS_ERROR
        );
      }
    }
  }

  /**
   * @description wrapper class for CCRM Opportunity
   */
  public class CCRMOpportunityWrapper {
    public Map<Id, Opportunity> closingOppoIdMap;
    public Map<Id, Opportunity> stageUpdatedOpps;
    public List<Opportunity> filteredOpps;
    public Map<Id, String> oppsStageSegmentMap;
    public Map<Id, Id> oppIdToOwnerIdMap;
    public Map<Id, User> oppOwnerIdToSegmentMap;

    /**
     * @description constructor for wrapper class for CCRM Opportunity
     */
    public CCRMOpportunityWrapper() {
      closingOppoIdMap = new Map<Id, Opportunity>();
      stageUpdatedOpps = new Map<Id, Opportunity>();
      filteredOpps = new List<Opportunity>();
      oppsStageSegmentMap = new Map<Id, String>();
      oppIdToOwnerIdMap = new Map<Id, Id>();
      oppOwnerIdToSegmentMap = new Map<Id, User>();
    }
  }
}

/**
 * @author Naman Garg
 * @since  Nov 2024
 * @description This is the action class for CommercialOpportunityTriggerHandler
 */
public with sharing class CommercialOpportunityActions {
  @testVisible
  private static final String OPP_WON = 'Opportunity Won';
  @testVisible
  private static final String OPP_LOST = 'Opportunity Lost';
  @testVisible
  private static final String NEW_STAGE = 'New';
  public static final String CLOSE_DATE_FIELD_NAME = 'CloseDate';
  public static final String INVALID_CLOSE_DATE_ERROR = 'Please Log Close Date: Click on the "Log Close Date" button and enter a Closing date (i.e. expected settlement date)';
  public static final String ACCOUNT_ID_FIELD_NAME = 'AccountId';
  public static final String LEAD_PROCESS_FOR_PROSPECT_ERROR = 'Error Message - Lead process to be followed for prospect opportunity creation';
  public static final String RECIPROCAL_ROLE_FOR_CLG = 'CG';
  public static Boolean insertOpportunityContext = false;
  private static final String MULTIPLE_CUSTOMER_NEEDS = 'Multiple Customer Needs';
  @testVisible
  private static final String OPP_DEFAULT_STAGE_ERROR = 'Stage can only be set to New.';
  @testVisible
  private static final String OTHER_SOURCE_DETAIL_MANDATORY = 'Other Source Detail is mandatory if Lead Source is Other.';
  @testVisible
  private static final String CUSTOMER_NEEDS_ERROR = 'Secondary Customer Needs should not be the same as Customer Needs.';
  private static final String OTHER = 'Other';

  private static final Set<SObjectField> OPP_FIELDS = new Set<SObjectField>{
    Opportunity.CLG__c,
    Opportunity.CLG_ID__c
  };
  private static final String CCRM_PROFILE = 'ANZ CCRM Standard User';

  private static final CommercialOpportunityRepository OPP_REPOSITORY = (CommercialOpportunityRepository) Lib_InstanceProvider.forType(
    CommercialOpportunityRepository.class
  );
  private static final UserInfoRepository USER_REPO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );
  /**
   * @description Define custom exceptions
   */
  public class CustomException extends Exception {
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
    Set<Id> accountIds = ListUtil.getIds(records, Opportunity.AccountId);
    Map<Id, Id> mapOfAccountWithClgAccount = CommercialOpportunityHelper.getMapOfAccountWithClgAccount(
      accountIds
    );

    for (Opportunity opp : records) {
      Id clgAccount = mapOfAccountWithClgAccount.containsKey(opp.AccountId)
        ? mapOfAccountWithClgAccount.get(opp.AccountId)
        : null;
      opp.CLG__c = clgAccount != null ? clgAccount : null;
    }
  }

  /**
   * @description : It will restrict the user to upload images in rich text fields
   * @name : restrictImagesInRichTextFields
   * @param records List of Opportunity records
   * @param oldMap Map of old Opportunity records
   */
  public static void restrictImagesInRichTextFields(
    List<Opportunity> records,
    Map<Id, Opportunity> oldMap
  ) {
    try {
      List<SObjectField> fieldList = Schema.SObjectType.Opportunity.fields.getMap()
        .values();
      Set<SObjectField> richTextFieldSet = CommercialCommonUtil.getRichTextFields(
        fieldList
      );
      CommercialCommonUtil.restrictImages(records, oldMap, richTextFieldSet);
    } catch (Exception e) {
      Logger.error('Error while restrict images on Opportunity', e).save();
    }
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
    Set<Id> accountIds = ListUtil.getIds(records, Opportunity.AccountId);
    Map<Id, Account> accounts = OPP_REPOSITORY.getClosedAccountMap(accountIds);
    CommercialOpportunityHelper.checkAccountIsProspect(accounts, records);
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
    List<Opportunity> filteredRecords = ListUtil.filter(records, oldMap)
      .changed(Opportunity.CloseDate)
      .toList();
    ListUtil.setField(
      filteredRecords,
      Opportunity.Has_Close_Date_Changed__c,
      true
    );
    Set<Id> changedClosedDateIds = ListUtil.getIds(
      filteredRecords,
      Opportunity.Id
    );
    List<Opportunity> errorRecords = ListUtil.filter(records, oldMap)
      .oldEquals(Opportunity.Name, 'placeholder')
      .equals(Opportunity.Lead_Converted__c, true)
      .equals(Opportunity.Has_Close_Date_Changed__c, false)
      .notEquals(Opportunity.Id, changedClosedDateIds)
      .toList();
    ListUtil.addError(errorRecords, INVALID_CLOSE_DATE_ERROR);
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
      validateCCRMOpportunity(oppWrapper, isInsert);

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
   * @description validate CCRM opportunities
   * @name validateCCRMOpportunity
   * @param oppWrapper CCRMOpportunity Wrapper
   * @param isInsert if the operation is insert
   */
  public static void validateCCRMOpportunity(
    CommercialOpportunityActions.CCRMOpportunityWrapper oppWrapper,
    Boolean isInsert
  ) {
    for (Opportunity oppIterator : oppWrapper.filteredOpps) {
      List<String> errors = new List<String>();

      //check if stage is not equal to "New" on creation of lead
      if (isInsert && oppIterator.StageName != NEW_STAGE) {
        errors.add(OPP_DEFAULT_STAGE_ERROR);
      }
      //check if other source detail is provided if leadsource is other
      if (
        oppIterator.LeadSource == OTHER &&
        String.isBlank(oppIterator.Other_Source_Detail__c)
      ) {
        errors.add(OTHER_SOURCE_DETAIL_MANDATORY);
      }

      String errorMessage = String.join(errors, '\n');

      //add error message
      if (String.isNotBlank(errorMessage)) {
        oppIterator.addError(errorMessage);
      }
    }
  }

  /**
   * @description sets opportunity wrapper
   * @name setOpportunityWrapper
   * @param newOppList list of new records
   * @param oldOppMap map of old recordsList
   * @return CCRMOpportunityWrapper wrapper object
   */
  public static CCRMOpportunityWrapper setOpportunityWrapper(
    List<Opportunity> newOppList,
    Map<Id, Opportunity> oldOppMap
  ) {
    CCRMOpportunityWrapper oppWrapper = new CCRMOpportunityWrapper();

    oppWrapper.filteredOpps = newOppList;

    List<Opportunity> stageUpdatedOppsList = ListUtil.filter(
        newOppList,
        oldOppMap
      )
      .changed(Opportunity.StageName)
      .toList();

    oppWrapper.stageUpdatedOpps = (Map<Id, Opportunity>) ListUtil.mapBy(
      stageUpdatedOppsList,
      Opportunity.Id
    );

    List<Opportunity> oppsWonList = ListUtil.filter(
        stageUpdatedOppsList,
        oldOppMap
      )
      .changedTo(Opportunity.StageName, OPP_WON)
      .toList();

    oppWrapper.closingOppoIdMap = (Map<Id, Opportunity>) ListUtil.mapBy(
      oppsWonList,
      Opportunity.Id
    );

    for (Opportunity oppIterator : newOppList) {
      oppWrapper.oppIdToOwnerIdMap.put(oppIterator.Id, oppIterator.OwnerId);
    }

    oppWrapper.oppOwnerIdToSegmentMap = (Map<Id, User>) ListUtil.mapBy(
      OPP_REPOSITORY.getUsers(oppWrapper.oppIdToOwnerIdMap.values()),
      User.Id
    );

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

      updatedOppsNameMap = getMapWithOpportunitiesName(filteredOpps, null);
      CommercialOpportunityHelper.updateOpportunityListOnInsert(
        filteredOpps,
        updatedOppsNameMap
      );
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

      oppList = CommercialOpportunityHelper.getFilteredOpportunities(
        filteredOpps,
        oldMap
      );

      updatedOppsNameMap = getMapWithOpportunitiesName(oppList, oldMap);

      oppList = CommercialOpportunityHelper.updateOpportunityListOnUpdate(
        oppList,
        updatedOppsNameMap
      );

      return oppList;
    } catch (Exception ex) {
      Logger.error(ex.getMessage(), ex);
      Logger.saveLog();
      throw new CustomException(ex.getMessage());
    }
  }

  @testVisible
  private static Map<Id, String> getMapWithOpportunitiesName(
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

      oppName = getOpportunityName(opp, oldMap);
      updatedOppName = CommercialOpportunityHelper.generateOpportunityName(
        opp.Opp_Id__c,
        opp.Lead_Converted__c ? customerNeeds : null,
        oppName,
        oldMap
      );
      updatedOppsNameMap.put(opp.Id, updatedOppName);
    }
    return updatedOppsNameMap;
  }

  @testVisible
  private static String getOpportunityName(
    Opportunity opp,
    Map<Id, Opportunity> oldMap
  ) {
    String oppoName = '';
    String oppName;
    String customerNeeds;

    if (oldMap == null && opp.Lead_Converted__c) {
      return null;
    }
    if (oldMap == null && !opp.Lead_Converted__c) {
      return opp.Name;
    }
    oppName = opp?.Name;
    customerNeeds = opp?.Customer_Needs__c;
    Opportunity oldOpp = oldMap.get(opp.Id);
    String oldCustomerNeeds = oldOpp?.Customer_Needs__c;

    //Replace new customer needs and opp Id with blank
    oppoName = oppName.replace(opp?.Opp_Id__c, '');
    oppoName = oppoName.replace(customerNeeds, '');

    //Replace old if it has customer needs and opp Id with blank
    oppoName = oppoName.replace(oldCustomerNeeds, '');
    oppoName = oppoName.contains(MULTIPLE_CUSTOMER_NEEDS)
      ? oppoName.replace(MULTIPLE_CUSTOMER_NEEDS, '')
      : oppoName;
    return oppoName.trim();
  }

  /**
   * @description check if secondary customer needs contains customer needs
   * @name checkIfSecondaryCustomerNeedsContainsCustomerNeeds
   * @param ccrmOpps ccrm opps
   * @param oldOppsMap old map of opportunities
   */
  public static void checkIfSecondaryCustomerNeedsContainsCustomerNeeds(
    List<Opportunity> ccrmOpps,
    Map<Id, Opportunity> oldOppsMap
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
        Opportunity.Secondary_Customer_Needs__c,
        Opportunity.Customer_Needs__c,
        objType
      );

      if (oldOppsMap != null) {
        oldOpp = oldOppsMap.get(oppIterator.Id);

        isCustomerNeedsChanged =
          oldOpp != null &&
          RecordComparisonUtil.fieldWasChanged(
            oppIterator,
            oldOpp,
            Opportunity.Customer_Needs__c
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
        (oldOppsMap == null || isCustomerNeedsChanged || isSecNeedsChanged) &&
        hasSameValue
      ) {
        oppIterator.Secondary_Customer_Needs__c.addError(CUSTOMER_NEEDS_ERROR);
      }
    }
  }

  /**
   * @description check if mandatory fields are filled on closed AFP
   * @name checkClosedStageFieldsOnAFPRelatedToOpp
   * @param commercialOpps commercial opps
   * @param oldOppMap old map of opportunities
   */
  public static void checkClosedStageFieldsOnAFPRelatedToOpp(
    List<Opportunity> commercialOpps,
    Map<Id, Opportunity> oldOppMap
  ) {
    List<Opportunity> closedOppsList = new List<Opportunity>();

    closedOppsList.addAll(
      (List<Opportunity>) ListUtil.filter(commercialOpps, oldOppMap)
        .equals(Opportunity.RecordTypeId, RTOpportunity.commercialOpportunity)
        .changedTo(Opportunity.StageName, OPP_LOST)
        .toList()
    );
    closedOppsList.addAll(
      (List<Opportunity>) ListUtil.filter(commercialOpps, oldOppMap)
        .equals(Opportunity.RecordTypeId, RTOpportunity.commercialOpportunity)
        .changedTo(Opportunity.StageName, OPP_WON)
        .toList()
    );

    Map<Id, Opportunity> closedOppsMap = (Map<Id, Opportunity>) ListUtil.mapBy(
      closedOppsList,
      Opportunity.Id
    );

    List<ApplicationFormProduct> appFormProducts = OPP_REPOSITORY.getLostAFPRelatedToOpportunity(
      closedOppsMap.keySet()
    );
    CommercialOpportunityHelper.addErrorOnOppForMissingFieldsOnClosedAFP(
      appFormProducts,
      closedOppsMap
    );
  }

  /**
   * @description : This is used to populate the CLG Info on Opportunity based on Existing customer
   * @param records opportunity list
   * @param oldMap record map
   */
  public static void populateInfo(
    List<Opportunity> records,
    Map<Id, Opportunity> oldMap
  ) {
    List<Opportunity> filteredOppList = ListUtil.filter(records, oldMap)
      .changed(Opportunity.AccountId)
      .isNotNull(Opportunity.AccountId)
      .toList();

    List<Opportunity> oppWithNoAccountIdList = ListUtil.filter(records, oldMap)
      .changed(Opportunity.AccountId)
      .isNull(Opportunity.AccountId)
      .toList();

    ListUtil.setField(oppWithNoAccountIdList, OPP_FIELDS, null);

    Set<Id> accountIdSet = ListUtil.getIds(
      filteredOppList,
      Opportunity.AccountId
    );

    Map<Id, Account> accMap = new Map<Id, Account>(
      OPP_REPOSITORY.getAccountMap(accountIdSet)
    );

    List<FinServ__AccountAccountRelation__c> aarList = OPP_REPOSITORY.getAccountAccountRelations(
      accountIdSet
    );

    Map<Id, Map<Id, FinServ__AccountAccountRelation__c>> accIdToClgIdAARMap = formAccountIdToCLGIdAARMap(
      aarList
    );

    CommercialOpportunityHelper.populateClgCpidInfoOnOpp(
      filteredOppList,
      accMap,
      accIdToClgIdAARMap
    );
  }
  /**
   * @description : This is used to form the Account Id to related CLG Ids Map
   * @param aarList Account-Account relationship records
   * @return `Map<Id, Map<Id, FinServ__AccountAccountRelation__c>>`
   */
  @TestVisible
  private static Map<Id, Map<Id, FinServ__AccountAccountRelation__c>> formAccountIdToCLGIdAARMap(
    List<FinServ__AccountAccountRelation__c> aarList
  ) {
    Map<Id, Map<Id, FinServ__AccountAccountRelation__c>> accIdToClgIdsAARMap = new Map<Id, Map<Id, FinServ__AccountAccountRelation__c>>();
    for (FinServ__AccountAccountRelation__c aarRecord : aarList) {
      if (!accIdToClgIdsAARMap.containsKey(aarRecord.FinServ__Account__c)) {
        accIdToClgIdsAARMap.put(
          aarRecord.FinServ__Account__c,
          new Map<Id, FinServ__AccountAccountRelation__c>()
        );
      }
      accIdToClgIdsAARMap.get(aarRecord.FinServ__Account__c)
        .put(aarRecord.FinServ__RelatedAccount__c, aarRecord);
    }
    return accIdToClgIdsAARMap;
  }

  /**
   * @description : This is used to validate the account and CLG Info
   * @param records list of opportunities
   * @param oldMap Account-Account relationship records
   */
  public static void validateAndPopulateInfo(
    List<Opportunity> records,
    Map<Id, Opportunity> oldMap
  ) {
    if (!USER_REPO.checkProfile(CCRM_PROFILE)) {
      return;
    }
    List<Opportunity> filteredOppList = ListUtil.filter(records, oldMap)
      .changed(Opportunity.CLG__c)
      .toList();

    Set<Id> accountIdSet = ListUtil.getIds(
      filteredOppList,
      Opportunity.AccountId
    );

    Set<Id> clgIdSet = ListUtil.getIds(filteredOppList, Opportunity.CLG__c);

    Set<Id> combinedAccountIdsSet = new Set<Id>(accountIdSet);
    combinedAccountIdsSet.addAll(clgIdSet);

    Map<Id, Account> accMap = new Map<Id, Account>(
      OPP_REPOSITORY.getAccountMap(combinedAccountIdsSet)
    );

    List<Account> clgAccountList = ListUtil.filter(accMap.values())
      .equals(Account.RecordTypeId, RTAccount.clgAccount)
      .toList();

    List<FinServ__AccountAccountRelation__c> aarList = OPP_REPOSITORY.getAccountAccountRelations(
      accountIdSet
    );

    Map<Id, Set<Id>> accIdToClgIdsMap = formAccountIdToCLGIdsMap(aarList);

    addCLGAccountToMap(accIdToClgIdsMap, clgAccountList);

    CommercialOpportunityHelper.validateAndPopulateCLGInfo(
      filteredOppList,
      accMap,
      accIdToClgIdsMap
    );
  }

  /**
   * @description : This is used to form the Account Id to related CLG Ids Map
   * @param aarList Account-Account relationship records
   * @return `Map<Id, Set<Id>>`
   */
  @TestVisible
  private static Map<Id, Set<Id>> formAccountIdToCLGIdsMap(
    List<FinServ__AccountAccountRelation__c> aarList
  ) {
    Map<Id, Set<Id>> accIdToClgIdsMap = new Map<Id, Set<Id>>();
    for (FinServ__AccountAccountRelation__c aarRecord : aarList) {
      if (!accIdToClgIdsMap.containsKey(aarRecord.FinServ__Account__c)) {
        accIdToClgIdsMap.put(aarRecord.FinServ__Account__c, new Set<Id>());
      }
      accIdToClgIdsMap.get(aarRecord.FinServ__Account__c)
        .add(aarRecord.FinServ__RelatedAccount__c);
    }
    return accIdToClgIdsMap;
  }

  /**
   * @description : This is used to form the Account Id to related CLG Ids Map
   * @param accIdToClgIdsMap map of accountId to CLGIds
   * @param clgAccountList list of accounts
   */
  @TestVisible
  private static void addCLGAccountToMap(
    Map<Id, Set<Id>> accIdToClgIdsMap,
    List<Account> clgAccountList
  ) {
    for (Account accRec : clgAccountList) {
      if (!accIdToClgIdsMap.containsKey(accRec.Id)) {
        accIdToClgIdsMap.put(accRec.Id, new Set<Id>());
      }
      accIdToClgIdsMap.get(accRec.Id).add(accRec.Id);
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

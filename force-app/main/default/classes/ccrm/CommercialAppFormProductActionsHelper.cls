/**
 * @author Nabia Nadir
 * @since 08/2024
 * @description  CommercialAppFormProductActionsHelper is the helper class for commercial app form product Action class.
 */
public with sharing class CommercialAppFormProductActionsHelper {
  private static final CommercialOpportunityRepository COMMERCIALOPP_REPOSITORY = (CommercialOpportunityRepository) Lib_InstanceProvider.forType(
    CommercialOpportunityRepository.class
  );
  private static final CommercialAppFormProductActionsRepo AFP_REPOSITORY = (CommercialAppFormProductActionsRepo) Lib_InstanceProvider.forType(
    CommercialAppFormProductActionsRepo.class
  );
  private static final String REOPEN_CLOSED_OPP = 'You cannot reopen a closed stage.';

  private static final Set<String> CLOSED_STAGES = new Set<String>{
    'Opportunity Won',
    'Opportunity Lost'
  };

  /**
   * @description getAppFormProductsRelatedToCommercialOpportunity to get app form products records related to commercial opp
   * @param appFormIds set of app form ids set
   * @param records list of new app form products records
   * @return AppFormProductWrapper afp wrapper
   */
  public static AppFormProductWrapper getAppFormProductsRelatedToCommercialOpportunity(
    Set<Id> appFormIds,
    List<ApplicationFormProduct> records
  ) {
    AppFormProductWrapper appFormProductWrapper = new AppFormProductWrapper();

    try {
      List<ApplicationForm> appForms = AFP_REPOSITORY.getApplicationForms(
        appFormIds
      );
      Map<Id, ApplicationForm> appFormMap = new Map<Id, ApplicationForm>(
        appForms
      );
      appFormProductWrapper.filteredAppFormProducts = ListUtil.filter(records)
        .equals(ApplicationFormProduct.ApplicationFormId, appFormMap.keySet())
        .toList();

      for (
        ApplicationFormProduct appFormProduct : appFormProductWrapper.filteredAppFormProducts
      ) {
        appFormProductWrapper.apFormToOppIdMap.put(
          appFormProduct.ApplicationFormId,
          appFormMap.get(appFormProduct.ApplicationFormId).OpportunityId
        );
      }
    } catch (Exception e) {
      Logger.error(
          'Error occured while getting app form products related to commercial opp',
          e
        )
        .save();
    }
    return appFormProductWrapper;
  }

  /**
   * @description fetchvalidRecordId to get valid record Ids
   * @param records list of ApplicationFormProduct
   * @param oldMap map of Id and application form products
   * @return set<Id> set of valid Ids
   */
  public static Set<Id> fetchvalidRecordId(
    List<ApplicationFormProduct> records,
    Map<Id, ApplicationFormProduct> oldMap
  ) {
    records = ListUtil.filter(records, oldMap)
      .changed(ApplicationFormProduct.Close_Date__c)
      .toList();

    return ListUtil.getIds(records, ApplicationFormProduct.ApplicationFormId);
  }

  /**
   * @description setOpportunityCloseDateField to set opp fields based on filter condition
   * @param appFormList list of ApplicationForm
   * @param records List of ApplicationFormProduct
   * @return List<Opportunity> list of opp to update
   */
  public static List<Opportunity> setOpportunityCloseDateField(
    List<ApplicationForm> appFormList,
    List<ApplicationFormProduct> records
  ) {
    if (appFormList.isEmpty()) {
      return new List<Opportunity>();
    }
    Map<Id, ApplicationForm> appformMap = new Map<Id, ApplicationForm>(
      appFormList
    );
    list<Opportunity> oppToUpdate = new List<opportunity>();

    for (ApplicationFormProduct rec : records) {
      if (!appformMap.containsKey(rec.ApplicationFormId)) {
        continue;
      }
      Opportunity opp = appformMap.get(rec.ApplicationFormId).Opportunity;
      if (rec.Close_Date__c > opp.closeDate) {
        opp.closedate = rec.Close_Date__c;
        oppToUpdate.add(opp);
      }
    }
    return oppToUpdate;
  }

  /**
   * @description Validates AFP while stage changes
   * @name mandatoryFieldAndSkipStageCheck
   * @param appFormProductWrapper AppFormProductWrapper
   * @param oldMap map of old recordsList
   * @param isInsert when record is insert
   */
  public static void mandatoryFieldAndSkipStageCheck(
    AppFormProductWrapper appFormProductWrapper,
    Map<Id, ApplicationFormProduct> oldMap,
    Boolean isInsert
  ) {
    try {
      appFormProductWrapper = populateAppFormProductWrapper(
        appFormProductWrapper,
        oldMap
      );

      appFormProductWrapper = getStageSegmentMap(appFormProductWrapper, oldMap);

      //checks for validations on afp
      validateCommercialAppFormProducts(appFormProductWrapper, isInsert);

      //gets AFPs whose old stages are Opp Won/Lost
      List<ApplicationFormProduct> filteredRecords = ListUtil.filter(
          appFormProductWrapper.stageUpdatedAppFormProducts.values(),
          oldMap
        )
        .changed(ApplicationFormProduct.Stage)
        .oldEquals(ApplicationFormProduct.Stage, CLOSED_STAGES)
        .toList();

      ListUtil.addError(filteredRecords, REOPEN_CLOSED_OPP);
    } catch (Exception e) {
      Logger.error('Error ocurred while checking stage on AFP', e).save();
    }
  }

  /**
   * @description populate afp wrapper
   * @name populateAppFormProductWrapper
   * @param appFormProductWrapper afp wrapper
   * @param oldMap map of id and old afp change opportunity
   * @return AppFormProductWrapper
   */
  public static AppFormProductWrapper populateAppFormProductWrapper(
    AppFormProductWrapper appFormProductWrapper,
    Map<Id, ApplicationFormProduct> oldMap
  ) {
    List<ApplicationFormProduct> stageUpdatedAfpList = ListUtil.filter(
        appFormProductWrapper.filteredAppFormProducts,
        oldMap
      )
      .changed(ApplicationFormProduct.Stage)
      .toList();

    appFormProductWrapper.stageUpdatedAppFormProducts = (Map<Id, ApplicationFormProduct>) ListUtil.mapBy(
      stageUpdatedAfpList,
      ApplicationFormProduct.Id
    );

    for (
      ApplicationFormProduct afp : appFormProductWrapper.filteredAppFormProducts
    ) {
      appFormProductWrapper.afpIdToOwnerIdMap.put(afp.Id, afp.OwnerId);
    }

    appFormProductWrapper.afpOwnerIdToSegmentMap = (Map<Id, User>) ListUtil.mapBy(
      COMMERCIALOPP_REPOSITORY.getUsers(
        appFormProductWrapper.afpIdToOwnerIdMap.values()
      ),
      User.Id
    );
    return appFormProductWrapper;
  }

  /**
   * @description get stage segment map
   * @name getStageSegmentMap
   * @param appFormProductWrapper wrapper having map of id and new afp having stage changes
   * @param oldMap map of id and old afp
   * @return AppFormProductWrapper afp wrapper
   */
  public static AppFormProductWrapper getStageSegmentMap(
    AppFormProductWrapper appFormProductWrapper,
    Map<Id, ApplicationFormProduct> oldMap
  ) {
    for (
      ApplicationFormProduct afp : appFormProductWrapper.stageUpdatedAppFormProducts.values()
    ) {
      String ownerSegment = appFormProductWrapper.afpOwnerIdToSegmentMap.get(
          appFormProductWrapper.afpIdToOwnerIdMap.get(afp.Id)
        )
        .Commercial_Segment__c;

      String oldValueKey = oldMap.get(afp.Id).Stage + '-' + ownerSegment;

      appFormProductWrapper.afpStageSegmentMap.put(afp.Id, oldValueKey);
    }
    return appFormProductWrapper;
  }

  /**
   * @description validate commercial afp
   * @name validateCommercialAppFormProducts
   * @param appFormProductWrapper appFormProductWrapper
   * @param isInsert if the operation is insert
   */
  public static void validateCommercialAppFormProducts(
    AppFormProductWrapper appFormProductWrapper,
    Boolean isInsert
  ) {
    for (
      ApplicationFormProduct appFormProduct : appFormProductWrapper.filteredAppFormProducts
    ) {
      List<String> errors = new List<String>();
      String errorMessage;

      //check if stage is not equal to "Opportunity Identified" on creation
      if (isInsert && appFormProduct.Stage != CCRMConstants.OPP_IDENTIFIED) {
        errors.add(CCRMConstants.AFP_DEFAULT_STAGE_ERROR);
      }

      //check if Lost reason and Lost reason details are provided if Opportunity is lost
      if (
        appFormProductWrapper.stageUpdatedAppFormProducts.values()
          .contains(appFormProduct) &&
        appFormProduct.Stage == CCRMConstants.OPP_LOST &&
        (String.isBlank(appFormProduct.Lost_Reason__c) ||
        String.isBlank(appFormProduct.Lost_Reason_Detail__c))
      ) {
        errors.add(CCRMConstants.LOST_REASON_DETAIL_MISSING);
      }
      //check if Won from lost is provided for Won/Lost opportunity
      if (
        (appFormProductWrapper.stageUpdatedAppFormProducts.values()
          .contains(appFormProduct) &&
        (appFormProduct.Stage == CCRMConstants.OPP_LOST ||
        appFormProduct.Stage == CCRMConstants.OPP_WON) &&
        String.isBlank(appFormProduct.Won_from_Lost_to__c))
      ) {
        errors.add(CCRMConstants.WON_LOST_MANDATORY);
      }

      errorMessage = String.join(errors, CCRMConstants.NEW_LINE_CHAR);

      //add error message
      if (String.isNotBlank(errorMessage)) {
        appFormProduct.addError(errorMessage);
      }
    }
  }

  /**
   * @description populateCloseDateOnAFP populate close date on AFP
   * @param appFormProductWrapper Application Form Product Wrapper
   * @param oppLineItemsMap Map containing productId as key and OLI as value
   */
  public static void populateCloseDateOnAFP(
    AppFormProductWrapper appFormProductWrapper,
    Map<String, OpportunityLineItem> oppLineItemsMap
  ) {
    for (
      ApplicationFormProduct afpRec : appFormProductWrapper.filteredAppFormProducts
    ) {
      if (afpRec.Close_Date__c != null) {
        continue;
      }
      Id oppId = appFormProductWrapper.apFormToOppIdMap.get(
        afpRec.ApplicationFormId
      );
      afpRec.Close_Date__c = oppLineItemsMap.get(oppId + '-' + afpRec.ProductId)
        ?.Expected_Settlement_Date__c;
    }
  }

  /**
   * @description updateStage update stage value
   * @param appFormProducts app form product records
   */
  public static void updateStage(List<ApplicationFormProduct> appFormProducts) {
    for (ApplicationFormProduct record : appFormProducts) {
      Loan_Application_System_Status_Mapping__mdt mappingRec = QueryLoanAppSystemStatusMapping.getBySourceSystemStatus(
        record.Source_System_Status__c
      );
      if (mappingRec == null) {
        continue;
      }
      record.Stage = mappingRec.Application_Product_Stage__c ?? record.Stage;
    }
  }

  /**
   * @description wrapper class for commercial afp
   */
  public class AppFormProductWrapper {
    public Map<Id, ApplicationFormProduct> stageUpdatedAppFormProducts = new Map<Id, ApplicationFormProduct>();
    public List<ApplicationFormProduct> filteredAppFormProducts = new List<ApplicationFormProduct>();
    public Map<Id, String> afpStageSegmentMap = new Map<Id, String>();
    public Map<Id, Id> afpIdToOwnerIdMap = new Map<Id, Id>();
    public Map<Id, User> afpOwnerIdToSegmentMap = new Map<Id, User>();
    public Map<Id, Id> apFormToOppIdMap = new Map<Id, Id>();
  }
}

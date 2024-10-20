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
  /**
   * @description Returns the opportunity stages metadata
   */
  static Map<String, Commercial_Stage__mdt> afpStagesBySegment {
    get {
      if (afpStagesBySegment != null) {
        return afpStagesBySegment;
      }
      afpStagesBySegment = new Map<String, Commercial_Stage__mdt>();
      for (
        Commercial_Stage__mdt metadata : Commercial_Stage__mdt.getAll().values()
      ) {
        if (
          metadata.Object_Name__c == null ||
          metadata.Object_Name__c.split(';')
            .contains(CCRMConstants.APPLICATION_FORM_PRODUCT)
        ) {
          String key =
            metadata.Current_Stage__c +
            '-' +
            metadata.Commercial_Segment__c;
          afpStagesBySegment.put(key, metadata);
        }
      }
      return afpStagesBySegment;
    }
    set;
  }

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

      //adds error for skipped stages
      addErrorForSkippedStage(
        appFormProductWrapper.stageUpdatedAppFormProducts.values(),
        oldMap,
        appFormProductWrapper.afpStageSegmentMap
      );
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
    if (appFormProductWrapper.filteredAppFormProducts.isEmpty()) {
      return;
    }

    for (
      ApplicationFormProduct appFormProduct : appFormProductWrapper.filteredAppFormProducts
    ) {
      String errorMessage = '';

      //check if stage is not equal to "Opportunity Identified" on creation
      if (isInsert && appFormProduct.Stage != CCRMConstants.OPP_IDENTIFIED) {
        errorMessage +=
          CCRMConstants.AFP_DEFAULT_STAGE_ERROR + CCRMConstants.NEW_LINE_CHAR;
      }

      //check if Lost reason and Lost reason details are provided if Opportunity is lost
      if (
        appFormProductWrapper.stageUpdatedAppFormProducts.values()
          .contains(appFormProduct) &&
        appFormProduct.Stage == CCRMConstants.OPP_LOST &&
        (String.isBlank(appFormProduct.Lost_Reason__c) ||
        String.isBlank(appFormProduct.Lost_Reason_Detail__c))
      ) {
        errorMessage +=
          CCRMConstants.LOST_REASON_DETAIL_MISSING +
          CCRMConstants.NEW_LINE_CHAR;
      }
      //check if Won from lost is provided for Won/Lost opportunity
      if (
        (appFormProductWrapper.stageUpdatedAppFormProducts.values()
          .contains(appFormProduct) &&
        (appFormProduct.Stage == CCRMConstants.OPP_LOST ||
        appFormProduct.Stage == CCRMConstants.OPP_WON) &&
        String.isBlank(appFormProduct.Won_from_Lost_to__c))
      ) {
        errorMessage +=
          CCRMConstants.WON_LOST_MANDATORY + CCRMConstants.NEW_LINE_CHAR;
      }

      //add error message
      if (String.isNotBlank(errorMessage)) {
        appFormProduct.addError(
          errorMessage.removeEnd(CCRMConstants.NEW_LINE_CHAR)
        );
      }
    }
  }

  /**
   * @description Adds error if stage is skipped
   * @name addErrorForSkippedStage
   * @param stageUpdatedAppFormProducts list of afp having stage changes
   * @param oldMap map of id and old afp change opportunity
   * @param afpStageSegmentMap afp stage segment map
   */
  public static void addErrorForSkippedStage(
    List<ApplicationFormProduct> stageUpdatedAppFormProducts,
    Map<Id, ApplicationFormProduct> oldMap,
    Map<Id, String> afpStageSegmentMap
  ) {
    for (ApplicationFormProduct afp : stageUpdatedAppFormProducts) {
      List<String> nextStage = new List<String>();

      Commercial_Stage__mdt metadata = afpStagesBySegment.get(
        afpStageSegmentMap.get(afp.Id)
      );

      if (metadata != null && metadata.Next_Stage__c != null) {
        nextStage = metadata.Next_Stage__c.split(';');
      }

      if (
        oldMap.get(afp.Id).Stage == metadata.Current_Stage__c &&
        afp.Stage != metadata.Previous_Stage__c &&
        !nextStage.contains(afp.Stage)
      ) {
        afp.addError(CCRMConstants.SKIP_STAGE);
      }

      if (
        (oldMap.get(afp.Id).Stage == CCRMConstants.OPP_LOST ||
        oldMap.get(afp.Id).Stage == CCRMConstants.OPP_WON) &&
        String.isNotBlank(afp.Stage)
      ) {
        afp.addError(CCRMConstants.REOPEN_CLOSED_OPP);
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
      afpRec.Close_Date__c = oppLineItemsMap.containsKey(
          oppId +
          '-' +
          afpRec.ProductId
        )
        ? oppLineItemsMap.get(oppId + '-' + afpRec.ProductId)
            .Expected_Settlement_Date__c
        : null;
    }
  }

  /**
   * @description wrapper class for commercial afp
   */
  public class AppFormProductWrapper {
    public Map<Id, ApplicationFormProduct> stageUpdatedAppFormProducts;
    public List<ApplicationFormProduct> filteredAppFormProducts;
    public Map<Id, String> afpStageSegmentMap;
    public Map<Id, Id> afpIdToOwnerIdMap;
    public Map<Id, User> afpOwnerIdToSegmentMap;
    public Map<Id, Id> apFormToOppIdMap;

    /**
     * @description constructor for wrapper class for commercial afp
     */
    public AppFormProductWrapper() {
      stageUpdatedAppFormProducts = new Map<Id, ApplicationFormProduct>();
      filteredAppFormProducts = new List<ApplicationFormProduct>();
      afpStageSegmentMap = new Map<Id, String>();
      afpIdToOwnerIdMap = new Map<Id, Id>();
      afpOwnerIdToSegmentMap = new Map<Id, User>();
      apFormToOppIdMap = new Map<Id, Id>();
    }
  }
}

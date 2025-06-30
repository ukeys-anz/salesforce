/**
 * @author Ayushi Gupta
 * @since 08/2024
 * @description  CommercialAppFormProductActions is the orchestrator class for commercial app form product Trigger handler.
 */
public with sharing class CommercialAppFormProductActions {
  private static final CommercialAppFormProductActionsRepo AFP_REPOSITORY = (CommercialAppFormProductActionsRepo) Lib_InstanceProvider.forType(
    CommercialAppFormProductActionsRepo.class
  );
  private static final CommercialOpportunityRepository COMMERCIALOPP_REPOSITORY = (CommercialOpportunityRepository) Lib_InstanceProvider.forType(
    CommercialOpportunityRepository.class
  );
  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final UserInfoRepository USER_REPO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );
  private static final CommercialAppFormProductActionsHelper AFP_HELPER = (CommercialAppFormProductActionsHelper) Lib_InstanceProvider.forType(
    CommercialAppFormProductActionsHelper.class
  );
  private static final CommercialOppTeamMemberRepository OPPTEAMMEMBER_REPOSITORY = (CommercialOppTeamMemberRepository) Lib_InstanceProvider.forType(
    CommercialOppTeamMemberRepository.class
  );
  private static final String ANZ_CCRM_STANDARD_USER = 'ANZ CCRM Standard User';

  /**
   * @description checkd stage of AFP on insert
   * @name checkStageOnInsert
   * @param records List<ApplicationFormProduct>
   */
  public static void checkStageOnInsert(List<ApplicationFormProduct> records) {
    Set<Id> appFormIds = ListUtil.getIds(
      records,
      ApplicationFormProduct.ApplicationFormId
    );
    CommercialAppFormProductActionsHelper.AppFormProductWrapper appFormProductWrapper = AFP_HELPER.getAppFormProductsRelatedToCommercialOpportunity(
      appFormIds,
      records
    );
    //checks for validations on AFP
    CommercialAppFormProductActionsHelper.validateCommercialAppFormProducts(
      appFormProductWrapper,
      true
    );
  }

  /**
   * @description check if stage is skipped
   * @name checkSkipStage
   * @param records List<ApplicationFormProduct>
   * @param oldMap map of old recordsList
   */
  public static void checkSkipStage(
    List<ApplicationFormProduct> records,
    Map<Id, ApplicationFormProduct> oldMap
  ) {
    if (!USER_REPO.checkProfile(ANZ_CCRM_STANDARD_USER)) {
      return;
    }

    Set<Id> appFormIds = ListUtil.getIds(
      records,
      ApplicationFormProduct.ApplicationFormId
    );
    CommercialAppFormProductActionsHelper.AppFormProductWrapper appFormProductWrapper = AFP_HELPER.getAppFormProductsRelatedToCommercialOpportunity(
      appFormIds,
      records
    );
    CommercialAppFormProductActionsHelper.mandatoryFieldAndSkipStageCheck(
      appFormProductWrapper,
      (Map<Id, ApplicationFormProduct>) oldMap,
      false
    );
  }

  /**
   * @description setFieldOnRelatedOpportunity to set fields of Opportunity
   * @param records List of ApplicationFormProduct
   * @param oldAppFormMap Map of Id and ApplicationFormProduct
   */
  public static void setFieldsOnRelatedOpportunity(
    List<ApplicationFormProduct> records,
    Map<Id, ApplicationFormProduct> oldAppFormMap
  ) {
    try {
      Set<Id> validAppFormRecordId = CommercialAppFormProductActionsHelper.fetchvalidRecordId(
        records,
        oldAppFormMap
      );
      List<ApplicationForm> filteredAppForms = AFP_REPOSITORY.getApplicationForms(
        validAppFormRecordId
      );
      List<Opportunity> oppToUpdate = CommercialAppFormProductActionsHelper.setOpportunityCloseDateField(
        filteredAppForms,
        records
      );
      DML.doUpdate(oppToUpdate);
    } catch (Exception e) {
      Logger.error('Error while setting fields on related opportunity', e)
        .save();
    }
  }

  /**
   * @description populateCloseDate This is to populate close date on AFP based on OLI
   * @param records applicationFormProduct records list
   */
  public static void populateCloseDate(List<ApplicationFormProduct> records) {
    try {
      Map<String, OpportunityLineItem> oppLineItemsMap = new Map<String, OpportunityLineItem>();
      Set<Id> appFormIds = ListUtil.getIds(
        records,
        ApplicationFormProduct.ApplicationFormId
      );
      CommercialAppFormProductActionsHelper.AppFormProductWrapper appFormProductWrapper = AFP_HELPER.getAppFormProductsRelatedToCommercialOpportunity(
        appFormIds,
        records
      );
      Set<Id> afpProductIds = ListUtil.getIds(
        appFormProductWrapper.filteredAppFormProducts,
        ApplicationFormProduct.ProductId
      );
      Set<Id> opportunityIdsSet = new Set<Id>(
        appFormProductWrapper.apFormToOppIdMap.values()
      );
      List<OpportunityLineItem> fetchOpportunityLineItems = AFP_REPOSITORY.getOppProductRelatedToAFP(
        afpProductIds,
        opportunityIdsSet
      );
      for (OpportunityLineItem oppLineItem : fetchOpportunityLineItems) {
        oppLineItemsMap.put(
          oppLineItem.OpportunityId + '-' + oppLineItem.Product2Id,
          oppLineItem
        );
      }
      CommercialAppFormProductActionsHelper.populateCloseDateOnAFP(
        appFormProductWrapper,
        oppLineItemsMap
      );
    } catch (Exception e) {
      Logger.error('Error while populating close date on AFP', e).save();
    }
  }

  /**
   * @description populateCloseDateForAmbitOnStageChange This is to populate close date on AMBIT AFPs when AFP is updated to closed Won
   * @param records applicationFormProduct records list
   * @param oldMap old applicationFormProduct map
   */
  public static void populateCloseDateForAmbitOnStageChange(
    List<ApplicationFormProduct> records,
    Map<Id, ApplicationFormProduct> oldMap
  ) {
    try {
      List<ApplicationFormProduct> filterAfpList = ListUtil.filter(
          records,
          oldMap
        )
        .changedTo(ApplicationFormProduct.Stage, CCRMConstants.OPP_WON)
        .toList();

      Set<Id> appFormIds = ListUtil.getIds(
        filterAfpList,
        ApplicationFormProduct.ApplicationFormId
      );

      List<ApplicationForm> fetchApplicationForm = AFP_REPOSITORY.getApplicationForms(
        appFormIds
      );

      List<ApplicationForm> filteredApplicationFormList = ListUtil.filter(
          fetchApplicationForm
        )
        .equals(
          ApplicationForm.RecordTypeId,
          RTApplicationForm.ambitApplication
        )
        .toList();

      Set<Id> ambitAppIds = new Map<Id, ApplicationForm>(
          filteredApplicationFormList
        )
        .keySet();

      filterAfpList = ListUtil.filter(filterAfpList)
        .equals(ApplicationFormProduct.ApplicationFormId, ambitAppIds)
        .toList();

      ListUtil.setField(
        filterAfpList,
        ApplicationFormProduct.Close_Date__c,
        System.today()
      );
    } catch (Exception e) {
      Logger.error('Error while populating close date on AFP', e).save();
    }
  }

  /**
   * @description populateStageUpdatedDate This is to populate stage updated date on AFP
   * @param records applicationFormProduct records list
   * @param oldMap old applicationFormProduct map
   */
  public static void populateStageUpdatedDate(
    List<ApplicationFormProduct> records,
    Map<Id, ApplicationFormProduct> oldMap
  ) {
    List<String> stages = new List<String>{
      'Opportunity Identified',
      'Needs Analysis',
      'Solution Development',
      'Approved & Offered',
      'Customer Acceptance'
    };
    for (ApplicationFormProduct afp : records) {
      if (stages.contains(afp.Stage) && afp.Stage != oldMap.get(afp.Id).Stage) {
        afp.Last_Updated_Stage_Date__c = System.today();
      }
    }
  }

  /**
   * @description mapStageWithSourceSystemStatus This is to map stage with source system status value
   * @param records applicationFormProduct records list
   * @param oldMap old applicationFormProduct map
   */
  public static void mapStageWithSourceSystemStatus(
    List<ApplicationFormProduct> records,
    Map<Id, ApplicationFormProduct> oldMap
  ) {
    try {
      List<ApplicationFormProduct> filterAfpList = ListUtil.filter(
          records,
          oldMap
        )
        .changed(ApplicationFormProduct.Source_System_Status__c)
        .toList();
      Set<Id> appFormIds = ListUtil.getIds(
        filterAfpList,
        ApplicationFormProduct.ApplicationFormId
      );
      CommercialAppFormProductActionsHelper.AppFormProductWrapper appFormProductWrapper = AFP_HELPER.getAppFormProductsRelatedToCommercialOpportunity(
        appFormIds,
        records
      );
      CommercialAppFormProductActionsHelper.updateStage(
        appFormProductWrapper.filteredAppFormProducts
      );
    } catch (Exception e) {
      Logger.error('Error while mapping status with source system status', e)
        .save();
    }
  }

  /**
   * @description validateProductOnAFP This is to used to validate product on AFP
   * @param records applicationFormProduct records list
   * @param oldMap old applicationFormProduct map
   */
  public static void validateProductOnAFP(
    List<ApplicationFormProduct> records,
    Map<Id, ApplicationFormProduct> oldMap
  ) {
    try {
      List<ApplicationFormProduct> filteredAfpList = ListUtil.filter(
          records,
          oldMap
        )
        .changed(ApplicationFormProduct.ProductId)
        .tolist();

      Set<Id> appFormIds = ListUtil.getIds(
        filteredAfpList,
        ApplicationFormProduct.ApplicationFormId
      );

      CommercialAppFormProductActionsHelper.AppFormProductWrapper appFormProductWrapper = AFP_HELPER.getAppFormProductsRelatedToCommercialOpportunity(
        appFormIds,
        filteredAfpList
      );

      List<OpportunityLineItem> oppLineItemList = AFP_REPOSITORY.fetchOppLineItems(
        appFormProductWrapper.apFormToOppIdMap.values()
      );

      Map<Id, List<OpportunityLineItem>> oppIdToOliMap = (Map<Id, List<OpportunityLineItem>>) ListUtil.groupBy(
        oppLineItemList,
        OpportunityLineItem.OpportunityId
      );

      CommercialAppFormProductActionsHelper.validateProduct(
        appFormProductWrapper,
        oppIdToOliMap
      );
    } catch (Exception e) {
      Logger.error('Error while updating the Product on App Form Product', e)
        .save();
    }
  }

  /**
   * @description createAppFormShareRecords This is to create app form share records
   * @param records applicationFormProduct records list
   */
  public static void createAppFormShareRecords(
    List<ApplicationFormProduct> records
  ) {
    try {
      Set<Id> appFormIds = ListUtil.getIds(
        records,
        ApplicationFormProduct.ApplicationFormId
      );
      List<ApplicationForm> filteredAppForms = AFP_REPOSITORY.getApplicationForms(
        appFormIds
      );
      Set<Id> oppIds = ListUtil.getIds(
        filteredAppForms,
        ApplicationForm.OpportunityId
      );
      List<OpportunityTeamMember> oppTeamMembers = OPPTEAMMEMBER_REPOSITORY.getOppTeamMembersRelatedToOpp(
        oppIds
      );
      Map<Id, List<OpportunityTeamMember>> oppIdToTeamMembersMap = (Map<Id, List<OpportunityTeamMember>>) ListUtil.groupBy(
        oppTeamMembers,
        OpportunityTeamMember.OpportunityId
      );
      List<ApplicationForm> appFormsForOppOwner = getAppFormsForOppOwner(
        filteredAppForms
      );
      Map<Id, Set<Id>> oppIdToMemberIds = getOppTeamMemberIds(
        filteredAppForms,
        oppIdToTeamMembersMap
      );
      List<ApplicationFormShare> appFormsShareList = createAppFormSharesForOppOwner(
        appFormsForOppOwner
      );
      appFormsShareList.addAll(
        createAppFormSharesForOppTeamMembers(filteredAppForms, oppIdToMemberIds)
      );
      DML.doInsert(appFormsShareList, new DmlConfig().withoutSharing());
    } catch (Exception e) {
      Logger.error(
          'Error while creating app form share records on creation of app form records',
          e
        )
        .save();
    }
  }

  /**
   * @description getAppFormsForOppOwner This is to get app forms records for opp owner
   * @param filteredAppForms filtered app forms
   * @return List<ApplicationForm>
   */
  private static List<ApplicationForm> getAppFormsForOppOwner(
    List<ApplicationForm> filteredAppForms
  ) {
    List<ApplicationForm> appFormsForOppOwner = new List<ApplicationForm>();
    for (ApplicationForm appForm : filteredAppForms) {
      if (appForm.OwnerId == appForm.Opportunity.OwnerId) {
        continue;
      }
      appFormsForOppOwner.add(appForm);
    }
    return appFormsForOppOwner;
  }

  /**
   * @description getOppTeamMemberIds This is to get team members for which we need sharing record
   * @param filteredAppForms filtered app forms
   * @param oppIdToTeamMembersMap opp Id to team members map
   * @return  Map<Id, Set<Id>>
   */
  @testVisible
  private static Map<Id, Set<Id>> getOppTeamMemberIds(
    List<ApplicationForm> filteredAppForms,
    Map<Id, List<OpportunityTeamMember>> oppIdToTeamMembersMap
  ) {
    Map<Id, Set<Id>> oppIdToMemberIds = new Map<Id, Set<Id>>();
    for (ApplicationForm appForm : filteredAppForms) {
      List<OpportunityTeamMember> teamMembers = oppIdToTeamMembersMap.get(
        appForm.OpportunityId
      ) ?? new List<OpportunityTeamMember>();
      for (OpportunityTeamMember member : teamMembers) {
        if (member.UserId == appForm.OwnerId) {
          continue;
        }
        if (!oppIdToMemberIds.containsKey(member.OpportunityId)) {
          oppIdToMemberIds.put(member.OpportunityId, new Set<Id>());
        }
        oppIdToMemberIds.get(member.OpportunityId).add(member.UserId);
      }
    }
    return oppIdToMemberIds;
  }

  /**
   * @description createAppFormSharesForOppTeamMembers This is to create app form share records for opp team members
   * @param appFormsForOppTeamMembers filtered app forms
   * @param oppIdToMemberIds opp Id to member ids set
   * @return List<ApplicationFormShare>
   */
  private static List<ApplicationFormShare> createAppFormSharesForOppTeamMembers(
    List<ApplicationForm> appFormsForOppTeamMembers,
    Map<Id, Set<Id>> oppIdToMemberIds
  ) {
    List<ApplicationFormShare> appFormsShareList = new List<ApplicationFormShare>();
    for (ApplicationForm appForm : appFormsForOppTeamMembers) {
      Set<Id> userIds = oppIdToMemberIds.get(appForm.OpportunityId) ??
        new Set<Id>();
      for (Id userId : userIds) {
        ApplicationFormShare appFormShare = new ApplicationFormShare();
        appFormShare.ParentId = appForm.Id;
        appFormShare.RowCause = 'Manual';
        appFormShare.accesslevel = 'Edit';
        appFormShare.UserOrGroupId = userId;
        appFormsShareList.add(appFormShare);
      }
    }
    return appFormsShareList;
  }

  /**
   * @description createOppShares This is to create opp share records
   * @param filteredAppForms filtered app forms
   * @return List<ApplicationFormShare>
   */
  private static List<ApplicationFormShare> createAppFormSharesForOppOwner(
    List<ApplicationForm> filteredAppForms
  ) {
    List<ApplicationFormShare> appFormsShareList = new List<ApplicationFormShare>();
    for (ApplicationForm appForm : filteredAppForms) {
      ApplicationFormShare appFormShare = new ApplicationFormShare();
      appFormShare.ParentId = appForm.Id;
      appFormShare.RowCause = 'Manual';
      appFormShare.accesslevel = 'Edit';
      appFormShare.UserOrGroupId = appForm.Opportunity.OwnerId;
      appFormsShareList.add(appFormShare);
    }
    return appFormsShareList;
  }
}

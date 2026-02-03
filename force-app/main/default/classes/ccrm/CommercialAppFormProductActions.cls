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
  private static final CommercialOppTeamMemberRepository OPPTEAMMEMBER_REPOSITORY = (CommercialOppTeamMemberRepository) Lib_InstanceProvider.forType(
    CommercialOppTeamMemberRepository.class
  );

  private static final String ANZ_CCRM_STANDARD_USER = 'ANZ CCRM Standard User';
  @testVisible
  private static final String OPP_WON = 'Opportunity Won';
  @testVisible
  private static final String OPP_LOST = 'Opportunity Lost';
  @testVisible
  private static final String OPP_CANCELLED = 'Cancelled';

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
    CommercialAppFormProductActionsHelper.AppFormProductWrapper appFormProductWrapper = CommercialAppFormProductActionsHelper.getAppFormProductsRelatedToCommercialOpportunity(
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
    CommercialAppFormProductActionsHelper.AppFormProductWrapper appFormProductWrapper = CommercialAppFormProductActionsHelper.getAppFormProductsRelatedToCommercialOpportunity(
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
      CommercialAppFormProductActionsHelper.AppFormProductWrapper appFormProductWrapper = CommercialAppFormProductActionsHelper.getAppFormProductsRelatedToCommercialOpportunity(
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
      CommercialAppFormProductActionsHelper.AppFormProductWrapper appFormProductWrapper = CommercialAppFormProductActionsHelper.getAppFormProductsRelatedToCommercialOpportunity(
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
  @testVisible
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
  @testVisible
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

  /**
   * @description This is used to update Application Amount on Opp
   * @name updateApprovedAmountOnOpp
   * @param records Application Form Products records
   * @param oldMap Map of Id and Application Form Products records
   */
  public static void updateApprovedAmountOnOpp(
    List<ApplicationFormProduct> records,
    Map<Id, ApplicationFormProduct> oldMap
  ) {
    try {
      //Filter AFP list when Stage changes to Opportunity Won
      List<ApplicationFormProduct> filteredAfpList = ListUtil.filter(
          records,
          oldMap
        )
        .changedTo(ApplicationFormProduct.Stage, 'Opportunity Won')
        .toList();

      //Filter AFP list when Amount changes and Stage equals to Opportunity Won
      filteredAfpList.addAll(
        (List<ApplicationFormProduct>) ListUtil.filter(records, oldMap)
          .changed(ApplicationFormProduct.Amount__c)
          .equals(ApplicationFormProduct.Stage, 'Opportunity Won')
          .toList()
      );

      if (filteredAfpList.isEmpty()) {
        return;
      }

      //Get the Application Form Id from the changed AFPs
      Set<Id> appFormIds = ListUtil.getIds(
        filteredAfpList,
        ApplicationFormProduct.ApplicationFormId
      );

      //Fetch the Application form records linked to those AFPs
      List<ApplicationForm> afList = AFP_REPOSITORY.getApplicationForms(
        appFormIds
      );

      //Fetch the Opportunity Id linked to AF
      Set<Id> oppIdsSet = ListUtil.getIds(
        afList,
        ApplicationForm.OpportunityId
      );

      //Fetch the AFPs linked to the Opportunity
      List<ApplicationFormProduct> afpAssociatedToOppList = AFP_REPOSITORY.getAfpRelatedToOpp(
        oppIdsSet
      );

      //Filtered out AFPs having stage as 'Opportunity Won'
      List<ApplicationFormProduct> wonAfpList = ListUtil.filter(
          afpAssociatedToOppList
        )
        .equals(ApplicationFormProduct.Stage, 'Opportunity Won')
        .toList();

      //Form map of Opportunity Line Item to Application Form Product
      Map<Id, List<ApplicationFormProduct>> oliToAfpMap = (Map<Id, List<ApplicationFormProduct>>) ListUtil.groupBy(
        wonAfpList,
        ApplicationFormProduct.Opportunity_Product__c
      );

      //Get the Opportunity Line items Ids from AFPs
      Set<Id> oliIdsSet = ListUtil.getIds(
        wonAfpList,
        ApplicationFormProduct.Opportunity_Product__c
      );

      //Fetch the Opportunity Line Items
      List<OpportunityLineItem> oliList = AFP_REPOSITORY.getOppLineItems(
        oliIdsSet
      );

      //Create map of line item to opp Id
      Map<Id, Id> itemIdToOppIdMap = CommercialAppFormProductActionsHelper.createLineItemIdToOppIdMap(
        oliList
      );

      Map<Id, Decimal> oppToAppAmountMap = CommercialAppFormProductActionsHelper.formOppToAmountMap(
        itemIdToOppIdMap,
        oliToAfpMap,
        ApplicationFormProduct.Amount__c
      );

      List<Opportunity> oppToUpdateList = CommercialAppFormProductActionsHelper.updateAmountOnOpportunity(
        oppToAppAmountMap,
        Opportunity.Approved_Amount__c
      );

      DML.doUpdate(oppToUpdateList);
    } catch (Exception e) {
      Logger.error('Error while updating the approved amount on Opportunity', e)
        .save();
    }
  }

  /**
   * @description This is used to update estimated revenue on Opp
   * @name calculateEstimatedRevenueOnOpp
   * @param records Application Form Products records
   * @param oldMap Map of Id and Application Form Products records
   */
  public static void calculateEstimatedRevenueOnOpp(
    List<ApplicationFormProduct> records,
    Map<Id, ApplicationFormProduct> oldMap
  ) {
    try {
      List<ApplicationFormProduct> filteredAfpList = ListUtil.filter(
          records,
          oldMap
        )
        .changed(ApplicationFormProduct.Revenue__c)
        .toList();

      if (filteredAfpList.isEmpty()) {
        return;
      }

      //Get the Application Form Id from the changed AFPs
      Set<Id> appFormIds = ListUtil.getIds(
        filteredAfpList,
        ApplicationFormProduct.ApplicationFormId
      );

      //Fetch the Application form records linked to those AFPs
      List<ApplicationForm> afList = AFP_REPOSITORY.getApplicationForms(
        appFormIds
      );

      //Fetch the Opportunity Id linked to AF
      Set<Id> oppIdsSet = ListUtil.getIds(
        afList,
        ApplicationForm.OpportunityId
      );

      //Fetch the AFPs linked to the Opportunity
      List<ApplicationFormProduct> afpAssociatedToOppList = AFP_REPOSITORY.getAfpRelatedToOpp(
        oppIdsSet
      );

      //Form map of Opportunity Line Item to Application Form Product
      Map<Id, List<ApplicationFormProduct>> oliToAfpMap = (Map<Id, List<ApplicationFormProduct>>) ListUtil.groupBy(
        afpAssociatedToOppList,
        ApplicationFormProduct.Opportunity_Product__c
      );

      //Get the Opportunity Line items Ids from AFPs
      Set<Id> oliIdsSet = ListUtil.getIds(
        afpAssociatedToOppList,
        ApplicationFormProduct.Opportunity_Product__c
      );

      //Fetch the Opportunity Line Items
      List<OpportunityLineItem> oliList = AFP_REPOSITORY.getOppLineItems(
        oliIdsSet
      );

      //Create map of line item to opp Id
      Map<Id, Id> itemIdToOppIdMap = CommercialAppFormProductActionsHelper.createLineItemIdToOppIdMap(
        oliList
      );

      Map<Id, Decimal> oppToEstimatedRevenueMap = CommercialAppFormProductActionsHelper.formOppToAmountMap(
        itemIdToOppIdMap,
        oliToAfpMap,
        ApplicationFormProduct.Revenue__c
      );

      List<Opportunity> oppToUpdateList = CommercialAppFormProductActionsHelper.updateAmountOnOpportunity(
        oppToEstimatedRevenueMap,
        Opportunity.Estimated_Revenue__c
      );

      DML.doUpdate(oppToUpdateList);
    } catch (Exception e) {
      Logger.error('Error while updating estimated revenue on Opportunity', e)
        .save();
    }
  }

  /**
   * @description This is used to update stage on opp
   * @name updateStageOnOpportunity
   * @param records Application Form Products records
   * @param oldMap Map of Id and Application Form Products records
   */
  public static void updateStageOnOpportunity(
    List<ApplicationFormProduct> records,
    Map<Id, ApplicationFormProduct> oldMap
  ) {
    try {
      List<ApplicationFormProduct> filteredAfpList = ListUtil.filter(
          records,
          oldMap
        )
        .changed(ApplicationFormProduct.Stage)
        .anyEqual(
          new Set<SObjectField>{ ApplicationFormProduct.Stage },
          new Set<String>{ OPP_WON, OPP_LOST, OPP_CANCELLED }
        )
        .toList();

      if (filteredAfpList.isEmpty()) {
        return;
      }
      Set<Id> appFormProductIds = new Map<Id, ApplicationFormProduct>(
          filteredAfpList
        )
        .keySet();
      List<ApplicationFormProduct> appFormProducts = AFP_REPOSITORY.getRelatedAFP(
        appFormProductIds
      );
      Set<Id> oppIds = new Set<Id>();
      for (ApplicationFormProduct afp : appFormProducts) {
        oppIds.add(afp.ApplicationForm.OpportunityId);
      }
      List<ApplicationFormProduct> appFormProductsList = AFP_REPOSITORY.getAfpRelatedToOpp(
        oppIds
      );
      Map<Id, List<ApplicationFormProduct>> appFormProductsByOppId = CommercialAppFormProductActionsHelper.getAFPsRelatedToOpp(
        appFormProductsList
      );
      List<Opportunity> opps = populateStage(appFormProductsByOppId);
      Map<Id, Opportunity> oppsToUpdate = new Map<Id, Opportunity>(opps);
      CommercialAFPActionsExtended.checkForOpenTasks(
        appFormProducts,
        filteredAfpList,
        oppsToUpdate
      );
      DML.doUpdate(opps);
    } catch (Exception e) {
      Logger.error('Error while updating stage on Opportunity', e).save();
    }
  }

  /**
   * @description populateStage updates stage on opp based on AFP
   * @param appFormProductsByOppId map of opp Id and app form products
   * @return List<Opportunity> list of opportunities
   */
  public static List<Opportunity> populateStage(
    Map<Id, List<ApplicationFormProduct>> appFormProductsByOppId
  ) {
    List<Opportunity> opps = new List<Opportunity>();

    for (Id oppId : appFormProductsByOppId.keySet()) {
      Set<String> stages = new Set<String>();

      for (ApplicationFormProduct afp : appFormProductsByOppId.get(oppId)) {
        if (
          afp.Stage != OPP_WON &&
          afp.Stage != OPP_LOST &&
          afp.Stage != OPP_CANCELLED
        ) {
          stages.clear();
          break;
        }
        stages.add(afp.Stage);
      }

      if (stages.isEmpty()) {
        continue;
      }

      String stageName = CommercialAppFormProductActionsHelper.resolveStage(
        stages
      );
      if (stageName != null) {
        opps.add(new Opportunity(Id = oppId, StageName = stageName));
      }
    }
    return opps;
  }

  /**
   * @description Synchronizes related Opportunity and Opportunity Line Item (OLI) fields
   * based on changes made to the Application Form Product (AFP) records.
   * @param records List of updated ApplicationFormProduct records (Trigger.new).
   * @param oldMap Map of ApplicationFormProduct records prior to update (Trigger.oldMap).
   */
  public static void syncSettlementDateAndAmountToOppProduct(
    List<ApplicationFormProduct> records,
    Map<Id, ApplicationFormProduct> oldMap
  ) {
    try {
      List<ApplicationFormProduct> changedAfpList = ListUtil.filter(
          records,
          oldMap
        )
        .anyChanged(
          new Set<SObjectField>{
            ApplicationFormProduct.Amount__c,
            ApplicationFormProduct.Close_Date__c
          }
        )
        .isNotNull(ApplicationFormProduct.Opportunity_Product__c)
        .toList();
      if (changedAfpList.isEmpty()) {
        return;
      }
      List<OpportunityLineItem> olisToUpdate = CommercialAppFormProductActionsHelper.prepareSyncOLI(
        changedAfpList
      );
      DML.doUpdate(olisToUpdate);
    } catch (Exception e) {
      Logger.error('Error in syncSettlementDateAndAmountToOppProduct', e)
        .save();
    }
  }

  /**
   * @description This is used to update the Is Potential Duplicate flag
   * @name setPotentialDuplicateFlag
   * @param records AFP records
   * @param oldMap Map of Id, records
   */
  public static void setPotentialDuplicateFlag(
    List<ApplicationFormProduct> records,
    Map<Id, ApplicationFormProduct> oldMap
  ) {
    try {
      //Get the list of AFP where Reference_Number__c changed
      List<ApplicationFormProduct> filteredAfpList = ListUtil.filter(
          records,
          oldMap
        )
        .changed(ApplicationFormProduct.Reference_Number__c)
        .equals(ApplicationFormProduct.Stage, 'Opportunity Won')
        .toList();

      //Extract the AF Ids from above filtered AFPs
      Set<Id> appFormIds = ListUtil.getIds(
        filteredAfpList,
        ApplicationFormProduct.ApplicationFormId
      );

      //Query AF records where Record type = 'BBD' and Opp stage = 'Opp Won'
      Map<Id, ApplicationForm> appFormMap = AFP_REPOSITORY.getApplicationFormsList(
        appFormIds
      );

      //Filter New version of AFPs records where AF Ids exists in above AF Map
      List<ApplicationFormProduct> newAfpList = ListUtil.filter(filteredAfpList)
        .equals(ApplicationFormProduct.ApplicationFormId, appFormMap.keySet())
        .toList();

      //Extract the new Reference number
      List<String> rnList = (List<String>) ListUtil.getValues(
        newAfpList,
        'Reference_Number__c',
        String.class
      );

      //Filter Old version of AFPs records where AF Ids exists in above AF Map
      List<ApplicationFormProduct> oldAfpList = ListUtil.filter(oldMap.values())
        .equals(ApplicationFormProduct.ApplicationFormId, appFormMap.keySet())
        .toList();

      //Extract the old Reference number
      rnList.addAll(
        (List<String>) ListUtil.getValues(
          oldAfpList,
          'Reference_Number__c',
          String.class
        )
      );

      //Queries all the existing AFPs based on above Reference Number and AFP Ids
      List<ApplicationFormProduct> existingAfpList = AFP_REPOSITORY.getExistingAfpList(
        rnList
      );

      //Form a Map of Reference number and list of AFPs
      Map<String, List<ApplicationFormProduct>> refNoToExistingAfpListMap = CommercialAppFormProductActionsHelper.formRefNoToExistingAfpListMap(
        existingAfpList
      );

      //Prepare the List of AFPs that need to be updated
      List<ApplicationFormProduct> afpListToUpdate = CommercialAppFormProductActionsHelper.setPDFlag(
        refNoToExistingAfpListMap
      );

      //Update AFPs records
      DML.doUpdate(afpListToUpdate, new DmlConfig().systemMode());
    } catch (Exception e) {
      Logger.error(
          'Error while setting the Is Potential Duplicate flag on AFPs',
          e
        )
        .save();
    }
  }
}

/**
 * @description Handles the publishing of Cloud Events for ApplicationFormProduct records.
 *              This class identifies relevant changes in ApplicationFormProduct data
 *              (insert/update), validates related ApplicationForms, and triggers event publication.
 *              After publishing, it updates the Account Sync Status where required.
 *
 * @author      Akanksha Kulkarni
 * @date        2025-11-10
 */
public with sharing class CommercialBrokerAppFormProdActions {
  private static final ApplicationFormEventRepository APPLICATIONFORM_EVENT_REPOSITORY = (ApplicationFormEventRepository) Lib_InstanceProvider.forType(
    ApplicationFormEventRepository.class
  );
  private static final ApplicationFormProductEventRepository APPLICATIONFORMPRODUCT_EVENT_REPOSITORY = (ApplicationFormProductEventRepository) Lib_InstanceProvider.forType(
    ApplicationFormProductEventRepository.class
  );
  private static final CommercialAppFormProductActionsRepo AFP_REPOSITORY = (CommercialAppFormProductActionsRepo) Lib_InstanceProvider.forType(
    CommercialAppFormProductActionsRepo.class
  );
  private static final CommercialOpportunityRepository COMMERCIALOPP_REPOSITORY = (CommercialOpportunityRepository) Lib_InstanceProvider.forType(
    CommercialOpportunityRepository.class
  );
  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  @TestVisible
  public static final String SYNC_STATUS_BROKER_ORG = 'Broker Org';
  @TestVisible
  public static final String SYNC_STATUS_BLOCKED = 'Blocked';
  @TestVisible
  public static final String APP_SOURCE_BKOLA = 'BKOLA';

  /**
   * @description Publishes one event per parent ApplicationForm
   *              when qualifying ApplicationFormProduct fields change (update)
   *              or are populated on insert.
   * @param records      The list of ApplicationFormProduct records being processed.
   * @param oldMap       The map of old ApplicationFormProduct records for updates (null for inserts).
   * @param eventContext The event type or context (e.g., 'applicationformproductadd').
   * @return A list of published Cloud_Event__e records.
   */
  public static List<Cloud_Event__e> publishApplicationFormProductEvent(
    List<ApplicationFormProduct> records,
    Map<Id, ApplicationFormProduct> oldMap,
    String eventContext
  ) {
    List<Cloud_Event__e> allPublishedEvents = new List<Cloud_Event__e>();

    try {
      List<ApplicationFormProduct> changedProducts = getChangedProducts(
        records,
        oldMap
      );
      Set<Id> assetFinanceProductIdSet = QueryProducts.getAssetFinanceProduct();

      /*** Application FORM "NO QUOTE" SCENARIO FILTERING - STARTS ***/
      //Check if asset finance product
      List<ApplicationFormProduct> filteredProducts = ListUtil.filter(
          changedProducts
        )
        .equals(ApplicationFormProduct.ProductId, assetFinanceProductIdSet)
        .toList();
      //Check if related ApplicationForm is AMBIT
      List<ApplicationForm> appFormsAmbitWithoutQuote = APPLICATIONFORMPRODUCT_EVENT_REPOSITORY.getQualifiedApplicationForms(
        filteredProducts
      );
      //Check if Broker is not Null OR TPMI SAO is not null
      List<ApplicationForm> appFormsWithoutBrokerWithQuote = filterFormsWithBroker(
        appFormsAmbitWithoutQuote
      );
      List<ApplicationForm> appFormListWithBrokerSyncStatus = ListUtil.filter(
          appFormsWithoutBrokerWithQuote
        )
        .Contains(
          ApplicationForm.Sync_Status__c,
          BrokerConstants.SYNC_STATUS_BROKER_ORG
        )
        .toList();
      /*** Application FORM "NO QUOTE" SCENARIO FILTERING - ENDS ***/

      /*** Application FORM "QUOTE" SCENARIO FILTERING - STARTS ***/
      //Check if related ApplicationForm is AMBIT
      List<ApplicationFormProduct> solutionDevelopmentAppList = ListUtil.filter(
          changedProducts,
          oldMap
        )
        .changed(ApplicationFormProduct.Stage)
        .equals(ApplicationFormProduct.ProductId, assetFinanceProductIdSet)
        .anyEqual(
          new Set<SObjectField>{ ApplicationFormProduct.Stage },
          new Set<String>{ CCRMConstants.SOL_DEV }
        )
        .isNotNull(ApplicationFormProduct.Reference_Number__c)
        .toList();
      //Check if related ApplicationForm is AMBIT
      List<ApplicationForm> appFormsAmbitWithQuote = APPLICATIONFORMPRODUCT_EVENT_REPOSITORY.getQualifiedApplicationForms(
        solutionDevelopmentAppList
      );
      List<ApplicationForm> applicationFormWithQuote = ListUtil.filter(
          appFormsAmbitWithQuote
        )
        .isNull(ApplicationForm.Reference_Number__c)
        .toList();
      List<ApplicationForm> appFormsWithBrokerWithQuote = filterFormsWithBroker(
        applicationFormWithQuote
      );
      /*** Application FORM "QUOTE" SCENARIO FILTERING - ENDS ***/

      Map<Id, ApplicationForm> applicationsWithoutQuote = new Map<Id, ApplicationForm>(
        appFormListWithBrokerSyncStatus
      );
      Map<Id, ApplicationForm> applicationsWithQuote = new Map<Id, ApplicationForm>(
        appFormsWithBrokerWithQuote
      );
      Map<Id, ApplicationForm> mergedApplicationForm = new Map<Id, ApplicationForm>();
      mergedApplicationForm.putAll(applicationsWithQuote);
      mergedApplicationForm.putAll(applicationsWithoutQuote);
      Map<Id, String> accountIdAndExternalId = APPLICATIONFORM_EVENT_REPOSITORY.getRelatedAccounts(
        mergedApplicationForm.values()
      );
      ApplicationFormHelper.updateApplicationFormValues(
        mergedApplicationForm.values()
      );
      allPublishedEvents.addAll(
        publishEvents(
          mergedApplicationForm.values(),
          accountIdAndExternalId,
          eventContext
        )
      );

      if (!mergedApplicationForm.isEmpty()) {
        //'Calling Account Sync Status update for ApplicationForms: '
        ApplicationFormAccountActions.accountSyncStatusUpdate(
          mergedApplicationForm.keySet()
        );
      }
      return allPublishedEvents;
    } catch (Exception e) {
      Logger.error(
        'Error in CommercialBrokerAppFormProdActions.publishApplicationFormProductEvent: ' +
        e.getMessage(),
        e
      );
      Logger.saveLog();
    }

    return allPublishedEvents;
  }

  /**
   * @description Detects ApplicationFormProducts that changed or were newly populated with watched fields.
   * @param records The list of ApplicationFormProduct records being processed.
   * @param oldMap  The old values of ApplicationFormProduct records (null for insert operations).
   * @return A list of ApplicationFormProduct records where at least one relevant field changed or was populated.
   */
  @TestVisible
  private static List<ApplicationFormProduct> getChangedProducts(
    List<ApplicationFormProduct> records,
    Map<Id, ApplicationFormProduct> oldMap
  ) {
    Set<SObjectField> watchedFields = new Set<SObjectField>{
      ApplicationFormProduct.Application_Type__c,
      ApplicationFormProduct.Application_Source__c,
      ApplicationFormProduct.ProductId,
      ApplicationFormProduct.Amount__c,
      ApplicationFormProduct.Loan_Purpose__c,
      ApplicationFormProduct.Brokerage_Amount__c,
      ApplicationFormProduct.Reference_Number__c,
      ApplicationFormProduct.Source_System_Id__c,
      ApplicationFormProduct.Stage,
      ApplicationFormProduct.Source_System_Status__c,
      ApplicationFormProduct.Interest_Rate__c,
      ApplicationFormProduct.CSP_Status__c
    };
    return ListUtil.filter(records, oldMap)
      .anyChanged(watchedFields)
      .anyNotNull(watchedFields)
      .toList();
  }
  /**
   * @description Filters ApplicationForm records to include only those
   *             records where Broker_Name__c is not null.
   * @param applicationFormRecords The list of ApplicationForm records to filter.
   * @return A list of ApplicationForm records with Broker_Name__c.
   */
  @TestVisible
  private static List<ApplicationForm> filterFormsWithBroker(
    List<ApplicationForm> applicationFormRecords
  ) {
    List<ApplicationForm> result = new List<ApplicationForm>();
    for (ApplicationForm form : applicationFormRecords) {
      if (
        String.isNotBlank(form.Assisted_Broker_TPMI_SAO__c) ||
        (form.Opportunity != null &&
        form.Opportunity.Broker_Name__c != null)
      ) {
        result.add(form);
      }
    }
    return result;
  }

  /**
   * @description Publishes Cloud Events for each qualifying ApplicationForm record.
   * @param appForms             The list of qualifying ApplicationForm records.
   * @param accountIdAndExternalId A map of Account Ids to their corresponding External_Id__c values.
   * @param eventContext         The event type or context (e.g., 'applicationformproductadd').
   * @return A list of Cloud_Event__e records that were successfully published.
   */
  @TestVisible
  private static List<Cloud_Event__e> publishEvents(
    List<ApplicationForm> appForms,
    Map<Id, String> accountIdAndExternalId,
    String eventContext
  ) {
    List<Cloud_Event__e> publishedEvents = new List<Cloud_Event__e>();
    List<BrokerCloudEventModel> lstBrokerCloudEventModel = new List<BrokerCloudEventModel>();

    for (ApplicationForm app : appForms) {
      BrokerCloudEventModel.BrokerCloudEventDataModel ceData = ApplicationFormEventBuilder.buildApplicationFormPayload(
        new List<ApplicationForm>{ app },
        accountIdAndExternalId
      );
      String sourceId = app.OpportunityId + '-' + app.Assisted_Broker__c;
      BrokerCloudEventModel cloudEventModel = new BrokerCloudEventModel();
      cloudEventModel.ce_xtargets = 'ApplicationForm/' + sourceId;
      cloudEventModel.ce_type =
        System.Label.ANZX_applicationform_event_ce_type + eventContext;
      cloudEventModel.ce_source = System.Label.ANZX_applicationform_event_ce_source;
      cloudEventModel.ce_subject = 'ApplicationForm/' + sourceId;
      cloudEventModel.ce_partitionkey = 'ApplicationForm/' + sourceId;
      cloudEventModel.ce_dataschema = System.Label.ANZX_Main_Event_ApplicationForm_Proto_Data_Schema;
      cloudEventModel.ce_data = ceData;

      lstBrokerCloudEventModel.add(cloudEventModel);
    }

    List<SObject> published = CloudEventController.publishCloudEvents(
      lstBrokerCloudEventModel
    );

    CloudEventController.logSuccessEvents(
      (List<Cloud_Event__e>) published,
      'ApplicationFormProduct Event: '
    );

    publishedEvents.addAll((List<Cloud_Event__e>) published);

    return publishedEvents;
  }
  /**
   * @description createOptyAndOptyProductRecords - Creates Opportunities and Opportunity Products
   *              after the creation of ApplicationForm and ApplicationFormProduct records.
   * @param records List of ApplicationFormProduct records.
   * @author A M VIKASH
   * @since 10/2025
   */
  public static void createOptyAndOptyProductRecords(
    List<ApplicationFormProduct> records
  ) {
    try {
      // === Step 1
      OpportunityProcessingContext context = buildOpportunityProcessingContext(
        records
      );

      // Step 2: Create and update Opportunities
      Map<String, Object> oppData = createAndUpdateOpportunities(context);
      context.oppName = (Map<Id, String>) oppData.get('oppName');
      context.oppOwnerId = (Map<Id, String>) oppData.get('oppOwnerId');
      context.oppId = (Map<Id, String>) oppData.get('oppId');
      context.oppExternalId = (Map<Id, String>) oppData.get('oppExternalId');
      Map<String, String> optyIdFromAppNumber = (Map<String, String>) oppData.get(
        'optyIdFromAppNumber'
      );

      // Step 3: Create OpportunityLineItems and send notifications
      List<OpportunityLineItem> oliList = createOpportunityLineItemsAndNotify(
        context
      );
      if (!oliList.isEmpty()) {
        DML.doInsert(oliList, new DmlConfig().withoutSharing());
      }

      // Step 4: Update ApplicationForm and ApplicationFormProduct records
      Id optyLineItemId = oliList.isEmpty() ? null : oliList[0].Id;
      updateApplicationFormAndProduct(
        context,
        optyIdFromAppNumber,
        optyLineItemId
      );

      // Publish Event
      CommercialOpportunityEventAction.publishApplicationFormEvent(
        context.oppRecords,
        context.appFormMap,
        oliList,
        context.allProducts,
        'insert'
      );
    } catch (Exception e) {
      Logger.error('Error while creating Opportunity and related records', e)
        .save();
    }
  }

  // =========================================================================================================
  // === BUILD OPPORTUNITY PROCESSING CONTEXT
  // =========================================================================================================
  /**
   * @description Prepares and returns an OpportunityProcessingContext object by gathering
   *              ApplicationForm, ApplicationFormProduct, and Standard Pricebook data.
   * @param records List of ApplicationFormProduct records.
   * @return OpportunityProcessingContext Populated context for downstream operations.
   * @since 11/2025
   */
  private static OpportunityProcessingContext buildOpportunityProcessingContext(
    List<ApplicationFormProduct> records
  ) {
    // === Step 1: Build helper maps and collect all ApplicationFormProducts ===
    Map<Id, ApplicationForm> appFormMap = new Map<Id, ApplicationForm>();
    Map<Id, String> appFormAppNum = new Map<Id, String>();
    List<ApplicationFormProduct> allProducts = new List<ApplicationFormProduct>();

    // === Step 2: Extract unique ApplicationForm IDs ===
    Set<Id> appFormIds = ListUtil.getIds(
      records,
      ApplicationFormProduct.ApplicationFormId
    );

    // === Step 3: Retrieve ApplicationForms and related products ===
    List<ApplicationForm> filteredAppForms = AFP_REPOSITORY.getApplicationFormsAndProducts(
      appFormIds
    );

    for (ApplicationForm appForm : filteredAppForms) {
      appFormAppNum.put(
        appForm.Assisted_Broker__c,
        appForm.Reference_Number__c
      );
      appFormMap.put(appForm.Id, appForm);

      if (
        appForm.ApplicationFormProducts != null &&
        !appForm.ApplicationFormProducts.isEmpty()
      ) {
        allProducts.addAll(appForm.ApplicationFormProducts);
      }
    }

    // === Step 4: Retrieve Standard Pricebook ID ===
    Pricebook2 standardPricebook = COMMERCIALOPP_REPOSITORY.getStandardPricebook();

    // === Step 5: Build and return context ===
    OpportunityProcessingContext context = new OpportunityProcessingContext();
    context.allProducts = allProducts;
    context.appFormMap = appFormMap;
    context.appFormAppNum = appFormAppNum;
    context.standardPricebookId = standardPricebook.Id;
    context.notificationType = AFP_REPOSITORY.getOpportunityNotificationType();

    return context;
  }

  // =========================================================================================================
  // === CREATE & UPDATE OPPORTUNITIES
  // =========================================================================================================
  /**
   * @description Creates and updates Opportunity records based on ApplicationForm data.
   *              Handles both creation and post-insert updates (Name, Application Numbers, etc.).
   * @param context Wrapper object holding all required data.
   * @return Map<String, Object> Containing oppName, oppOwnerId, oppId, and optyIdFromAppNumber.
   */
  private static Map<String, Object> createAndUpdateOpportunities(
    OpportunityProcessingContext context
  ) {
    // Step 1: Build helper maps
    // Map<AccountId, OpportunityName>
    // Stores the Opportunity Name for each Account to use in notifications or updates
    Map<Id, String> accountIdToOpportunityNameMap = new Map<Id, String>();

    // Map<AccountId, OpportunityOwnerId>
    // Stores the Owner Id of each Opportunity for notification purposes
    Map<Id, Id> accountIdToOpportunityOwnerIdMap = new Map<Id, Id>();

    // Map<AccountId, OpportunityId>
    // Stores the created Opportunity Ids for each Account
    Map<Id, Id> accountIdToOpportunityIdMap = new Map<Id, Id>();

    // Map<ApplicationNumber, OpportunityId>
    // Used to update ApplicationForm and ApplicationFormProduct records after Opportunity creation
    Map<String, Id> applicationNumberToOpportunityIdMap = new Map<String, Id>();

    Map<Id, String> accountIdToOppExternalIdMap = new Map<Id, String>();

    // List of Opportunities that require post-insert updates (e.g., Name, Application Numbers)
    List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
    // Step 2: Create new Opportunities
    List<Opportunity> newOptys = CommercialBrokerAppFormProdActionsHelper.createOpportunity(
      context.allProducts,
      context.appFormMap,
      context.standardPricebookId
    );
    DML.doInsert(newOptys, new DmlConfig().withoutSharing());

    // Step 3: Retrieve inserted Opportunity details
    Set<Id> insertedOppIds = ListUtil.getIds(newOptys, Opportunity.Id);
    List<Opportunity> allOptyDetails = COMMERCIALOPP_REPOSITORY.getOpportunityDetails(
      insertedOppIds
    );

    //Store full opportunity records in context
    context.oppRecords = allOptyDetails;

    for (Opportunity opty : allOptyDetails) {
      String appNum = context.appFormAppNum.get(opty.Broker_Name__c);
      applicationNumberToOpportunityIdMap.put(appNum, opty.Id);

      Opportunity updatedOpty = new Opportunity(
        Id = opty.Id,
        Name = opty.Name.replace('DUMMY', '').trim(),
        Application_Numbers__c = appNum
      );
      opportunitiesToUpdate.add(updatedOpty);

      accountIdToOpportunityNameMap.put(opty.AccountId, updatedOpty.Name);
      accountIdToOpportunityOwnerIdMap.put(opty.AccountId, opty.OwnerId);
      accountIdToOpportunityIdMap.put(opty.AccountId, opty.Id);
      accountIdToOppExternalIdMap.put(opty.AccountId, opty.Opp_Id__c);
    }

    DML.doUpdate(opportunitiesToUpdate, new DmlConfig().withoutSharing());

    return new Map<String, Object>{
      'oppName' => accountIdToOpportunityNameMap,
      'oppOwnerId' => accountIdToOpportunityOwnerIdMap,
      'oppId' => accountIdToOpportunityIdMap,
      'optyIdFromAppNumber' => applicationNumberToOpportunityIdMap,
      'oppExternalId' => accountIdToOppExternalIdMap
    };
  }

  // =========================================================================================================
  // === CREATE OPPORTUNITY LINE ITEMS & SEND NOTIFICATIONS
  // =========================================================================================================
  /**
   * @description Creates OpportunityLineItems for the Opportunities and sends notifications
   *              to Opportunity Owners.
   * @param context Wrapper object holding all required data.
   * @return List<OpportunityLineItem> List of all OpportunityLineItems created.
   */
  private static List<OpportunityLineItem> createOpportunityLineItemsAndNotify(
    OpportunityProcessingContext context
  ) {
    List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();

    for (ApplicationFormProduct appFormProd : context.allProducts) {
      ApplicationForm parentForm = context.appFormMap.get(
        appFormProd.ApplicationFormId
      );
      if (parentForm == null) {
        continue;
      }

      // Create OpportunityLineItem for related Opportunity
      OpportunityLineItem oli = new OpportunityLineItem();
      oli.OpportunityId = context.oppId.get(parentForm.AccountId);
      oli.Product2Id = appFormProd.ProductId;
      oli.UnitPrice = appFormProd.Amount__c;

      oliList.add(oli);

      // Send notification
      CommercialBrokerAppFormProdActionsHelper.notifyOpportunityOwner(
        context.oppName.get(parentForm.AccountId),
        context.oppId.get(parentForm.AccountId),
        context.oppOwnerId.get(parentForm.AccountId),
        context.notificationType
      );
    }
    return oliList;
  }

  // =========================================================================================================
  // === UPDATE APPLICATION FORM & PRODUCT WITH OPPORTUNITY DATA
  // =========================================================================================================
  /**
   * @description Updates ApplicationForm and ApplicationFormProduct records with the OpportunityId.
   * @param context Wrapper object with data.
   * @param optyIdFromAppNumber Map of Application Number → Opportunity Id.
   * @param optyLineItemId The Id of an OpportunityLineItem for Source_System_Id__c generation.
   */
  private static void updateApplicationFormAndProduct(
    OpportunityProcessingContext context,
    Map<String, String> optyIdFromAppNumber,
    Id optyLineItemId
  ) {
    List<ApplicationFormProduct> updateProducts = new List<ApplicationFormProduct>();

    for (ApplicationFormProduct appFormProd : context.allProducts) {
      ApplicationForm appForm = context.appFormMap.get(
        appFormProd.ApplicationFormId
      );

      updateProducts.add(
        new ApplicationFormProduct(
          Id = appFormProd.Id,
          Source_System_Id__c = context.oppExternalId.get(appForm.AccountId) +
            '' +
            optyLineItemId
        )
      );
    }

    DML.doUpdate(updateProducts);
  }

  // =========================================================================================================
  // === WRAPPER CLASS
  // =========================================================================================================
  /**
   * @description Wrapper class used to hold all required data for Opportunity creation,
   *              avoiding long parameter lists.
   */
  public class OpportunityProcessingContext {
    public List<ApplicationFormProduct> allProducts;
    public Map<Id, ApplicationForm> appFormMap;
    public Map<Id, String> appFormAppNum;
    public Map<Id, String> oppId;
    public Map<Id, String> oppName;
    public Map<Id, String> oppOwnerId;
    public Id standardPricebookId;
    public CustomNotificationType notificationType;
    public List<Opportunity> oppRecords;
    public Map<Id, String> oppExternalId;
    /**
     * @description Default constructor for OpportunityProcessingContext.
     *              Initializes an empty context for Opportunity creation.
     * @author A M Vikash
     * @since 11/2025
     */
    public OpportunityProcessingContext() {
    }
  }
}

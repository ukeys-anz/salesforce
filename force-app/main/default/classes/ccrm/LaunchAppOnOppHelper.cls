/**
 * @author Ayushi Gupta
 * @since  08/2024
 * @description Helper class for launch application lwc.
 */
public with sharing class LaunchAppOnOppHelper {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  private static final LaunchAppOnOppControllerRepository APP_REPOSITORY = (LaunchAppOnOppControllerRepository) Lib_InstanceProvider.forType(
    LaunchAppOnOppControllerRepository.class
  );

  /**
   * @description create opp line item wrapper
   * @name createOppLineItemWrapper
   * @param items opp line items
   * @param selectedOppLineItemsIds selected opp line item ids
   * @return List<LaunchAppOnOppController.OppLineItemWrapper> wrapper list
   */
  public static List<LaunchAppOnOppController.OppLineItemWrapper> createOppLineItemWrapper(
    List<OpportunityLineItem> items,
    Set<Id> selectedOppLineItemsIds
  ) {
    List<LaunchAppOnOppController.OppLineItemWrapper> itemWrapper = new List<LaunchAppOnOppController.OppLineItemWrapper>();
    for (OpportunityLineItem record : items) {
      LaunchAppOnOppController.OppLineItemWrapper item = new LaunchAppOnOppController.OppLineItemWrapper();
      item.oppLineItemId = record.Id;
      item.productURL = '/lightning/r/Product2/' + record.Product2Id + '/view';
      item.productName = record.Product2?.Name;
      item.oppProductURL =
        '/lightning/r/OpportunityLineItem/' +
        record.Id +
        '/view';
      item.oppProductName = String.isNotBlank(record.Opp_Product_name__c)
        ? record.Opp_Product_name__c
        : record.Product2?.Name;
      if (String.isBlank(item.oppProductName)) {
        item.oppProductName = 'View Line Item';
      }
      item.unitPrice = record.UnitPrice;
      item.fundingPurpose = record.Funding_purpose__c;
      item.productId = record.Product2Id;
      item.isRowDisabled = selectedOppLineItemsIds.contains(record.Id);
      item.isSelected = false;
      itemWrapper.add(item);
    }
    return itemWrapper;
  }

  /**
   * @description create productId  amount map
   * @name createProductAmountMap
   * @param items opp line items
   * @return Map<Id, Decimal> productIdToAmountMap
   */
  public static Map<Id, Decimal> createProductAmountMap(
    List<OpportunityLineItem> items
  ) {
    Map<Id, Decimal> productIdToAmountMap = new Map<Id, Decimal>();
    for (OpportunityLineItem item : items) {
      productIdToAmountMap.put(item.Product2Id, item.UnitPrice);
    }
    return productIdToAmountMap;
  }

  /**
   * @description create application form
   * @name createApplicationForm
   * @param oppId opportunityId
   * @param recordTypeId record type Id
   * @return Id ap form Id
   */
  public static Id createApplicationForm(Id oppId, Id recordTypeId) {
    ApplicationForm appForm = new ApplicationForm(
      OpportunityId = oppId,
      UsageType = 'Other',
      RecordTypeId = recordTypeId
    );

    DML_REPOSITORY.doInsert(new List<ApplicationForm>{ appForm });
    return appForm.Id;
  }

  /**
   * @description create application form products
   * @name createApplicationFormProduct
   * @param appFormId appFormId
   * @param recordTypeId recordTypeId
   * @param oppLineItems oppLineItems
   * @return Id app form product Id
   */
  public static List<Id> createApplicationFormProduct(
    Id appFormId,
    Id recordTypeId,
    List<OpportunityLineItem> oppLineItems
  ) {
    List<Id> appFormProductIds = new List<Id>();
    List<ApplicationFormProduct> appFormProducts = new List<ApplicationFormProduct>();
    for (OpportunityLineItem item : oppLineItems) {
      ApplicationFormProduct appFormProduct = new ApplicationFormProduct(
        ApplicationFormId = appFormId,
        ProductId = item.Product2Id,
        Opportunity_Product__c = item.Id,
        Stage = CCRMConstants.OPP_IDENTIFIED,
        Amount__c = item.UnitPrice,
        Source_System_Id__c = recordTypeId == RTApplicationForm.ambitApplication
          ? item.Opportunity.Opp_Id__c + '' + item.Id
          : ''
      );
      appFormProducts.add(appFormProduct);
    }
    List<Database.SaveResult> result = DML_REPOSITORY.doInsert(appFormProducts);
    for (Database.SaveResult sr : result) {
      if (sr.isSuccess()) {
        appFormProductIds.add(sr.getId());
      }
    }
    return appFormProductIds;
  }

  /**
   * @description get selected opp line items ids in AFP's
   * @name getSelectedOppLineItemIds
   * @param apps list of app form products
   * @return Set<Id> set of opp line item ids
   */
  public static Set<Id> getSelectedOppLineItemIds(
    List<ApplicationFormProduct> apps
  ) {
    Set<Id> selectedOppLineItemsIds = new Set<Id>();
    for (ApplicationFormProduct app : apps) {
      Integer idIndex = app.Source_System_Id__c?.indexOf('00k') ?? -1;
      if (idIndex == -1) {
        continue;
      }
      Id oppLineItemId = app.Source_System_Id__c.substring(idIndex);
      selectedOppLineItemsIds.add(oppLineItemId);
    }
    return selectedOppLineItemsIds;
  }

  /**
   * @description populate record type wrapper
   * @name populateRecordTypeWrapper
   * @param opps Opportunity record
   * @return List<LaunchAppOnOppController.RecordTypeWrapper> list of record type wrapper
   */
  @AuraEnabled
  public static List<LaunchAppOnOppController.RecordTypeWrapper> populateRecordTypeWrapper(
    Opportunity opps
  ) {
    List<LaunchAppOnOppController.RecordTypeWrapper> typesList = new List<LaunchAppOnOppController.RecordTypeWrapper>();
    LaunchAppOnOppController.RecordTypeWrapper ambitRTWrapper = new LaunchAppOnOppController.RecordTypeWrapper(
      RTApplicationForm.ambitApplicationName,
      RTApplicationForm.ambitApplication,
      false,
      opps
    );
    typesList.add(ambitRTWrapper);
    LaunchAppOnOppController.RecordTypeWrapper bbdRTWrapper = new LaunchAppOnOppController.RecordTypeWrapper(
      RTApplicationForm.bbdApplicationName,
      RTApplicationForm.bbdApplication,
      true,
      opps
    );
    typesList.add(bbdRTWrapper);
    LaunchAppOnOppController.RecordTypeWrapper acmRTWrapper = new LaunchAppOnOppController.RecordTypeWrapper(
      RTApplicationForm.acmApplicationName,
      RTApplicationForm.acmApplication,
      true,
      opps
    );
    typesList.add(acmRTWrapper);
    LaunchAppOnOppController.RecordTypeWrapper internalAppRTWrapper = new LaunchAppOnOppController.RecordTypeWrapper(
      RTApplicationForm.internalApplicationName,
      RTApplicationForm.internalApplication,
      true,
      opps
    );
    typesList.add(internalAppRTWrapper);
    LaunchAppOnOppController.RecordTypeWrapper ocpRTWrapper = new LaunchAppOnOppController.RecordTypeWrapper(
      RTApplicationForm.ocpApplicationName,
      RTApplicationForm.ocpApplication,
      true,
      opps
    );
    typesList.add(ocpRTWrapper);
    return typesList;
  }

  /**
   * @description This is used to create the Request body need to send AMBIT
   * @name createAMBITRequestBody
   * @param opportunityId opportunity Id
   * @param oppLineItemId string of opp line items Id
   * @return CommercialAMBITRequestModel
   */
  public static CommercialAMBITRequestModel createAMBITRequestBody(
    Id opportunityId,
    Id oppLineItemId
  ) {
    Opportunity oppRec = APP_REPOSITORY.getOpportunityData(opportunityId);
    CommercialAMBITRequestModel ambitModel = new CommercialAMBITRequestModel(
      oppRec,
      oppLineItemId
    );
    return ambitModel;
  }

  /**
   * @description update application form and application form products
   * @name updateApplicationFormAndAppFormProduct
   * @param oppId opportunity Id
   * @param appFormProducts list of application form products
   * @param oppLineItemIds opportunity line item ids
   * @return List<Id> app form product Ids
   */
  public static List<Id> updateApplicationFormAndAppFormProduct(
    Id oppId,
    List<ApplicationFormProduct> appFormProducts,
    List<Id> oppLineItemIds
  ) {
    List<Id> appFormProductIds = new List<Id>();
    List<ApplicationForm> appForms = new List<ApplicationForm>();
    List<ApplicationFormProduct> lstAppFormsProds = new List<ApplicationFormProduct>();

    for (ApplicationFormProduct appFormProduct : appFormProducts) {
      appForms.add(
        new ApplicationForm(
          Id = appFormProduct.ApplicationFormId,
          OpportunityId = oppId // Mapping Opportunity.
        )
      );

      lstAppFormsProds.add(
        new ApplicationFormProduct(
          Id = appFormProduct.Id,
          Stage = CCRMConstants.OPP_IDENTIFIED, // Updating Stage
          Opportunity_Product__c = oppLineItemIds[0] // Mapping Opportunity Product.
        )
      );
    }
    DML_REPOSITORY.doUpdate(appForms);
    List<Database.SaveResult> appFormProductresult = DML_REPOSITORY.doUpdate(
      lstAppFormsProds
    );

    for (Database.SaveResult sr : appFormProductresult) {
      if (sr.isSuccess()) {
        appFormProductIds.add(sr.getId());
      }
    }
    return appFormProductIds;
  }
}

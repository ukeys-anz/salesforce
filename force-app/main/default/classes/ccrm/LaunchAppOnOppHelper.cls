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
    LaunchAppOnOppController.RecordTypeWrapper ambitRTWrapper = new LaunchAppOnOppController.RecordTypeWrapper();
    LaunchAppOnOppController.RecordTypeWrapper bbdRTWrapper = new LaunchAppOnOppController.RecordTypeWrapper();
    LaunchAppOnOppController.RecordTypeWrapper acmRTWrapper = new LaunchAppOnOppController.RecordTypeWrapper();
    LaunchAppOnOppController.RecordTypeWrapper internalAppRTWrapper = new LaunchAppOnOppController.RecordTypeWrapper();

    ambitRTWrapper.recordTypeName = RTApplicationForm.ambitApplicationName;
    ambitRTWrapper.recordTypeId = RTApplicationForm.ambitApplication;
    ambitRTWrapper.allowMultiple = false;
    ambitRTWrapper.url =
      'https://' +
      Label.Commercial_Abmit_Instance_URL +
      '/Opportunity/GetQuotes/?iko=' +
      opps.Opp_Id__c +
      '&ikpr={OppProductId}';
    typesList.add(ambitRTWrapper);

    bbdRTWrapper.recordTypeName = RTApplicationForm.bbdApplicationName;
    bbdRTWrapper.recordTypeId = RTApplicationForm.bbdApplication;
    bbdRTWrapper.allowMultiple = true;
    bbdRTWrapper.url = String.isNotBlank(opps.Account.Source_System_ID__c)
      ? Label.BBD_Link
          .replace(
            '{!Account.Source_System_ID__c}',
            opps.Account.Source_System_ID__c
          )
          .replace('{!Opportunity.Opp_Id__c}', opps.Opp_Id__c)
      : Label.BBD_Link;
    typesList.add(bbdRTWrapper);

    acmRTWrapper.recordTypeName = RTApplicationForm.acmApplicationName;
    acmRTWrapper.recordTypeId = RTApplicationForm.acmApplication;
    acmRTWrapper.allowMultiple = true;
    acmRTWrapper.url = Label.ACM_Link;
    typesList.add(acmRTWrapper);

    internalAppRTWrapper.recordTypeName = RTApplicationForm.internalApplicationName;
    internalAppRTWrapper.recordTypeId = RTApplicationForm.internalApplication;
    internalAppRTWrapper.allowMultiple = true;
    typesList.add(internalAppRTWrapper);
    return typesList;
  }

  /**
   * @description This is used to create the Request body need to send AMBIT
   * @name createAMBITRequestBody
   * @param opportunityId opportunity Id
   * @param oppLineItemIds string of opp line items Ids
   * @return CommercialAMBITRequestModel
   */
  public static CommercialAMBITRequestModel createAMBITRequestBody(
    Id opportunityId,
    List<Id> oppLineItemIds
  ) {
    Opportunity oppRec = APP_REPOSITORY.getOpportunityData(opportunityId);
    CommercialAMBITRequestModel ambitModel = new CommercialAMBITRequestModel(
      oppRec,
      oppLineItemIds[0]
    );
    return ambitModel;
  }
}

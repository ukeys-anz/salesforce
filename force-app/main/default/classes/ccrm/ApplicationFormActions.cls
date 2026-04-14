/**
 * @author Ali Mujtaba | 27-10-2025
 * @description  ApplicationFormActions is the orchestrator class for Application Form Trigger handler.
 * @last modified on  :  10-2025
 * @last modified by  :  Ali Mujtaba | Salesforce | 31-10-2025
 */
public with sharing class ApplicationFormActions {
  @TestVisible
  private static final Set<String> EMPTY_NULL_SET = new Set<String>{ '', null };

  /**
   * @description populate Assisted Broker on Application Form based on tpmisao id
   * @param records updated records
   * @param oldMap old records
   * @author Ali Mujtaba | Salesforce | 30-10-2025
   */
  public static void updateBrokerOnApplicationForm(
    List<ApplicationForm> records,
    Map<Id, ApplicationForm> oldMap
  ) {
    try {
      if (!ApplicationFormHelper.validateAmbitIntegrationUserAccess()) {
        return;
      }
      List<ApplicationForm> filteredApplicationForms = ListUtil.filter(
          records,
          oldMap
        )
        .equals(
          ApplicationForm.RecordTypeId,
          RTApplicationForm.ambitApplication
        )
        .changed(ApplicationForm.Assisted_Broker_TPMI_SAO__c)
        .contains(
          ApplicationForm.Sync_Status__c,
          BrokerConstants.SYNC_STATUS_BROKER_ORG
        )
        .toList();
      List<ApplicationFormProduct> filteredApplicationFormProduct = ApplicationFormHelper.getBkolaApplicationFormProd(
        filteredApplicationForms
      );
      Set<Id> appFormIds = ListUtil.getIds(
        filteredApplicationFormProduct,
        ApplicationFormProduct.ApplicationFormId
      );
      List<ApplicationForm> bkolaApplicationForms = ListUtil.filter(
          filteredApplicationForms
        )
        .equals(ApplicationForm.Id, appFormIds)
        .toList();
      Set<String> tpmisaoIds = ApplicationFormHelper.collectTpmisaoIds(
        bkolaApplicationForms
      );
      List<Contact> brokerList = ApplicationFormHelper.getBrokers(tpmisaoIds);
      Map<String, Id> mapTpmisaoWithBroker = ApplicationFormHelper.prepareMapOfTpmisaoWithBroker(
        tpmisaoIds,
        brokerList
      );
      ApplicationFormHelper.updateAssistedBrokerOnAppForm(
        mapTpmisaoWithBroker,
        filteredApplicationForms
      );
    } catch (Exception e) {
      Logger.error('Error while setting fields on Application Form', e).save();
    }
  }

  /**
   * @description prevent Customer change on Opportunity
   * @param records updated records
   * @param oldMap old records
   * @author Ali Mujtaba | Salesforce | 30-10-2025
   */
  public static void preventCustomerChangeOnAppForm(
    List<ApplicationForm> records,
    Map<Id, ApplicationForm> oldMap
  ) {
    List<ApplicationForm> filteredApplicationForms = ListUtil.filter(
        records,
        oldMap
      )
      .equals(ApplicationForm.RecordTypeId, RTApplicationForm.ambitApplication)
      .changed(ApplicationForm.AccountId)
      .notEquals(ApplicationForm.Application_Number__c, EMPTY_NULL_SET)
      .toList();
    List<ApplicationFormProduct> filteredApplicationFormProduct = ApplicationFormHelper.getBkolaApplicationFormProd(
      filteredApplicationForms
    );
    ApplicationFormHelper.blockCustomerModificationOnAppForm(
      filteredApplicationForms,
      filteredApplicationFormProduct
    );
  }
  /**
   * @description populate Source_System_Id__c on Application Form based on Sync Status as BROKER_ORG
   * @author Harshit Goyal | Salesforce | 02-13-2026
   * @param records
   * @param oldMap
   **/
  public static void updateSourceSystemIdOnSyncChange(
    List<ApplicationForm> records,
    Map<Id, ApplicationForm> oldMap
  ) {
    Set<SObjectField> applicationFormFieldsSet = new Set<SObjectField>{
      ApplicationForm.OpportunityId,
      ApplicationForm.Sync_Status__c
    };

    List<ApplicationForm> filteredApplicationForms = ListUtil.filter(
        records,
        oldMap
      )
      .anyChanged(applicationFormFieldsSet)
      .contains(
        ApplicationForm.Sync_Status__c,
        BrokerConstants.SYNC_STATUS_BROKER_ORG
      )
      .isNotNull(ApplicationForm.OpportunityId)
      .isNotNull(ApplicationForm.Assisted_Broker__c)
      .toList();
    for (ApplicationForm appForm : filteredApplicationForms) {
      String sourceId =
        appForm.OpportunityId +
        '-' +
        appForm.Assisted_Broker__c;
      if (String.valueOf(appForm.Source_System_Id__c) != sourceId) {
        appForm.Source_System_Id__c = sourceId;
      }
    }
  }
}

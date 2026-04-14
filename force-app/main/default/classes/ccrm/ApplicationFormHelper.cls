/**
 * @author Ali Mujtaba | 30-10-2025
 * @description  helper class for Application Form
 * @last modified on  :  10-2025
 * @last modified by  :  Ali Mujtaba | Salesforce | 31-10-2025
 */
public with sharing class ApplicationFormHelper {
  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final CommercialAppFormProductActionsRepo AFP_REPOSITORY = (CommercialAppFormProductActionsRepo) Lib_InstanceProvider.forType(
    CommercialAppFormProductActionsRepo.class
  );
  private static final CommercialContactRepository CONTACT_REPOSITORY = (CommercialContactRepository) Lib_InstanceProvider.forType(
    CommercialContactRepository.class
  );
  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );
  @TestVisible
  private static final String PS_NAME = System.Label.AMBIT_Integration_User_PS_Name;
  @TestVisible
  private static final String PREVENT_CUSTOMER_CHANGE_ERROR_MSG = System.Label.Customer_Change_Error_Msg_On_App_Form;

  /**
   * @description fetch BKOLA Application Form Product records
   * @param applicationFormList Application Form records
   * @author Ali Mujtaba | Salesforce | 31-10-2025
   * @return List<ApplicationFormProduct> list of application form products
   */
  public static List<ApplicationFormProduct> getBkolaApplicationFormProd(
    List<ApplicationForm> applicationFormList
  ) {
    return AFP_REPOSITORY.getBkolaAppFormProductByAppForm(applicationFormList);
  }

  /**
   * @description update Assisted Broker on Opportunity
   * @param applicationFormProductList Application Form Product records
   * @author Ali Mujtaba | Salesforce | 31-10-2025
   */
  public static void updateAssistedBrokerOnOpp(
    List<ApplicationFormProduct> applicationFormProductList
  ) {
    List<Opportunity> oppToUpdate = new List<Opportunity>();
    for (ApplicationFormProduct afp : applicationFormProductList) {
      oppToUpdate.add(
        new Opportunity(
          Id = afp.ApplicationForm.OpportunityId,
          Broker_Name__c = afp.ApplicationForm.Assisted_Broker__c
        )
      );
    }
    DML.doUpdate(oppToUpdate);
  }

  /**
   * @description update Customer on Opportunity
   * @param applicationFormProductList Application Form Product records
   * @author Ali Mujtaba | Salesforce | 31-10-2025
   */
  public static void updateCustomerOnOpp(
    List<ApplicationFormProduct> applicationFormProductList
  ) {
    List<Opportunity> oppToUpdate = new List<Opportunity>();
    for (ApplicationFormProduct afp : applicationFormProductList) {
      oppToUpdate.add(
        new Opportunity(
          Id = afp.ApplicationForm.OpportunityId,
          AccountId = afp.ApplicationForm.AccountId
        )
      );
    }
    DML.doUpdate(oppToUpdate);
  }

  /**
   * @description prepares a Set<String> of Assisted Broker TPMISAO from the Application Form records
   * @param applicationFormList Application Form records
   * @author Ali Mujtaba | Salesforce | 31-10-2025
   * @return Set<String> set of tpmisao ids
   */
  public static Set<String> collectTpmisaoIds(
    List<ApplicationForm> applicationFormList
  ) {
    Set<String> tpmisaoIds = new Set<String>();
    for (ApplicationForm af : applicationFormList) {
      tpmisaoIds.add(af.Assisted_Broker_TPMI_SAO__c);
    }
    return tpmisaoIds;
  }

  /**
   * @description fetch Broker details based on TPMISAO
   * @param tpmisaoIds Broker TPMISAO Ids
   * @author Ali Mujtaba | Salesforce | 31-10-2025
   * @return List<Contact> list of brokers
   */
  public static List<Contact> getBrokers(Set<String> tpmisaoIds) {
    return CONTACT_REPOSITORY.getBrokersByTpmisao(tpmisaoIds);
  }

  /**
   * @description prepares a map of TPMISAO and Broker Id
   * @param tpmisaoIds Broker TPMISAO Ids
   * @param brokerList Broker records
   * @author Ali Mujtaba | Salesforce | 31-10-2025
   * @return Map<String, Id> map of tpmisao with broker id
   */
  public static Map<String, Id> prepareMapOfTpmisaoWithBroker(
    Set<String> tpmisaoIds,
    List<Contact> brokerList
  ) {
    Map<String, Id> mapTpmisaoWithBroker = new Map<String, Id>();
    for (Contact con : brokerList) {
      if (tpmisaoIds.contains(con.AssetFinanceTPMISAO__c)) {
        mapTpmisaoWithBroker.put(con.AssetFinanceTPMISAO__c, con.Id);
      }
      if (tpmisaoIds.contains(con.CommercialTPMISAO__c)) {
        mapTpmisaoWithBroker.put(con.CommercialTPMISAO__c, con.Id);
      }
      if (tpmisaoIds.contains(con.RetailTPMISAO__c)) {
        mapTpmisaoWithBroker.put(con.RetailTPMISAO__c, con.Id);
      }
    }
    return mapTpmisaoWithBroker;
  }

  /**
   * @description update Assisted Broker on Application Form records
   * @param mapTpmisaoWithBroker map of TPMISAO and Broker Id
   * @param applicationFormList Application Form records
   * @author Ali Mujtaba | Salesforce | 31-10-2025
   */
  public static void updateAssistedBrokerOnAppForm(
    Map<String, Id> mapTpmisaoWithBroker,
    List<ApplicationForm> applicationFormList
  ) {
    for (ApplicationForm af : applicationFormList) {
      af.Assisted_Broker__c = mapTpmisaoWithBroker.get(
          af.Assisted_Broker_TPMI_SAO__c
        ) != null
        ? mapTpmisaoWithBroker.get(af.Assisted_Broker_TPMI_SAO__c)
        : null;
    }
  }

  /**
   * @description block Customer modification on Application Form
   * @param applicationFormList Application Form records
   * @param applicationFormProductList Application Form Product records
   * @author Ali Mujtaba | Salesforce | 31-10-2025
   */
  public static void blockCustomerModificationOnAppForm(
    List<ApplicationForm> applicationFormList,
    List<ApplicationFormProduct> applicationFormProductList
  ) {
    if (validateAmbitIntegrationUserAccess()) {
      return;
    }
    if (applicationFormProductList.isEmpty()) {
      return;
    }
    for (ApplicationForm af : applicationFormList) {
      af.AccountId.addError(PREVENT_CUSTOMER_CHANGE_ERROR_MSG);
    }
  }

  /**
   * @description validates if the current context of the user has AMBIT related integration PS
   * @author Ali Mujtaba | Salesforce | 31-10-2025
   * @return Boolean user has the AMBIT permisison set
   */
  public static Boolean validateAmbitIntegrationUserAccess() {
    if (USER_INFO.checkPermission(PS_NAME)) {
      return true;
    }
    return false;
  }
  /**
   * @description update Application Form Assisted_Broker__c & Sync_Status__c
   * @author Harshit Goyal | Salesforce | 02-17-2026
   * @param appForms
   **/
  @TestVisible
  public static void updateApplicationFormValues(
    List<ApplicationForm> appForms
  ) {
    if (appForms == null || appForms.isEmpty()) {
      return;
    }
    List<ApplicationForm> applicationFormsToUpdate = new List<ApplicationForm>();
    try {
      for (ApplicationForm appForm : appForms) {
        if (
          String.isBlank(appForm.Sync_Status__c) ||
          !appForm.Sync_Status__c.contains(
            BrokerConstants.SYNC_STATUS_BROKER_ORG
          )
        ) {
          appForm.Sync_Status__c = PicklistUtil.addMultiPicklistValue(
            appForm.Sync_Status__c,
            BrokerConstants.SYNC_STATUS_BROKER_ORG
          );
        }
        if (appForm.Opportunity != null) {
          // Preserve existing Assisted_Broker__c if already populated
          if (appForm.Assisted_Broker__c == null) {
            appForm.Assisted_Broker__c = appForm.Opportunity?.Broker_Name__c;
            appForm.Assisted_Broker_TPMI_SAO__c = appForm.Opportunity
              ?.Broker_Name__r.AssetFinanceTPMISAO__c;
          }
          // Always sync AccountId from related Opportunity when present
          appForm.AccountId = appForm.Opportunity?.AccountId;
        }
        String sourceId =
          appForm.OpportunityId +
          '-' +
          appForm.Assisted_Broker__c;
        if (
          String.valueOf(appForm.Source_System_Id__c) != sourceId &&
          String.isNotBlank(appForm.OpportunityId) &&
          String.isNotBlank(appForm.Assisted_Broker__c)
        ) {
          appForm.Source_System_Id__c = sourceId;
        }

        applicationFormsToUpdate.add(appForm);
      }
      DML.doUpdate(applicationFormsToUpdate);
    } catch (Exception e) {
      Logger.error(
        'Error in ApplicationFormHelper.updateApplicationFormValues: ' +
        e.getMessage(),
        e
      );
      Logger.saveLog();
    }
  }
}

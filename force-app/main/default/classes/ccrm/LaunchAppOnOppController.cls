/**
 * @author Ayushi Gupta
 * @since  08/2024
 * @description Controller class for launch application lwc.
 */
public with sharing class LaunchAppOnOppController {
  private static final LaunchAppOnOppControllerRepository APP_REPOSITORY = (LaunchAppOnOppControllerRepository) Lib_InstanceProvider.forType(
    LaunchAppOnOppControllerRepository.class
  );

  private static final CommercialAMBITRepo AMBIT_REPO = (CommercialAMBITRepo) Lib_InstanceProvider.forType(
    CommercialAMBITRepo.class
  );

  private static final String AF_STATUS = 'Active';
  private static final String CUSTOMER_RT_CLG = 'CLG';
  private static final String CUSTOMER_RT_INDIVIDUAL = 'Individual';
  @testVisible
  private static final String AF_ACCREDITED_BROKER_ERROR = 'Please add a valid Asset Finance accredited broker.';
  @testVisible
  private static final String NON_CLG_INDIVIDUAL_CUSTOMER_ERROR = 'Select an Organisation-type customer in the opportunity to start an AMBIT quote (Note: Quotes cannot be created for CLG or Individual customers).';
  @testVisible
  private static final String OPP_TEAM_MEMBR_ERROR = 'Please include Asset Finance Manager under Opportunity team to progress';

  private static final String SERVER_EXCEPTION = 'The server encountered an unexpected error. Please retry after some time.';
  private static final String INSUFFICIENT_EXCEPTION = 'You do not have required permission to perform this action.';
  private static final String UNHANDLED_EXCEPTION = 'Errored out while creating a quote in AMBIT';
  /**
   * @description get opp line items related to opp
   * @name getOpportunityLineItems
   * @param oppId opportunity Id
   * @param recordTypeName record type name
   * @return List<OppLineItemWrapper> wrapper list
   */
  @AuraEnabled
  public static List<OppLineItemWrapper> getOpportunityLineItems(
    Id oppId,
    String recordTypeName
  ) {
    try {
      List<OpportunityLineItem> items = APP_REPOSITORY.getOpportunityLineItems(
        oppId
      );
      List<ApplicationFormProduct> apps = APP_REPOSITORY.getAppFormProductsRelatedToOpp(
        oppId,
        recordTypeName
      );

      Set<Id> selectedOppLineItemsIds = LaunchAppOnOppHelper.getSelectedOppLineItemIds(
        apps
      );

      List<OppLineItemWrapper> itemWrapper = LaunchAppOnOppHelper.createOppLineItemWrapper(
        items,
        selectedOppLineItemsIds
      );
      return itemWrapper;
    } catch (Exception e) {
      Logger.error('Error occured while getting opportunity line items', e)
        .save();
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description create app Form and app form product
   * @name createApplication
   * @param oppId opportunity Id
   * @param oppLineItemIds string of opp line items Ids
   * @param recordTypeId record type Id
   * @return List<Id> app form products Ids set
   */
  @AuraEnabled
  public static List<Id> createApplication(
    Id oppId,
    List<Id> oppLineItemIds,
    Id recordTypeId
  ) {
    try {
      Set<Id> oppLineItemIdsSet = new Set<Id>(oppLineItemIds);
      Id applicationFormId = LaunchAppOnOppHelper.createApplicationForm(
        oppId,
        recordTypeId
      );
      List<OpportunityLineItem> items = APP_REPOSITORY.getSelectedOppLineItems(
        oppLineItemIdsSet
      );
      List<Id> appFormProductIds = LaunchAppOnOppHelper.createApplicationFormProduct(
        applicationFormId,
        recordTypeId,
        items
      );
      return appFormProductIds;
    } catch (Exception e) {
      Logger.error('Error occured while creating application', e).save();
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description validate AMBIT response
   * @name validateAMBITResponse
   * @param oppId opportunity Id
   * @param oppLineItemId string of opp line items Id
   * @return List<Id> app form products Ids set
   */
  @AuraEnabled
  public static Boolean getAMBITResponse(Id oppId, Id oppLineItemId) {
    try {
      CommercialAMBITRequestModel ambitModel = LaunchAppOnOppHelper.createAMBITRequestBody(
        oppId,
        oppLineItemId
      );
      return AMBIT_REPO.getAMBITQuoteResponse(ambitModel);
    } catch (CommercialAMBITRepo.ServerErrorException se) {
      throw new AuraHandledException(SERVER_EXCEPTION);
    } catch (CommercialAMBITRepo.InsufficientAccessException ie) {
      throw new AuraHandledException(INSUFFICIENT_EXCEPTION);
    } catch (CommercialAMBITRepo.UnhandledException ue) {
      throw new AuraHandledException(UNHANDLED_EXCEPTION);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description populate record type wrapper
   * @name populateRecordTypeWrapper
   * @param oppId opportunity Id
   * @return List<RecordTypeWrapper> record type wrapper
   */
  @AuraEnabled
  public static List<RecordTypeWrapper> populateRecordTypeWrapper(Id oppId) {
    try {
      Opportunity opps = APP_REPOSITORY.getOppIdAndSourceSystemId(oppId);
      List<RecordTypeWrapper> recordTypeWrapperList = LaunchAppOnOppHelper.populateRecordTypeWrapper(
        opps
      );
      return recordTypeWrapperList;
    } catch (Exception e) {
      Logger.error('Error occured while populating record type wrapper', e)
        .save();
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description This is used to check if broker on Opportunity is accreadited to Asset finance and if Customer is CLG/Individual
   * @param oppId opportunity Id
   * @return @return String contains error message
   */
  @AuraEnabled
  public static String validateOpportunity(Id oppId) {
    Opportunity oppRec = APP_REPOSITORY.getOpportunityData(oppId);
    return validateCustomerForAMBIT(oppRec) ?? validateBrokerAFStatus(oppRec) ??
      validateOppTeamMember(oppRec);
  }

  /**
   * @description This is used to check if Customer is CLG/Individual
   * @param oppRec opportunity record
   * @return String contains error message
   */
  private static String validateCustomerForAMBIT(Opportunity oppRec) {
    if (
      oppRec.Account.RecordType.Name == CUSTOMER_RT_CLG ||
      oppRec.Account.RecordType.Name == CUSTOMER_RT_INDIVIDUAL
    ) {
      return NON_CLG_INDIVIDUAL_CUSTOMER_ERROR;
    }
    return null;
  }

  /**
   * @description This is used to check if broker on Opportunity is accreadited to Asset finance
   * @param oppRec opportunity record
   * @return String contains error message
   */
  @TestVisible
  private static String validateBrokerAFStatus(Opportunity oppRec) {
    if (oppRec.Broker_Name__c == null) {
      return null;
    }
    if (
      oppRec.Broker_Name__r.Asset_Finance_Accreditation_Status__c == AF_STATUS
    ) {
      return null;
    }
    return AF_ACCREDITED_BROKER_ERROR;
  }

  /**
   * @description This is used to check if Asset Finance Manager is added to Opportunity team
   * @param oppRec opportunity record
   * @return String contains error message
   */
  @TestVisible
  private static String validateOppTeamMember(Opportunity oppRec) {
    if (oppRec.OpportunityTeamMembers.size() == 0) {
      return OPP_TEAM_MEMBR_ERROR;
    }
    return null;
  }

  /**
   * @description This is used to validate the selected OLI
   * @param oppId Opportunity Id
   * @param selectedLineItemIds Selected OLI from Launch app
   * @return List<String> List of Product which is already launched
   */
  @AuraEnabled
  public static List<String> validateSelectedOppLineItems(
    String oppId,
    List<Id> selectedLineItemIds
  ) {
    try {
      List<ApplicationFormProduct> appFormProducts = APP_REPOSITORY.getAppFormProductsNotRelatedToAMBIT(
        oppId
      );
      List<String> alreadyLaunchProductList = new List<String>();
      for (ApplicationFormProduct afp : appFormProducts) {
        if (selectedLineItemIds.contains(afp.Opportunity_Product__c)) {
          alreadyLaunchProductList.add(
            afp.Opportunity_Product__r?.Opp_Product_name__c ?? afp.Product?.Name
          );
        }
      }
      return alreadyLaunchProductList;
    } catch (Exception e) {
      Logger.error('Error occured while validating selected opp line items', e)
        .save();
      throw new AuraHandledException(
        'An unexpected error occurred while validating selected opp line items. Please contact your System Administrator.'
      );
    }
  }

  /**
   * @description wrapper class for OppLineItemWrapper
   */
  public class OppLineItemWrapper {
    @AuraEnabled
    public String oppLineItemId;
    @AuraEnabled
    public String productId;
    @AuraEnabled
    public String productURL;
    @AuraEnabled
    public String productName;
    @AuraEnabled
    public String oppProductName; // New field from OLI : Opp Product Name
    @AuraEnabled
    public String oppProductURL; // Opp Product Name URL
    @AuraEnabled
    public Decimal unitPrice;
    @AuraEnabled
    public String fundingPurpose;
    @AuraEnabled
    public Boolean isRowDisabled;
    @AuraEnabled
    public Boolean isSelected;
  }

  /**
   * @description wrapper class for app form record types
   */
  public class RecordTypeWrapper {
    @AuraEnabled
    public String url;
    @AuraEnabled
    public String recordTypeName;
    @AuraEnabled
    public Id recordTypeId;
    @AuraEnabled
    public Boolean allowMultiple;

    /**
     * @description Constructor for RecordTypeWrapper
     * @param recordTypeName Record type name
     * @param recordTypeId Record type Id
     * @param allowMultiple we can select multiple product
     * @param opps Opp record
     */
    public RecordTypeWrapper(
      String recordTypeName,
      Id recordTypeId,
      Boolean allowMultiple,
      Opportunity opps
    ) {
      this.recordTypeName = recordTypeName;
      this.recordTypeId = recordTypeId;
      this.allowMultiple = allowMultiple;

      switch on recordTypeName {
        when 'AMBIT' {
          this.url =
            'https://' +
            Label.Commercial_Abmit_Instance_URL +
            '/Opportunity/GetQuotes/?iko=' +
            opps.Opp_Id__c +
            '&ikpr={OppProductId}';
        }
        when 'BBD' {
          this.url = String.isNotBlank(opps.Account.Source_System_ID__c)
            ? Label.BBD_Link
                .replace(
                  '{!Account.Source_System_ID__c}',
                  opps.Account.Source_System_ID__c
                )
                .replace('{!Opportunity.Opp_Id__c}', opps.Opp_Id__c)
            : Label.BBD_Link;
        }
        when 'ACM' {
          this.url = Label.ACM_Link;
        }
        when 'OCP' {
          this.url = Label.OCP_Link;
        }
      }
    }
  }
}

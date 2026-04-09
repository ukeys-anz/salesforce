/**
 * @author       : Ayushi Gupta
 * @since        : 21-08-2024
 * @description  : This class contains public repository for all queries used in CommercialAppFormProductActions
 **/
public class CommercialAppFormProductActionsRepo {
  private static final String AFM_APPLICATION_SOURCE_BKOLA = System.Label.AFP_App_Source_BKOLA;
  private static final String CUSTOM_NOTIFICATION_TYPE_BROKERBIZ = System.Label.Custom_Notification_On_Opportunity;
  /**
   * @description getApplicationForms to get app forms records related to commercial opp
   * @param appFormIds set of new app form ids
   * @return List<ApplicationForm> app forms list
   */
  public List<ApplicationForm> getApplicationForms(Set<Id> appFormIds) {
    if (appFormIds.isEmpty()) {
      return new List<ApplicationForm>();
    }
    return [
      SELECT
        Id,
        RecordTypeId,
        OpportunityId,
        Opportunity.RecordTypeId,
        Opportunity.closeDate,
        Opportunity.OwnerId,
        OwnerId,
        (SELECT Id, ApplicationFormId FROM ApplicationFormProducts)
      FROM ApplicationForm
      WHERE
        Id IN :appFormIds
        AND Opportunity.RecordTypeId = :RTOpportunity.commercialOpportunity
      WITH USER_MODE
    ];
  }

  /**
   * @description getOppProductRelatedToAFP - To fetch the product related to Application Form Product
   * @param productIds - Ids of Products on AFP
   * @param oppIds - List of Opportunity
   * @return  List<OpportunityLineItem> Opportunity line item list
   */
  public List<OpportunityLineItem> getOppProductRelatedToAFP(
    Set<Id> productIds,
    Set<Id> oppIds
  ) {
    if (productIds.isEmpty() || oppIds.isEmpty()) {
      return new List<OpportunityLineItem>();
    }
    return new List<OpportunityLineItem>(
      [
        SELECT Id, Product2Id, OpportunityId, Expected_Settlement_Date__c
        FROM OpportunityLineItem
        WHERE Product2Id IN :productIds AND OpportunityId IN :oppIds
        WITH USER_MODE
      ]
    );
  }

  /**
   * @description getOppLineItems - To fetch the OLI
   * @param oliIdsSet set of opportunity line items Ids
   * @return  List<OpportunityLineItem> opportunity line item list
   */
  public List<OpportunityLineItem> getOppLineItems(Set<Id> oliIdsSet) {
    if (oliIdsSet.isEmpty()) {
      return new List<OpportunityLineItem>();
    }
    return new List<OpportunityLineItem>(
      [
        SELECT Id, OpportunityId
        FROM OpportunityLineItem
        WHERE Id IN :oliIdsSet
        WITH USER_MODE
      ]
    );
  }

  /**
   * @description getAfpRelatedToOpp - To fetch the AFP related to OLI
   * @param oppIdsSet set of opportunity ids
   * @return  List<ApplicationFormProduct> afp list
   */
  public List<ApplicationFormProduct> getAfpRelatedToOpp(Set<Id> oppIdsSet) {
    if (oppIdsSet.isEmpty()) {
      return new List<ApplicationFormProduct>();
    }
    return new List<ApplicationFormProduct>(
      [
        SELECT
          Id,
          Opportunity_Product__c,
          ApplicationFormId,
          Amount__c,
          Stage,
          Revenue__c,
          ApplicationForm.RecordTypeId,
          ApplicationForm.OpportunityId
        FROM ApplicationFormProduct
        WHERE ApplicationForm.OpportunityId IN :oppIdsSet
        WITH USER_MODE
      ]
    );
  }

  /**
   * @description to get BKOLA application form product records based on application form.
   * @author  Ali Mujtaba | Salesforce | 27-10-2025
   * @param applicationForm application form list
   * @return List<ApplicationFormProduct>
   **/
  public List<ApplicationFormProduct> getBkolaAppFormProductByAppForm(
    List<ApplicationForm> applicationForm
  ) {
    if (applicationForm.isEmpty()) {
      return new List<ApplicationFormProduct>();
    }
    return [
      SELECT
        Id,
        ApplicationFormId,
        ApplicationForm.AccountId,
        ApplicationForm.OpportunityId,
        ApplicationForm.Assisted_Broker__c,
        ApplicationForm.Assisted_Broker_TPMI_SAO__c
      FROM ApplicationFormProduct
      WHERE
        ApplicationFormId IN :applicationForm
        AND ApplicationForm.OpportunityId != NULL
      WITH USER_MODE
      LIMIT 1
    ];
  }

  /**
   * @description Fetches Application Forms for given Opportunity IDs and their products.
   * @author  A M Vikash | Salesforce | 28-10-2025
   * @param appFormIds Set<Id> of ApplicationForm IDs
   * @return List<ApplicationForm> list of Application Forms with related products
   **/
  public List<ApplicationForm> getApplicationFormsAndProducts(
    Set<Id> appFormIds
  ) {
    if (appFormIds.isEmpty()) {
      return new List<ApplicationForm>();
    }

    return [
      SELECT
        Id,
        RecordTypeId,
        AccountId,
        Assisted_Broker__c,
        OwnerId,
        Reference_Number__c,
        OpportunityId,
        (
          SELECT
            Id,
            Loan_Purpose__c,
            ApplicationFormId,
            Brokerage_Amount__c,
            Application_Source__c,
            ProductId,
            Amount__c,
            Reference_Number__c
          FROM ApplicationFormProducts
          WHERE Application_Source__c = :AFM_APPLICATION_SOURCE_BKOLA
        )
      FROM ApplicationForm
      WHERE
        Id IN :appFormIds
        AND RecordTypeId = :RTApplicationForm.ambitApplication
        AND Reference_Number__c != NULL
        AND OpportunityId = NULL
      WITH USER_MODE
    ];
  }

  /**
   * @description Retrieves the custom notification type used for alerting Opportunity Owners.
   * @author  A M Vikash | Salesforce | 28-10-2025
   * @return CustomNotificationType record if found, otherwise null
   **/
  public CustomNotificationType getOpportunityNotificationType() {
    List<CustomNotificationType> types = [
      SELECT Id
      FROM CustomNotificationType
      WHERE DeveloperName = :CUSTOM_NOTIFICATION_TYPE_BROKERBIZ
      LIMIT 1
    ];

    return types.isEmpty() ? null : types[0];
  }
  /**
   * @description Retrieves Opportunity records for the given set of Opportunity IDs, including specific fields like Broker Name and Application Numbers.
   * @author  A M Vikash | Salesforce | 28-10-2025
   * @param insertedOppIds Set<Id> The set of Opportunity IDs to fetch Opportunity details
   * @return List<Opportunity> List of Opportunity records matching the given IDs
   **/
  public List<opportunity> getOpportunityDetails(Set<Id> insertedOppIds) {
    if (insertedOppIds.isEmpty()) {
      return new List<opportunity>();
    }

    return [
      SELECT Id, Name, Broker_Name__c, Application_Numbers__c
      FROM opportunity
      WHERE Id IN :insertedOppIds
      WITH USER_MODE
    ];
  }

  /**
   * @description Retrieves "AMBIT" ApplicationForm records and their related ApplicationFormProducts for specific opportunities & Reference Number is BLANK
   * @author Vikash Agarwal | Salesforce | 02-12-2026
   * @param setOppIds
   * @return List<ApplicationForm>
   **/
  public List<ApplicationForm> getApplicationFormAndProductsWithAmbitQuote(
    Set<Id> setOppIds
  ) {
    if (setOppIds.isEmpty()) {
      return new List<ApplicationForm>();
    }

    return [
      SELECT
        Id,
        RecordTypeId,
        AccountId,
        Assisted_Broker__c,
        OwnerId,
        Reference_Number__c,
        OpportunityId,
        Sync_Status__c,
        Source_System_Id__c,
        (
          SELECT
            Id,
            Loan_Purpose__c,
            ApplicationFormId,
            Brokerage_Amount__c,
            Application_Source__c,
            ProductId,
            Amount__c,
            Reference_Number__c
          FROM ApplicationFormProducts
          WHERE Reference_Number__c != NULL
        )
      FROM ApplicationForm
      WHERE
        OpportunityId IN :setOppIds
        AND RecordTypeId = :RTApplicationForm.ambitApplication
        AND Reference_Number__c = NULL
      WITH USER_MODE
    ];
  }

  /**
   * @description getRelatedAFP - To fetch the related AFPs
   * @param appFormProductIds set of app form product ids
   * @return  List<ApplicationFormProduct> afp list
   */
  public List<ApplicationFormProduct> getRelatedAFP(Set<Id> appFormProductIds) {
    if (appFormProductIds.isEmpty()) {
      return new List<ApplicationFormProduct>();
    }
    return new List<ApplicationFormProduct>(
      [
        SELECT Id, ApplicationFormId, Stage, ApplicationForm.OpportunityId
        FROM ApplicationFormProduct
        WHERE
          Id IN :appFormProductIds
          AND ApplicationForm.Opportunity.RecordTypeId = :RTOpportunity.commercialOpportunity
        WITH USER_MODE
      ]
    );
  }

  /**
   * @description getApplicationForms to get BBD app forms records related to commercial Closed won opp
   * @param appFormIds set of new app form ids
   * @return Map<Id, ApplicationForm> app forms Map
   */
  public Map<Id, ApplicationForm> getApplicationFormsList(Set<Id> appFormIds) {
    if (appFormIds.isEmpty()) {
      return new Map<Id, ApplicationForm>();
    }
    return new Map<Id, ApplicationForm>(
      [
        SELECT
          Id,
          RecordTypeId,
          OpportunityId,
          Opportunity.RecordTypeId,
          Opportunity.closeDate,
          Opportunity.OwnerId,
          Opportunity.StageName,
          OwnerId
        FROM ApplicationForm
        WHERE
          Id IN :appFormIds
          AND RecordTypeId = :RTApplicationForm.bbdApplication
          AND Opportunity.RecordTypeId = :RTOpportunity.commercialOpportunity
        WITH SYSTEM_MODE
      ]
    );
  }

  /**
   * @description getExistingAfpList - Fetch all AFP list
   * @param rnList List of Reference Number
   * @return List<ApplicationFormProduct> afp list
   */
  public List<ApplicationFormProduct> getExistingAfpList(List<String> rnList) {
    if (rnList.isEmpty()) {
      return new List<ApplicationFormProduct>();
    }
    return [
      SELECT
        Id,
        Reference_Number__c,
        ApplicationFormId,
        Stage,
        ApplicationForm.RecordTypeId,
        ApplicationForm.Opportunity.RecordTypeId,
        ApplicationForm.Opportunity.StageName
      FROM ApplicationFormProduct
      WHERE
        Reference_Number__c IN :rnList
        AND Stage = 'Opportunity Won'
        AND ApplicationForm.RecordTypeId = :RTApplicationForm.bbdApplication
        AND ApplicationForm.Opportunity.RecordTypeId = :RTOpportunity.CommercialOpportunity
      WITH SYSTEM_MODE
    ];
  }
  /**
   * @description getOppLineItemsRelatedToOpp - Fetch all opp line items related to opp
   * @param oppIds set of opp ids
   * @return List<OpportunityLineItem> opp line items list
   */
  public List<OpportunityLineItem> getOppLineItemsRelatedToOpp(Set<Id> oppIds) {
    if (oppIds.isEmpty()) {
      return new List<OpportunityLineItem>();
    }
    return [
      SELECT Id, OpportunityId
      FROM OpportunityLineItem
      WHERE OpportunityId IN :oppIds
      WITH USER_MODE
    ];
  }
}

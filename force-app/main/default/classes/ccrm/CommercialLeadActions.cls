/**
 * @author       : Naman Garg
 * @since        : Nov 2024
 * @description  : This is the action class for CommercialLeadTriggerHandler
 **/
public with sharing class CommercialLeadActions {
  private static final LeadActionsRepository LEAD_ACTION_REPOSITORY = (LeadActionsRepository) Lib_InstanceProvider.forType(
    LeadActionsRepository.class
  );
  private static final A2ZReviewRepository A2ZREVIEW_REPOSITORY = (A2ZReviewRepository) Lib_InstanceProvider.forType(
    A2ZReviewRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final UserInfoRepository USER_REPO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );
  private static final UserActionsRepository USER_REPOSITORY = (UserActionsRepository) Lib_InstanceProvider.forType(
    UserActionsRepository.class
  );

  private static final CommercialLeadPlatformEventActions PLATFORM_EVENT_ACTIONS = (CommercialLeadPlatformEventActions) Lib_InstanceProvider.forType(
    CommercialLeadPlatformEventActions.class
  );

  private static final String ENTITY_TYPE_INDIVIDUAL = 'Individual';
  private static final String CCRM_PROFILE = 'ANZ CCRM Standard User';
  private static final String SKIP_VALIDATION = 'SkipValidation';
  private static final String VALIDATE = 'Validate';
  private static final String COPY_LEAD_ID = 'copyLeadId';
  private static final String CUSTOMER_NEEDS_ERROR = 'Secondary Customer Needs should not be the same as Customer Needs.';
  private static final String ORIGINATOR_CCRM = 'CCRM';
  private static final String ORIGINATOR_UNICA = 'UNICA';
  private static final String ORIGINATOR_ADOBE = 'Adobe';

  private static final Set<String> SET_OF_ELIGIBLE_LEAD_ORIGINATOR = new Set<String>{
    ORIGINATOR_ADOBE,
    ORIGINATOR_UNICA,
    ORIGINATOR_CCRM
  };
  private static final Set<SObjectField> LEAD_FIELDS = new Set<SObjectField>{
    Lead.CLG_Name__c,
    Lead.CLG_ID__c,
    Lead.CPID__c,
    Lead.CPID_Owner__c
  };

  /**
   * @description Define custom exceptions
   */
  public class CustomException extends Exception {
  }

  /**
   * @description : It will restrict the user to upload images in rich text fields
   * @name : restrictImagesInRichTextFields
   * @param records List of Lead records
   * @param oldMap Map of old Lead records
   */
  public static void restrictImagesInRichTextFields(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    try {
      List<SObjectField> fieldList = Schema.SObjectType.Lead.fields.getMap()
        .values();
      Set<SObjectField> richTextFieldSet = CommercialCommonUtil.getRichTextFields(
        fieldList
      );
      CommercialCommonUtil.restrictImages(records, oldMap, richTextFieldSet);
    } catch (Exception e) {
      Logger.error('Error while restrict images on Lead', e).save();
    }
  }

  /**
   * @description This method is to check if there is existing customer, set new to bank flag
   * @name checkForExistingCustomerOnUpdate
   * @param records List of new lead records
   * @param oldMap oldMap of lead records
   */
  public static void checkForExistingCustomer(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    List<Lead> filteredLeads = ListUtil.filter(records, oldMap)
      .changed(Lead.FinServ__RelatedAccount__c)
      .toList();
    Set<Id> prospectCustomersIds = CommercialLeadActionsHelper.getProspectCustomers(
      filteredLeads
    );
    CommercialLeadActionsHelper.updateNewToBankFlag(
      filteredLeads,
      prospectCustomersIds
    );
  }

  /**
   * @description After Update populate A2ZReviews Customer Lookup
   * @name setCustomerOnA2ZReview
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in afterUpdate.
   * @param records from the trigger
   */
  public static void setCustomerOnA2ZReview(
    Map<Id, Lead> oldMap,
    List<Lead> records
  ) {
    try {
      List<Lead> filteredLeads = ListUtil.filter(records, oldMap)
        .changed(Lead.FinServ__RelatedAccount__c)
        .toList();
      Map<Id, Lead> filteredLeadMap = (Map<Id, Lead>) ListUtil.mapBy(
        filteredLeads,
        Lead.Id
      );
      List<A_Z_Review__c> listOfA2ZReviews = A2ZREVIEW_REPOSITORY.fetchReviewsByLead(
        filteredLeadMap.keySet()
      );
      List<A_Z_Review__c> filteredRecords = CommercialLeadActionsHelper.getUpdatedAZRecords(
        filteredLeadMap,
        listOfA2ZReviews
      );

      DML_REPOSITORY.doUpdate(
        filteredRecords,
        new DmlConfig().allowPartial().systemMode()
      );
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
      throw new CustomException(e.getMessage());
    }
  }

  /**
   * @description This method will update the Skip Validation during owner change
   * @name setSkipValidationOnOwnerChange
   * @param records from the trigger
   * @param oldMap Map of old records
   */
  public static void setSkipValidationOnOwnerChange(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    if (!USER_REPO.checkProfile(CCRM_PROFILE)) {
      return;
    }
    List<Lead> filteredLeadsWithOwnerChange = ListUtil.filter(records, oldMap)
      .changed(Lead.OwnerId)
      .toList();

    for (Lead ownerChangedLead : filteredLeadsWithOwnerChange) {
      ownerChangedLead.Skip_Validations__c = ownerChangedLead.Skip_Validations__c !=
        SKIP_VALIDATION
        ? SKIP_VALIDATION
        : VALIDATE;
    }
  }

  /**
   * @description This method is used to map referral status with lead status
   * @name mapLeadStatusWithReferralStatus
   * @param records List of Lead records
   * @param oldMap old map of lead records
   */
  public static void mapLeadStatusWithReferralStatus(
    Lead[] records,
    Map<Id, Lead> oldMap
  ) {
    List<Lead> filteredLeads = ListUtil.filter(records, oldMap)
      .isNotNull(Lead.FinServ__ReferredByUser__c)
      .changed(Lead.Status)
      .toList();
    LeadActionsHelper.mapLeadStatusWithReferralStatus(filteredLeads);
  }

  /**
   * @description Populate Registered_Company__c on New Leads before Inserting based on Entity Type.
   *  - Registered_Company__c: populate it as per Entity Type
   * @name populateRegisteredCompany
   * @param leadList List of lead records.
   */
  public static void populateRegisteredCompanyForIndividual(
    List<Lead> leadList
  ) {
    List<Lead> filteredLeadsList = ListUtil.filter(leadList)
      .equals(Lead.RecordTypeId, RTLead.commercialLead)
      .equals(Lead.Entity_Type__c, ENTITY_TYPE_INDIVIDUAL)
      .toList();

    ListUtil.setField(filteredLeadsList, Lead.Registered_Company__c, 'No');
  }

  /**
   * @description Update expiry date to 14 days when banker accept the referral
   * @name updateExpirydate
   * @param leadList List of lead records
   * @param oldMap Map of old records
   */
  public static void updateExpirydate(
    List<Lead> leadList,
    Map<Id, Lead> oldMap
  ) {
    List<Lead> filteredLeadsList = ListUtil.filter(leadList)
      .changed(Lead.RecordTypeId)
      .isNotNull(Lead.FinServ__ReferredByUser__c)
      .toList();

    ListUtil.setField(
      filteredLeadsList,
      Lead.Expiry_Date__c,
      DateTimeUtils.getNextWeekdayDate(14)
    );
  }

  /**
   * @description Check and update expiry date for lead.
   *  - lead ownership changed
   *  - follow-up date changed
   *  - expiry date are set after campaign end date
   * @name setExpiryDate
   * @param records List of lead NEW records.
   * @param oldMap Map of leads with Id
   */
  public static void setExpiryDate(List<Lead> records, Map<Id, Lead> oldMap) {
    List<Lead> unExpiredLeads = LeadExpiryActions.getUnexpiredLeads(records);
    Map<Id, CampaignMember> mapCampaigns = LeadExpiryActions.getMapOfCampaign(
      unExpiredLeads
    );
    Map<Id, Task> mapTask = LeadExpiryActions.getMapOfLeadResponse(
      unExpiredLeads,
      oldMap
    );
    List<Lead> leadsToUpdateExpiryDate = CommercialLeadActionsHelper.updateExpiryDateWhenFollowUpChanged(
      unExpiredLeads,
      mapTask
    );
    List<Lead> ownerChangedLeads = ListUtil.filter(unExpiredLeads, oldMap)
      .changed(Lead.OwnerId)
      .toList();
    List<Lead> filteredLeadsBasedOnExpiryDate = ListUtil.filter(
        ownerChangedLeads
      )
      .equals(
        Lead.Expiry_Date__c,
        Date.today().addDays(Integer.valueOf(Label.CCRM_Today_Date))
      )
      .toList();
    Map<Id, Boolean> leadWithIncludeFridayMap = LeadExpiryActions.getLeadsWithIncludeFridayMap(
      filteredLeadsBasedOnExpiryDate
    );
    LeadExpiryActions.getLeadsWithIncludeFridayMapForFutureExpiry(
      ownerChangedLeads,
      leadWithIncludeFridayMap
    );
    List<Lead> filteredLeadsForWeekEndExpiry = ListUtil.filter(
        filteredLeadsBasedOnExpiryDate
      )
      .equals(Lead.Id, leadWithIncludeFridayMap.keySet())
      .toList();
    leadsToUpdateExpiryDate.addAll(filteredLeadsForWeekEndExpiry);
    LeadExpiryActions.validateExpiryDateWithCampaignDate(
      leadsToUpdateExpiryDate,
      mapCampaigns
    );
    LeadExpiryActions.populateExpiryDaysBasedOnWeekDays(
      leadsToUpdateExpiryDate,
      leadWithIncludeFridayMap
    );
    LeadExpiryActions.updateExpiryDateForNextDay(
      filteredLeadsBasedOnExpiryDate
    );
  }

  /**
   * @description This method to check if secondary customer needs contain customer needs value
   * @name checkIfSecondaryCustomerNeedsContainsCustomerNeeds
   * @param records List of Lead records
   * @param oldMap Map of old map
   */
  public static void checkIfSecondaryCustomerNeedsContainsCustomerNeeds(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    Set<SObjectField> leadFieldsSet = new Set<SObjectField>{
      Lead.FinServ__ExpressedInterest__c,
      Lead.Secondary_Customer_Needs__c
    };
    List<Lead> leadsHavingNeedsChanged = ListUtil.filter(records, oldMap)
      .anyChanged(leadFieldsSet)
      .toList();
    for (Lead record : leadsHavingNeedsChanged) {
      Boolean result = RecordComparisonUtil.picklistContainSameValue(
        record,
        Lead.Secondary_Customer_Needs__c,
        Lead.FinServ__ExpressedInterest__c,
        Schema.Lead.getSObjectType()
      );
      // if secondary customer needs has value same as customer needs
      // throw error
      if (!result) {
        continue;
      }
      record.Secondary_Customer_Needs__c.addError(CUSTOMER_NEEDS_ERROR);
    }
  }

  /**
   * @description This method send Lead - Response update to UNICA or Adobe
   * @name publishLeadResponseUpdateToAdobeOrUnica
   * @param records List of lead records
   * @param oldMap Map of old lead records
   */
  public static void publishLeadResponseUpdateToAdobeOrUnica(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    List<Lead> listOfLeads = ListUtil.filter(records, oldMap)
      .equals(Lead.Lead_Originator__c, SET_OF_ELIGIBLE_LEAD_ORIGINATOR)
      .notEquals(Lead.Id, LeadManagementActions.calloutLeadIds)
      .changed(Lead.SubStatus__c)
      .isNull(Lead.FinServ__ReferredByUser__c)
      .toList();

    PLATFORM_EVENT_ACTIONS.publishLeadResponseUpdateToAdobeOrUnica(
      listOfLeads,
      oldMap
    );
  }

  /**
   * @description This method send CCRM/UNICA/ADOBE lead change update to UNICA or ADOBE
   * @name sendLeadOwnerUpdateToUnica
   * @param records List of lead records
   * @param oldMap Map of old lead records
   */
  public static void sendLeadOwnerUpdateToUnica(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    if (USER_REPOSITORY.isIntegrationUser()) {
      return;
    }
    Set<SObjectField> fieldsToValidateChange = new Set<SObjectField>{
      Lead.OwnerID
    };
    List<Lead> listOfLeads = ListUtil.filter(records, oldMap)
      .equals(Lead.Lead_Originator__c, SET_OF_ELIGIBLE_LEAD_ORIGINATOR)
      .notEquals(Lead.Id, LeadManagementActions.calloutLeadIds)
      .anyChanged(fieldsToValidateChange)
      .isNull(Lead.FinServ__ReferredByUser__c)
      .toList();
    PLATFORM_EVENT_ACTIONS.publishLeadUpdateToUnicaOrAdobe(
      listOfLeads,
      new List<Task>(),
      true
    );
  }

  /**
   * @description This method send CCRM/UNICA/ADOBE lead change update to UNICA or ADOBE
   * @name sendLeadUpdateToUnicaOrAdobe
   * @param records List of lead records
   * @param oldMap Map of old lead records
   */
  public static void sendLeadUpdateToUnicaOrAdobe(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    if (USER_REPOSITORY.isIntegrationUser()) {
      return;
    }
    Set<SObjectField> fieldsToValidateChange = new Set<SObjectField>{
      Lead.Expiry_Date__c,
      Lead.Status
    };
    List<Lead> listOfLeads = ListUtil.filter(records, oldMap)
      .equals(Lead.Lead_Originator__c, SET_OF_ELIGIBLE_LEAD_ORIGINATOR)
      .notEquals(Lead.Id, LeadManagementActions.calloutLeadIds)
      .anyChanged(fieldsToValidateChange)
      .isNull(Lead.FinServ__ReferredByUser__c)
      .toList();
    PLATFORM_EVENT_ACTIONS.publishLeadUpdateToUnicaOrAdobe(
      listOfLeads,
      new List<Task>(),
      false
    );
  }

  /**
   * @description This method send manual Leads to UNICA
   * @name sendManualLeadsToUnica
   * @param records List of lead records
   * @param oldMap Map of old lead records
   */
  public static void sendManualLeadsToUnica(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    Set<String> setOfEligibleLeadOriginator = new Set<String>{
      ORIGINATOR_UNICA,
      ORIGINATOR_CCRM
    };
    List<Lead> filteredLeads = ListUtil.filter(records)
      .equals(Lead.Lead_Originator__c, setOfEligibleLeadOriginator)
      .toList();
    PLATFORM_EVENT_ACTIONS.publishManualLeads(filteredLeads);
  }

  /**
   * @description : It will map primary contact method according to phone fields
   * @name : populatePrimaryContactMethod
   * @param records List of Lead records
   */
  public static void populatePrimaryContactMethod(List<Lead> records) {
    try {
      List<Lead> filteredLeadList = ListUtil.filter(records)
        .equals(
          Lead.Lead_Originator__c,
          new Set<String>{ ORIGINATOR_UNICA, ORIGINATOR_ADOBE }
        )
        .toList();
      CommercialLeadActionsHelper.updatePrimaryContactMethod(filteredLeadList);
    } catch (Exception e) {
      Logger.error('Error while mapping Primary contact method', e).save();
    }
  }

  /**
   * @description : This is used to validate the account and CLG Info
   * @param records list of leads
   * @param oldMap Account-Account relationship records
   */
  public static void validateAndPopulateInfo(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    if (!USER_REPO.checkProfile(CCRM_PROFILE)) {
      return;
    }
    List<Lead> filteredLeadsList = ListUtil.filter(records, oldMap)
      .changed(Lead.CLG_Name__c)
      .toList();

    Set<Id> accountIdSet = ListUtil.getIds(
      filteredLeadsList,
      Lead.FinServ__RelatedAccount__c
    );

    Set<Id> clgIdSet = ListUtil.getIds(filteredLeadsList, Lead.CLG_Name__c);

    Set<Id> combinedAccountIdsSet = new Set<Id>(accountIdSet);
    combinedAccountIdsSet.addAll(clgIdSet);

    Map<Id, Account> accMap = new Map<Id, Account>(
      LEAD_ACTION_REPOSITORY.getAccountList(combinedAccountIdsSet)
    );

    List<Account> clgAccountList = ListUtil.filter(accMap.values())
      .equals(Account.RecordTypeId, RTAccount.clgAccount)
      .toList();

    List<FinServ__AccountAccountRelation__c> aarList = LEAD_ACTION_REPOSITORY.getAccountAccountRelations(
      accountIdSet
    );

    Map<Id, Set<Id>> accIdToClgIdsMap = CommercialLeadActionsHelper.formAccountIdToCLGIdsMap(
      aarList
    );

    CommercialLeadActionsHelper.addCLGAccountToMap(
      accIdToClgIdsMap,
      clgAccountList
    );

    CommercialLeadActionsHelper.validateAndPopulateCLGInfo(
      filteredLeadsList,
      accMap,
      accIdToClgIdsMap
    );
  }

  /**
   * @description : This is used to populate the CLG Info on Lead based on Existing customer
   * @param records Lead list
   * @param oldMap record map
   */
  public static void populateInfo(List<Lead> records, Map<Id, Lead> oldMap) {
    List<Lead> filteredLeadsList = ListUtil.filter(records, oldMap)
      .changed(Lead.FinServ__RelatedAccount__c)
      .isNotNull(Lead.FinServ__RelatedAccount__c)
      .toList();

    List<Lead> leadWithNoAccountIdList = ListUtil.filter(records, oldMap)
      .changed(Lead.FinServ__RelatedAccount__c)
      .isNull(Lead.FinServ__RelatedAccount__c)
      .toList();

    ListUtil.setField(leadWithNoAccountIdList, LEAD_FIELDS, null);

    Set<Id> accountIdSet = ListUtil.getIds(
      filteredLeadsList,
      Lead.FinServ__RelatedAccount__c
    );

    Map<Id, Account> accMap = new Map<Id, Account>(
      LEAD_ACTION_REPOSITORY.getAccountList(accountIdSet)
    );

    List<FinServ__AccountAccountRelation__c> aarList = LEAD_ACTION_REPOSITORY.getAccountAccountRelations(
      accountIdSet
    );

    Map<Id, Map<Id, FinServ__AccountAccountRelation__c>> accIdToClgIdAARMap = CommercialLeadActionsHelper.formAccountIdToCLGIdAARMap(
      aarList
    );

    CommercialLeadActionsHelper.populateClgCpidInfoOnLead(
      filteredLeadsList,
      accMap,
      accIdToClgIdAARMap
    );
  }
}

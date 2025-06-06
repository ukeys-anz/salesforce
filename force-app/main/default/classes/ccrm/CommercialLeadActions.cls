/**
 * @author       : Naman Garg
 * @since        : Nov 2024
 * @description  : This is the action class for CommercialLeadTriggerHandler
 **/
public with sharing class CommercialLeadActions {
  static final String ENTITY_TYPE_INDIVIDUAL = 'Individual';
  private static final String CCRM_PROFILE = 'ANZ CCRM Standard User';
  private static final String SKIP_VALIDATION = 'SkipValidation';
  private static final String VALIDATE = 'Validate';
  private static final String COPY_LEAD_ID = 'copyLeadId';

  private static final LeadActionsRepository LEAD_REPOSITORY = (LeadActionsRepository) Lib_InstanceProvider.forType(
    LeadActionsRepository.class
  );
  private static final UserInfoRepository USER_REPO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );
  private static final UserActionsRepository USER_REPOSITORY = (UserActionsRepository) Lib_InstanceProvider.forType(
    UserActionsRepository.class
  );

  private static final String ORIGINATOR_CCRM = 'CCRM';
  private static final String ORIGINATOR_UNICA = 'UNICA';
  private static final String ORIGINATOR_ADOBE = 'Adobe';
  private static final String PRIMARY_CONTACT_MOBILE = 'Mobile';
  private static final String PRIMARY_CONTACT_WORK = 'Work Phone';
  private static final String PRIMARY_CONTACT_HOME = 'Home Phone';

  private static final Set<String> SET_OF_ELIGIBLE_LEAD_ORIGINATOR = new Set<String>{
    ORIGINATOR_ADOBE,
    ORIGINATOR_UNICA,
    ORIGINATOR_CCRM
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
   * @description This method will populate fields
   * @name populateCLG
   * @param records list of lead records
   * @param oldMap map of old records
   */
  public static void populateCLG(List<Lead> records, Map<Id, Lead> oldMap) {
    Set<Id> accountIdsSet = extractAccountIds(records, oldMap);
    List<FinServ__AccountAccountRelation__c> aarList = LEAD_REPOSITORY.getAccountAccountRelations(
      accountIdsSet
    );

    Map<Id, FinServ__AccountAccountRelation__c> accountToAARMap = (Map<Id, FinServ__AccountAccountRelation__c>) ListUtil.mapBy(
      aarList,
      FinServ__AccountAccountRelation__c.FinServ__Account__c
    );

    populateCLGAccount(records, accountToAARMap);
  }

  /**
   * @description This method will fetch the Existing customer Id from leads
   * @name fetchAccountIds
   * @param records list of lead records
   * @param oldMap map of old records
   * @return Set<Id> set of account Id
   */
  @testVisible
  private static Set<Id> extractAccountIds(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    if (oldMap == null) {
      return ListUtil.getIds(records, Lead.FinServ__RelatedAccount__c);
    }
    List<Lead> filteredLeadsList = ListUtil.filter(records, oldMap)
      .changed(Lead.FinServ__RelatedAccount__c)
      .toList();

    return ListUtil.getIds(filteredLeadsList, Lead.FinServ__RelatedAccount__c);
  }

  /**
   * @description This method will populate CLG account
   * @name populateCLGAccount
   * @param leadList from the trigger
   * @param accountToAARMap Map of account to AAR
   */
  public static void populateCLGAccount(
    List<Lead> leadList,
    Map<Id, FinServ__AccountAccountRelation__c> accountToAARMap
  ) {
    for (Lead leadRecord : leadList) {
      if (!accountToAARMap.containsKey(leadRecord.FinServ__RelatedAccount__c)) {
        continue;
      }
      FinServ__AccountAccountRelation__c aarRecord = accountToAARMap.get(
        leadRecord.FinServ__RelatedAccount__c
      );
      leadRecord.CLG_Name__c = aarRecord?.FinServ__RelatedAccount__c;
      leadRecord.CLG_ID__c = aarRecord?.FinServ__RelatedAccount__r.CLG__c;
      leadRecord.CPID__c = aarRecord?.FinServ__RelatedAccount__r.CPID__c;
      leadRecord.CPID_Owner__c = aarRecord
        ?.FinServ__RelatedAccount__r.Controlling_Post__r
        ?.OwnerId;
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
      for (Lead leadRecord : filteredLeadList) {
        //check phone fields in priority order
        if (String.isNotBlank(leadRecord.MobilePhone)) {
          leadRecord.Primary_Contact_Method__c = PRIMARY_CONTACT_MOBILE;
          continue;
        }
        if (String.isNotBlank(leadRecord.Work_Phone__c)) {
          leadRecord.Primary_Contact_Method__c = PRIMARY_CONTACT_WORK;
          continue;
        }
        if (String.isNotBlank(leadRecord.Home_Phone__c)) {
          leadRecord.Primary_Contact_Method__c = PRIMARY_CONTACT_HOME;
          continue;
        }
        leadRecord.Primary_Contact_Method__c = null;
      }
    } catch (Exception e) {
      Logger.error('Error while mapping Primary contact method', e).save();
    }
  }
}

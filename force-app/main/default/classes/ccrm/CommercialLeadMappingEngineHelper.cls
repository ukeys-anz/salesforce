/**
 * @author Naman Garg
 * @since  May 2025
 * @group CCRM (Commercial CRM)
 * @description CommercialLeadMappingEngineHelper is class to helper class for CommercialLeadMappingEngine
 */
public with sharing class CommercialLeadMappingEngineHelper {
  private static final Map<Id, String> ACCOUNT_TYPE_MAP = new Map<Id, String>{
    RTAccount.businessAccount => 'Business',
    RTAccount.personAccount => 'Customer',
    RTAccount.clgAccount => 'CLG'
  };
  private static final String ACCOUNT_OBJECT = 'Account';
  private static final String CONTACT_OBJECT = 'Contact';

  private static final Set<SObjectField> MANUAL_LEAD_FIELDS = new Set<SObjectField>{
    CCRM_Account_To_Lead_Mapping__mdt.Account_Field_API_Name__c,
    CCRM_Account_To_Lead_Mapping__mdt.Lead_Field_API_Name__c
  };
  private static final Set<SObjectField> UNICA_LEAD_FIELDS = new Set<SObjectField>{
    CCRM_UNICA_To_Lead_Mapping__mdt.Account_or_Contact_Field_API_Name__c,
    CCRM_UNICA_To_Lead_Mapping__mdt.Lead_Field_API_Name__c
  };

  /**
   * @description form account field to Lead map
   * @name formAccountToLeadMappingMap
   * @param records List of lead records
   * @param mapAccountsRecordTypeId Map of account Id and Account
   * @return PrefillManualLeadWrapper Wrapper record
   */
  public CommercialLeadMappingEngine.PrefillManualLeadWrapper formAccountToLeadMappingMap(
    List<Lead> records,
    Map<Id, Account> mapAccountsRecordTypeId
  ) {
    String accountType = '';
    CommercialLeadMappingEngine.PrefillManualLeadWrapper prefillManualLeadWrap = new CommercialLeadMappingEngine.PrefillManualLeadWrapper();

    for (Lead record : records) {
      prefillManualLeadWrap.accountToLeadMappingClone = new Map<string, string>();
      Id accountRecordTypeId = mapAccountsRecordTypeId.get(
          record.FinServ__RelatedAccount__c
        )
        ?.RecordTypeId;
      accountType = ACCOUNT_TYPE_MAP.get(accountRecordTypeId);

      if (String.isBlank(accountType)) {
        continue;
      }

      formManualAccountToLeadMappingMap(
        record,
        accountType,
        prefillManualLeadWrap
      );
    }
    return prefillManualLeadWrap;
  }

  /**
   * @description form account field to Lead map for manual leads
   * @name formManualAccountToLeadMappingMap
   * @param record lead record
   * @param accountType account type
   * @param prefillManualLeadWrap Wrapper record
   */
  @TestVisible
  private static void formManualAccountToLeadMappingMap(
    Lead record,
    String accountType,
    CommercialLeadMappingEngine.PrefillManualLeadWrapper prefillManualLeadWrap
  ) {
    List<CCRM_Account_To_Lead_Mapping__mdt> filteredManualLeadMetadataList = ListUtil.filter(
        CCRM_Account_To_Lead_Mapping__mdt.getall().values()
      )
      .allNotNull(MANUAL_LEAD_FIELDS)
      .equals(CCRM_Account_To_Lead_Mapping__mdt.Account_Type__c, accountType)
      .equals(
        CCRM_Account_To_Lead_Mapping__mdt.Lead_Record_Types__c,
        RTLead.get(record.RecordTypeId).developername
      )
      .containsIgnoreCase(
        CCRM_Account_To_Lead_Mapping__mdt.Source_System__c,
        record.Lead_Originator__c
      )
      .toList();

    for (
      CCRM_Account_To_Lead_Mapping__mdt mapping : filteredManualLeadMetadataList
    ) {
      if (
        !prefillManualLeadWrap.accountToLeadMapping.containsKey(
          mapping.Account_Field_API_Name__c
        )
      ) {
        prefillManualLeadWrap.query += mapping.Account_Field_API_Name__c + ',';
      }
      prefillManualLeadWrap.accountToLeadMapping.put(
        mapping.Account_Field_API_Name__c,
        mapping.Lead_Field_API_Name__c
      );
    }
    //Create clone to create Map - accountToLeadMappingWithAccount based on account types
    prefillManualLeadWrap.accountToLeadMappingWithAccount.put(
      accountType,
      prefillManualLeadWrap.accountToLeadMappingClone
    );
  }

  /**
   * @description form account contact field to Lead map
   * @name formAccountContactToLeadMappingMap
   * @param records List of lead records
   * @param accountMap Map of account
   * @return PrefillUnicaLeadWrapper Wrapper record
   */

  public CommercialLeadMappingEngine.PrefillUnicaLeadWrapper formAccountContactToLeadMappingMap(
    List<Lead> records,
    Map<String, Account> accountMap
  ) {
    CommercialLeadMappingEngine.PrefillUnicaLeadWrapper prefillUnicaLeadWrap = new CommercialLeadMappingEngine.PrefillUnicaLeadWrapper();

    for (Lead record : records) {
      prefillUnicaLeadWrap.accountToLeadMappingClone = new Map<String, String>();
      prefillUnicaLeadWrap.contactToLeadMappingClone = new Map<String, String>();

      String fieldName = record.Customer_ID__c ?? record.Business_ID__c ??
        record.Clg_ID__c ?? '';
      if (String.isBlank(fieldName)) {
        record.addError(Label.ML_Unica_Lead_Source_System_Not_Found_Error);
        continue;
      }
      String accountType = ACCOUNT_TYPE_MAP.get(
        accountMap.get(fieldName).RecordTypeId
      );

      if (String.isBlank(accountType)) {
        continue;
      }
      record.FinServ__RelatedAccount__c = accountMap.get(fieldName).Id;

      formUnicaAccountToLeadMappingMap(
        record,
        accountType,
        prefillUnicaLeadWrap
      );
      formUnicaContactToLeadMappingMap(
        record,
        accountType,
        prefillUnicaLeadWrap
      );
    }
    return prefillUnicaLeadWrap;
  }

  /**
   * @description form account field to Lead map for unica leads
   * @name formUnicaAccountToLeadMappingMap
   * @param record lead record
   * @param accountType account type
   * @param prefillUnicaLeadWrap Wrapper record
   */
  @TestVisible
  private static void formUnicaAccountToLeadMappingMap(
    Lead record,
    String accountType,
    CommercialLeadMappingEngine.PrefillUnicaLeadWrapper prefillUnicaLeadWrap
  ) {
    List<CCRM_UNICA_To_Lead_Mapping__mdt> filteredUnicaLeadMetadataList = ListUtil.filter(
        CCRM_UNICA_To_Lead_Mapping__mdt.getall().values()
      )
      .allNotNull(UNICA_LEAD_FIELDS)
      .equals(CCRM_UNICA_To_Lead_Mapping__mdt.Object__c, ACCOUNT_OBJECT)
      .equals(CCRM_UNICA_To_Lead_Mapping__mdt.Account_Type__c, accountType)
      .equals(
        CCRM_UNICA_To_Lead_Mapping__mdt.Lead_Record_Types__c,
        RTLead.get(record.RecordTypeId).developername
      )
      .toList();

    for (
      CCRM_UNICA_To_Lead_Mapping__mdt mapping : filteredUnicaLeadMetadataList
    ) {
      if (
        !prefillUnicaLeadWrap.accountToLeadMapping.containsKey(
          mapping.Account_or_Contact_Field_API_Name__c
        )
      ) {
        prefillUnicaLeadWrap.accountFields +=
          mapping.Account_or_Contact_Field_API_Name__c + ',';
      }
      prefillUnicaLeadWrap.accountToLeadMapping.put(
        mapping.Account_or_Contact_Field_API_Name__c,
        mapping.Lead_Field_API_Name__c
      );

      //Create clone to create Map - accountToLeadMappingWithAccount based on account types
      prefillUnicaLeadWrap.accountToLeadMappingClone.put(
        mapping.Account_or_Contact_Field_API_Name__c,
        mapping.Lead_Field_API_Name__c
      );
    }

    prefillUnicaLeadWrap.accountToLeadMappingWithAccount.put(
      accountType,
      prefillUnicaLeadWrap.accountToLeadMappingClone
    );
  }

  /**
   * @description form contact field to Lead map for unica leads
   * @name formUnicaContactToLeadMappingMap
   * @param record lead record
   * @param accountType account type
   * @param prefillUnicaLeadWrap Wrapper record
   */
  @TestVisible
  private static void formUnicaContactToLeadMappingMap(
    Lead record,
    String accountType,
    CommercialLeadMappingEngine.PrefillUnicaLeadWrapper prefillUnicaLeadWrap
  ) {
    List<CCRM_UNICA_To_Lead_Mapping__mdt> filteredUnicaLeadMetadataList = ListUtil.filter(
        CCRM_UNICA_To_Lead_Mapping__mdt.getall().values()
      )
      .allNotNull(UNICA_LEAD_FIELDS)
      .equals(CCRM_UNICA_To_Lead_Mapping__mdt.Object__c, CONTACT_OBJECT)
      .equals(CCRM_UNICA_To_Lead_Mapping__mdt.Account_Type__c, accountType)
      .equals(
        CCRM_UNICA_To_Lead_Mapping__mdt.Lead_Record_Types__c,
        RTLead.get(record.RecordTypeId).developername
      )
      .toList();

    for (
      CCRM_UNICA_To_Lead_Mapping__mdt mapping : filteredUnicaLeadMetadataList
    ) {
      if (
        !prefillUnicaLeadWrap.contactToLeadMapping.containsKey(
          mapping.Account_or_Contact_Field_API_Name__c
        )
      ) {
        prefillUnicaLeadWrap.contactFields +=
          mapping.Account_or_Contact_Field_API_Name__c + ',';
      }
      prefillUnicaLeadWrap.contactToLeadMapping.put(
        mapping.Account_or_Contact_Field_API_Name__c,
        mapping.Lead_Field_API_Name__c
      );
      //Create clone to create Map - accountToLeadMappingWithAccount based on account types
      prefillUnicaLeadWrap.contactToLeadMappingClone.put(
        mapping.Account_or_Contact_Field_API_Name__c,
        mapping.Lead_Field_API_Name__c
      );
    }
    prefillUnicaLeadWrap.contactToLeadMappingWithContact.put(
      accountType,
      prefillUnicaLeadWrap.contactToLeadMappingClone
    );
  }
}

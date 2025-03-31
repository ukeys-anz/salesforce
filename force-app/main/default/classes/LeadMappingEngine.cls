/**
 * @author MLCRM Developer
 * @since  26/09/2024
 * @description LeadMappingEngine is class to handle mapping of account, contact to lead for manual & UNICA leads and Opportunity to lead for lead Conversion
 */
public with sharing class LeadMappingEngine {
  private static final LeadConversionActionsRepository LEADCONV_REPOSITORY = (LeadConversionActionsRepository) Lib_InstanceProvider.forType(
    LeadConversionActionsRepository.class
  );
  private static final String SOBJECT_OPPORTUNITY = 'Opportunity';
  private static final String SOBJECT_ACCOUNT = 'Account';
  private static final String MAPPING_TYPE_FIELD = 'Field';
  private static final String MAPPING_TYPE_RT = 'Record Type';
  private static final Set<String> CONTACT_FIELDS = new Set<String>{
    'FirstName',
    'LastName',
    'Title__c',
    'Email',
    'Work_Phone__c',
    'MobilePhone',
    'Home_Phone__c'
  };

  /**
   * @description This method map lead fields to opportunity for
   * opportunity creation when lead is converted
   * @name mapLeadToOpportunityFields
   * @param leadRecord The Lead records.
   * @param accountId account id from lead conversion result
   * @return Opportunity
   */
  public static Opportunity mapLeadToOpportunityFields(
    Lead leadRecord,
    Id accountId
  ) {
    List<DCRM_Lead_Conversion_Mapping__mdt> leadToSObjectMappingCustomMetadata = getLeadConversionMappingCMDT();
    Map<Id, Schema.RecordTypeInfo> mapLeadRecordTypes = getRecordTypes();
    String mdLeadFields = getLeadQuerySelectFields(
      mapLeadRecordTypes.get(leadRecord.RecordTypeId).developername,
      leadToSObjectMappingCustomMetadata
    );
    Lead record = LEADCONV_REPOSITORY.getLeadforOpportunityCreation(
      mdLeadFields,
      leadRecord.Id
    );
    LeadInfoWrapper leadInfo = new LeadInfoWrapper(
      record,
      SOBJECT_OPPORTUNITY,
      accountId
    );
    //CC-1099 made the method as generic as per CLD to reusably fetch any conversionRecord from Leads.
    SObject targetSObject = prefillConversionRecords(
      leadInfo,
      leadToSObjectMappingCustomMetadata
    );
    if (targetSObject == null) {
      return null;
    }
    return ((Opportunity) targetSObject);
  }

  /**
   * @description This method to get custom metadata records DCRM_Lead_Conversion_Mapping__mdt
   * @name getLeadConversionMappingCMDT
   * @return List<DCRM_Lead_Conversion_Mapping__mdt> custom metadata records
   */
  private static List<DCRM_Lead_Conversion_Mapping__mdt> getLeadConversionMappingCMDT() {
    //Get Lead to Opportunity mapping from custom metadata
    return DCRM_Lead_Conversion_Mapping__mdt.getall().Values();
  }

  /**
   * @description This method to get all the recordtype developername of lead object
   * @name getRecordTypes
   * @return  Map<Id, Schema.RecordTypeInfo> All Lead RecordTypes
   */
  private static Map<Id, Schema.RecordTypeInfo> getRecordTypes() {
    return Lead.sobjectType.getDescribe().getRecordTypeInfosById();
  }

  /**
   * @description This method to get the lead fields from metadata to query
   * @name getLeadQuerySelectFields
   * @param leadRecordType The Lead record Type developer name.
   * @param leadToSObjectMappingcustomMetadata Custom Metadata records
   * @return mdLeadFields - All lead fields from metadata to query
   */
  private static String getLeadQuerySelectFields(
    String leadRecordType,
    List<DCRM_Lead_Conversion_Mapping__mdt> leadToSObjectMappingcustomMetadata
  ) {
    Set<String> mdLeadFields = new Set<String>();
    String defaultleadFields = System.Label.Lead_Conversion_Default_Fields;
    for (
      DCRM_Lead_Conversion_Mapping__mdt mdRecord : leadToSObjectMappingCustomMetadata
    ) {
      if (
        mdRecord.Lead_Field__c == null ||
        defaultleadFields.contains(mdRecord.Lead_Field__c) ||
        mdLeadFields.contains(mdRecord.Lead_Field__c) ||
        !mdRecord.Lead_Record_Types__c.contains(leadRecordType)
      ) {
        continue;
      }
      mdLeadFields.add(mdRecord.Lead_Field__c);
    }
    return String.join(mdLeadFields, ', ');
  }

  /**
   * @description CC-1099 This method prefill data to sObject from Leads for Lead Conversion
   * @name prefillConversionRecords
   * @param leadInfoWrapper lead info wrapper records
   * @param leadToSObjectMappingCustomMetadata  DCRM_Lead_Conversion_Mapping__mdt records
   * @return SObject the Sobject record
   */
  public static SObject prefillConversionRecords(
    LeadInfoWrapper leadInfoWrapper,
    List<DCRM_Lead_Conversion_Mapping__mdt> leadToSObjectMappingCustomMetadata
  ) {
    String strTargetObject = leadInfoWrapper.strTargetObject;
    Lead leadRecord = leadInfoWrapper.leadRecord;
    ID accountId = leadInfoWrapper.accountId;

    SObject targetObject = getTargetObject(strTargetObject);

    List<DCRM_Lead_Conversion_Mapping__mdt> activeMappingCMDT = filterActiveMappingCMDT(
      leadToSObjectMappingCustomMetadata,
      strTargetObject,
      getRecordTypes().get(leadRecord.RecordTypeId).developername
    );

    //prefill Target Object from CustomMetadata
    targetObject = mapTargetFields(leadRecord, targetObject, activeMappingCMDT);
    targetObject = mapTargetRT(
      strTargetObject,
      targetObject,
      activeMappingCMDT
    );
    targetObject = mapConstants(
      targetObject,
      activeMappingCMDT,
      strTargetObject
    );
    targetObject = mapCampaignId(leadRecord, targetObject, strTargetObject);
    targetObject = mapAccountId(leadRecord, targetObject, accountId);
    targetObject = mapContactField(leadRecord, targetObject, strTargetObject);
    targetObject.put('CloseDate', DateTimeUtils.getNextWeekdayDate(90));

    if (targetObject == null) {
      return null;
    }
    return targetObject;
  }

  /**
   * @description This method to get the SObject
   * @name getTargetObject
   * @param strTargetObject Target Object Name
   * @return SObject
   */
  private static SObject getTargetObject(String strTargetObject) {
    return Schema.getGlobalDescribe().get(strTargetObject).newSObject();
  }

  /**
   * @description This method to get the corresponding target field of SObject from metadata
   * @name mapTargetFields
   * @param leadRecord the Lead record
   * @param targetObject the target sObject record
   * @param leadConversionMappings lead conversion mapping custom metadata
   * @return SObject
   */
  private static SObject mapTargetFields(
    Lead leadRecord,
    SObject targetObject,
    List<DCRM_Lead_Conversion_Mapping__mdt> leadConversionMappings
  ) {
    for (DCRM_Lead_Conversion_Mapping__mdt mapping : leadConversionMappings) {
      if (
        mapping.Mapping_Type__c != MAPPING_TYPE_FIELD ||
        mapping.Lead_Field__c == null
      ) {
        continue;
      }
      targetObject.put(
        mapping.Target_Field__c,
        leadRecord.get(mapping.Lead_Field__c)
      );
    }
    return targetObject;
  }

  /**
   * @description This method to get the corresponding target field of SObject from metadata
   * @name mapTargetRT
   * @param strTargetObject Target Object Name
   * @param targetObject the target sObject record
   * @param leadConversionMappings lead conversion mapping custom metadata
   * @return SObject
   */
  private static SObject mapTargetRT(
    String strTargetObject,
    SObject targetObject,
    List<DCRM_Lead_Conversion_Mapping__mdt> leadConversionMappings
  ) {
    for (DCRM_Lead_Conversion_Mapping__mdt mapping : leadConversionMappings) {
      if (
        mapping.Mapping_Type__c != MAPPING_TYPE_RT ||
        mapping.Target_Value__c == null
      ) {
        continue;
      }
      targetObject.put(
        mapping.Target_Field__c,
        getRecordTypeId(mapping.Target_Value__c, strTargetObject)
      );
    }
    return targetObject;
  }

  /**
   * @description This method to get the corresponding target field of SObject from metadata
   * @name mapConstants
   * @param targetObject the target sObject record
   * @param leadConversionMappings lead conversion mapping custom metadata
   * @param strTargetObject Target Object Name
   * @return SObject
   */
  private static SObject mapConstants(
    SObject targetObject,
    List<DCRM_Lead_Conversion_Mapping__mdt> leadConversionMappings,
    String strTargetObject
  ) {
    Map<String, Schema.SObjectField> mapSchema = getSchemaMap(strTargetObject);
    for (DCRM_Lead_Conversion_Mapping__mdt mapping : leadConversionMappings) {
      if (
        mapping.Mapping_Type__c != MAPPING_TYPE_FIELD ||
        mapping.Lead_Field__c != null ||
        mapping.Target_Value__c == null
      ) {
        continue;
      }
      Schema.DisplayType fieldDataType = mapSchema.get(mapping.Target_Field__c)
        .getDescribe()
        .getType();
      switch on fielddataType {
        when BOOLEAN {
          targetObject.put(
            mapping.Target_Field__c,
            Boolean.valueOf(mapping.Target_Value__c)
          );
        }
        when INTEGER {
          targetObject.put(
            mapping.Target_Field__c,
            Integer.valueOf(mapping.Target_Value__c)
          );
        }
        when DOUBLE {
          targetObject.put(
            mapping.Target_Field__c,
            Double.valueOf(mapping.Target_Value__c)
          );
        }
        when else {
          targetObject.put(mapping.Target_Field__c, mapping.Target_Value__c);
        }
      }
    }
    return targetObject;
  }

  /**
   * @description This method to map the CampaignId
   * @name mapCampaignId
   * @param leadRecord the Lead record
   * @param targetObject the target sObject record
   * @param strTargetObject Target Object Name
   * @return SObject
   */
  private static SObject mapCampaignId(
    Lead leadRecord,
    SObject targetObject,
    String strTargetObject
  ) {
    if (
      strTargetObject != SOBJECT_OPPORTUNITY ||
      leadRecord.CampaignMembers.isEmpty()
    ) {
      return targetObject;
    }
    targetObject.put('CampaignId', leadRecord.CampaignMembers[0]?.CampaignId);
    return targetObject;
  }

  /**
   * @description This method to map the Account id
   * @name mapAccountId
   * @param leadRecord the Lead record
   * @param targetObject the target sObject record
   * @param accountId the account id of the lead
   * @return SObject
   */
  private static SObject mapAccountId(
    Lead leadRecord,
    SObject targetObject,
    Id accountId
  ) {
    if (leadRecord.FinServ__RelatedAccount__c != null) {
      return targetObject;
    }
    targetObject.put('AccountId', accountId);
    return targetObject;
  }

  /**
   * @description This method to map the Contact fields
   * @name mapContactField
   * @param leadRecord the Lead record
   * @param targetObject the target sObject record
   * @param strTargetObject Target Object Name
   * @return SObject
   */
  private static SObject mapContactField(
    Lead leadRecord,
    SObject targetObject,
    String strTargetObject
  ) {
    if (strTargetObject != SOBJECT_OPPORTUNITY) {
      return targetObject;
    }
    targetObject.put('Contact__c', getContact(leadRecord));
    return targetObject;
  }

  /**
   * @description This method is used to get the Target object instance
   * @name getSchemaMap
   * @param strObject Target Object Name
   * @return Map<String, Schema.SObjectField>
   */
  private static Map<String, Schema.SObjectField> getSchemaMap(
    String strObject
  ) {
    return ((SObject) Type.forName(strObject).newInstance())
      .getSObjectType()
      .getDescribe()
      .fields.getMap();
  }

  /**
   * @description This method to get the filtered the lead conversion mapping metadata
   * @name filterActiveMappingCMDT
   * @param leadConversionMDT lead conversion mapping custom metadata
   * @param strObject Target Object Name
   * @param leadRT the Record Type of lead
   * @return List<DCRM_Lead_Conversion_Mapping__mdt>
   */

  private static List<DCRM_Lead_Conversion_Mapping__mdt> filterActiveMappingCMDT(
    List<DCRM_Lead_Conversion_Mapping__mdt> leadConversionMDT,
    String strObject,
    String leadRT
  ) {
    List<DCRM_Lead_Conversion_Mapping__mdt> filteredMDT = new List<DCRM_Lead_Conversion_Mapping__mdt>();
    for (DCRM_Lead_Conversion_Mapping__mdt mapping : leadConversionMDT) {
      if (
        mapping.Target_Object__c != strObject ||
        !mapping.Active__c ||
        mapping.Target_Field__c == null ||
        !mapping.Lead_Record_Types__c.contains(leadRT)
      ) {
        continue;
      }
      filteredMDT.add(mapping);
    }
    return filteredMDT;
  }

  /**
   * @description This method get contact fields from lead fields
   * @name getContact
   * @param record lead record
   * @return String Contact details
   */
  private static String getContact(Lead record) {
    List<String> contactFieldValues = new List<String>();
    for (String contactfield : CONTACT_FIELDS) {
      if (String.isNotBlank((String) record.get(contactfield))) {
        contactFieldValues.add((String) record.get(contactfield));
      }
    }
    return String.join(contactFieldValues, '\n');
  }
  /**
   * @description This method used to fetch Record Type id of Opportunity by use of Developer Name from the custom metadata
   * @name getOppRecordType
   * @param targetRTDeveloperName RecordType Developer Name
   * @param strTargetObject Object Name
   * @return ID objRecordTypeID id of the record type
   */
  public static ID getRecordTypeId(
    String targetRTDeveloperName,
    String strTargetObject
  ) {
    if (strTargetObject != SOBJECT_OPPORTUNITY) {
      return null;
    }
    return Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
      .get(targetRTDeveloperName)
      .getRecordTypeId();
  }

  /**
   * @description Wrapper class for LeadInfo.
   */
  private class LeadInfoWrapper {
    private Lead leadRecord { get; set; }
    private String strTargetObject { get; set; }
    private String accountId { get; set; }

    LeadInfoWrapper(Lead leadRecord, String strTargetObject, String accountId) {
      this.leadRecord = leadRecord;
      this.strTargetObject = strTargetObject;
      this.accountId = accountId;
    }
  }
}

/**
 * @author Sahil S
 * @since  08/2021
 * @modified: Prahlad Bhadani (April 2025)
 * @description AbnAcnServiceActions is class to handle all the ABN ACN Services Actions
 */
public with sharing class AbnAcnServiceActions {
  private final static String ABN_ACN_STATUS_INPROGRESS = 'Validation in progress';
  private static final String ABN_ACN_STATUS_FAILED = 'Validation Error';
  private static final Set<String> EMPTY_NULL_SET = new Set<String>{ '', null };

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description Check if the lead's ABN or ACN is added and set ABN or ACN validation status to Validation in progress
   * @name setValidationStatus
   * @param records leads to check
   * @param oldMap contains the map which holds the previous values of lead record
   */
  public static void setValidationStatus(Lead[] records, Map<Id, Lead> oldMap) {
    Set<SObjectField> fieldsToValidateABNChange = new Set<SObjectField>{
      Lead.ABN__c,
      Lead.Registered_Company__c
    };
    List<Lead> filteredABNLeads = ListUtil.filter(records, oldMap)
      .anyChanged(fieldsToValidateABNChange)
      .equals(Lead.Registered_Company__c, 'Yes')
      .notEquals(Lead.ABN__c, EMPTY_NULL_SET)
      .toList();
    ListUtil.setField(filteredABNLeads, Lead.ABN_Validation_Status__c, '');
    Set<SObjectField> fieldsToValidateACNChange = new Set<SObjectField>{
      Lead.ACN__c,
      Lead.Registered_Company__c
    };
    List<Lead> filteredACNLeads = ListUtil.filter(records, oldMap)
      .anyChanged(fieldsToValidateACNChange)
      .equals(Lead.Registered_Company__c, 'Yes')
      .notEquals(Lead.ACN__c, EMPTY_NULL_SET)
      .toList();
    ListUtil.setField(filteredACNLeads, Lead.ACN_Validation_Status__c, '');
  }

  /**
   * @description Check if the lead's ABN or ACN is removed and set ABN or ACN validation status to null
   * @param record lead record from the trigger
   * @param oldRec lead record with previous values from the trigger
   */
  /**
   * @name removeValidationStatus
   * @description Check if the lead's ABN or ACN is removed and set ABN or ACN validation status to null
   * @param records lead records
   * @param oldMap  map of old records
   */
  public static void removeValidationStatus(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    List<Lead> filteredABNLeads = ListUtil.filter(records, oldMap)
      .changedTo(Lead.ABN__c, EMPTY_NULL_SET)
      .toList();
    ListUtil.setField(filteredABNLeads, Lead.ABN_Validation_Status__c, '');
    List<Lead> filteredACNLeads = ListUtil.filter(records, oldMap)
      .changedTo(Lead.ACN__c, EMPTY_NULL_SET)
      .toList();
    ListUtil.setField(filteredACNLeads, Lead.ACN_Validation_Status__c, '');
  }
  /**
   * @description check if the ABN or ACN is added or changed and make a callout.
   * @param records from the trigger
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in afterUpdate.
   */
  public static void validateAbnAcnForCallout(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    //make this callout only when the trigger contains one record.
    if (
      records.isEmpty() ||
      records.size() != 1 ||
      records[0].Registered_Company__c != 'Yes'
    ) {
      return;
    }
    Lead record = records[0];
    Lead oldRec = oldMap?.get(record.id);
    if (AbnAcnUtil.isABNValueEntered(record, oldRec)) {
      makeAbnCallout(record.ABN__c.deleteWhitespace(), record.Id);
    }
    if (AbnAcnUtil.isACNValueEntered(record, oldRec)) {
      makeAcnCallout(record.ACN__c.deleteWhitespace(), record.Id);
    }
  }
  /**
   * @description method to make ABN callout and get abn status
   * @param abn Australian Business Number
   * @param leadId lead record id from the trigger
   */
  @future(callOut=true)
  public static void makeAbnCallout(String abn, String leadId) {
    CCRMAPIRepository apiRepo = new CCRMAPIRepository();
    CCRMValidateAbnAcnModel responseMap = apiRepo.validateAbn(abn);
    Lead leadRec = new Lead(id = leadId);
    leadRec.ABN_Validation_Status__c = responseMap?.abnStatus ??
      ABN_ACN_STATUS_FAILED;
    LeadManagementActions.calloutLeadIds.add(leadId);
    DML_REPOSITORY.doUpdate(leadRec);
  }
  /**
   * @description method to make ACN callout and get acn status
   * @param acn Australian Company Number
   * @param leadId lead record id from the trigger
   */
  @future(callOut=true)
  public static void makeAcnCallout(String acn, String leadId) {
    CCRMAPIRepository apiRepo = new CCRMAPIRepository();
    CCRMValidateAbnAcnModel responseMap = apiRepo.validateAcn(acn);
    Lead leadRec = new Lead(id = leadId);
    leadRec.ACN_Validation_Status__c = responseMap?.abnStatus ??
      ABN_ACN_STATUS_FAILED;
    LeadManagementActions.calloutLeadIds.add(leadId);
    DML_REPOSITORY.doUpdate(leadRec);
  }
}

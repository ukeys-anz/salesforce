/**
 * @author       : Advait Yermalkar
 * @since        : 10-15-2025
 * @description  : Controller for cloning Lead Lwc : cloneLead.js
 **/
public with sharing class CloneLeadController {
  private static final String CAMPAIGN_CODE = 'IKCMP-1579';
  private static final String FIELDSET_API_NAME = 'CCRM_Clone_Lead_Fields';
  private static final String ERROR_NOT_CLONEABLE = 'Only New to Bank leads associated with a Prospect can be cloned.';

  private static final CloneLeadRepository CLONE_LEAD_REPOSITORY = (CloneLeadRepository) Lib_InstanceProvider.forType(
    CloneLeadRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @name cloneLeadRecord
   * @description clones the Prospect lead record with selected fields only
   * @param leadId
   * @return Id
   **/
  @AuraEnabled(cacheable=true)
  public static Id cloneLeadRecord(Id leadId) {
    try {
      Lead newLead = new Lead();
      String query = buildLeadQuery(leadId);
      Lead oldLead = CLONE_LEAD_REPOSITORY.getLeadRecordByQuery(query);
      // Validation: Only clone if NTB == 'Yes' AND customer is a Prospect (or no related account)
      if (
        oldLead.New_to_Bank__c != 'Yes' ||
        !(oldLead.FinServ__RelatedAccount__r?.Is_Prospect__c ?? true)
      ) {
        throw new AuraHandledException(ERROR_NOT_CLONEABLE);
      }

      // Create new lead manually with selected fields only
      Schema.FieldSet fieldSet = SObjectType.Lead.FieldSets.getMap()
        .get(FIELDSET_API_NAME);
      if (fieldSet == null) {
        throw new AuraHandledException(
          'Field Set not found: ' + FIELDSET_API_NAME
        );
      }

      // copy selected fields from old lead to new lead
      copyFieldSetValues(oldLead, newLead, FIELDSET_API_NAME);

      // Set additional required fields
      newLead.Campaign_Code__c = CAMPAIGN_CODE;
      newLead.OwnerId = UserInfo.getUserId();
      newLead.Previous_Lead__c = oldLead.Id;
      newLead.FinServ__ExpressedInterest__c = null;

      DML_REPOSITORY.doInsert(
        newLead,
        new DmlConfig()
          .byPassDuplicateRule()
          .errorLog('Error while inserting lead record in CloneLeadController')
      );
      return newLead.Id;
    } catch (DmlException e) {
      Logger.error('Error occurred while cloning lead record', e).save();
      throw new AuraHandledException(e.getMessage());
    } catch (AuraHandledException ahe) {
      Logger.error('Error occurred while cloning lead record', ahe).save();
      throw ahe;
    }
  }

  @TestVisible
  private static void copyFieldSetValues(
    Lead oldLead,
    Lead newLead,
    String fieldSetName
  ) {
    Schema.FieldSet fieldSet = SObjectType.Lead.FieldSets.getMap()
      .get(fieldSetName);
    if (fieldSet == null) {
      return;
    }
    for (Schema.FieldSetMember fsm : fieldSet.getFields()) {
      String fieldName = fsm.getFieldPath();

      // Check field accessibility before assignment
      if (oldLead.get(fieldName) != null) {
        newLead.put(fieldName, oldLead.get(fieldName));
      }
    }
  }

  /**
   * @name buildLeadQuery
   * @description Dynamically builds SOQL for fetching a Lead with all Field Set + validation fields
   * @param leadId - Lead record Id
   * @return SOQL query string
   */
  private static String buildLeadQuery(Id leadId) {
    Schema.FieldSet fieldSet = SObjectType.Lead.FieldSets.getMap()
      .get(FIELDSET_API_NAME);
    Set<String> fieldNames = new Set<String>();

    for (Schema.FieldSetMember fsm : fieldSet.getFields()) {
      fieldNames.add(fsm.getFieldPath());
    }

    // Always include required fields
    fieldNames.add('Id');
    fieldNames.add('New_to_Bank__c'); //required for validation
    fieldNames.add('FinServ__RelatedAccount__r.Is_Prospect__c'); //required for validation

    // Build SOQL dynamically
    String query =
      'SELECT ' +
      String.join(new List<String>(fieldNames), ',') +
      ' FROM Lead WHERE Id = \'' +
      String.valueOf(leadId) +
      '\'' +
      ' AND RecordTypeId = \'' +
      String.valueOf(RTLead.commercialLead) +
      '\'' +
      ' WITH SYSTEM_MODE LIMIT 1';

    return query;
  }
}

/**
 * @author       : Advait Yermalkar
 * @since        : 10-15-2025
 * @description  : Controller for cloning Lead Lwc : cloneLead.js
 **/
public with sharing class CloneLeadController {
  private static final String CAMPAIGN_CODE = 'IKCMP-1579';
  private static final String ERROR_NOT_CLONEABLE = 'Only New to Bank leads associated with a Prospect can be cloned.';
  private static final Schema.FieldSet CLONE_FIELDSET = SObjectType.Lead.FieldSets.CCRM_Clone_Lead_Fields;

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
      String query = buildLeadQuery(CLONE_FIELDSET);
      Lead oldLead = CLONE_LEAD_REPOSITORY.getLeadRecordByQuery(query, leadId);
      // Validation: Only clone if NTB == 'Yes' AND customer is a Prospect (or no related account)
      if (
        oldLead.New_to_Bank__c != 'Yes' ||
        (oldLead.FinServ__RelatedAccount__r?.FinServ__Status__c != null &&
        oldLead.FinServ__RelatedAccount__r?.FinServ__Status__c != 'Prospect')
      ) {
        throw new AuraHandledException(ERROR_NOT_CLONEABLE);
      }

      copyFieldSetValues(oldLead, newLead, CLONE_FIELDSET);

      // Set additional required fields
      newLead.Campaign_Code__c = CAMPAIGN_CODE;
      newLead.OwnerId = UserInfo.getUserId();
      newLead.Previous_Lead__c = oldLead.Id;
      newLead.FinServ__ExpressedInterest__c = null;

      DML_REPOSITORY.doInsert(
        newLead,
        new DmlConfig()
          .systemMode()
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
    Schema.FieldSet fieldSet
  ) {
    for (Schema.FieldSetMember fsm : fieldSet.getFields()) {
      String fieldName = fsm.getFieldPath();
      if (oldLead.get(fieldName) != null) {
        newLead.put(fieldName, oldLead.get(fieldName));
      }
    }
  }

  /**
   * @name buildLeadQuery
   * @description Dynamically builds SOQL for fetching a Lead with all Field Set + validation fields
   * @param fieldSet - FieldSet containing fields to query
   * @return SOQL query string
   */
  private static String buildLeadQuery(Schema.FieldSet fieldSet) {
    Set<String> fieldNames = new Set<String>();

    for (Schema.FieldSetMember fsm : fieldSet.getFields()) {
      fieldNames.add(fsm.getFieldPath());
    }

    // Always include required fields
    fieldNames.add('Id');
    fieldNames.add('New_to_Bank__c'); //required for validation
    fieldNames.add('FinServ__RelatedAccount__r.FinServ__Status__c'); //required for validation
    String query =
      'SELECT ' +
      String.join(new List<String>(fieldNames), ',') +
      ' FROM Lead WHERE Id = :leadId AND RecordTypeId = :rtId' +
      ' LIMIT 1';

    return query;
  }
}

/**
 * @author Dhanashree Deshmukh
 * @since 04/2025
 * @group CCRM (Commercial CRM)
 * @description call ABN/ACN APIs if the value is present to update lead ABN/ACN status
 * @runTests ValidateABNACNControllerTest
 */
public with sharing class ValidateABNACNController implements Queueable, Database.AllowsCallouts {
  private static final LeadActionsRepository LEAD_REPOSITORY = (LeadActionsRepository) Lib_InstanceProvider.forType(
    LeadActionsRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private Lead leadToUpdate;

  /**
   * @description if ABN/ACN value is present then call respective API's to update status
   * @name validateAbnAcnForCallout
   * @param leadId leads id
   */
  @AuraEnabled
  public static void validateAbnAcnForCallout(Id leadId) {
    Lead leadRecord = LEAD_REPOSITORY.getLead(leadId);
    if (leadRecord.Registered_Company__c != 'Yes') {
      return;
    }
    System.enqueueJob(new ValidateABNACNController(leadRecord));
  }

  /**
   * @description Queuable Constructor
   * @param leadRecord lead record
   */
  public ValidateABNACNController(Lead leadRecord) {
    this.leadToUpdate = leadRecord;
  }

  /**
   * @description Queuable execute
   * @name execute
   * @param qc QueueableContext
   */
  public void execute(QueueableContext qc) {
    String abnValidationStatus = '';
    String acnValidationStatus = '';
    if (String.isNotBlank(leadToUpdate.ABN__c)) {
      abnValidationStatus = AbnAcnServiceActions.abnCallout(
          leadToUpdate.ABN__c.deleteWhitespace(),
          leadToUpdate.Id
        )
        .ABN_Validation_Status__c;
    }
    if (String.isNotBlank(leadToUpdate.ACN__c)) {
      acnValidationStatus = AbnAcnServiceActions.acnCallout(
          leadToUpdate.ACN__c.deleteWhitespace(),
          leadToUpdate.Id
        )
        .ACN_Validation_Status__c;
    }
    if (abnValidationStatus != null) {
      leadToUpdate.ABN_Validation_Status__c = abnValidationStatus;
    }
    if (acnValidationStatus != null) {
      leadToUpdate.ACN_Validation_Status__c = acnValidationStatus;
    }
    leadToUpdate.Skip_Validations__c = leadToUpdate.Skip_Validations__c !=
      'SkipValidation'
      ? 'SkipValidation'
      : 'Validate';
    DML_REPOSITORY.doUpdate(leadToUpdate);
  }
}

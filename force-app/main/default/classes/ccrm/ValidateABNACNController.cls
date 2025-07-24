/**
 * @author Dhanashree Deshmukh
 * @since 04/2025
 * @group CCRM (Commercial CRM)
 * @description call ABN/ACN APIs if the value is present to update lead ABN/ACN status
 * @runTests ValidateABNACNControllerTest
 */
public with sharing class ValidateABNACNController {
  private static final LeadActionsRepository LEAD_REPOSITORY = (LeadActionsRepository) Lib_InstanceProvider.forType(
    LeadActionsRepository.class
  );

  /**
   * @description if ABN/ACN value is present then call respective API's to update status
   * @name validateAbnAcnForCallout
   * @param leadId leads id
   */
  @AuraEnabled(cacheable=true)
  public static void validateAbnAcnForCallout(Id leadId) {
    Lead leadRecord = LEAD_REPOSITORY.getLead(leadId);
    if (leadRecord.Registered_Company__c != 'Yes') {
      return;
    }
    if (String.isNotBlank(leadRecord.ABN__c)) {
      AbnAcnServiceActions.makeAbnCallout(
        leadRecord.ABN__c.deleteWhitespace(),
        leadRecord.Id
      );
    }
    if (String.isNotBlank(leadRecord.ACN__c)) {
      AbnAcnServiceActions.makeAcnCallout(
        leadRecord.ACN__c.deleteWhitespace(),
        leadRecord.Id
      );
    }
  }
}

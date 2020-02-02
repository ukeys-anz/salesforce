/**
 * @author saiero
 * @since 2020
 * @group IDR(Internal Dispute Resolution)
 * @description Controller for the lightning componenent wrapping the complaint creation flow.
 */
 public with sharing class NewComplaintFlowWrapperController {
  /**
   * @description Get the Developer Name of a record type based on its Id
   * @param id Record Type ID
   * @return The RT's Dev Name
   */
    @AuraEnabled
    public static String getCaseRecordTypeDevNameById(Id id) {
        return Schema.SObjectType.Case.getRecordTypeInfosById().get(id).getDeveloperName();
    }
}
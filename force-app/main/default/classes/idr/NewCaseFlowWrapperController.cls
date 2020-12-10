/**
 * @author saiero
 * @since 2020
 * @group IDR(Internal Dispute Resolution)
 * @description Controller for the lightning component wrapping the Case creation flow, currently only for Complaints.
 */
public with sharing class NewCaseFlowWrapperController {
  /**
   * @description Get the Developer Name of a Case record type based on its Id
   * @param id Record Type ID
   * @return The RT's Dev Name
   */
  @AuraEnabled
  public static String getCaseRecordTypeDevNameById(Id id) {
    return Schema.SObjectType.Case.getRecordTypeInfosById()
      .get(id)
      .getDeveloperName();
  }
}

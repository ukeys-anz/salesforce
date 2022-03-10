/**
 *
 * @author Rebecca Jan
 * @since 2021
 * @description SubmitDisputeController is the apex controller for the submitDispute LWC
 */
public with sharing class SubmitDisputeController {
  /**
   * @description Changes to submitted boolean to flag as true on dispute records
   *
   * @param caseId the id of the case of the financial account
   * @return a boolean whether it was successful or not
   */
  @AuraEnabled
  public static Boolean updateSubmitFlag(Id caseId) {
    if (Schema.sObjectType.Case.isUpdateable()) {
      Database.DMLOptions dmo = new Database.DMLOptions();
      dmo.assignmentRuleHeader.useDefaultRule = true;
      Case disputeCase = new Case(
        Id = caseId,
        Submitted__c = true,
        Submitted_Time__c = DateTime.now()
      );
      disputeCase.setOptions(dmo);
      update disputeCase;
      return true;
    } else {
      CommonUtil.logAndThrowIAE(
        'SubmitDisputeController',
        'updateSubmitFlag',
        'Not enough permissions to submit dispute for Case ID: ' + caseId
      );
      return false;
    }
  }
}

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
      try {
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
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'SubmitDisputeController',
        'updateSubmitFlag',
        'Not enough permissions to submit dispute for Case ID: ' + caseId
      );
      return false;
    }
  }

  /**
   * @description checks presence of Token Card Number to support handling of alert
   * in submitDispute lwc if missing for ATM and Card Dispute Cases
   * @param caseId the id of the case of the financial account
   * @return a boolean confirming whether Card Token Number is missing
   */
  @AuraEnabled
  public static Boolean verifyCardTokenNumber(Id caseId) {
    List<Id> disputeRTIdsToQuery = new List<Id>{
      GetHelpConstants.ATM_DISPUTE_RT_ID,
      GetHelpConstants.CARD_DISPUTE_RT_ID
    };
    Boolean cardTokenNumberIsMissing = false;

    if (PermissionUtils.canQuery('Case')) {
      try {
        List<Case> disputeCaseList = [
          SELECT Id, Card_Token_Number__c
          FROM Case
          WHERE Id = :caseId AND RecordType.Id IN :disputeRTIdsToQuery
          LIMIT 1
        ];

        if (!disputeCaseList.isEmpty()) {
          cardTokenNumberIsMissing = String.isBlank(
            disputeCaseList[0].Card_Token_Number__c
          );
        }
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'SubmitDisputeController',
        'verifyCardTokenNumber',
        'Not enough permissions to verify card token number for: ' + caseId
      );
    }

    return cardTokenNumberIsMissing;
  }
}

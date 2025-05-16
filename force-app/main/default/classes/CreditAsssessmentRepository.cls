/**
 * @author Peter Charalambous
 * @since Mon Aug 05 2024
 * @description Provides SOQL and DML helpers for CreditAssessmentController
 */

public with sharing class CreditAsssessmentRepository {
  /**
   * @description retrieve case record
   * @param recordId of case to retrieve
   * @return Case
   */
  public Case getCaseRecord(String recordId) {
    PermissionUtils.canQuery('Case');
    return [
      SELECT Id, OwnerId, Status, Account.OCV_Id__c, Assessment_Id__c
      FROM Case
      WHERE Id = :recordId
    ];
  }

  /**
   * @description retrieve residential loan application record
   * @param recordId of rla to retrieve
   * @return ResidentialLoanApplication
   */
  public ResidentialLoanApplication getResidentialLoanApplicationRecord(
    String recordId
  ) {
    PermissionUtils.canQuery('ResidentialLoanApplication');
    return [
      SELECT Account.OCV_Id__c, Credit_ID__c, Status
      FROM ResidentialLoanApplication
      WHERE Id = :recordId
    ];
  }

  /**
   * @description retrieve list of users for fed id
   * @param emails of users to retrieve
   * @return List<User>
   */
  public List<User> getUserList(String emails) {
    SystemModeActions systemActions = new SystemModeActions(
      'CreditAsssessmentRepository',
      'getResidentialLoanApplicationRecord'
    );
    //Remove null as a potential check so we dont get random users with no fed ids
    return systemActions.query(
      'SELECT Name, FederationIdentifier FROM User WHERE FederationIdentifier != null AND FederationIdentifier IN (' +
        emails +
        ')'
    );
  }

  /**
   * @description retrieve list of reason outcomes based on referral reason
   * @param reasonCodeId reason code to retrieve records from
   * @return List<Reason_Outcome__c>
   */
  public List<Reason_Outcome__c> getReasonOutcomeByReferralReason(
    String reasonCodeId
  ) {
    PermissionUtils.canQuery('Reason_Outcome__c');
    return [
      SELECT Outcome_Code__c, Outcome_Description__c
      FROM Reason_Outcome__c
      WHERE Referral_Reason__c = :reasonCodeId
    ];
  }

  /**
   * @description retrieve list of referral reason code data
   * @param reasonCodeSet set of reason codes
   * @return List<Referral_Reason__c>
   */
  public List<Referral_Reason__c> getReferralReasonList(
    Set<String> reasonCodeSet
  ) {
    if (reasonCodeSet.isEmpty()) {
      return new List<Referral_Reason__c>();
    }

    PermissionUtils.canQuery('Referral_Reason__c');
    return [
      SELECT
        Id,
        Reason_Code__c,
        Guidance_Code__c,
        Assessment_Category__c,
        Authority_Level__c
      FROM Referral_Reason__c
      WHERE Reason_Code__c IN :reasonCodeSet
    ];
  }

  /**
   * @description retrieve list of reason outcomes based on outcome code
   * @param outcomeCodeSet set of outcome codes to retrieve list by
   * @return List<Reason_Outcome__c>
   */
  public List<Reason_Outcome__c> getReasonOutcomeByOutcomeCode(
    Set<String> outcomeCodeSet
  ) {
    if (outcomeCodeSet.isEmpty()) {
      return new List<Reason_Outcome__c>();
    }
    PermissionUtils.canQuery('Reason_Outcome__c');
    return [
      SELECT Outcome_Code__c, Outcome_Description__c
      FROM Reason_Outcome__c
      WHERE Outcome_Code__c IN :outcomeCodeSet
    ];
  }
}

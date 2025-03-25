/**
 *
 * @author Shivraj Kadam
 * @since 02/2025
 * @description TrustMeCaseActions class is to handle all the action taken for TrustMe eIDV Cases
 */
public with sharing class TrustMeCaseActions {
  public static final Set<SObjectField> TEST_FIELDS = new Set<SObjectField>{
    Case.Fraud_Customer_Details__c,
    Case.Fraud_MiddleNameCheck__c,
    Case.Fraud_Selfie_Comparison_Match__c,
    Case.Fraud_Address_Valid__c,
    Case.Fraud_ID_Legible__c,
    Case.Fraud_ID_Not_Picture__c,
    Case.Fraud_Customer_Photo_Modified__c,
    Case.Fraud_Security_Features__c
  };
   /**
   * @description Update Tested Date
   * @param cases List of Cases
   */
  public static void updateTestedDate(List<Case> cases) {
     List<Case> validCases = ListUtil.filter(cases)
      .isNull(Case.TestedDate__c)
      .allNotNull(TEST_FIELDS)
      .toList();
    ListUtil.setField(validCases, Case.TestedDate__c, System.now());
  }
}
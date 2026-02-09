/**
 *
 * @author Shivraj Kadam
 * @since 02/2025
 * @description TrustMeCaseActions class is to handle all the action taken for TrustMe eIDV Cases
 */
public with sharing class TrustMeCaseActions {
  private static final IDOpsQueryRepository REPOSITORY = (IDOpsQueryRepository) Lib_InstanceProvider.forType(
    IDOpsQueryRepository.class
  );
  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  private static final String MSG_ERROR_GENERIC_CHECK_COMPLETION = 'Error performing the checks completion. Please contact your System Administrator.';

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

  /**
   * @description method invoked in lwc.
   * @param recordId The TrustMe QA Case & ReKYC QA Case records to update.
   */
  @AuraEnabled
  public static void completeChecksAsYes(String recordId) {
    try {
      List<Case> cases = REPOSITORY.queryQAChecksByIds(new Set<Id>{ recordId });

      ListUtil.setFieldIfNull(cases, TEST_FIELDS, 'Yes');
      DML.doUpdate(cases);
    } catch (Exception ex) {
      CommonUtil.logAuraExceptionInfo(
        MSG_ERROR_GENERIC_CHECK_COMPLETION,
        recordId,
        ex
      );
      throw new AuraHandledException(MSG_ERROR_GENERIC_CHECK_COMPLETION);
    }
  }
}

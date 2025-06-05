/**
 * @description       : Action class for managing business logic on Associated_Loan_Application__c
 *                      in the RBM Broker Interaction flow.
 * @author            : Madhuri Edke | Salesforce
 * @group             :
 * @last modified on  : 06-04-2025
 * @last modified by  : Madhuri Edke | Salesforce
 **/

public with sharing class RBMAssociatedLoanApplicationActions {
  private static final AssociatedLoanApplicationRepository ASSOCIATED_APPLICATION_REPO = (AssociatedLoanApplicationRepository) Lib_InstanceProvider.forType(
    AssociatedLoanApplicationRepository.class
  );
  private static final Integer MAX_APPLICATIONS_PER_INTERACTION = 4;

  /**
   * @description Calculates and validates the count of loan applications related to the given interactions.
   * @param relatedApplications List of Associated_Loan_Application__c records, typically from Trigger.new
   */
  public static void calculateInteractionRelatedLoanApplications(
    List<Associated_Loan_Application__c> relatedApplications
  ) {
    if (relatedApplications.isEmpty()) {
      return;
    }
    Set<Id> interactionIds = ListUtil.getIds(
      relatedApplications,
      Associated_Loan_Application__c.Interaction__c
    );

    List<AggregateResult> loanAppCount = ASSOCIATED_APPLICATION_REPO.getLoanApplicationsCount(
      interactionIds
    );
    Map<Id, Integer> interactionToAppCount = mapInteractionToLoanAppCount(
      loanAppCount
    );
    validateApplicationLimit(relatedApplications, interactionToAppCount);
  }

  /**
   * @description Updates the unique key field on loan application records.
   * @param records List of Associated_Loan_Application__c records to update
   */
  public static void validateApplicationRecords(
    List<Associated_Loan_Application__c> records
  ) {
    for (Associated_Loan_Application__c app : records) {
      app.UniqueKeyForAssociatedApplication__c =
        app.Interaction__c +
        '_' +
        app.Residential_Loan_Application__c;
    }
  }

  /**
   * @description Converts AggregateResult list into a Map from Interaction Id to Loan Application count.
   * @param loanAppCount List of AggregateResult containing Interaction__c and appCount
   * @return Map from Interaction Id to Integer count of loan applications
   */
  @TestVisible
  private static Map<Id, Integer> mapInteractionToLoanAppCount(
    List<AggregateResult> loanAppCount
  ) {
    Map<Id, Integer> interactionToAppCount = new Map<Id, Integer>();
    if (loanAppCount == null) {
      return interactionToAppCount;
    }
    for (AggregateResult ar : loanAppCount) {
      interactionToAppCount.put(
        (Id) ar.get('Interaction__c'),
        (Integer) ar.get('appCount')
      );
    }
    return interactionToAppCount;
  }

  /**
   * @description Validates the number of linked loan applications per interaction, adding errors if limits exceeded.
   * @param relatedApplications List of Associated_Loan_Application__c to validate
   * @param interactionToAppCount Map of Interaction Id to count of linked loan applications
   */
  @TestVisible
  private static void validateApplicationLimit(
    List<Associated_Loan_Application__c> relatedApplications,
    Map<Id, Integer> interactionToAppCount
  ) {
    if (relatedApplications.isEmpty() || interactionToAppCount.isEmpty()) {
      return;
    }
    for (Associated_Loan_Application__c app : relatedApplications) {
      Id interactionId = app.Interaction__c;

      Integer currentCount = interactionToAppCount.get(interactionId);
      if (currentCount >= MAX_APPLICATIONS_PER_INTERACTION) {
        app.addError(
          'You cannot link more than ' +
            MAX_APPLICATIONS_PER_INTERACTION +
            ' applications'
        );
      }
    }
  }
}

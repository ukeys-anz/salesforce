/**
 * @description repository class for Residential Loan Application
 * @author Deepro De
 * @since August 2024
 */
public with sharing class LoanApplicantRepository {
  /**
   * @description get associated ResidentialLoanApplicantRecords
   * @return List<ResidentialLoanApplication>
   * @param loanApplicantIds Set of LoanApplicant Ids
   */
  public List<LoanApplicant> queryLoanApplicationOfApplicants(
    Set<Id> loanApplicantIds
  ) {
    List<LoanApplicant> loanApplicants = new List<LoanApplicant>();
    if (
      loanApplicantIds.isEmpty() ||
      !PermissionUtils.canQuery(BrokerConstants.LOAN_APPLICANT_OBJECT)
    ) {
      return loanApplicants;
    }
    loanApplicants = [
      SELECT
        Id,
        LoanApplication.Assisted_Broker_TPMI_SAO__c,
        Account__r.Sync_Status__c,
        Account__c
      FROM LoanApplicant
      WHERE
        Id IN :loanApplicantIds
        AND Account__r.Sync_Status__c EXCLUDES (
          :BrokerConstants.SYNC_STATUS_BROKER_ORG
        )
        AND LoanApplication.Assisted_Broker_TPMI_SAO__c != NULL
      WITH USER_MODE
    ];
    return loanApplicants;
  }

  /**
   * @description Get a single Loan Applicant by persona id
   * @param personaId the persona id value to search for
   * @return LoanApplicant record or null
   */
  public LoanApplicant getLoanApplicantByPersonaId(String personaId) {
    return [
      SELECT Id, Name
      FROM LoanApplicant
      WHERE Persona_Id__c = :personaId
      WITH USER_MODE
      LIMIT 1
    ] ?? null;
  }
}

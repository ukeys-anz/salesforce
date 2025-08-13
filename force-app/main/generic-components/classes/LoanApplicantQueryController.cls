/**
 * @description Controller to handle LoanApplicant SOQL for Generic Components
 * @author
 * @since 07/2025
 */
public with sharing class LoanApplicantQueryController implements Callable {
  private static final String ERROR_MSG = 'Failed to retrieve LoanApplicant details. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';
  private static final LoanApplicantRepository LOAN_APPLICANT_REPOSITORY = (LoanApplicantRepository) Lib_InstanceProvider.forType(
    LoanApplicantRepository.class
  );

  /**
   * @param methodName String value of local method to invoke
   * @param args arg map that contains parameters for the method
   * @return `Object`
   * @description invocable method overridden by callable interface
   */
  public Object call(String methodName, Map<String, Object> args) {
    switch on methodName {
      when 'getLoanApplicantByPersonaId' {
        return getLoanApplicantByPersonaId(args);
      }
      when else {
        throw new AuraHandledException('Unknown method: ' + methodName);
      }
    }
  }

  /**
   * @description getLoanApplicantByPersonaId returns Loan Applicant by personaId
   * @param args Map of params for call
   * @return LoanApplicant
   */
  public LoanApplicant getLoanApplicantByPersonaId(Map<String, Object> args) {
    try {
      String personaId = (String) args.get('personaId');
      return LOAN_APPLICANT_REPOSITORY.getLoanApplicantByPersonaId(personaId);
    } catch (Exception e) {
      Logger.error('Failure on LoanApplicantQueryController.getData', e);
      Logger.saveLog();
      AuraHandledException err = new AuraHandledException(ERROR_MSG);
      err.setMessage(ERROR_MSG);
      throw err;
    }
  }
}

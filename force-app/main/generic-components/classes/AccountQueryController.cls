/**
 * @description Controller to handle Account SOQL for Generic Components
 * @author Peter Charalambous
 * @since 07/2025
 */
public with sharing class AccountQueryController implements Callable {
  private static final String ERROR_MSG = 'Failed to retrieve Account details. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';
  private static final AccountRepository ACCOUNT_REPOSITORY = (AccountRepository) Lib_InstanceProvider.forType(
    AccountRepository.class
  );

  /**
   * @param methodName String value of local method to invoke
   * @param args arg map that contains parameters for the method
   * @return `Object`
   * @description invocable method overridden by callable interface
   */
  public Object call(String methodName, Map<String, Object> args) {
    switch on methodName {
      when 'getAccountByOcvId' {
        return getAccountByOcvId(args);
      }
      when else {
        throw new AuraHandledException('Unknown method: ' + methodName);
      }
    }
  }

  /**
   * @description getAccountByOcvId returns account by ocvId
   * @param args Map of params for call
   * @return Account
   */
  private Account getAccountByOcvId(Map<String, Object> args) {
    try {
      String ocvId = (String) args.get('ocvId');
      return ACCOUNT_REPOSITORY.getAccountByOcvId(ocvId);
    } catch (Exception e) {
      Logger.error('Failure on AccountQueryController.getData', e);
      Logger.saveLog();
      AuraHandledException err = new AuraHandledException(ERROR_MSG);
      err.setMessage(ERROR_MSG);
      throw err;
    }
  }
}

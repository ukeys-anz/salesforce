/**
 * @author Pavan Kumar Ananta
 * @since Feb 2020
 * @description Exception Handling https://developer.salesforce.com/blogs/2017/09/error-handling-best-practices-lightning-apex.html
 * @group Repository
 */
public virtual with sharing class RepositoryBase {
  protected Set<Integer> statusCodeSuccess = new Set<Integer>();
  protected Set<Integer> statusCodeErrorAccess = new Set<Integer>();
  protected Set<Integer> statusCodeErrorServer = new Set<Integer>();

  /**
   * @param response HttpCalloutResponse model to be handled
   * @return HttpCalloutResponse response
   * @description handle received response and either return the response or throw exception
   */
  protected virtual HttpCalloutResponse processResponse(
    HttpCalloutResponse response
  ) {
    if (response.successful) {
      return response;
    }
    Integer code = response.statusCode;
    if (isSuccessStatusCode(code)) {
      return response;
    }
    Exception ex = response.error;
    if (isAccessErrorStatusCode(code)) {
      Logger.info('Callout failed - HTTP ' + code, ex).save();
      throw new InsufficientAccessException(ex.getMessage());
    }
    Logger.error('Callout failed - HTTP ' + code, ex).save();
    if (isServerErrorStatusCode(code)) {
      throw new ServerErrorException(ex.getMessage());
    }
    throw ex;
  }

  private Boolean isSuccessStatusCode(Integer code) {
    return (statusCodeSuccess.isEmpty() && code.toString().startsWith('2')) ||
      (!statusCodeSuccess.isEmpty() && statusCodeSuccess.contains(code));
  }

  private Boolean isAccessErrorStatusCode(Integer code) {
    return (statusCodeErrorAccess.isEmpty() &&
      code.toString().startsWith('4')) ||
      (!statusCodeErrorAccess.isEmpty() &&
      statusCodeErrorAccess.contains(code));
  }

  private Boolean isServerErrorStatusCode(Integer code) {
    return (statusCodeErrorServer.isEmpty() &&
      code.toString().startsWith('5')) ||
      (!statusCodeErrorServer.isEmpty() &&
      statusCodeErrorServer.contains(code));
  }

  /**
   * @description custom exception
   */
  public class InsufficientAccessException extends Exception {
  }
  /**
   * @description custom exception
   */
  public class ServerErrorException extends Exception {
  }

  /**
   *
   * @param response - HttpCalloutResponse response to check for errors
   * @param error - Occured execption/error from code
   * @param apexType - ClassName from where the method called
   * @description This method handles errors by logging it as ERROR and throwing the same to the caller methods.
   */
  public void handleErrors(
    HttpCalloutResponse response,
    Object error,
    Type apexType
  ) {
    Exception err = error != null ? (Exception) error : response.error;
    logAndThrowError(err, false);
  }

  /**
   *
   * @param response - HttpCalloutResponse response to check for errors
   * @param error - Occured execption/error from code
   * @param apexType - ClassName from where the method called
   * @description This method handles errors by logging it as INFO and throwing the same to the caller methods. Use case would be "Permission exceptions", where the system did not fail, the user action failed because of invalid actions from user.
   */
  public void handleErrorAsInfo(
    HttpCalloutResponse response,
    Object error,
    Type apexType
  ) {
    Exception err = error != null ? (Exception) error : response.error;
    logAndThrowError(err, true);
  }

  /**
   *
   * @param err - Occured Exception
   * @param isInfo - Boolean variable to check whether to save as Info or Error
   * @description - This method will log the exception and throw the same
   */
  private void logAndThrowError(Exception err, Boolean isInfo) {
    if (isInfo) {
      Logger.info(err.getMessage(), err);
    } else {
      Logger.error(err.getMessage(), err);
    }
    Logger.saveLog();
    throw err;
  }
}

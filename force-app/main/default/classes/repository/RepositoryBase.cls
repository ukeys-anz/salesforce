/**
 * @author Pavan Kumar Ananta
 * @since Feb 2020
 * @description Exception Handling https://developer.salesforce.com/blogs/2017/09/error-handling-best-practices-lightning-apex.html
 * @group Repository
 */
public virtual with sharing class RepositoryBase {
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

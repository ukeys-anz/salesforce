/**
 * @author Pavan Kumar Ananta
 * @since Feb 2020
 * @description Exception Handling https://developer.salesforce.com/blogs/2017/09/error-handling-best-practices-lightning-apex.html
 * @group Repository
 */
public virtual with sharing class RepositoryBase {
  /**
   *
   * @param response
   * @param error
   * @param apexType
   * @description
   */
  public void handleErrors(
    HttpCalloutResponse response,
    Exception error,
    Type apexType
  ) {
    Exception err = error != null ? error : response.error;
    if (err instanceof JSONException) {
      Lib_SystemLog.createSingleLog(
        apexType.getName(),
        'RepositoryBase-handleErrors',
        '',
        err.getMessage(),
        Lib_SystemLog.Severity.ERROR
      );
    } else if (err instanceof CalloutException) {
      lib_systemLog.logAPIError(
        apexType.getName(),
        'RepositoryBase-handleErrors',
        err.getMessage(),
        err.getTypeName(),
        null,
        null,
        null,
        null,
        response.statusCode
      );
    } else {
      Lib_SystemLog.createSingleLog(
        apexType.getName(),
        'RepositoryBase-handleErrors',
        '',
        err.getMessage(),
        Lib_SystemLog.Severity.ERROR
      );
    }
    throw err;
  }
}

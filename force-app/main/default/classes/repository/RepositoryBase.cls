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

    Logger.error(err.getMessage(), err);
    Logger.saveLog();

    throw err;
  }
}

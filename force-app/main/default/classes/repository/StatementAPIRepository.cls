/**
 * @author Chiranjeeb Dhar
 * @since October 2021
 * @description statement API repository for all statement related callouts
 * @group Repository
 */
public with sharing class StatementAPIRepository extends RepositoryBase {
  /**
   * @description  The getStatementsAura is the method to make the Http callout to Mulesoft to fetch the statement details from Fabric against the account number.
   * {@link Lib_SystemLog.logAPIError} is called when ever the call fails to Fabric to have the logs recorded for monitoring.
   * @param ocvId required to make the callout to Mulesoft
   * @param accountNumber Account number for which we want to fetch the statements
   * @return String
   * @exception CalloutException
   */
  @AuraEnabled(cacheable=true)
  public static StatementModel getStatementsAura(
    String ocvId,
    String accountNumber
  ) {
    StatementAPIRepository statementapi = new StatementAPIRepository();
    try {
      StatementModel responseModel = statementapi.getStatements(
        ocvId,
        accountNumber
      );
      return responseModel;
    } catch (Exception e) {
      AuraHandledException ahe = new AuraHandledException(e.getMessage());
      ahe.setMessage(e.getMessage());
      throw ahe;
    }
  }
  /**
   * @param ocvId required to make the callout to Mulesoft
   * @param accountNumber Account number for which we want to fetch the statements
   * @return StatementModel model class constructed from api response
   * @description fetches statements from fabric based on the account number, deserialized to a model
   */
  public StatementModel getStatements(String ocvId, String accountNumber) {
    StatementModel result;
    Service s = ServiceProvider.getService(FabricService.class);
    HttpCalloutResponse response = s.getStatements(ocvId, accountNumber);
    if (response.successful) {
      try {
        result = StatementModel.parse(response.body);
      } catch (Exception e) {
        handleErrors(null, e, StatementAPIRepository.class);
      }
    } else {
      handleErrors(response, null, StatementAPIRepository.class);
    }
    return result;
  }
  /**
   * @param ocvId required to make the callout to Mulesoft
   * @param statementId for which we want to fetch the statements Url
   * @return StatementModel model class constructed from api response
   * @description fetches statement Url from fabric based on the statement id, deserialized to a model
   */
  @AuraEnabled
  public static StatementModel getStatementUrlAura(
    String ocvId,
    String statementId
  ) {
    StatementAPIRepository statementapi = new StatementAPIRepository();
    try {
      StatementModel responseModel = statementapi.getStatements(
        ocvId,
        statementId
      );
      return responseModel;
    } catch (Exception e) {
      AuraHandledException ahe = new AuraHandledException(e.getMessage());
      ahe.setMessage(e.getMessage());
      throw ahe;
    }
  }
  /**
   * @param ocvId required to make the callout to Mulesoft
   * @param statementId for which we want to fetch the statements Url
   * @return StatementModel model class constructed from api response
   * @description fetches statement Url from fabric based on the statement id, deserialized to a model
   */
  public StatementModel getStatementUrl(String ocvId, String statementId) {
    StatementModel result;
    Service s = ServiceProvider.getService(FabricService.class);
    HttpCalloutResponse response = s.getStatements(ocvId, statementId);
    if (response.successful) {
      try {
        result = StatementModel.parse(response.body);
      } catch (Exception e) {
        handleErrors(null, e, StatementAPIRepository.class);
      }
    } else {
      handleErrors(response, null, StatementAPIRepository.class);
    }
    return result;
  }
  /**
   * @author Chiranjeeb
   * @since October 2021
   * @description invaid information exception
   */
  public class InvalidInformationException extends Exception {
  }
}

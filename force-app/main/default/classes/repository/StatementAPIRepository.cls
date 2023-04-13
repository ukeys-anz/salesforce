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
   * @param pageSize number of statement records to be returned from Fabric
   * @return String
   * @exception CalloutException
   */
  @AuraEnabled(cacheable=true)
  public static StatementModel getStatementsAura(
    String ocvId,
    String accountNumber,
    String pageSize
  ) {
    StatementAPIRepository statementapi = new StatementAPIRepository();
    try {
      StatementModel responseModel = statementapi.getStatements(
        ocvId,
        accountNumber,
        pageSize
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
   * @param pageSize number of statement records to be returned from Fabric
   * @return StatementModel model class constructed from api response
   * @description fetches statements from fabric based on the account number, deserialized to a model
   */
  public StatementModel getStatements(
    String ocvId,
    String accountNumber,
    String pageSize
  ) {
    StatementModel result;
    if (FeatureManagement.checkPermission('ANZx_View_Statements')) {
      Service s = ServiceProvider.getService(FabricService.class);
      HttpCalloutResponse response = s.getStatements(
        ocvId,
        accountNumber,
        pageSize
      );
      if (response.successful) {
        try {
          result = StatementModel.parse(response.body);
        } catch (Exception e) {
          handleErrors(null, e, StatementAPIRepository.class);
        }
      } else {
        handleErrors(response, null, StatementAPIRepository.class);
      }
    } else {
      handleErrors(
        null,
        new PermissionException(
          'User does not have the view statements permission.'
        ),
        StatementAPIRepository.class
      );
    }
    return result;
  }
  /**
   * @param ocvId required to make the callout to Mulesoft
   * @param statementId for which we want to fetch the statements Url
   * @param additionalDetails map which contains the additional params required to log for statement access
   * @return StatementModel model class constructed from api response
   * @description fetches statement Url from fabric based on the statement id, deserialized to a model
   */
  @AuraEnabled
  public static StatementModel getStatementUrlAura(
    String ocvId,
    String statementId,
    Map<String, String> additionalDetails
  ) {
    StatementAPIRepository statementapi = new StatementAPIRepository();
    try {
      StatementModel responseModel = statementapi.getStatementUrl(
        ocvId,
        statementId,
        additionalDetails
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
   * @param additionalDetails map which contains the additional params required to log for statement access
   * @return StatementModel model class constructed from api response
   * @description fetches statement Url from fabric based on the statement id, deserialized to a model also logs the access to statements into the application loggin big object
   */
  public StatementModel getStatementUrl(
    String ocvId,
    String statementId,
    Map<String, String> additionalDetails
  ) {
    StatementModel result;
    if (FeatureManagement.checkPermission('ANZx_View_Statements')) {
      Map<String, String> responseMap = new Map<String, String>();
      Service s = ServiceProvider.getService(FabricService.class);
      StatementAccessModel st = createStatementAccessModel(additionalDetails);
      HttpCalloutResponse response = s.getStatementUrl(ocvId, statementId);
      if (response.successful) {
        try {
          result = StatementModel.parse(response.body);
          responseMap.put('traceid', UniqueIdUtil.getTraceId());
          responseMap.put('sfUserId', userinfo.getUserId());
          responseMap.put('accountId', additionaldetails.get('accountId'));
          responseMap.put(
            'financialAccountId',
            additionaldetails.get('financialAccountId')
          );
          responseMap.put('fromDate', additionaldetails.get('fromDate'));
          responseMap.put('toDate', additionaldetails.get('toDate'));
          responseMap.put(
            'statementType',
            additionaldetails.get('statementType')
          );
          Logger.info('User viewed the Statement record')
            .setPayload(json.serialize(st));
          Logger.saveLog();
        } catch (Exception e) {
          handleErrors(null, e, StatementAPIRepository.class);
        }
      } else {
        handleErrors(response, null, StatementAPIRepository.class);
      }
    } else {
      handleErrors(
        null,
        new PermissionException(
          'User does not have the view statements permission.'
        ),
        StatementAPIRepository.class
      );
    }

    return result;
  }

  /**
   * @param additionalDetails map which contains the additional params required to log for statement access
   * @return StatementAccess model class constructed for logging framework
   * @description fetches statement model values in the form of addition details parameter and returns statement access model object
   */

  public static StatementAccessModel createStatementAccessModel(
    Map<String, String> additionalDetails
  ) {
    StatementAccessModel st = new StatementAccessModel();
    st.accountId = additionaldetails.get('accountId');
    st.financialAccountId = additionaldetails.get('financialAccountId');
    st.fromDate = additionaldetails.get('fromDate');
    st.toDate = additionaldetails.get('toDate');
    st.statementType = 'Home Loan';
    st.timeStamp = System.now();
    st.sUID = userinfo.getUserId();
    return st;
  }

  /**
   * @description insufficient permission exception
   */
  public class PermissionException extends Exception {
  }
}

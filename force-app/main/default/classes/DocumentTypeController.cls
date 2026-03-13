/**
 * @author Pradeep Gaikwad
 * @since February 2026
 * @description controller for getting document types
 * @group Controller
 */
public with sharing class DocumentTypeController {
  /**
   * @description  The getStatements is the method to make the Http callout to Mulesoft to fetch the statement details from Fabric against the account number.
   * {@link Lib_SystemLog.logAPIError} is called when ever the call fails to Fabric to have the logs recorded for monitoring.
   * @param ocvId required to make the callout to Mulesoft
   * @param accountNumber Account number for which we want to fetch the statements
   * @param pageSize number of statement records to be returned from Fabric
   * @param contextType which indicates whether the documents is of statements or notices type
   * @return ListDocumentModel model class constructed from api response
   * @exception CalloutException
   */
  @AuraEnabled(cacheable=true)
  public static ListDocumentModel getStatements(
    String ocvId,
    String accountNumber,
    String pageSize,
    String contextType
  ) {
    StatementAPIRepository statementapi = new StatementAPIRepository();
    try {
      ListDocumentModel responseModel = statementapi.getStatements(
        ocvId,
        accountNumber,
        pageSize,
        contextType
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
   * @param documentId for which we want to fetch the documents Url
   * @param additionalDetails map which contains the additional params required to log for statement access
   * @return DocumentSignedURLModel model class constructed from api response
   * @description fetches statement Url from fabric based on the statement id, deserialized to a model
   */
  @AuraEnabled
  public static DocumentSignedURLModel getStatementUrl(
    String ocvId,
    String documentId,
    Map<String, String> additionalDetails
  ) {
    StatementAPIRepository statementapi = new StatementAPIRepository();
    try {
      DocumentSignedURLModel responseModel = statementapi.getStatementUrl(
        ocvId,
        documentId,
        additionalDetails
      );
      return responseModel;
    } catch (Exception e) {
      AuraHandledException ahe = new AuraHandledException(e.getMessage());
      ahe.setMessage(e.getMessage());
      throw ahe;
    }
  }
}

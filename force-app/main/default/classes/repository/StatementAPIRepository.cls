/**
 * @author Chiranjeeb Dhar
 * @since October 2021
 * @description statement API repository for all statement related callouts
 * @group Repository
 */
public with sharing class StatementAPIRepository extends RepositoryBase {
  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );

  /**
   * @param ocvId required to make the callout to Mulesoft
   * @param accountNumber Account number for which we want to fetch the statements
   * @param pageSize number of statement records to be returned from Fabric
   * @param contextType which indicates whether the documents is of statements or notices type
   * @return ListDocumentModel model class constructed from api response
   * @description fetches statements from fabric based on the account number, deserialized to a model
   */
  public ListDocumentModel getStatements(
    String ocvId,
    String accountNumber,
    String pageSize,
    String contextType
  ) {
    ListDocumentModel result;
    if (USER_INFO.checkCustomPermission('ANZx_View_Statements')) {
      Service s = ServiceProvider.getService(FabricService.class);
      HttpCalloutResponse response = s.getStatements(
        ocvId,
        accountNumber,
        pageSize,
        contextType
      );
      if (response.successful) {
        try {
          result = ListDocumentModel.buildDocsFromResponse(response.body);
          return result;
        } catch (Exception e) {
          handleErrors(null, e, StatementAPIRepository.class);
        }
      }
      handleErrors(response, null, StatementAPIRepository.class);
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
   * @param documentId for which we want to fetch the documents Url
   * @param additionalDetails map which contains the additional params required to log for statement access
   * @return DocumentSignedURLModel model class constructed from api response
   * @description fetches statement Url from fabric based on the statement id, deserialized to a model also logs the access to statements into the application loggin big object
   */
  public DocumentSignedURLModel getStatementUrl(
    String ocvId,
    String documentId,
    Map<String, String> additionalDetails
  ) {
    DocumentSignedURLModel result;
    if (USER_INFO.checkCustomPermission('ANZx_View_Statements')) {
      Service s = ServiceProvider.getService(FabricService.class);
      StatementAccessModel st = createStatementAccessModel(additionalDetails);
      HttpCalloutResponse response = s.getStatementUrl(ocvId, documentId);
      if (response.successful) {
        try {
          result = DocumentSignedURLModel.parse(response.body);
          Logger.info('User viewed the Statement record')
            .setPayload(json.serialize(st));
          Logger.saveLog();
          return result;
        } catch (Exception e) {
          handleErrors(null, e, StatementAPIRepository.class);
        }
      }
      handleErrors(response, null, StatementAPIRepository.class);
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
    if (additionaldetails.get('contextType').equals('NOTICES')) {
      st.issueDate = additionaldetails.get('issueDate');
    } else {
      st.fromDate = additionaldetails.get('fromDate');
      st.toDate = additionaldetails.get('toDate');
    }
    st.documentType = additionaldetails.get('documentType');
    st.timeStamp = System.now();
    st.sUID = UserInfo.getUserId();
    return st;
  }

  /**
   * @description insufficient permission exception
   */
  public class PermissionException extends Exception {
  }
}

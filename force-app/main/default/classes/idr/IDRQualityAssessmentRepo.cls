/** @author CMOS
 * @since April 2026
 * @description Repo class for fetching Quality Assessments
 */
public class IDRQualityAssessmentRepo extends RepositoryBase {
  private static final IDRQAService QA_SERVICE = (IDRQAService) Lib_InstanceProvider.forType(
    IDRQAService.class
  );
  /**
   * @param modelObj QualityAssessmentRequestModel model
   * @return QualityAssessmentResponseModel model
   * @description for sending and recieving the callout response
   */
  public QualityAssessmentResponseModel getQualityAssessments(
    QualityAssessmentRequestModel modelObj
  ) {
    HttpCalloutResponse resp = QA_SERVICE.getQualityAssessments(modelObj);

    return handleResponse(resp);
  }

  /**
   * @param response HttpCalloutResponse model to be handled
   * @return QualityAssessmentResponseModel model
   * @description handle received response and either return the response or throw exception
   */
  public static QualityAssessmentResponseModel handleResponse(
    HttpCalloutResponse response
  ) {
    if (response.statusCode == 500) {
      throw new TimeoutException(response);
    }
    if (response.statusCode >= 400 && response.statusCode < 500) {
      throw new IntegrationIssueException(response);
    }
    if (response.successful == false) {
      throw new UnhandledException(response);
    }
    QualityAssessmentResponseModel responseModel = QualityAssessmentResponseModel.parse(
      response.body
    );
    if (
      responseModel.httpsStatusCode == 400 &&
      !responseModel
        ?.message.containsIgnoreCase(
          QualityAssessmentActions.EVALUATION_TYPE_DUPLICATE_ERROR
        )
    ) {
      Logger.error(
        'C&Q Ai Evaluation error - ' + '\n' + responseModel?.message
      );
      Logger.saveLog();
      throw new ErrorWhileQACreationException(responseModel?.message);
    }
    if (
      response.statusCode == 200 &&
      responseModel
        ?.message.containsIgnoreCase('No QA record found for this case')
    ) {
      Logger.error(
        'C&Q Ai Evaluation error - ' +
          '\n' +
          'No A.I. evaluation available. Enter a different Complaint ID to continue.'
      );
      Logger.saveLog();
    }
    return responseModel;
  }
  /**
   * @description custom exception
   */
  public class ErrorWhileQACreationException extends Exception {
  }
  /**
   * @description custom exception
   */
  public class IntegrationIssueException extends Exception {
    /**
     * @description IntegrationIssueException
     * @param response response
     */
    public IntegrationIssueException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.error(
          'HTTP ' + response.statusCode + ' Error from QA Service',
          response.error
        )
        .save();
    }
  }
  /**
   * @description custom exception
   */
  public class TimeoutException extends Exception {
    /**
     * @description TimeoutException
     * @param response response
     */
    public TimeoutException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.error(
          'HTTP ' + response.statusCode + ' Timeout QA Service',
          response.error
        )
        .save();
    }
  }
  /**
   * @description custom exception
   */
  public class UnhandledException extends Exception {
    /**
     * @description UnhandledException
     * @param response HttpCalloutResponse
     */
    public UnhandledException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.error(
          'HTTP ' +
            response.statusCode +
            ' Unhandled exception from QA Service',
          response.error
        )
        .save();
    }
  }
}

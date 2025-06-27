/**
 * @author Naman Garg
 * @since  Jan 2025
 * @description Commercial AMBIT Repository
 */

public with sharing class CommercialAMBITRepo extends RepositoryBase {
  private static final CommercialAMBITService AMBIT_SERVICE = (CommercialAMBITService) Lib_InstanceProvider.forType(
    CommercialAMBITService.class
  );
  /**
   * @description to get the callout response from AMBIT application endpoint
   * @param ambitModel CommercialAMBITRequestModel
   * @return Boolean response from callout
   */
  public Boolean getAMBITQuoteResponse(CommercialAMBITRequestModel ambitModel) {
    HttpCalloutResponse response = AMBIT_SERVICE.createAMBITQuote(ambitModel);
    return handleAMBITResponse(response);
  }

  /**
   * @description process the response received from callout
   * @param response Http Callout Response
   * @return Boolean True in quote creation successful else False
   */
  @testVisible
  private Boolean handleAMBITResponse(HttpCalloutResponse response) {
    if (response.statusCode == 500) {
      throw new ServerErrorException(response);
    }
    if (response.statusCode == 400) {
      throw new InsufficientAccessException(response);
    }
    if (response.successful == false) {
      throw new UnhandledException(response);
    }
    ResponseWrapper responseWrap = (ResponseWrapper) JSON.deserialize(
      response.body,
      ResponseWrapper.class
    );
    if (response.statusCode == 200 && responseWrap.data.isSuccessful == false) {
      throw new InvalidDataException(responseWrap);
    }
    return responseWrap.data.isSuccessful;
  }

  /**
   * @author Naman Garg
   * @since  May 2025
   * @description ServerErrorException
   */
  public class ServerErrorException extends Exception {
    /**
     * @description ServerErrorException
     * @param response HttpCalloutResponse
     */
    public ServerErrorException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.error(
          'HTTP ' +
            response.statusCode +
            ' Error from Commercial AMBIT Service',
          response.error
        )
        .save();
    }
  }

  /**
   * @author Naman Garg
   * @since  May 2025
   * @description InsufficientAccessException
   */
  public class InsufficientAccessException extends Exception {
    /**
     * @description InsufficientAccessException
     * @param response HttpCalloutResponse
     */
    public InsufficientAccessException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.error(
          'HTTP ' +
            response.statusCode +
            ' Insufficient access to Commercial AMBIT',
          response.error
        )
        .save();
    }
  }

  /**
   * @author Naman Garg
   * @since  May 2025
   * @description UnhandledException
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
            ' Unhandled exception from Commercial AMBIT',
          response.error
        )
        .save();
    }
  }

  /**
   * @author Naman Garg
   * @since  May 2025
   * @description InvalidDataException
   */
  public class InvalidDataException extends Exception {
    /**
     * @description InsufficientAccessException
     * @param responseWrap responseWrapper
     */
    public InvalidDataException(ResponseWrapper responseWrap) {
      this(responseWrap.errors[0].message);
      Logger.error(
          'HTTP ' +
            200 +
            'Errored occured due to invalid data from Commercial AMBIT Service' +
            responseWrap.errors[0].message
        )
        .save();
    }
  }

  /**
   * @author Naman Garg
   * @since  March 2025
   * @description Commercial AMBIT Response Wrapper
   */
  public class ResponseWrapper {
    public DataWrapper data;
    public list<Errors> errors;
  }

  /**
   * @author Naman Garg
   * @since  March 2025
   * @description Commercial AMBIT Data Wrapper
   */
  public class DataWrapper {
    public Boolean isSuccessful;
  }

  /**
   * @author Naman Garg
   * @since  May 2025
   * @description Commercial AMBIT Error
   */
  public class Errors {
    public String message;
  }
}

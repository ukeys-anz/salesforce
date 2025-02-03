/**
 * @author Shivam Swaraj
 * @since August 2024
 * @description fabric implementation of the API service
 * @group Services
 */
public with sharing virtual class VaultService extends Service {
  /**
   * @param ocvId ocvId of the customer to generate jwt token
   * @param cardNumberToBeDetokenizedRequest required to make the callout to Mulesoft
   * @return `HttpCalloutResponse` the api response
   * @description retrieves the tokenized card number details
   */
  public virtual HttpCalloutResponse getFullCardNumberDetails(
    String ocvId,
    DetokenizationRequestModel cardNumberToBeDetokenizedRequest
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);
    headers.put('x-correlation-id', CommonUtil.generateUUID());
    headers.put('Content-Type', 'application/json');
    Lib_HttpCallout calloutService = new Lib_HttpCallout(
      new Lib_HttpCalloutConfig().logResponseBody(false)
    );
    return calloutService.makeRestCallout(
      Label.MS_Get_Full_Card_Number,
      HTTP_METHOD.HTTP_GET,
      headers,
      JSON.serialize(cardNumberToBeDetokenizedRequest)
    );
  }

  /**
   * @description Tokenized Document Number
   * @param customerId customer Id
   * @param customerIdType customer Id type
   * @param tokenizeDocumentNumberRequest the detokenized document number to be tokenized
   * @return `HttpCalloutResponse` the api response
   */
  public virtual HttpCalloutResponse tokenizeDocumentNumber(
    String customerId,
    String customerIdType,
    TokenizeDocumentNumberRequestModel tokenizeDocumentNumberRequest
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    return calloutService.makeRestCallout(
      Label.MS_TokenizeDocumentNumber,
      HTTP_METHOD.HTTP_POST,
      getHeadersV1(customerId, customerIdType),
      JSON.serialize(tokenizeDocumentNumberRequest)
    );
  }

  /**
   * @description Detokenized Document Number
   * @param customerId customer Id
   * @param customerIdType customer Id type
   * @param detokenizeDocumentNumberRequest the tokenized document number to be detokenized
   * @return `HttpCalloutResponse` the api response
   */
  public virtual HttpCalloutResponse detokenizeDocumentNumber(
    String customerId,
    String customerIdType,
    DetokenizeDocumentNumberRequestModel detokenizeDocumentNumberRequest
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    return calloutService.makeRestCallout(
      Label.MS_DetokenizeDocumentNumber,
      HTTP_METHOD.HTTP_POST,
      getHeadersV1(customerId, customerIdType),
      JSON.serialize(detokenizeDocumentNumberRequest)
    );
  }

  /**
   * @description Construct headers for the callout
   * @param customerId customer Id
   * @param customerIdType customer Id type
   * @return `Map<String, String>` the headers
   */
  private Map<String, String> getHeadersV1(
    String customerId,
    String customerIdType
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(
      Service.IdType.valueOf(customerIdType),
      customerId,
      headers
    );
    headers.put('x-correlation-id', CommonUtil.generateUUID());
    headers.put('Content-Type', 'application/json');
    return headers;
  }
}

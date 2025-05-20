/**
 * @description Provides methods for dealing with public key credentials callouts
 * @author Tan Phan
 * @since 04/2025
 * @group Person Digital Entity
 */
public with sharing virtual class PDIService extends Service {
  private static final Lib_HttpCallout CALLOUT = (Lib_HttpCallout) Lib_InstanceProvider.forType(
    Lib_HttpCallout.class
  );

  /**
   * @description Makes a REST callout to retrieve public key credentials.
   * @param customerUuid The UUID of the customer.
   * @param filter The type of the public key credential to retrieve.
   * @return The HTTP callout response containing the public key credentials.
   */
  public virtual HttpCalloutResponse getPublicKeyCredentials(
    String customerUuid,
    String filter
  ) {
    return CALLOUT.makeRestCallout(
      Label.MS_PublicKeyCredentials,
      HTTP_METHOD.HTTP_POST,
      this.getHeaders(customerUuid),
      JSON.serialize(new Map<String, Object>{ 'filter' => filter ?? '' })
    );
  }

  /**
   * @description Makes a REST callout to delete the public key credential.
   * @param customerUuid The UUID of the customer.
   * @param name The ExternalId of the record.
   * @return The HTTP callout response for the outcome of the deletion.
   */
  public virtual HttpCalloutResponse deletePublicKeyCredential(
    String customerUuid,
    String name
  ) {
    return CALLOUT.makeRestCallout(
      Label.MS_PublicKeyCredentials,
      HTTP_METHOD.HTTP_DELETE,
      this.getHeaders(customerUuid),
      JSON.serialize(new Map<String, Object>{ 'name' => name })
    );
  }

  /**
   * @description Disconnects the customer's linked accounts for the given customer UUID and personaId.
   * @param personId The externalId/UUID of the PersonDigitalIdentity record.
   * @param personaId The unique identifier of the customer.
   * @return The HTTP callout response for disconnecting the customer's linked accounts.
   */
  public virtual HttpCalloutResponse disconnectCRN(
    String personId,
    String personaId
  ) {
    return CALLOUT.makeRestCallout(
      Label.MS_ANZConnect_DisconnectCRN,
      HTTP_METHOD.HTTP_POST,
      this.getHeaders(personId),
      JSON.serialize(
        new Map<String, Object>{
          'personId' => personId,
          'personaId' => personaId
        }
      )
    );
  }

  @TestVisible
  private Map<String, String> getHeaders(String customerUuid) {
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    staffModel.idType = Service.IdType.UUID;
    staffModel.idValue = customerUuid;
    staffModel.anzTokenType = 'staffRqfCustomer';

    Map<String, String> headers = super.setCalloutCommonHeaders(staffModel);
    headers.put('x-correlation-id', UUID.randomUUID().toString());
    headers.put('x-anz-application-id', 'salesforce');
    headers.put('traceparent', CommonUtil.generateTraceParent());
    headers.put('Content-Type', 'application/json');
    return headers;
  }
}

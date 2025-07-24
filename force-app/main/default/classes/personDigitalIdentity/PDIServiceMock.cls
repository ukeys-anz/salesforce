/**
 * @description Mock implementation of the PDIService class for testing purposes.
 * @author Tan Phan
 * @since 04/2025
 * @group Person Digital Entity
 */
public with sharing class PDIServiceMock extends PDIService {
  public virtual override HttpCalloutResponse getAccessControls(
    String customerUuid,
    String filter
  ) {
    super.response.statusCode = 200;
    super.response.successful = true;
    super.response.body = Service.getStaticResource(
      'mock_PdiAccessControlList'
    );
    return super.response;
  }

  public virtual override HttpCalloutResponse createAccessControl(
    String customerUuid,
    PDIApiModel.AccessControl accessControl
  ) {
    super.response.statusCode = 200;
    super.response.successful = true;
    super.response.body = Service.getStaticResource('mock_PdiAccessControl');
    return super.response;
  }

  public virtual override HttpCalloutResponse deleteAccessControl(
    String customerUuid,
    String name
  ) {
    super.response.statusCode = 200;
    super.response.successful = true;
    return super.response;
  }

  public virtual override HttpCalloutResponse getPublicKeyCredentials(
    String customerUuid,
    String keyType
  ) {
    super.response.statusCode = 200;
    super.response.successful = true;
    super.response.body = Service.getStaticResource(
      'mock_PublicKeyCredentials'
    );
    return super.response;
  }

  public virtual override HttpCalloutResponse deletePublicKeyCredential(
    String customerUuid,
    String name
  ) {
    super.response.statusCode = 200;
    super.response.successful = true;
    super.response.body = '{}';
    return super.response;
  }

  public virtual override HttpCalloutResponse disconnectCRN(
    String personId,
    String personaId
  ) {
    super.response.statusCode = 200;
    super.response.successful = true;
    super.response.body = '{}';
    return super.response;
  }
}

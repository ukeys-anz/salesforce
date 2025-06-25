/**
 * @description This class serves as a repository for handling API interactions
 *              related to public key credentials and other PDI services.
 * @author Tan Phan
 * @since 04/2025
 * @group Person Digital Entity
 */
public with sharing class PDIApiRepository extends RepositoryBase {
  private static final PDIService SERVICE = (PDIService) Lib_InstanceProvider.forType(
    PDIService.class
  );

  /**
   * @description Retrieves a list of access controls for the specified customer.
   * @param customerUuid The unique identifier of the customer.
   * @param filter The filter criteria for access controls.
   * @return A list of AccessControl objects matching the criteria.
   */
  public List<PDIApiModel.AccessControl> getAccessControls(
    String customerUuid,
    String filter
  ) {
    HttpCalloutResponse response = super.processResponse(
      SERVICE.getAccessControls(customerUuid, filter)
    );
    PDIApiModel.AccessControlResponse model = (PDIApiModel.AccessControlResponse) JSON.deserialize(
      response.body,
      PDIApiModel.AccessControlResponse.class
    );
    return model.accessControls;
  }

  /**
   * @description Creates a new access control for the specified customer.
   * @param customerUuid The unique identifier of the customer.
   * @param accessControl The access control object to be created.
   * @return The created AccessControl object.
   */
  public PDIApiModel.AccessControl createAccessControl(
    String customerUuid,
    PDIApiModel.AccessControl accessControl
  ) {
    HttpCalloutResponse response = super.processResponse(
      SERVICE.createAccessControl(customerUuid, accessControl)
    );
    return (PDIApiModel.AccessControl) JSON.deserialize(
      response.body,
      PDIApiModel.AccessControl.class
    );
  }

  /**
   * @description Deletes the access control for the given customer UUID and name.
   * @param customerUuid The unique identifier of the customer.
   * @param name The name of the access control to be deleted.
   */
  public void deleteAccessControl(String customerUuid, String name) {
    HttpCalloutResponse res = SERVICE.deleteAccessControl(customerUuid, name);
    if (res.statusCode == 404) {
      return;
    }
    super.processResponse(res);
  }

  /**
   * @description Retrieves the public key credentials for a given customer UUID and key type.
   * @param customerUuid The unique identifier of the customer.
   * @param filter The type of the key to retrieve.
   * @return A PublicKeyCredentialResponse object containing the public key credentials.
   */
  public List<PDIApiModel.PublicKeyCredential> getPublicKeyCredentials(
    String customerUuid,
    String filter
  ) {
    HttpCalloutResponse response = super.processResponse(
      SERVICE.getPublicKeyCredentials(customerUuid, filter)
    );
    PDIApiModel.PublicKeyCredentialResponse model = (PDIApiModel.PublicKeyCredentialResponse) JSON.deserialize(
      response.body,
      PDIApiModel.PublicKeyCredentialResponse.class
    );
    return model.publicKeyCredentials;
  }

  /**
   * @description Deletes the Public Key Credential for the given customer UUID and external Id.
   * @param customerUuid The unique identifier of the customer.
   * @param name The externalId to be deleted.
   */
  public void deletePublicKeyCredential(String customerUuid, String name) {
    super.processResponse(
      SERVICE.deletePublicKeyCredential(customerUuid, name)
    );
  }

  /**
   * @description Disconnects the customer's linked accounts for the given customer UUID and personaId.
   * @param personId The externalId/UUID of the PersonDigitalIdentity record.
   * @param personaId The unique identifier of the customer.
   */
  public void disconnectCRN(String personId, String personaId) {
    super.processResponse(SERVICE.disconnectCRN(personId, personaId));
  }
}

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

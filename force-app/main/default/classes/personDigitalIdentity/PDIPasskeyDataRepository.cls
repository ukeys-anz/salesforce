/**
 * @description This class is responsible for querying and mapping passkey data
 *              from the PDIApiRepository to the required format.
 * @author Tan Phan
 * @since 04/2025
 * @group Person Digital Entity
 */
public with sharing class PDIPasskeyDataRepository extends PDIDataConnection.DataRepositoryBase {
  private static final PDIApiRepository REPO = (PDIApiRepository) Lib_InstanceProvider.forType(
    PDIApiRepository.class
  );

  @TestVisible
  protected override List<CalloutModel> doQuery(
    DataSource.QueryContext context
  ) {
    return REPO.getPublicKeyCredentials(
      PDIHelper.getCustomerUuid(context.tableSelection.filter),
      'type=TYPE_WEB_AUTHN'
    );
  }

  @TestVisible
  protected override Map<String, Object> transform(CalloutModel apiRecord) {
    if ((apiRecord instanceof PDIApiModel.PublicKeyCredential) == false) {
      return null;
    }
    PDIApiModel.PublicKeyCredential record = (PDIApiModel.PublicKeyCredential) apiRecord;
    String aaguid = record.authenticatorMetadata
      ?.webAuthnAuthenticatorMetadata
      ?.aaguid;
    if (aaguid == null) {
      return null;
    }
    return new Map<String, Object>{
      'ExternalId' => record.name,
      'PersonId' => record.personId,
      'AAGUID' => aaguid,
      'CreatedTime' => record.createTime,
      'LastAuthenticationTime' => record.lastAuthenticationTime
    };
  }

  @TestVisible
  protected override void doDelete(String externalId) {
    String customerUuid = PDIHelper.parseResourcePath(externalId, 'person');
    REPO.deletePublicKeyCredential(customerUuid, externalId);
  }
}

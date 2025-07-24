/**
 * @description Test class for {@link PDIPasskeyDataRepository}.
 * @author Tan Phan
 * @since 04/2025
 * @group Person Digital Entity
 */
@IsTest
private class PDIPasskeyDataRepositoryTest {
  static PDIPasskeyDataRepository repo = new PDIPasskeyDataRepository();

  @IsTest
  static void testDoQuery() {
    DataSource.Filter filter = new DataSource.Filter();
    DataSource.Filter subFilter = new DataSource.Filter();
    subFilter.columnName = 'PersonId';
    subFilter.columnValue = '12345-abcde-67890';
    filter.subfilters = new List<DataSource.Filter>{ subFilter };
    DataSource.TableSelection tableSelection = new DataSource.TableSelection();
    tableSelection.filter = filter;
    DataSource.QueryContext context = new DataSource.QueryContext();
    context.tableSelection = tableSelection;

    Lib_MockProvider mockRepo = Lib_MockProvider.forType(PDIApiRepository.class)
      .mock(
        'getPublicKeyCredentials',
        new List<PDIApiModel.PublicKeyCredential>{ credential }
      );

    Test.startTest();
    repo.doQuery(context);
    Test.stopTest();

    String inputUuid = (String) mockRepo.getHistory('getPublicKeyCredentials')
      ?.getParam('customerUuid');
    Assert.areEqual(
      filter.columnValue,
      inputUuid,
      'Should pass the correct customerUuid to the callout'
    );
  }

  @IsTest
  static void testTransformValidPublicKeyCredential() {
    Test.startTest();
    Map<String, Object> result = repo.transform(credential);
    Test.stopTest();

    Assert.isNotNull(result, 'Should return a non-null result');
    Assert.areEqual(
      'test-aaguid',
      result.get('AAGUID'),
      'Should return the correct AAGUID'
    );
  }

  @IsTest
  static void testTransformNullWebAuthenticatorMetadata() {
    credential.authenticatorMetadata.webAuthnAuthenticatorMetadata = null;

    Test.startTest();
    Map<String, Object> result = repo.transform(credential);
    Test.stopTest();

    Assert.isNull(
      result,
      'Should return null for null silent device authenticator metadata'
    );
  }

  @IsTest
  static void testTransformInvalidCalloutModel() {
    InvalidModel invalidModel = new InvalidModel();

    Test.startTest();
    Map<String, Object> result = repo.transform(invalidModel);
    Test.stopTest();

    Assert.isNull(result, 'Should return null for invalid CalloutModel type');
  }

  static PDIApiModel.PublicKeyCredential credential {
    get {
      if (credential != null) {
        return credential;
      }
      credential = new PDIApiModel.PublicKeyCredential();
      credential.name = 'test-mockDevice-name';
      credential.personId = 'test-person-id';
      credential.state = 'ACTIVE';
      credential.createTime = credential.lastAuthenticationTime = credential.updateTime = Datetime.now();

      credential.authenticatorMetadata = new PDIApiModel.AuthenticatorMetadata();
      credential.authenticatorMetadata.webAuthnAuthenticatorMetadata = new PDIApiModel.WebAuthnAuthenticatorMetadata();
      credential.authenticatorMetadata.webAuthnAuthenticatorMetadata.aaguid = 'test-aaguid';
      return credential;
    }
    set;
  }

  class InvalidModel extends CalloutModel {
  }
}

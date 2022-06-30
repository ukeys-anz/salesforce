/**
 *
 * @author Lance Shi
 * @since 2020
 * @description ANZAzureADAuthProviderTest is the test class to cover tests for {@link ANZAzureADAuthProvider}
 */
@isTest
public class ANZAzureADAuthProviderTest {
  public static final String AUTH_URL = 'https://login.microsoftonline.com/7f0788f7-3634-419b-bf74-bbe48147830c/oauth2/v2.0/authorize';
  public static final String REDIRECT_URL = 'https://anz--ssopoc.my.salesforce.com/services/authcallback/Azure_AD_Custom_Test_OIDC';
  public static final String USER_ENDPOINT = 'https://graph.microsoft.com/v1.0/me';

  private static final String ID_TOKEN = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6IlBlM1h1eVFHQXFzNEcxVU9qMUhaT1EyQmhEayJ9.eyJhdWQiOiJkZmI4MmI4OC1mMWFmLTQ5MzQtYmNmZC04YWFhMzUxNGRmY2YiLCJpc3MiOiJodHRwczovL2xvZ2luLm1pY3Jvc29mdG9ubGluZS5jb20vN2YwNzg4ZjctMzYzNC00MTliLWJmNzQtYmJlNDgxNDc4MzBjL3YyLjAiLCJpYXQiOjE2MDIyNDA3MTEsIm5iZiI6MTYwMjI0MDcxMSwiZXhwIjoxNjAyMjQ0NjExLCJhY2N0IjowLCJhaW8iOiJFMlJnWUhEZ1QrL2c1L2J6dlhaL3o0TzkyajRuSnZySy8rMmJ2Q3NxT3ExcDNxYkcyQzRBIiwiYXV0aF90aW1lIjoxNjAxODczOTExLCJlbWFpbCI6IllhbmcuU2hpQGFuem5wLmNvbSIsImdyb3VwcyI6WyJBVSBBTlp4IENSTSJdLCJuYW1lIjoiWWFuZyBTaGkiLCJvaWQiOiJjMTk5MjYxOS1mNzZjLTQ1ZGUtODIyZi0wNGU4NjAxMDFkYTkiLCJwbGF0ZiI6IjUiLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJZYW5nLlNoaUBhbnpucC5jb20iLCJyaCI6IjAuQUFBQTk0Z0hmelEybTBHX2RMdmtnVWVERElncnVOLXY4VFJKdlAyS3FqVVUzODhsQUg0LiIsInN1YiI6IkdwQTJCdEhRc0ZoYVlZTGNEbWxEMEljaTVjUVByV2tzNkVVT1VfRzlIZW8iLCJ0aWQiOiI3ZjA3ODhmNy0zNjM0LTQxOWItYmY3NC1iYmU0ODE0NzgzMGMiLCJ1cG4iOiJZYW5nLlNoaUBhbnpucC5jb20iLCJ1dGkiOiJDaG04NzcwcnIwNkpka0JMcnQtYUFBIiwidmVyIjoiMi4wIiwid2lkcyI6WyJiNzlmYmY0ZC0zZWY5LTQ2ODktODE0My03NmIxOTRlODU1MDkiXSwic2FtQWNjb3VudE5hbWUiOiJzaGl5MiJ9.C4dOoIx9DAYNNIC17iipcRyVfadvlVAQBH8NmT4SOSD6P_DUsTKUZ0582ynZRKcsCK6m_NsjyrzreCf86GvutUGkS5jIYa2goa6tbJfzI3S3TL4lXCUhlD_y2irSxZykj0VB_sS6JiMeGZr0RzdXfwDQmKvqrf2VjOjJcbx-JnNf4ekL3c0A-Fb39KFXjPMr6SsfiD1dPT-yMHDGBcMHO_kJuOEINRcirFP5RJFWi_5AlRmHSHgZVp2NeQu7qXRwMCXBPZuuTFmoMoz_HDYbGudscnygG5ER72d6UtQWXyVIw2UmY0sZZU5Be3vIddbeny1_dYriuCD3SQREmwMgJg';
  /**
   * @description setupAuthProviderConfig is to setup auth provider map for each test method to use
   * @return `Map<String,String>`
   */
  private static Map<String, String> setupAuthProviderConfig() {
    final Map<String, String> authProviderConfiguration = new Map<String, String>();
    authProviderConfiguration.put(
      ANZAzureADAuthProvider.FIELD_REDIRECT_URL,
      REDIRECT_URL
    );
    authProviderConfiguration.put(
      ANZAzureADAuthProvider.FIELD_AUTH_URL,
      AUTH_URL
    );
    authProviderConfiguration.put(
      ANZAzureADAuthProvider.FIELD_USER_ENDPOINT,
      USER_ENDPOINT
    );
    authProviderConfiguration.put(ANZAzureADAuthProvider.FIELD_CID, 'Test cid');

    return authProviderConfiguration;
  }

  /**
   * @description testMetadataType is test metadata type method returns correct information
   */
  @isTest
  public static void testMetadataType() {
    final ANZAzureADAuthProvider provider = new ANZAzureADAuthProvider();
    final String actual = provider.getCustomMetadataType();
    System.assertEquals(
      'AzureAD_Identity__mdt',
      actual,
      'Provider type should be AzureAD_Identity'
    );
  }

  /**
   * @description testInitiateMethod is test initiate method initiates correctly
   */
  @isTest
  public static void testInitiateMethod() {
    final Map<String, String> authProviderConfiguration = setupAuthProviderConfig();
    final ANZAzureADAuthProvider provider = new ANZAzureADAuthProvider();

    final PageReference actualUrl = provider.initiate(
      authProviderConfiguration,
      'testState'
    );
    final PageReference expectedUrl = new PageReference(
      authProviderConfiguration.get(ANZAzureADAuthProvider.FIELD_AUTH_URL)
    );
    expectedUrl.getParameters().put('state', 'testState');

    System.assertEquals(
      expectedUrl.getParameters().get('state'),
      actualUrl.getParameters().get('state'),
      'State of actual URL should be as expected.'
    );
  }

  /**
   * @description testHandleCallback is test callback functionality is handled correctly
   */
  @isTest
  public static void testHandleCallback() {
    final Map<String, String> authProviderConfiguration = setupAuthProviderConfig();
    final ANZAzureADAuthProvider provider = new ANZAzureADAuthProvider();

    final Map<String, String> queryParams = new Map<String, String>();
    queryParams.put('code', 'code');
    queryParams.put('state', 'mocktestState');

    final Auth.AuthProviderCallbackState cbState = new Auth.AuthProviderCallbackState(
      null,
      null,
      queryParams
    );
    final Auth.AuthProviderTokenResponse actualAuthProvResponse = provider.handleCallback(
      authProviderConfiguration,
      cbState
    );

    final Auth.AuthProviderTokenResponse expectedAuthProvResponse = new Auth.AuthProviderTokenResponse(
      'Open Id Connect',
      'testaccesstoken',
      'samplerefreshtoken',
      'mocktestState'
    );

    System.assertEquals(
      expectedAuthProvResponse.provider,
      actualAuthProvResponse.provider,
      'Auth provider should be as expected.'
    );
    System.assertEquals(
      expectedAuthProvResponse.oauthToken,
      actualAuthProvResponse.oauthToken,
      'Auth provider oauthToken should be as expected.'
    );
    System.assertEquals(
      expectedAuthProvResponse.oauthSecretOrRefreshToken,
      actualAuthProvResponse.oauthSecretOrRefreshToken,
      'Auth provider refresh token should be as expected.'
    );
    System.assertEquals(
      expectedAuthProvResponse.state,
      actualAuthProvResponse.state,
      'Auth provider state should be as expected.'
    );
  }

  /**
   * @description testGetUserInfo is to test Get user functionality works as expected
   */
  @isTest
  public static void testGetUserInfo() {
    final Auth.AuthProviderTokenResponse provResponse = new Auth.AuthProviderTokenResponse(
      'Open Id Connect',
      'testaccesstoken',
      'samplerefreshtoken',
      'mocktestState'
    );
    final Map<String, String> authProviderConfiguration = setupAuthProviderConfig();
    final ANZAzureADAuthProvider provider = new ANZAzureADAuthProvider();

    provider.idToken = ID_TOKEN;

    final Auth.UserData actualData = provider.getUserInfo(
      authProviderConfiguration,
      provResponse
    );
    Map<String, String> provMap = new Map<String, String>();
    provMap.put('accessToken', 'testaccesstoken');
    provMap.put('email', 'TestUser@example.com');
    final Auth.UserData expectedData = new Auth.UserData(
      'Yang.Shi@anznp.com',
      null,
      null,
      null,
      null,
      null,
      'Yang.Shi@anznp.com',
      null,
      'AzurePOCCustom',
      null,
      provMap
    );
    System.assertEquals(
      expectedData.email,
      actualData.email,
      'Actual data email should be as expected.'
    );
  }
}

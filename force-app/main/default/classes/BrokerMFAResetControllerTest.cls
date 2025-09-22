@isTest
public class BrokerMFAResetControllerTest {
  private static final Lib_MockProvider MFA_API_REPO_MOCK = Lib_MockProvider.forType(
    MFAResetAPIRepository.class
  );
  private static final Lib_MockProvider CONTACT_REPO_MOCK = Lib_MockProvider.forType(
    RetailContactRepository.class
  );
  // a mock Id token, with an expiry date of year 2144
  private static final String MOCK_STAFF_ID_TOKEN = 'eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjU1MTYyMzkwMjJ9.ZToMCYwQa9w6CrediExCJNBoSrtVSVkccfR-u1rmJ50';

  @isTest
  private static void testDoMFAResetActionSuccess() {
    // set a mock staff Id token
    Id currentUserId = new UserInfoRepository().getUser().Id;
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + currentUserId,
      MOCK_STAFF_ID_TOKEN,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
    // setup rest of the mocks
    final Contact mockBrokerContact = new Contact(
      Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType),
      Email = 'abc@anz.test.com',
      OCV_ID__c = '123'
    );
    CONTACT_REPO_MOCK.mock('getBrokerDetail', mockBrokerContact);
    MFA_API_REPO_MOCK.mock('getElevatedToken', 'test-elevated-token-123');
    MFA_API_REPO_MOCK.mock('resetMFA', true);

    Test.startTest();
    Boolean result = BrokerMFAResetController.doMFAResetAction(
      mockBrokerContact.Id.toString()
    );
    Test.stopTest();

    Assert.isTrue(result, 'Should return "true" when MFA reset is successful');
  }

  @isTest
  private static void testDoMFAResetActionFailBrokerEmailMissing() {
    // keep email empty on mocked broker contact
    final Contact mockBrokerContact = new Contact(
      Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType),
      OCV_ID__c = '123'
    );
    CONTACT_REPO_MOCK.mock('getBrokerDetail', mockBrokerContact);

    try {
      Test.startTest();
      BrokerMFAResetController.doMFAResetAction(
        mockBrokerContact.Id.toString()
      );
      Test.stopTest();

      Assert.fail('Expected an exception when broker email is missing.');
    } catch (Exception e) {
      Assert.isTrue(
        e instanceof AuraHandledException,
        'Exception is not of type "AuraHandledException"'
      );
      Assert.isNotNull(
        e.getCause(),
        'Missing source exception for when Broker email is empty.'
      );
      Assert.areEqual(
        e.getCause().getMessage(),
        'Couldn\'t read broker email address. Broker Id: ' +
        mockBrokerContact.Id,
        'Exception message for empty broker email did not match.'
      );
    }
  }

  @isTest
  private static void testDoMFAResetActionFailBlankStaffToken() {
    final Contact mockBrokerContact = new Contact(
      Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType),
      Email = 'abc@anz.test.com',
      OCV_ID__c = '123'
    );
    CONTACT_REPO_MOCK.mock('getBrokerDetail', mockBrokerContact);

    // set a blank staff Id token in Cache
    Id currentUserId = new UserInfoRepository().getUser().Id;
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + currentUserId,
      '',
      300,
      Cache.Visibility.NAMESPACE,
      false
    );

    try {
      Test.startTest();
      BrokerMFAResetController.doMFAResetAction(
        mockBrokerContact.Id.toString()
      );
      Test.stopTest();

      Assert.fail('Expected an exception when staff Id token is blank.');
    } catch (Exception e) {
      Assert.isTrue(
        e instanceof AuraHandledException,
        'Exception is not of type "AuraHandledException"'
      );
      Assert.isNotNull(
        e.getCause(),
        'Missing source exception for when Staff token is empty'
      );
      Assert.isTrue(
        e.getCause() instanceof AuthTokenCacheUtil.TokenCacheException,
        'Source exception should be of type "TokenCacheException" when token is blank.'
      );
      Assert.areEqual(
        'Invalid format when checking token validity',
        e.getCause().getMessage(),
        'Token exception message did not match.'
      );
    }
  }
}

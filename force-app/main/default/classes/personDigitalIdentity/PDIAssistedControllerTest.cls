/**
 * @author Karen Valeriano
 * @since 05/2025
 * @description controller class for PDIAssistedController lwc components
 */
@isTest
private class PDIAssistedControllerTest {
  static Lib_MockProvider repoMock;
  static String personId = UUID.randomUUID().toString();
  static String personaId = UUID.randomUUID().toString();

  static void registerMock() {
    repoMock = Lib_MockProvider.forType(PDIApiRepository.class);
  }

  @isTest
  static void testDisconnectANZAccountsSuccess() {
    registerMock();
    repoMock.mock('disconnectCRN', null);

    Test.startTest();
    PDIAssistedController.disconnectANZAccounts(personId, personaId);
    Test.stopTest();

    Assert.areEqual(
      personId,
      repoMock.getHistory('disconnectCRN').getParam('personId'),
      'Correct personId should be passed.'
    );
    Assert.areEqual(
      personaId,
      repoMock.getHistory('disconnectCRN').getParam('personaId'),
      'Correct personaId should be passed.'
    );
  }

  @isTest
  static void testDisconnectANZAccountsFailed() {
    registerMock();
    repoMock.mockException('disconnectCRN');

    try {
      Test.startTest();
      PDIAssistedController.disconnectANZAccounts(personId, personaId);
      Test.stopTest();
      Assert.fail('Exception should have been thrown');
    } catch (Exception ex) {
      Assert.isInstanceOfType(
        ex,
        AuraHandledException.class,
        'AuraHandledException should have been thrown'
      );
    }
  }
}

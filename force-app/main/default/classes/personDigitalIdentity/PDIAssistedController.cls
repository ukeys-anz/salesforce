/**
 * @description Controller class for PersonDigitalIdentity's lwc components
 * @author Karen Valeriano
 * @since 05/2025
 * @group Person Digital Entity
 */
public with sharing class PDIAssistedController {
  private static final PDIApiRepository REPO = (PDIApiRepository) Lib_InstanceProvider.forType(
    PDIApiRepository.class
  );
  private static final String MSG_ERROR_GENERIC_ANZ_DISCONNECT = 'Error occurred while disconnecting the customer\'s linked account.';

  /**
   * @description method invoked in quickActions lwc.
   * @param personId The externalId/UUID of the PersonDigitalIdentity record.
   * @param personaId The unique identifier of the customer.
   */
  @AuraEnabled
  public static void disconnectANZAccounts(String personId, String personaId) {
    try {
      Logger.debug('Disconnecting ANZ Accounts started');
      REPO.disconnectCRN(personId, personaId);
    } catch (Exception ex) {
      throw new AuraHandledException(MSG_ERROR_GENERIC_ANZ_DISCONNECT);
    } finally {
      Logger.debug('Disconnecting ANZ Accounts finished').save();
    }
  }
}

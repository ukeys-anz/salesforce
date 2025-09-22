/**
 * @description Controller class for managing Multi-Factor Authentication (MFA) reset actions for brokers.
 *
 * @created      2025-08-30 Manish Bisht
 * @lastModified 2025-08-30 Manish Bisht
 */
public with sharing class BrokerMFAResetController {
  private static final MFAResetAPIRepository MFA_RESET_API = (MFAResetAPIRepository) Lib_InstanceProvider.forType(
    MFAResetAPIRepository.class
  );
  private static final RetailContactRepository CONTACT_REPO = (RetailContactRepository) Lib_InstanceProvider.forType(
    RetailContactRepository.class
  );

  /**
   * @description Resets the Multi-Factor Authentication for a broker identified by the provided contact ID.
   * @param brokerContactId The ID of the broker contact whose MFA needs to be reset.
   * @return Boolean indicating the success of the MFA reset operation.
   * @throws  AuraHandledException if there's any unexpected failure
   */
  @AuraEnabled
  public static Boolean doMFAResetAction(Id brokerContactId) {
    Boolean isResetSuccess = false;
    try {
      Logger.info('Starting MFA Reset for Broker Id: ' + brokerContactId)
        .setRecord(brokerContactId)
        .save();
      Contact broker = CONTACT_REPO.getBrokerDetail(brokerContactId);
      if (broker == null || String.isBlank(broker.Email)) {
        throw new HandledException(
          'Couldn\'t read broker email address. Broker Id: ' + brokerContactId
        );
      }
      final String staffIdToken = AuthTokenCacheUtil.getSessionIdToken();
      final String elevatedToken = MFA_RESET_API.getElevatedToken(
        broker.Email,
        staffIdToken
      );
      isResetSuccess = MFA_RESET_API.resetMFA(elevatedToken);
      return isResetSuccess;
    } catch (Exception e) {
      Logger.info(e.getMessage(), e).save();
      Exception auraException = new AuraHandledException(
        Label.Forge_MFA_Reset_Error_Message
      );
      auraException.initCause(e);
      throw auraException;
    } finally {
      Logger.info(
          String.format(
            '{0} MFA Reset for Broker Id: {1}',
            new List<Object>{
              isResetSuccess ? 'Successful' : 'Failed',
              brokerContactId
            }
          )
        )
        .setRecord(brokerContactId)
        .save();
    }
  }
}

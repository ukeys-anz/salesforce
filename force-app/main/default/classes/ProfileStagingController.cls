/**
 * @description controller class for profileStaging lwc component
 * @author Karen Valeriano
 * @since 10/2024
 */
public with sharing class ProfileStagingController {
  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final ProfileStagingHandler HANDLER = (ProfileStagingHandler) Lib_InstanceProvider.forType(
    ProfileStagingHandler.class
  );

  private static final String MSG_ERROR_GENERIC_RETRY = 'Error occurred while retrying the Profile Staging record.';

  /**
   * @description method invoked in profileStagingRetry lwc.
   * @param recordId The Profile Staging recordId to update.
   */
  @AuraEnabled
  public static void profileStagingRetry(Id recordId) {
    try {
      Logger.debug('Profile Staging Retry started');

      Customer_Profile_Updates__c record = new Customer_Profile_Updates__c(
        Id = recordId,
        Status__c = 'Pending',
        Error_Description__c = null
      );
      DML.doUpdate(record, new DmlConfig().withoutSharing());
      HANDLER.publishEvents(new Set<Id>{ recordId });

      Logger.debug('Profile Staging Retry is successful');
    } catch (Exception ex) {
      Logger.error(MSG_ERROR_GENERIC_RETRY, ex);
      throw new AuraHandledException(MSG_ERROR_GENERIC_RETRY);
    } finally {
      Logger.debug('Profile Staging Retry finished').save();
    }
  }
}

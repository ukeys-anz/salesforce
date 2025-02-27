/**
 * @description controller class for profileStaging lwc component
 * @author Karen Valeriano
 * @since 10/2024
 */
public with sharing class ProfileStagingController {
  private static final ProfileStagingRepository QUERY = (ProfileStagingRepository) Lib_InstanceProvider.forType(
    ProfileStagingRepository.class
  );
  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final ProfileStagingHandler HANDLER = (ProfileStagingHandler) Lib_InstanceProvider.forType(
    ProfileStagingHandler.class
  );

  private static final String MSG_ERROR_GENERIC_RETRY = 'Error occurred while re-triggering the request.';

  /**
   * @description method invoked in profileStagingRetry lwc.
   * @param recordId The Profile Staging recordId to update.
   */
  @AuraEnabled
  public static void profileStagingRetry(Id recordId) {
    try {
      Logger.debug('Profile Staging Retry started');
      Set<Id> recordIds = new Set<Id>{ recordId };
      List<Customer_Profile_Updates__c> records = QUERY.queryCustomerProfileUpdates(
        recordIds
      );
      validate(records);
      Customer_Profile_Updates__c record = new Customer_Profile_Updates__c(
        Id = recordId,
        Status__c = 'Pending',
        Error_Description__c = null
      );
      DML.doUpdate(record, new DmlConfig().withoutSharing());
      HANDLER.publishEvents(recordIds);

      Logger.debug('Profile Staging Retry is successful');
    } catch (ValidationException ex) {
      throw new AuraHandledException(ex.getMessage());
    } catch (Exception ex) {
      Logger.error(MSG_ERROR_GENERIC_RETRY, ex);
      throw new AuraHandledException(MSG_ERROR_GENERIC_RETRY);
    } finally {
      Logger.debug('Profile Staging Retry finished').save();
    }
  }

  /**
   * @description Validates a list of Customer_Profile_Updates__c records.
   * Checks each record for a specific error description and throws a ValidationException if found.
   * @param records List of Customer_Profile_Updates__c records to be validated.
   * @throws ValidationException if a record contains the specified error description.
   */
  private static void validate(List<Customer_Profile_Updates__c> records) {
    for (Customer_Profile_Updates__c record : records) {
      if (
        record.Error_Description__c.contains(
          'applied successfully, but error in retrieving the sequence number of the restraints in CAP'
        )
      ) {
        throw new ValidationException(
          'Retry not allowed on successfully placed restraints'
        );
      }
    }
  }

  private class ValidationException extends Exception {
  }
}

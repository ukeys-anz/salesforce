/**
 * @description controller class for kycqaCompleteChecksAsYes lwc component
 * @author Karen Valeriano
 * @since 10/2024
 */
public with sharing class AutoKYCQACaseController {
  private static final AutoKYCQACaseRepository REPOSITORY = (AutoKYCQACaseRepository) Lib_InstanceProvider.forType(
    AutoKYCQACaseRepository.class
  );
  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final String MSG_SUCCESS_CHECKS_COMPLETION = 'All the KYC QA checks are completed successfully.';
  private static final String MSG_ERROR_CHECKS_ALREADY_COMPLETED = 'All the KYC QA checks have already been completed. No changes were made.';
  private static final String MSG_ERROR_GENERIC_CHECK_COMPLETION = 'Error performing the completion. Please contact your System Administrator.';

  /**
   * @description Define custom exceptions
   */
  private class CompletionChecksException extends Exception {
  }

  /**
   * @description method invoked in lwc.
   * @param recordId The KYC QA Case records to update.
   */
  @AuraEnabled
  public static void completeChecksAsYes(Id recordId) {
    try {
      Logger.debug('Check completion started');

      List<Case> cases = REPOSITORY.queryKYCQAChecksByIds(
        new Set<Id>{ recordId }
      );
      if (AutoKYCQACaseActions.hasKycCheckCompleted(cases[0])) {
        throw new CompletionChecksException(MSG_ERROR_CHECKS_ALREADY_COMPLETED);
      }
      ListUtil.setFieldIfNull(cases, AutoKYCQACaseActions.TEST_FIELDS, 'Yes');
      DML.doUpdate(cases);

      Logger.debug(MSG_SUCCESS_CHECKS_COMPLETION);
    } catch (CompletionChecksException ex) {
      Logger.debug(ex.getMessage());
      throw new AuraHandledException(ex.getMessage());
    } catch (DmlException ex) {
      throw new AuraHandledException(MSG_ERROR_GENERIC_CHECK_COMPLETION);
    } catch (Exception ex) {
      Logger.error(MSG_ERROR_GENERIC_CHECK_COMPLETION, ex);
      throw new AuraHandledException(MSG_ERROR_GENERIC_CHECK_COMPLETION);
    } finally {
      Logger.debug('Check completion finished').save();
    }
  }
}

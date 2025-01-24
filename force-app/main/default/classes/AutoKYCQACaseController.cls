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
  private static final String MSG_ERROR_GENERIC_CHECK_COMPLETION = 'Error performing the KYC QA checks completion. Please contact your System Administrator.';

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
      ListUtil.setFieldIfNull(cases, AutoKYCQACaseActions.TEST_FIELDS, 'Yes');
      DML.doUpdate(cases);

      Logger.debug(MSG_SUCCESS_CHECKS_COMPLETION);
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

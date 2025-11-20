/**
 * @author       : Kritika Sharma
 * @since        : 10-11-2025
 * @description  : Leads enhancement - Automation - populate selected commercial contact on Lead
 **/
public with sharing class LeadEnhmentUpdateCommContactController {
  private static final LeadCommContactRepository REPOSITORY = (LeadCommContactRepository) Lib_InstanceProvider.forType(
    LeadCommContactRepository.class
  );

  /**
   * @description Fetches the list of related Individual Accounts (Person Accounts) for a given Customer Account.
   * @param accountId The ID of the Organization or CLG Account (Existing Customer on Lead).
   * @return List of getRelatedIndividualAccounts.
   */
  @AuraEnabled(cacheable=true)
  public static List<FinServ__AccountAccountRelation__c> getIndividualCustomerRecord(
    Id accountId
  ) {
    try {
      return REPOSITORY.getRelatedIndividualAccounts(accountId);
    } catch (Exception e) {
      Logger.error(
        'Failure on LeadEnhmentUpdateCommContactController.getIndividualCustomerRecord',
        e
      );
      Logger.saveLog();
      throw new AuraHandledException(e.getMessage());
    }
  }
}

/**
 * @author       : Kritika Sharma
 * @since        : 10-11-2025
 * @description  : Handles all data access operations related to Lead Commercial Contacts (Person Accounts).
 */
public with sharing class LeadCommContactRepository {
  /**
   * @description Retrieves the list of related Account IDs (Person Accounts) linked to the Customer Account.
   * @param customerAccountId The ID of the Organization or CLG Account.
   * @return List of FinServ__AccountAccountRelation__c records containing the related Account details.
   */
  public List<FinServ__AccountAccountRelation__c> getRelatedIndividualAccounts(
    Id customerAccountId
  ) {
    if (customerAccountId == null) {
      return new List<FinServ__AccountAccountRelation__c>();
    }
    return [
      SELECT
        FinServ__RelatedAccount__r.Id,
        FinServ__RelatedAccount__r.Name,
        FinServ__RelatedAccount__r.Salutation,
        FinServ__RelatedAccount__r.FirstName,
        FinServ__RelatedAccount__r.MiddleName,
        FinServ__RelatedAccount__r.LastName,
        FinServ__RelatedAccount__r.Phone,
        FinServ__RelatedAccount__r.PersonMobilePhone,
        FinServ__RelatedAccount__r.PersonOtherPhone,
        FinServ__RelatedAccount__r.PersonHomePhone,
        FinServ__RelatedAccount__r.Other_Email__c
      FROM FinServ__AccountAccountRelation__c
      WHERE
        FinServ__Account__c = :customerAccountId
        AND FinServ__RelatedAccount__c != NULL
        AND FinServ__RelatedAccount__r.RecordTypeId = :RTAccount.personAccount
        AND FinServ__RelatedAccount__r.Source_System_Name__c = 'CAP-CIS'
      WITH USER_MODE
    ];
  }
}

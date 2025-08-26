/**
 * @author Saurabh Chauhan
 * @since 03/2025
 * @description This class provide SOQL helper for class related to RetailBrokerRelationEventActions.
 */
public with sharing class RetailContactRepository {
  /**
   * @description To be used fetch Contact records
   * @param contactIds set of Contact Ids
   * @return List<Contact> Contact list
   */
  public List<Contact> getContacts(Set<Id> contactIds) {
    if (contactIds.isEmpty()) {
      return new List<Contact>();
    }
    return [
      SELECT
        Id,
        Name,
        Broker_Set__r.Primary_RBM__c,
        Broker_Set__r.Secondary_RBM__c,
        Broker_Set__r.Primary_RBM__r.Lan_Id__c,
        Broker_Set__r.Secondary_RBM__r.Lan_Id__c,
        External_Id__c,
        OCV_Event_Version__c,
        Sync_Status__c
      FROM Contact
      WHERE Id IN :contactIds
      WITH USER_MODE
    ];
  }

  /**
   * @description To be used fetch Contact records
   * @param brokerSetIds set of Broker_Relation__c Ids
   * @return List<Contact> Contact list
   */
  public List<Contact> getBrokerSetContacts(Set<Id> brokerSetIds) {
    if (brokerSetIds.isEmpty()) {
      return new List<Contact>();
    }
    return [
      SELECT
        Id,
        Name,
        Broker_Set__c,
        Broker_Set__r.Primary_RBM__c,
        Broker_Set__r.Secondary_RBM__c,
        Broker_Set__r.Primary_RBM__r.Lan_Id__c,
        Broker_Set__r.Secondary_RBM__r.Lan_Id__c,
        External_Id__c,
        OCV_Event_Version__c,
        Sync_Status__c
      FROM Contact
      WHERE Broker_Set__c IN :brokerSetIds
      WITH USER_MODE
    ];
  }

  /**
   * @description To be used fetch Contact records
   * @param contactEmails List of Contact Emails
   * @param ocvIds List of Contact OCV Ids
   * @return List<Contact> Contact list
   */
  public List<Contact> getDuplicateContacts(
    List<String> contactEmails,
    List<String> ocvIds
  ) {
    if (contactEmails.isEmpty() && ocvIds.isEmpty()) {
      return new List<Contact>();
    }
    return [
      SELECT
        Id,
        Email,
        External_Id__c,
        OCV_ID__c,
        Survivor_Party_Id__c,
        Victim_Party_Id__c,
        OCV_Profile_ID__c
      FROM Contact
      WHERE Email IN :contactEmails OR OCV_ID__c IN :ocvIds
      WITH USER_MODE
    ];
  }

  /**
   * @description Gets list of contacts by contact Ids
   * @param contactIds contact Ids
   * @return List<Contact> List of contacts
   */

  public List<Contact> queryContactRecords(Set<Id> contactIds) {
    if (contactIds.isEmpty()) {
      return new List<Contact>();
    }
    return [
      SELECT
        Id,
        External_Id__c,
        OCV_Event_Version__c,
        OCV_ID__c,
        Survivor_Party_Id__c,
        Victim_Party_Id__c,
        OCV_Profile_ID__c
      FROM Contact
      WHERE Id IN :contactIds
      WITH USER_MODE
    ];
  }

  /**
   * @description Gets list of orphan ResidentialLoanApplications where the Assisted Broker is null
   *              and Assisted Broker TPMI matches one of the provided broker TPMI.
   * @param brokerTPMIIds Set of broker TPMIs to filter applications
   * @return List<ResidentialLoanApplication> List of matching orphan ResidentialLoanApplications
   */
  public List<ResidentialLoanApplication> getRelatedOrphanResidentialApplications(
    Set<String> brokerTPMIIds
  ) {
    if (brokerTPMIIds.isEmpty()) {
      return new List<ResidentialLoanApplication>();
    }
    return [
      SELECT Id, Assisted_Broker__c, Assisted_Broker_TPMI_SAO__c
      FROM ResidentialLoanApplication
      WHERE
        Assisted_Broker_TPMI_SAO__c IN :brokerTPMIIds
        AND Assisted_Broker__c = NULL
      WITH USER_MODE
    ];
  }

  /**
   * @description Gets list of orphan Financial Accounts where the Assisted Broker is null
   *              and Assisted Broker TPMI matches one of the provided broker TPMI.
   * @param brokerTPMIIds Set of broker TPMIs to filter financial accounts
   * @return List<FinServ__FinancialAccount__c> List of matching orphan Financial Accounts
   */
  public List<FinServ__FinancialAccount__c> getRelatedOrphanFinancialAccounts(
    Set<String> brokerTPMIIds
  ) {
    if (brokerTPMIIds.isEmpty()) {
      return new List<FinServ__FinancialAccount__c>();
    }
    return [
      SELECT id, Assisted_Broker__c, Assisted_Broker_TPMI_SAO__c
      FROM FinServ__FinancialAccount__c
      WHERE
        Assisted_Broker_TPMI_SAO__c IN :brokerTPMIIds
        AND Assisted_Broker__c = NULL
    ];
  }

  /**
   * @description Gets list of contacts by contact Ids
   * @param survivorExternalIdList contact Ids
   * @return List<Contact> List of contacts
   */

  public List<Contact> queryContactRecordsByExternalIds(
    Set<String> survivorExternalIdList
  ) {
    if (survivorExternalIdList.isEmpty()) {
      return new List<Contact>();
    }
    return [
      SELECT
        Id,
        External_Id__c,
        Survivor_Party_Id__c,
        Victim_Party_Id__c,
        Sync_Status__c,
        Broker_Set__c,
        Office_Group__c
      FROM Contact
      WHERE External_Id__c IN :survivorExternalIdList
      WITH USER_MODE
    ];
  }
}

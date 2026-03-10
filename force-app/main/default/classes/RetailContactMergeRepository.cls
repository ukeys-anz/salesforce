/**
 * @author Smruti Khobragade
 * @since 08/2025
 * @description This class provide SOQL helper for class related to RetailBrokerContactActions.
 */
public with sharing class RetailContactMergeRepository {
  /**
   * @description To be used fetch Contact records
   * @param contactIds List of ContactIds of Triggering Contacts.
   * @param contactEmails List of Contact Emails
   * @param ocvIds List of Contact OCV Ids
   * @return List<Contact> Contact list
   */
  public List<Contact> getDuplicateContacts(
    Set<Id> contactIds,
    Set<String> contactEmails,
    Set<String> ocvIds
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
        OCV_Profile_ID__c,
        Sync_Status__c
      FROM Contact
      WHERE
        RecordTypeId = :RTContact.broker
        AND ID NOT IN :contactIds
        AND (Email IN :contactEmails
        OR OCV_ID__c IN :ocvIds)
      WITH USER_MODE
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
        Office_Group__c,
        Is_Beta_Broker__c
      FROM Contact
      WHERE External_Id__c IN :survivorExternalIdList
      WITH USER_MODE
    ];
  }

  /**
   * @description get the list of the Broker code records
   * @param brokerIds Set of broker Ids
   * @return List<Broker_Code__c> list of filtered broker codes
   */
  public List<Broker_Code__c> getRelatedBrokerCodes(Set<Id> brokerIds) {
    if (brokerIds.isEmpty()) {
      return new List<Broker_Code__c>();
    }
    return [
      SELECT Id, External_Id__c, Broker_Name__c
      FROM Broker_Code__c
      WHERE Broker_Name__c IN :brokerIds
      WITH USER_MODE
    ];
  }

  /**
   * @description get the list of the Broker code records
   * @param brokerIdentifiers List of broker identifiers
   * @return List<Broker_Code__c> list of filtered broker codes
   */
  public List<Broker_Code__c> getBrokerIdentifiers(
    Set<String> brokerIdentifiers
  ) {
    if (brokerIdentifiers.isEmpty()) {
      return new List<Broker_Code__c>();
    }
    return [
      SELECT Id, External_Id__c, Broker_Name__c, Broker_Name__r.Sync_Status__c
      FROM Broker_Code__c
      WHERE
        External_Id__c IN :brokerIdentifiers
        AND Broker_Name__r.Sync_Status__c EXCLUDES (
          'Duplicate - Email',
          'Duplicate - OCV Id'
        )
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
   * @description To be used fetch Contact records
   * @param contactIds Set of Contact Ids
   * @return List<Contact> Contact list
   */
  public List<Contact> getContactsByIds(Set<Id> contactIds) {
    if (contactIds.isEmpty()) {
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
        OCV_Profile_ID__c,
        Sync_Status__c
      FROM Contact
      WHERE RecordTypeId = :RTContact.broker AND ID IN :contactIds
      WITH USER_MODE
    ];
  }
}

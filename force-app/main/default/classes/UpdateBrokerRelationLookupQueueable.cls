/**
 * @description       : Queueable Apex class that updates Broker_Relation__c Lookup fields on Contact records
 * @author            : Madhuri Edke | Salesforce
 * @last modified on  : 08-25-2025
 * @last modified by  : Madhuri Edke | Salesforce
 **/
public class UpdateBrokerRelationLookupQueueable implements Queueable {
  private Map<String, List<Contact>> contactMap;
  private Map<Id, String> contactIdByBrokerSet;
  private Map<Id, String> contactIdByOfficeGroup;
  private Set<Id> contactIdsForCCREvent;
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final RetailContactMergeRepository CONTACT_REPOSITORY = (RetailContactMergeRepository) Lib_InstanceProvider.forType(
    RetailContactMergeRepository.class
  );
  /**
   * @description Constructor to initialize the queueable job.
   * @param contactMap with List of Contacts representing survivors after merge and Updated Contacts For CCR
   * @param contactIdByBrokerSet Map of Contact IDs to their Broker_Set__c values from victim contacts.
   * @param contactIdByOfficeGroup Map of Contact IDs to their Office_Group__c values from victim contacts.
   * @param contactIdsForCCREvent Set of Contact IDs for CCREvent
   */
  public UpdateBrokerRelationLookupQueueable(
    Map<String, List<Contact>> contactMap,
    Map<Id, String> contactIdByBrokerSet,
    Map<Id, String> contactIdByOfficeGroup,
    Set<Id> contactIdsForCCREvent
  ) {
    this.contactMap = contactMap;
    this.contactIdByBrokerSet = contactIdByBrokerSet;
    this.contactIdByOfficeGroup = contactIdByOfficeGroup;
    this.contactIdsForCCREvent = contactIdsForCCREvent;
  }

  /**
   * @description Executes the queueable job to update Broker_Set__c and Office_Group__c fields on Contact records.
   * @param context Queueable job context
   */
  public void execute(QueueableContext context) {
    List<Contact> contactsToUpdate = new List<Contact>();
    Set<Id> survivorIds = new Set<Id>();
    if (
      contactMap != null && contactMap.containsKey('survivorDuplicatesList')
    ) {
      survivorIds = ListUtil.getIds(
        contactMap.get('survivorDuplicatesList'),
        Contact.Id
      );
    }
    for (Id contactId : survivorIds) {
      if (
        contactIdByBrokerSet.containsKey(contactId) ||
        contactIdByOfficeGroup.containsKey(contactId)
      ) {
        Contact contactRec = new Contact(Id = contactId);
        contactRec.Broker_Set__c = contactIdByBrokerSet.get(contactId);
        contactRec.Office_Group__c = contactIdByOfficeGroup.get(contactId);
        contactsToUpdate.add(contactRec);
      }
    }

    if (
      contactMap.get('duplicateEmailContacts') != null &&
      contactMap.get('duplicateOcvIdContacts') != null
    ) {
      contactsToUpdate.addAll(
        getDuplicateContacts(
          contactMap.get('duplicateEmailContacts') != null
            ? contactMap.get('duplicateEmailContacts')
            : new List<Contact>(),
          contactMap.get('duplicateOcvIdContacts') != null
            ? contactMap.get('duplicateOcvIdContacts')
            : new List<Contact>()
        )
      );
    }

    DML_REPOSITORY.doUpdate(contactsToUpdate);

    List<Contact> contactList = (contactMap != null &&
      contactMap.containsKey('updatedContacts'))
      ? contactMap.get('updatedContacts')
      : new List<Contact>();

    Set<String> setOfBrokerTPMI = ListUtil.getStrings(
      contactMap.get('updatedContacts'),
      Contact.RetailTPMISAO__c
    );

    List<ResidentialLoanApplication> loanAppList = CONTACT_REPOSITORY.getRelatedOrphanResidentialApplications(
      setOfBrokerTPMI
    );

    List<FinServ__FinancialAccount__c> finServAccList = CONTACT_REPOSITORY.getRelatedOrphanFinancialAccounts(
      setOfBrokerTPMI
    );

    try {
      Map<String, Contact> contactByTMPI = (Map<String, Contact>) ListUtil.mapBy(
        contactList,
        contact.RetailTPMISAO__c
      );
      List<ResidentialLoanApplication> loanAppListToUpdate = updateResidentialLoanApplication(
        loanAppList,
        contactByTMPI
      );
      List<FinServ__FinancialAccount__c> accountsToUpdate = updateFinancialAccounts(
        finServAccList,
        contactByTMPI
      );
      DML_REPOSITORY.doUpdate(loanAppListToUpdate);
      DML_REPOSITORY.doUpdate(accountsToUpdate);
      RetailBrokerRelationEventActions.publishBrokerRelationEventFromContact(
        contactIdsForCCREvent,
        null
      );
    } catch (Exception e) {
      Logger.error(
          'Error during MergeResidentialLoanAppQueueable execution ',
          e
        )
        .save();
    }
  }

  /**
   * @description Updates the Assisted_Broker__c field in ResidentialLoanApplication
   * records by matching TPMI code with Contact records.
   * @param loanAppList List of orphan ResidentialLoanApplication records
   * @param contactByTMPI Map of Contacts keyed by RetailTPMISAO__c
   * @return List<ResidentialLoanApplication> with updated Assisted_Broker__c field
   */
  public static List<ResidentialLoanApplication> updateResidentialLoanApplication(
    List<ResidentialLoanApplication> loanAppList,
    Map<String, Contact> contactByTMPI
  ) {
    List<ResidentialLoanApplication> loanAppListToUpdate = new List<ResidentialLoanApplication>();
    for (ResidentialLoanApplication rla : loanAppList) {
      rla.Assisted_Broker__c = contactByTMPI.get(
          rla.Assisted_Broker_TPMI_SAO__c
        )
        ?.Id;
      loanAppListToUpdate.add(rla);
    }
    return loanAppListToUpdate;
  }

  /**
   * @description Updates the Assisted_Broker__c field in FinancialAccount
   * records by matching TPMI code with Contact records.
   * @param finServAccList List of orphan FinancialAccount records
   * @param contactByTMPI Map of Contacts keyed by RetailTPMISAO__c
   * @return List<FinServ__FinancialAccount__c> with updated Assisted_Broker__c field
   */
  public static List<FinServ__FinancialAccount__c> updateFinancialAccounts(
    List<FinServ__FinancialAccount__c> finServAccList,
    Map<String, Contact> contactByTMPI
  ) {
    List<FinServ__FinancialAccount__c> accountsToUpdate = new List<FinServ__FinancialAccount__c>();
    for (FinServ__FinancialAccount__c acc : finServAccList) {
      acc.Assisted_Broker__c = contactByTMPI.get(
          acc.Assisted_Broker_TPMI_SAO__c
        )
        ?.Id;
      accountsToUpdate.add(acc);
    }
    return accountsToUpdate;
  }

  /**
   * @description Constructor to initialize the queueable job.
   * @param emailDuplicateContacts List of Contacts with duplicate emails
   * @param ocvIDDuplicateContacts List of Contacts with duplicate OCV IDs
   * @return  list<Contact> list of contacts to be updated with duplicate email and ocv id status
   */

  public static List<Contact> getDuplicateContacts(
    List<Contact> emailDuplicateContacts,
    List<Contact> ocvIDDuplicateContacts
  ) {
    List<Contact> contactList = new List<Contact>(emailDuplicateContacts);
    contactList.addAll(ocvIDDuplicateContacts);
    List<Contact> contactsToBeUpdated = new List<Contact>();
    List<Contact> contactsListToValidate = CONTACT_REPOSITORY.getContactsByIds(
      ListUtil.getIds(contactList, Contact.Id)
    );

    map<id, contact> emailContactMap = (Map<Id, Contact>) ListUtil.mapBy(
      emailDuplicateContacts,
      Contact.Id
    );
    map<id, contact> ocvIdContactMap = (Map<Id, Contact>) ListUtil.mapBy(
      ocvIDDuplicateContacts,
      Contact.Id
    );

    for (Contact con : contactsListToValidate) {
      if (String.isBlank(con.Sync_Status__c)) {
        continue;
      }

      Set<String> statusValues = new Set<String>(con.Sync_Status__c.split(';'));

      if (emailContactMap.containsKey(con.Id)) {
        statusValues.add(BrokerConstants.SYNC_STATUS_DUPLICATE_EMAIL);
      }

      if (ocvIdContactMap.containsKey(con.Id)) {
        statusValues.add(BrokerConstants.SYNC_STATUS_DUPLICATE_OCVID);
      }
      if (
        statusValues.contains(BrokerConstants.SYNC_STATUS_BROKER_ORG) &&
        statusValues.size() > 1
      ) {
        statusValues.remove(BrokerConstants.SYNC_STATUS_BROKER_ORG);
      }

      con.Sync_Status__c = String.join(new List<String>(statusValues), ';');

      contactsToBeUpdated.add(con);
    }
    return contactsToBeUpdated;
  }
}

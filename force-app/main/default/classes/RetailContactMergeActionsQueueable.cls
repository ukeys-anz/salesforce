/**
 * @description       : Queueable Apex class that updates orphaned ResidentialLoanApplication and FinancialAccount records by linking them to the correct
 *                      Contact records using the broker's TPMI Code.
 * @author            : Madhuri Edke | Salesforce
 * @last modified on  : 08-25-2025
 * @last modified by  : Madhuri Edke | Salesforce
 **/
public class RetailContactMergeActionsQueueable implements Queueable {
  private List<Contact> contactList;
  private List<ResidentialLoanApplication> rlaList;
  private List<FinServ__FinancialAccount__c> faList;
  private Set<Id> contactIdsForCCREvent;
  private static final RetailContactRepository CONTACT_REPOSITORY = (RetailContactRepository) Lib_InstanceProvider.forType(
    RetailContactRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description Constructor to initialize the queueable with a set of Broker TPMI codes.
   * @param contactList list of Contact
   * @param rlaList list of ResidentialLoanApplication to update
   * @param faList list of FinancialAccount to update
   * @param contactIdsForCCREvent of Contact Ids for CCREvent
   */
  public RetailContactMergeActionsQueueable(
    List<Contact> contactList,
    List<ResidentialLoanApplication> rlaList,
    List<FinServ__FinancialAccount__c> faList,
    Set<Id> contactIdsForCCREvent
  ) {
    this.contactList = contactList;
    this.rlaList = rlaList;
    this.faList = faList;
    this.contactIdsForCCREvent = contactIdsForCCREvent;
  }

  /**
   * @description Executes the queueable job to merge orphan ResidentialLoanApplication
   * and FinancialAccount records by updating the Assisted_Broker__c field using
   * the broker TPMI code.
   * @param context Queueable job context
   */
  public void execute(QueueableContext context) {
    if (contactList.isEmpty()) {
      return;
    }

    try {
      Map<String, Contact> contactByTMPI = (Map<String, Contact>) ListUtil.mapBy(
        contactList,
        contact.RetailTPMISAO__c
      );
      List<ResidentialLoanApplication> loanAppListToUpdate = updateResidentialLoanApplication(
        rlaList,
        contactByTMPI
      );
      List<FinServ__FinancialAccount__c> accountsToUpdate = updateFinancialAccounts(
        faList,
        contactByTMPI
      );
      DML_REPOSITORY.doUpdate(loanAppListToUpdate);
      DML_REPOSITORY.doUpdate(accountsToUpdate);
      RetailBrokerRelationEventActions.publishBrokerRelationEventFromContact(
        contactIdsForCCREvent,
        null
      );
    } catch (Exception e) {
      String errorMsg =
        'Error during MergeResidentialLoanAppQueueable execution.\n' +
        e.getMessage() +
        '\n';
      if (e instanceof DmlException) {
        DmlException de = (DmlException) e;
        errorMsg += 'DML Exception Full Message:\n' + de.getMessage() + '\n';
      }
      Logger.error(errorMsg).save();
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
}
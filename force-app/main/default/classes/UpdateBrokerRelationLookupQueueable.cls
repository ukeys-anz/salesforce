/**
 * @description       : Queueable Apex class that updates Broker_Relation__c Lookup fields on Contact records
 * @author            : Madhuri Edke | Salesforce
 * @last modified on  : 08-25-2025
 * @last modified by  : Madhuri Edke | Salesforce
 **/
public class UpdateBrokerRelationLookupQueueable implements Queueable {
  private List<Id> survivorIds;
  private Map<Id, String> contactIdByBrokerSet;
  private Map<Id, String> contactIdByOfficeGroup;
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description Constructor to initialize the queueable job.
   * @param survivorIds List of Contact IDs representing survivors after merge
   * @param contactIdByBrokerSet Map of Contact IDs to their Broker_Set__c values from victim contacts.
   * @param contactIdByOfficeGroup Map of Contact IDs to their Office_Group__c values from victim contacts.
   */
  public UpdateBrokerRelationLookupQueueable(
    List<Id> survivorIds,
    Map<Id, String> contactIdByBrokerSet,
    Map<Id, String> contactIdByOfficeGroup
  ) {
    this.survivorIds = survivorIds;
    this.contactIdByBrokerSet = contactIdByBrokerSet;
    this.contactIdByOfficeGroup = contactIdByOfficeGroup;
  }

  /**
   * @description Executes the queueable job to update Broker_Set__c and Office_Group__c fields on Contact records.
   * @param context Queueable job context
   */
  public void execute(QueueableContext context) {
    List<Contact> contactsToUpdate = new List<Contact>();

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

    DML_REPOSITORY.doUpdate(contactsToUpdate, new DMLConfig());
  }
}

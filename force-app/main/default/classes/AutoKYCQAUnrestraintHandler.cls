/**
 * @author Tan Phan
 * @since 06/2024
 * @description This class represents the profile staging handler for the AutoKYCQA restraint event.
 */
public with sharing class AutoKYCQAUnrestraintHandler {
  private static final AutoKYCQACaseRepository REPOSITORY = (AutoKYCQACaseRepository) Lib_InstanceProvider.forType(
    AutoKYCQACaseRepository.class
  );
  private static final ProfileStagingHandler HANDLER = (ProfileStagingHandler) Lib_InstanceProvider.forType(
    ProfileStagingHandler.class
  );

  /**
   * @description Processes the records for AutoKYCQA unrestraint.
   * @param records The list of Account records.
   */
  public void process(List<Account> records) {
    if (REPOSITORY.isRestraintEnabled() == false) {
      return;
    }
    List<Customer_Profile_Updates__c> updates = this.generateUpdates(records);
    HANDLER.process(updates);
  }

  @TestVisible
  private List<Customer_Profile_Updates__c> generateUpdates(
    List<Account> records
  ) {
    List<Customer_Profile_Updates__c> updates = new List<Customer_Profile_Updates__c>();
    for (Account acc : records) {
      for (
        Customer_Profile_Updates__c oldCpu : acc.Customer_Profile_Updates__r
      ) {
        updates.add(generateUpdate(oldCpu));
      }
    }
    return updates;
  }

  @TestVisible
  private Customer_Profile_Updates__c generateUpdate(
    Customer_Profile_Updates__c oldCpu
  ) {
    Customer_Profile_Updates__c cpu = HANDLER.templateCpu;
    cpu.Action__c = 'Update';
    cpu.Object_Name__c = 'Case';
    cpu.Customer_Name__c = oldCpu.Customer_Name__c;
    cpu.Occurrence_Number__c = oldCpu.Occurrence_Number__c;
    cpu.TriggeredFrom__c = oldCpu.TriggeredFrom__c.replace('Add', 'Remove');
    cpu.NewValue__c = oldCpu.NewValue__c.replace('Apply', 'Remove');
    cpu.Name = oldCpu.Name.replace('Add', 'Remove');
    cpu.ToBeValue__c = createUnrestraintPayload(
      oldCpu.ToBeValue__c,
      (Integer) oldCpu.Occurrence_Number__c,
      oldCpu.LastModifiedDate
    );
    return cpu;
  }

  @TestVisible
  private String createUnrestraintPayload(
    String oldPayloadString,
    Integer occurrenceNumber,
    DateTime datePlaced
  ) {
    CustomerRestraintModel oldPayload = (CustomerRestraintModel) JSON.deserialize(
      oldPayloadString,
      CustomerRestraintModel.class
    );
    CustomerRestraintModel model = new CustomerRestraintModel();
    model.accountNumber = oldPayload.accountNumber;
    model.productCode = oldPayload.productCode;
    model.restraints.restraintClass = 1;
    model.restraints.restraintType = oldPayload.restraints.restraintType;
    model.restraints.datePlaced = datePlaced.format('YYYY-MM-dd');
    model.restraints.dateExpires = '';
    model.restraints.sequence = occurrenceNumber;
    return JSON.serialize(model);
  }
}

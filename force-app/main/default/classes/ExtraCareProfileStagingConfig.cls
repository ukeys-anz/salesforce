/**
 * @description       : This class represents the configuration for the Manage Extra Care.
 * @author            : Akshat Khandelwal
 * @group             :
 * @last modified on  : Apr 2025
 **/
public with sharing class ExtraCareProfileStagingConfig extends ProfileStagingConfig {
  /**
   * @description Constructor. Declare tracked field relevant to Manage Extra Care.
   */
  public ExtraCareProfileStagingConfig() {
    super.revertOnDone = false;
    super.trackedFields = new Set<String>{
      'ExtraCareTimePeriod__c',
      'ExtraCareReason__c',
      'ExtraCareNotes__c',
      'ExtraCareReviewDate__c',
      'ExtraCareDisclosure__c',
      'ExtraCareConsent__c',
      'OCV_Event_Version__c'
    };
  }

  /**
   * @description Populate the staging record with the Account details
   * @param cpu The Customer_Profile_Updates__c record
   */
  protected override void finalise(Customer_Profile_Updates__c cpu) {
    Account acc = (Account) super.record;
    cpu.Name = 'Extra Care Update';
    cpu.Object_Name__c = 'Account';
    cpu.TriggeredFrom__c = 'Account.Individual.ExtraCare';
    cpu.Customer_Name__c = acc.Id;
    cpu.Action__c = 'Update';
  }

  /**
   * @description Overriden to ignore user FLS.
   * @param field The field to check.
   * @return `Boolean` always return true for Extra Care Staging
   */
  protected override Boolean canCapture(String field) {
    return true;
  }
}

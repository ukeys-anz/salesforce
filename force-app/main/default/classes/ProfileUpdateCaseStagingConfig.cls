/**
 * @author Karen Valeriano
 * @since Jan 2025
 * @description This class represents the staging configuration for Profile Update case.
 */
public with sharing class ProfileUpdateCaseStagingConfig extends ProfileStagingConfig {
  private Map<Id, Case> mapAccountIdToCase;
  @TestVisible
  private static final String CPU_NAME_VALUE_LEGAL_NAME = 'Legal Name Update case {0}, Approved';
  @TestVisible
  private static final String TRIGGERED_FROM_VALUE_LEGAL_NAME = 'Case.ProfileUpdate.LegalNameUpdate';
  @TestVisible
  private static final String LEGAL_NAME_NEW_VALUE = 'Update the Legal Name to {0}{1}{2}';

  /**
   * @description Constructor. Declare tracked fields relevant to KYC QA Cases.
   * @param mapAccountIdToCase A map of AccountId to Case record.
   */
  public ProfileUpdateCaseStagingConfig(Map<Id, Case> mapAccountIdToCase) {
    this.mapAccountIdToCase = mapAccountIdToCase;
  }

  /**
   * @description Override hasChanges() to return true
   * @return `Boolean` always return true for Legal Name Update case
   */
  protected override Boolean hasChanges() {
    return true;
  }

  /**
   * @description Populate the staging record with the case details
   * @param cpu The Customer_Profile_Updates__c record
   */
  protected override void finalise(Customer_Profile_Updates__c cpu) {
    Account acc = (Account) super.record;
    Case theCase = this.mapAccountIdToCase.get(acc.Id);
    LegalNameUpdateModel model = new LegalNameUpdateModel(theCase, acc);

    cpu.Action__c = 'Update';
    cpu.Case__c = theCase.Id;
    cpu.Customer_Name__c = acc.Id;
    cpu.Name = String.format(
      CPU_NAME_VALUE_LEGAL_NAME,
      new List<String>{ theCase.CaseNumber }
    );
    cpu.Object_Name__c = 'Case';
    cpu.TriggeredFrom__c = TRIGGERED_FROM_VALUE_LEGAL_NAME;
    cpu.ToBeValue__c = JSON.serialize(model, true);
    cpu.NewValue__c = String.format(
        LEGAL_NAME_NEW_VALUE,
        new List<String>{
          getValue(theCase.NewFirstName__c),
          getValue(theCase.NewMiddleName__c),
          getValue(theCase.NewLastName__c)
        }
      )
      .trim();
  }

  /**
   * @description Get the field value from the case record. Return empty string if the value is null or empty.
   * @param value The field value
   * @return `String` the field value
   */
  @TestVisible
  private static String getValue(String value) {
    if (String.isBlank(value)) {
      return '';
    }
    return value + ' ';
  }
}

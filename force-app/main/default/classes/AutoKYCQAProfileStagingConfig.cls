/**
 * @author Tan Phan
 * @since 06/2024
 * @description This class represents the configuration for the AutoKYCQA Case upgrade/downgrade.
 */
public with sharing class AutoKYCQAProfileStagingConfig extends ProfileStagingConfig {
  private static final Map<String, String> KYC_GRADE_SUFFIX = new Map<String, String>{
    'PC' => ' - KYC Downgrade',
    'CO' => ' - KYC Upgrade'
  };

  private Map<Id, Case> mapAccountIdToCase;

  /**
   * @description Constructor. Declare tracked field relevant to KYC QA Cases.
   * @param mapAccountIdToCase A map of AccountId to Case record.
   */
  public AutoKYCQAProfileStagingConfig(Map<Id, Case> mapAccountIdToCase) {
    this.mapAccountIdToCase = mapAccountIdToCase;
    super.revertOnDone = false;
    super.trackedFields = new Set<String>{
      'FinServ__KYCStatus__c',
      'KYC_Verification_Level__c'
    };
  }

  /**
   * @description Populate the staging record with the case details
   * @param cpu The Customer_Profile_Updates__c record
   */
  protected override void finalise(Customer_Profile_Updates__c cpu) {
    Account acc = (Account) super.record;
    Case theCase = this.mapAccountIdToCase.get(acc.Id);
    cpu.Name = 'KYC QA Case ' + theCase.CaseNumber;
    if (KYC_GRADE_SUFFIX.containsKey(acc.FinServ__KYCStatus__c)) {
      cpu.Name += KYC_GRADE_SUFFIX.get(acc.FinServ__KYCStatus__c);
    }
    cpu.Object_Name__c = 'Case';
    cpu.TriggeredFrom__c = 'Case.KYC_QA';
    cpu.Customer_Name__c = acc.Id;
  }

  /**
   * @description Overriden to ignore user FLS since this is simulated account changes, initiated from case trigger
   * @param field The field to check.
   * @return `Boolean` always return true for KYC QA profile staging
   */
  protected override Boolean canCapture(String field) {
    return true;
  }
}

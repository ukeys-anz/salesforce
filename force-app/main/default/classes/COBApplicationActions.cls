/**
 * @author Batya Aisman Sufrin
 * @since  05/2023
 * @description COBApplicationActions is to handle all the COB Application Trigger actions
 */
public with sharing class COBApplicationActions {
  @TestVisible
  private static final String YES = 'Yes';
  @TestVisible
  private static final String NONE = null;

  /**
   * @description Create KYC QA cases when a COB Application is updated with Electronic Verification Acknowledged == true
   * @param records Case records from trigger
   * @param oldMap map of records id and old records
   */
  public static void createKYCQACase(
    List<CustomerOnboardingApplication__c> records,
    Map<Id, CustomerOnboardingApplication__c> oldMap
  ) {
    //Create base KYC QA Case
    Map<String, Case> ocvIdsKYCQACases = createBaseKYCQACase(records, oldMap);

    if (ocvIdsKYCQACases.isEmpty()) {
      return;
    }

    //Link to Person Account if exist
    linkToPersonAccount(ocvIdsKYCQACases);

    //Set KYC QA Case test fields
    setKYCQATestFelds(ocvIdsKYCQACases);

    DMLUtil.insertRecords(ocvIdsKYCQACases.values(), false, false);
  }

  /**
   * @description Create Base KYC QA case when a COB Application is updated with Electronic Verification Acknowledged == true
   * @param records Case records from trigger
   * @param oldMap map of records id and old records
   * @return Map<String, Case> OCV IDs with KYC QA Cases
   */
  @TestVisible
  private static Map<String, Case> createBaseKYCQACase(
    List<CustomerOnboardingApplication__c> records,
    Map<Id, CustomerOnboardingApplication__c> oldMap
  ) {
    Map<String, Case> ocvIdsKYCQACases = new Map<String, Case>();

    for (CustomerOnboardingApplication__c cobApp : records) {
      CustomerOnboardingApplication__c oldCOBApp = oldMap.get(cobApp.Id);

      if (
        cobApp.ElectronicVerificationAcknowledged__c == true &&
        oldCOBApp?.ElectronicVerificationAcknowledged__c == false
      ) {
        Case kycQACase = COBApplicationActionsHelper.createKYCQACase(cobApp);

        ocvIdsKYCQACases.put(cobApp.OCVId__c, kycQACase);
      }
    }

    return ocvIdsKYCQACases;
  }

  /**
   * @description Link KYC QA case with Person Account if exists by OCV ID
   * @param ocvIdsKYCQACases OCV IDs with KYC QA Cases
   */
  @TestVisible
  private static void linkToPersonAccount(Map<String, Case> ocvIdsKYCQACases) {
    List<Account> accounts = COBApplicationActionsHelper.getAccountsByOCVIds(
      ocvIdsKYCQACases.keySet()
    );

    for (Account acc : accounts) {
      ocvIdsKYCQACases.get(acc.OCV_ID__c).AccountId = acc.Id;
    }
  }

  /**
   * @description Set KYC QA Case test fields
   * @param ocvIdsKYCQACases OCV IDs with KYC QA Cases
   */
  @TestVisible
  private static void setKYCQATestFelds(Map<String, Case> ocvIdsKYCQACases) {
    List<COBPrimaryIDDocument__c> cobPids = COBApplicationActionsHelper.getCOBPIDsByOCVIds(
      ocvIdsKYCQACases.keySet()
    );
    for (COBPrimaryIDDocument__c cobPid : cobPids) {
      ocvIdsKYCQACases.get(cobPid.CustomerOnboardingApplication__r.OCVId__c)
        .Fraud_MiddleNameCheck__c = cobPid.MiddleNamesOCRMatch__c ? YES : NONE;
    }
  }
}

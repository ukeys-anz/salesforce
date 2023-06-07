/**
 * @author Batya Aisman Sufrin
 * @since  05/2023
 * @description COBApplicationActions is to handle all the COB Application Trigger actions
 */
public with sharing class COBApplicationActions {
  /**
   * @description Create KYC QA cases when a COB Application is updated with Electronic Verification Acknowledged == true
   * @param records Case records from trigger
   * @param oldMap map of records id and old records
   */
  public static void createKYCQACase(
    List<CustomerOnboardingApplication__c> records,
    Map<Id, CustomerOnboardingApplication__c> oldMap
  ) {
    Map<String, Case> ocvIdsKycQACases = new Map<String, Case>();

    for (CustomerOnboardingApplication__c cobApp : records) {
      CustomerOnboardingApplication__c oldCOBApp = oldMap.get(cobApp.Id);

      if (
        cobApp.ElectronicVerificationAcknowledged__c == true &&
        oldCOBApp?.ElectronicVerificationAcknowledged__c == false
      ) {
        Case kycQACase = COBApplicationActionsHelper.createKYCQACase(cobApp);

        ocvIdsKycQACases.put(cobApp.OCVId__c, kycQACase);
      }
    }

    if (ocvIdsKycQACases.isEmpty()) {
      return;
    }

    List<Account> accounts = COBApplicationActionsHelper.getAccountsByOCVID(
      ocvIdsKycQACases.keySet()
    );

    for (Account acc : accounts) {
      Case kycQACase = ocvIdsKycQACases.get(acc.OCV_ID__c);
      kycQACase.AccountId = acc.Id;

      ocvIdsKycQACases.put(acc.OCV_ID__c, kycQACase);
    }

    DMLUtil.insertRecords(ocvIdsKycQACases.values(), false, false);
  }
}

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
  @TestVisible
  private static final String CURRENT = 'Current';

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
    Map<String, Case> ocvIdsKYCQACases = constructBaseKYCQACase(
      records,
      oldMap
    );

    if (ocvIdsKYCQACases.isEmpty()) {
      return;
    }

    //Set KYC QA Case fields
    setKYCQAFields(records, ocvIdsKYCQACases);
    DMLUtil.insertRecords(ocvIdsKYCQACases.values(), false, false);
  }

  /**
   * @description Update KYC QA case after query
   * @param cobApps List of COB Applications
   * @param ocvIdsKycQACases Map of OCV id and KYC QA case
   */
  @TestVisible
  private static void setKYCQAFields(
    List<CustomerOnboardingApplication__c> cobApps,
    Map<String, Case> ocvIdsKycQACases
  ) {
    setKYCQAFieldsAccount(ocvIdsKycQACases);
    setKYCQAFieldsCOBPID(cobApps, ocvIdsKycQACases);
    setKYCQAFieldsCOBAddress(ocvIdsKycQACases);
  }

  /**
   * @description Update KYC QA case Account Id field
   * @param ocvIdsKycQACases map of OCV id and KYC QA case
   */
  @TestVisible
  private static void setKYCQAFieldsAccount(
    Map<String, Case> ocvIdsKycQACases
  ) {
    Map<String, Account> accs = COBApplicationActionsHelper.getAccountsByOCVIDs(
      ocvIdsKycQACases.keySet()
    );
    for (Case kycQACase : ocvIdsKycQACases.values()) {
      Account acc = accs.get(kycQACase.OCV_Id__c);
      kycQACase.AccountId = acc?.Id;
    }
  }

  /**
   * @description Update KYC QA case Fields base on COB Primary ID Document
   * @param cobApps List of COB Applications
   * @param ocvIdsKycQACases Map of OCV id and KYC QA case
   */
  @TestVisible
  private static void setKYCQAFieldsCOBPID(
    List<CustomerOnboardingApplication__c> cobApps,
    Map<String, Case> ocvIdsKycQACases
  ) {
    Map<Id, CustomerOnboardingApplication__c> cobAppIdApps = new Map<Id, CustomerOnboardingApplication__c>(
      cobApps
    );
    Map<String, COBPrimaryIDDocument__c> cobPids = COBApplicationActionsHelper.getCOBPIDsByOCVIds(
      ocvIdsKycQACases.keySet()
    );

    for (Case kycQACase : ocvIdsKycQACases.values()) {
      COBPrimaryIDDocument__c cobPid = cobPids.get(kycQACase.OCV_Id__c);
      CustomerOnboardingApplication__c cobApp = cobAppIdApps.get(
        kycQACase.CustomerOnboardingApplication__c
      );

      if (cobApp == null || cobPid == null) {
        continue;
      }

      kycQACase.Fraud_MiddleNameCheck__c = COBApplicationActionsHelper.populateMiddleNameCheck(
        cobPid
      );
      kycQACase.Fraud_Customer_Details__c = COBApplicationActionsHelper.populateFraudCustomerDetails(
        cobApp,
        cobPid
      );
    }
  }

  /**
   * @description Update KYC QA case Fields base on COB Address
   * @param ocvIdsKycQACases Map of OCV id and KYC QA case
   */
  @TestVisible
  private static void setKYCQAFieldsCOBAddress(
    Map<String, Case> ocvIdsKycQACases
  ) {
    Map<String, COBAddress__c> cobAddresses = COBApplicationActionsHelper.getCOBAddressByOCVIdAddressType(
      ocvIdsKycQACases.keySet(),
      CURRENT
    );

    for (Case kycQACase : ocvIdsKycQACases.values()) {
      COBAddress__c cobAddress = cobAddresses.get(kycQACase.OCV_Id__c);
      if (cobAddress != null) {
        kycQACase.Fraud_PO_Box__c = cobAddress.QASAddress__c ? YES : NONE;
        kycQACase.Fraud_Address_Valid__c = cobAddress.QASAddress__c
          ? YES
          : NONE;
      }
    }
  }

  /**
   * @description Constructs Base KYC QA case when a COB Application is updated with Electronic Verification Acknowledged == true
   * @param records Case records from trigger
   * @param oldMap map of records id and old records
   * @return Map<String, Case> OCV IDs with KYC QA Cases
   */
  @TestVisible
  private static Map<String, Case> constructBaseKYCQACase(
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
        Case kycQACase = COBApplicationActionsHelper.setKYCQACaseBaseFields(
          cobApp
        );

        ocvIdsKYCQACases.put(cobApp.OCVId__c, kycQACase);
      }
    }

    return ocvIdsKYCQACases;
  }
}

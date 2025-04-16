/**
 * @author Batya Aisman Sufrin
 * @since 03/2025
 * @description FalseCustomerProfileCaseActions class is to handle all the False Customer Profile Case Actions
 */
public with sharing class FalseCustomerProfileCaseActions {
  @TestVisible
  private static final String FALSE_CUSTOMER_PROFILE_CASE_SUBJECT = 'False Onboarding';
  private static final FalseCustomerProfileCaseRepository REPOSITORY = (FalseCustomerProfileCaseRepository) Lib_InstanceProvider.forType(
    FalseCustomerProfileCaseRepository.class
  );

  /**
   * @description Populate False Customer Profile Case fields based on the Customer Onboarding Application (COB) and Account.
   * This method is called when the Case is created or updated.
   * Set the Onboarding Customer Name to be Customer Name from COB
   * @param cases New record instances to process
   * @param oldCaseMap old case map
   */
  public static void populateFalseCustomerProfileCaseBasedOnCOB(
    List<Case> cases,
    Map<Id, Case> oldCaseMap
  ) {
    Logger.debug(
      'Populate False Customer Profile case fields based on COB started: ' +
      System.now()
    );

    // If Cases have COB, then pick the name from COB PID
    List<Case> casesWithCOBChanged = ListUtil.filter(cases, oldCaseMap)
      .changed(Case.CustomerOnboardingApplication__c)
      .isNotNull(Case.CustomerOnboardingApplication__c)
      .toList();
    Set<Id> cobIds = ListUtil.getIds(
      casesWithCOBChanged,
      Case.CustomerOnboardingApplication__c
    );
    List<CustomerOnboardingApplication__c> cobsWithPID = REPOSITORY.queryCobsWithPIDByIds(
      cobIds
    );
    setFraudOnboardingCustomerNameFromPID(casesWithCOBChanged, cobsWithPID);

    Logger.debug(
        'Populate False Customer Profile field based on COB finished: ' +
        System.now()
      )
      .save();
  }

  /**
   * @description Populate False Customer Profile Case fields based on the Account.
   * This method is called when the Case is created or updated.
   * Set the Onboarding Customer Name to be Customer Name from Account
   * @param cases New record instances to process
   * @param oldCaseMap old case map
   */
  public static void populateFalseCustomerProfileCaseBasedOnAccount(
    List<Case> cases,
    Map<Id, Case> oldCaseMap
  ) {
    Logger.debug(
      'Populate False Customer Profile case fields based on Account started: ' +
      System.now()
    );

    // If Cases have Account changed and without COB, then pick the name from Account
    List<Case> casesWithCustomerChanged = ListUtil.filter(cases, oldCaseMap)
      .changed(Case.AccountId)
      .isNull(Case.CustomerOnboardingApplication__c)
      .toList();
    Set<Id> accIds = ListUtil.getIds(casesWithCustomerChanged, Case.AccountId);
    List<Account> accs = REPOSITORY.queryAccountsByIds(accIds);
    setFraudOnboardingCustomerNameFromAccount(casesWithCustomerChanged, accs);

    Logger.debug(
        'Populate False Customer Profile field based on Account finished: ' +
        System.now()
      )
      .save();
  }

  /**
   * @description Set the Onboarding Customer Name for the False Customer Profile Case
   * @param casesWithCOBChanged List of cases with changed COB
   * @param cobsWithPID List of Customer Onboarding Applications with PIDs
   */
  @TestVisible
  private static void setFraudOnboardingCustomerNameFromPID(
    List<Case> casesWithCOBChanged,
    List<CustomerOnboardingApplication__c> cobsWithPID
  ) {
    Map<Id, CustomerOnboardingApplication__c> cobsById = new Map<Id, CustomerOnboardingApplication__c>(
      cobsWithPID
    );
    for (Case fcpCase : casesWithCOBChanged) {
      CustomerOnboardingApplication__c cob = cobsById.get(
        fcpCase.CustomerOnboardingApplication__c
      );
      fcpCase.Fraud_Onboarding_Customer_Name__c = constructOnboardingCustomerName(
        cob
      );
    }
  }

  /**
   * @description Construct the Onboarding Customer Name
   * @param cob Customer Onboarding Application
   * @return String Onboarding Customer Name, null if there is no PID
   */
  @TestVisible
  private static String constructOnboardingCustomerName(
    CustomerOnboardingApplication__c cob
  ) {
    if (cob == null || cob.COBPrimaryIDDocuments__r.isEmpty()) {
      return null;
    }
    COBPrimaryIDDocument__c pid = cob.COBPrimaryIDDocuments__r[0];
    return CommonUtil.buildTrimmedConcatenatedString(
      new List<String>{ pid.FirstName__c, pid.MiddleNames__c, pid.LastName__c }
    );
  }

  /**
   * @description Set the Fraud Onboarding Customer Name for the False Customer Profile Case
   * @param casesWithCustomerChanged List of cases with changed Account
   * @param accs List of accounts
   */
  @TestVisible
  private static void setFraudOnboardingCustomerNameFromAccount(
    List<Case> casesWithCustomerChanged,
    List<Account> accs
  ) {
    Map<Id, Account> accountsById = new Map<Id, Account>(accs);
    for (Case fcpCase : casesWithCustomerChanged) {
      Account acc = accountsById.get(fcpCase.AccountId);
      fcpCase.Fraud_Onboarding_Customer_Name__c = acc.Name;
    }
  }

  /**
   * @description This method populates False Customer Profile Case subject based on Case record type
   * @param cases List of cases to populate the subject
   */
  public static void populateFalseCustomerProfileCaseSubject(List<Case> cases) {
    ListUtil.setField(cases, Case.Subject, FALSE_CUSTOMER_PROFILE_CASE_SUBJECT);
  }
}

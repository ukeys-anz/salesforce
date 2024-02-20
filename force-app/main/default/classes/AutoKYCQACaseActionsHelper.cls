/**
 * @author Batya Aisman Sufrin
 * @since 09/2023
 * @description Helper class for @link AutoKYCQACaseActions
 * TO BE CLEANED UP AFTER NEW KYC IMPLEMENTATION IS RELEASED
 */
public with sharing class AutoKYCQACaseActionsHelper {
  public static final Group PENDING_KYC_QA_WO_CUSTOMER = CommonUtil.getQueueByName(
    'Pending_KYC_QA_No_Customer'
  );

  @TestVisible
  private static final String YES = 'Yes';
  @TestVisible
  private static final String NONE = null;

  /**
   * @description Get Mobile Number and Case map - TO BE CLEANED UP AFTER NEW KYC IMPLEMENTATION IS RELEASED
   * @param oldCaseIds Set of old KYC QA Case Ids trigger.oldMap
   * @return Mobile Number and Case Id map
   */
  public static Map<String, String> getMobileByCaseId(Set<Id> oldCaseIds) {
    if (oldCaseIds.isEmpty() || PermissionUtils.canQuery('Case') == false) {
      return new Map<String, String>();
    }

    Map<String, String> mobileByCaseIdMap = new Map<String, String>();
    for (Case c : [
      SELECT Id, CustomerOnboardingApplication__r.SecurityMobile__c
      FROM Case
      WHERE Id IN :oldCaseIds AND RecordTypeId = :GetHelpConstants.KYCQA_RT_ID
    ]) {
      if (
        String.isNotBlank(c.CustomerOnboardingApplication__r.SecurityMobile__c)
      ) {
        mobileByCaseIdMap.put(
          c.Id,
          '+' + c.CustomerOnboardingApplication__r.SecurityMobile__c
        );
      }
    }
    return mobileByCaseIdMap;
  }

  /**
   * @description Get Mobile Phones and Account map - TO BE CLEANED UP AFTER NEW KYC IMPLEMENTATION IS RELEASED
   * @param mobileNumbers List of mobiles from COB Applications
   * @return Mobile Phones and Account map
   */
  public static Map<String, Account> getAccountsByMobile(
    List<String> mobileNumbers
  ) {
    if (
      mobileNumbers.isEmpty() || PermissionUtils.canQuery('Account') == false
    ) {
      return new Map<String, Account>();
    }

    Map<String, Account> accountByMobileMap = new Map<String, Account>();
    for (Account acc : [
      SELECT Id, PersonMobilePhone, PersonContactId
      FROM Account
      WHERE PersonMobilePhone IN :mobileNumbers AND ANZx_Customer__c = TRUE
    ]) {
      accountByMobileMap.put(acc.PersonMobilePhone, acc);
    }
    return accountByMobileMap;
  }

  /**
   * @description Set case fileds with matching Account- TO BE CLEANED UP AFTER NEW KYC IMPLEMENTATION IS RELEASED
   * @param c Case
   * @param matchingAcc Matched Account
   * @param accountEntitlmentId Matched Account Entitlment Id
   */
  public static void setMatchingAccountFields(
    Case c,
    Account matchingAcc,
    Id accountEntitlmentId
  ) {
    c.AccountId = matchingAcc.Id;
    c.ContactId = matchingAcc.PersonContactId;
    c.EntitlementId = accountEntitlmentId;
  }

  /**
   * @description Handle KYC QA Case in the situatuon there is still no MAtched Account:
   * Either move to "Pending KYC QA - No Customer" queue in the event the case is not closed yet or
   * remain in the "Pending KYC QA - No Customer" queue untill there is a Matched Account
   * TO BE CLEANED UP AFTER NEW KYC IMPLEMENTATION IS RELEASED
   * @param c Case
   * @param oldCase Old case
   */
  public static void handleKYCQACaseNoCustomer(Case c, Case oldCase) {
    if (
      (oldCase.Status != GetHelpConstants.CLOSED_STATUS &&
      c.Status == GetHelpConstants.CLOSED_STATUS) ||
      oldCase.OwnerId == PENDING_KYC_QA_WO_CUSTOMER.Id
    ) {
      c.OwnerId = PENDING_KYC_QA_WO_CUSTOMER.Id;

      Logger.debug(
        'Case ' + c.Id + ' moved to Pending KYC QA - No Customer queue'
      );
      Logger.saveLog();
    }
  }

  /**
   * @description Filter cases by Record Type Id - TO BE CLEANED UP AFTER NEW KYC IMPLEMENTATION IS RELEASED
   * @param kycQACases List of KYC QA Case records
   * @return List of filtered cases
   */
  public static List<Case> getKYCQACasesWithoutCustomer(List<Case> kycQACases) {
    List<Case> kycQACasesWithNoCustomer = new List<Case>();
    for (Case c : kycQACases) {
      if (c.AccountId == null) {
        kycQACasesWithNoCustomer.add(c);
      }
    }

    return kycQACasesWithNoCustomer;
  }
}

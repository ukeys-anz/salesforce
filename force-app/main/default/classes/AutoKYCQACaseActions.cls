/**
 * @author Batya Aisman Sufrin
 * @since 09/2023
 * @description AutoKYCCaseActions class is to handle all the Auto KYC QA Case Actions
 * */
public with sharing class AutoKYCQACaseActions {
  private List<Case> newKYCQACases;
  private Map<Id, Case> oldKYCQACaseMap;

  @TestVisible
  private static final String CANT_MOVE_NOT_CLOSED_CASE = 'Please complete the KYC QA case and not move the case to this queue';

  /**
   * @description Constructor
   * @param newCases List of Case records passed from Trigger.new()
   * @param oldMap Map of Case records passed from Trigger.oldMap()
   */
  public AutoKYCQACaseActions(List<Case> newCases, Map<Id, Case> oldMap) {
    newKYCQACases = getAutoKYCQACases(newCases).values();
    oldKYCQACaseMap = getAutoKYCQACases(oldMap.values());
  }

  /**
   * @description onBeforeUpdate
   */
  public void onBeforeUpdate() {
    linkKYCQACasesToAccount();
    validateKYCQACases();
  }

  private Map<Id, Case> getAutoKYCQACases(List<Case> cases) {
    if (cases.isEmpty() == true) {
      return new Map<Id, Case>();
    }

    Map<Id, Case> kycCaseMap = new Map<Id, Case>();
    List<Case> kycQACases = CommonUtil.filterCasesByRecordTypeId(
      cases,
      GetHelpConstants.KYCQA_RT_ID
    );
    for (Case kycCase : kycQACases) {
      kycCaseMap.put(kycCase.Id, kycCase);
    }
    return kycCaseMap;
  }

  /**
   * @description linkCasestoAccountByOCVId link case to customer profile by OCV Id or Mobile number
   */
  private void linkKYCQACasesToAccount() {
    //get all the cases with no customer from filtered kycQACases
    List<Case> kycQACasesWithNoCustomer = AutoKYCQACaseActionsHelper.getKYCQACasesWithoutCustomer(
      newKYCQACases
    );

    if (kycQACasesWithNoCustomer.isEmpty()) {
      return;
    }

    Map<String, String> mobileByCaseIdMap = AutoKYCQACaseActionsHelper.getMobileByCaseId(
      new Map<Id, Case>(kycQACasesWithNoCustomer).keySet()
    );

    Map<String, Account> accountByMobileMap = AutoKYCQACaseActionsHelper.getAccountsByMobile(
      mobileByCaseIdMap.values()
    );
    // Get matched Accounts Entitelments
    Map<Id, Id> accountIdEntitlmentMap = GetHelpCaseActionsHelper.getAccountIdEntitlmentMap(
      accountByMobileMap.values()
    );

    for (Case c : kycQACasesWithNoCustomer) {
      Account matchingAcc = accountByMobileMap.get(mobileByCaseIdMap.get(c.Id));
      if (matchingAcc != null) {
        Id accountEntitlmentId = accountIdEntitlmentMap.get(matchingAcc.Id);
        AutoKYCQACaseActionsHelper.setMatchingAccountFields(
          c,
          matchingAcc,
          accountEntitlmentId
        );
      } else {
        Case oldCase = oldKYCQACaseMap.get(c.Id);
        AutoKYCQACaseActionsHelper.handleKYCQACaseNoCustomer(c, oldCase);
      }
      Logger.debug('KYC QA Case Number: ' + c.CaseNumber__c);
    }
    Logger.saveLog();
  }

  /**
   * @description Prevent the Cases either not in Close status or in Close status with linked Account to be moved to Pending KYC QA - No Customer queue
   */
  private void validateKYCQACases() {
    for (Case kycQACase : newKYCQACases) {
      Case oldCase = oldKYCQACaseMap.get(kycQACase.Id);
      if (
        (oldCase.OwnerId != kycQACase.OwnerId &&
        kycQACase.OwnerId ==
        AutoKYCQACaseActionsHelper.PENDING_KYC_QA_WO_CUSTOMER.Id) &&
        (kycQACase.Status != 'Closed' ||
        (kycQACase.Status == 'Closed' &&
        kycQACase.AccountId != null))
      ) {
        kycQACase.addError(CANT_MOVE_NOT_CLOSED_CASE);
      }
    }
  }
}

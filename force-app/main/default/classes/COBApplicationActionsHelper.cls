/**
 * @author Batya Aisman Sufrin
 * @since 05/2023
 * @description Helper class for @link COBApplicationActions
 */
public with sharing class COBApplicationActionsHelper {
  public static final Group PENDING_KYC_QA_QUEUE = CommonUtil.getQueueByName(
    'Pending_KYC_QA'
  );
  public static final Map<String, String> VERIFICATION_TYPE_PRIORITY = new Map<String, String>{
    'MANUAL' => 'High',
    'UNSPECIFIED' => 'High',
    'ASSISTED' => 'Medium',
    'STP' => 'Standard'
  };

  /**
   * @description Create KYC QA cases
   * @param cobApp Customer Onboarding Application
   * @return Case KYC QA case
   */
  public static Case createKYCQACase(CustomerOnboardingApplication__c cobApp) {
    Case kycQACase = new Case(
      RecordTypeId = GetHelpConstants.KYCQA_RT_ID,
      OwnerId = PENDING_KYC_QA_QUEUE.Id,
      CustomerOnboardingApplication__c = cobApp.Id,
      PersonaId__c = cobApp.PersonaId__c,
      OCV_Id__c = cobApp.OCVId__c,
      Priority = VERIFICATION_TYPE_PRIORITY.get(cobApp.VerificationType__c)
    );

    return kycQACase;
  }

  /**
   * @description Get Accounts by OCV ids
   * @param ocvIds Case ids
   * @return List<account> List of accounts
   */
  public static List<Account> getAccountsByOCVID(Set<String> ocvIds) {
    if (ocvIds.isEmpty()) {
      return new List<Account>();
    }

    if (PermissionUtils.canQuery('Account')) {
      return [SELECT Id, OCV_ID__c FROM Account WHERE OCV_ID__c IN :ocvIds];
    }

    return new List<Account>();
  }
}

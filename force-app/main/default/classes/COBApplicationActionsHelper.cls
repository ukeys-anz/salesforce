/**
 * @author Batya Aisman Sufrin
 * @since 05/2023
 * @description Helper class for @link COBApplicationActions
 */
public with sharing class COBApplicationActionsHelper {
  private static final Group PENDING_KYC_QA_QUEUE = CommonUtil.getQueueByName(
    'Pending_KYC_QA'
  );

  private static final String EXPR_0 = 'expr0';

  public static final Map<String, String> VERIFICATION_TYPE_PRIORITY = new Map<String, String>{
    'MANUAL' => 'High',
    'UNSPECIFIED' => 'High',
    'ASSISTED' => 'Medium',
    'STP' => 'Standard'
  };

  /**
   * @description Create KYC QA case
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
   * @description Get Accounts by OCV Ids
   * @param ocvIds OCV ids
   * @return List<account> List of Accounts
   */
  public static List<Account> getAccountsByOCVIds(Set<String> ocvIds) {
    if (ocvIds.isEmpty()) {
      return new List<Account>();
    }

    if (PermissionUtils.canQuery('Account')) {
      return [SELECT Id, OCV_ID__c FROM Account WHERE OCV_ID__c IN :ocvIds];
    }

    return new List<Account>();
  }

  /**
   * @description Get PID by  OCV Ids
   * @param ocvIds OCV ids
   * @return List<COBPrimaryIDDocument__c> COB Primary ID Documents
   */
  public static List<COBPrimaryIDDocument__c> getCOBPIDsByOCVIds(
    Set<String> ocvIds
  ) {
    if (
      ocvIds.isEmpty() ||
      PermissionUtils.canQuery('COBPrimaryIDDocument__c') == false
    ) {
      return new List<COBPrimaryIDDocument__c>();
    }

    //getting max COB PID records createdDate for each cobAppId
    List<AggregateResult> records = [
      SELECT CustomerOnboardingApplication__r.OCVId__c, MAX(Id)
      FROM COBPrimaryIDDocument__c
      WHERE CustomerOnboardingApplication__r.OCVId__c IN :ocvIds
      GROUP BY CustomerOnboardingApplication__r.OCVId__c
    ];

    Set<Id> latestCreatedIds = new Set<Id>();
    for (AggregateResult record : records) {
      latestCreatedIds.add((Id) record.get(EXPR_0));
    }

    //get lastest COB PID record for each cobAppId
    return [
      SELECT
        Id,
        IdDocumentType__c,
        CustomerOnboardingApplication__r.OCVId__c,
        MiddleNamesOCRMatch__c
      FROM COBPrimaryIDDocument__c
      WHERE
        CustomerOnboardingApplication__r.OCVId__c IN :ocvIds
        AND Id IN :latestCreatedIds
    ];
  }
}

/**
 * @author mani.murugesan@anz.com, sebastien.quinternet@anz.com
 * @since January 2024
 * @description Batch process to attach Orphaned KYC QA Cases with their recently created Customer records
 */
public with sharing class COBOrphanedKYCQABatch implements Database.Batchable<SObject> {
  private static final String CUSTOMER_LINKED_TO_KYC_QA_ERROR = 'Error occured while linking Customer to KYC QA Case';
  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  /**
   * @description Fetch orphaned Auto KYC QA Cases that are not linked to Customer profile
   * @param context Unused
   *
   * @return QueryLocator for batch process
   */
  public Database.QueryLocator start(Database.BatchableContext context) {
    if (
      !Case.SObjectType.getDescribe().isUpdateable() ||
      !Account.SObjectType.getDescribe().isQueryable()
    ) {
      CommonUtil.logAndThrowIAE(
        'COBOrphanedKYCQABatch',
        'start',
        'Not enough permissions to update Case or query Account.'
      );
    }
    return Database.getQueryLocator(
      'SELECT Id, OCV_Id__c, PersonaId__c, AccountId, CustomerOnboardingApplication__c, ' +
        'CustomerOnboardingApplication__r.SecurityMobile__c ' +
        'FROM Case ' +
        'WHERE RecordType.DeveloperName = \'KYC_QA\' ' +
        'AND AccountId = NULL AND CustomerOnboardingApplication__c != NULL'
    );
  }

  /**
   * @description Find Account Id for OCV Id or for Mobile Phone and update orphaned Cases
   *
   * @param context unused
   * @param cases batch of Case record for processing
   */
  public void execute(Database.BatchableContext context, List<Case> cases) {
    Logger.info(
        'Linking KYC QA cases, Processing no of cases : ' + cases.size()
      )
      .save();

    Map<Id, Account> cobIdToAccountMap = new Map<Id, Account>();
    cobIdToAccountMap.putAll(
      KYCQACustomerLinkingUtil.getAccountsByMobileAndDOB(cases)
    );
    cobIdToAccountMap.putAll(
      KYCQACustomerLinkingUtil.getAccountsByOCVIdAndDOB(cases)
    );
    setKYCQACase(cases, cobIdToAccountMap);

    List<Case> casesToUpdate = ListUtil.filter(cases)
      .isNotNull(Case.AccountId)
      .toList();

    DML.doUpdate(
      casesToUpdate,
      new DmlConfig()
        .allowPartial()
        .systemMode()
        .errorLog(CUSTOMER_LINKED_TO_KYC_QA_ERROR)
    );
  }
  /**
   * @description Set KYC QA Case AccountId by Mobile Phone and Date of Birth
   * @param cases List of KYC QA Cases to be updated
   * @param accsMap Map of Customer Onboarding Application Id and Account
   */
  @TestVisible
  private static void setKYCQACase(List<Case> cases, Map<Id, Account> accsMap) {
    for (Case kycQACase : cases) {
      Id cobId = kycQACase.CustomerOnboardingApplication__c;
      if (accsMap.containsKey(cobId)) {
        kycQACase.AccountId = accsMap.get(cobId).Id;
      }
    }
  }

  /**
   * @description Unused
   * @param context unused
   */
  public void finish(Database.BatchableContext context) {
  }
}

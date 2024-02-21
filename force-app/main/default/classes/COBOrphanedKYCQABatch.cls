/**
 * @author mani.murugesan@anz.com, sebastien.quinternet@anz.com
 * @since January 2024
 * @description Batch process to attach Orphaned KYC QA Cases with their recently created Customer records
 */
public with sharing class COBOrphanedKYCQABatch implements Database.Batchable<SObject> {
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
      'SELECT Id, CustomerOnboardingApplication__c, CustomerOnboardingApplication__r.PersonaId__c, ' +
      'CustomerOnboardingApplication__r.OCVId__c, CustomerOnboardingApplication__r.SecurityMobile__c, Status ' +
      'FROM Case ' +
      'WHERE RecordType.DeveloperName = \'KYC_QA\' ' +
      'AND AccountId = NULL AND CustomerOnboardingApplication__c != NULL'
    );
  }

  /**
   * @description Extract OCVIds ad MobilePhone numbers from the list of cases
   * @param lstCases Cases to be analysed for the query
   * @param stOCVIds output Set of OCV ids that occur in this list of cases
   * @param stMobilesPhones output Set of MobilePhone numbers that occur in this list of cases
   */
  private static void buildQuerySets(
    List<Case> lstCases,
    Set<String> stOCVIds,
    Set<String> stMobilesPhones
  ) {
    String strOCVId;
    String strMobilePhone;
    for (Case oCase : lstCases) {
      strOCVId = oCase.CustomerOnboardingApplication__r.OCVId__c;
      strMobilePhone = oCase.CustomerOnboardingApplication__r.SecurityMobile__c;
      if (strOCVId != null) {
        stOCVIds.add(strOCVId);
      }
      if (strMobilePhone != null) {
        stMobilesPhones.add(strMobilePhone);
        if (!strMobilePhone.startsWith('+')) {
          stMobilesPhones.add('+' + strMobilePhone);
        }
      }
    }
  }

  /**
   * @description Take List of Cases and link to Account based on OCVId or MobilePhone
   * @param lstCases Cases to be optionally updated
   * @param mpOCVId2AccountId Map of OCVId to AccountId
   * @param mpMobilePhone2AccountId Map of Mobile Phone to AccountId
   *
   * @return List of Cases to be updated
   */
  @TestVisible
  private static List<Case> buildUpdatesList(
    List<Case> lstCases,
    Map<String, String> mpOCVId2AccountId,
    Map<String, String> mpMobilePhone2AccountId
  ) {
    List<Case> lstUpdates = new List<Case>();
    String strOCVId;
    String strMobilePhone;
    for (Case oCase : (List<Case>) lstCases) {
      strOCVId = oCase.CustomerOnboardingApplication__r.OCVId__c;
      strMobilePhone = oCase.CustomerOnboardingApplication__r.SecurityMobile__c;
      if (mpOCVId2AccountId.containsKey(strOCVId)) {
        oCase.AccountId = mpOCVId2AccountId.get(strOCVId);
        lstUpdates.add(oCase);
      } else if (mpMobilePhone2AccountId.containsKey(strMobilePhone)) {
        oCase.AccountId = mpMobilePhone2AccountId.get(strMobilePhone);
        lstUpdates.add(oCase);
      } else if (mpMobilePhone2AccountId.containsKey('+' + strMobilePhone)) {
        oCase.AccountId = mpMobilePhone2AccountId.get('+' + strMobilePhone);
        lstUpdates.add(oCase);
      }
    }
    return lstUpdates;
  }
  /**
   * @description Find Account Id for OCV Id or for Mobile Phone and update orphaned Cases
   *
   * @param context unused
   * @param records batch of Case record for processing
   */
  public void execute(Database.BatchableContext context, List<Case> records) {
    Set<String> stOCVIds = new Set<String>();
    Set<String> stMobilePhones = new Set<String>();
    Logger.info(
      'Linking KYC QA cases, Processing no of cases : ' + records.size()
    );
    buildQuerySets(records, stOCVIds, stMobilePhones);

    Map<String, String> mpOCVId2AccountId = new Map<String, String>();
    Map<String, String> mpMobilePhone2AccountId = new Map<String, String>();
    for (Account oCustomer : [
      SELECT
        Id,
        OCV_ID__c,
        PersonMobilePhone,
        External_Id__c,
        FinServ__KYCStatus__c,
        KYC_Verification_Level__c
      FROM Account
      WHERE
        ANZx_Customer__c = TRUE
        AND (OCV_ID__c IN :stOCVIds
        OR PersonMobilePhone IN :stMobilePhones)
    ]) {
      if (
        oCustomer.External_Id__c != null &&
        oCustomer.External_Id__c.contains('_offboarded')
      ) {
        continue;
      }
      if (stOCVIds.contains(oCustomer.OCV_ID__c)) {
        mpOCVId2AccountId.put(oCustomer.OCV_ID__c, oCustomer.Id);
      }
      if (stMobilePhones.contains(oCustomer.PersonMobilePhone)) {
        mpMobilePhone2AccountId.put(oCustomer.PersonMobilePhone, oCustomer.Id);
      }
    }
    Logger.debug(
      'Linking KYC QA cases, found matching customers by ocvid : ' +
      mpOCVId2AccountId.size()
    );
    Logger.debug(
      'Linking KYC QA cases, found matching customers by security mobile : ' +
      mpMobilePhone2AccountId.size()
    );

    List<Case> lstUpdates = buildUpdatesList(
      records,
      mpOCVId2AccountId,
      mpMobilePhone2AccountId
    );

    handleCaseUpdate(lstUpdates);
    Logger.saveLog();
  }
  private void handleCaseUpdate(List<Case> lstUpdates) {
    if (lstUpdates.isEmpty()) {
      Logger.info('Linking KYC QA cases, no customers to link');
      return;
    }

    Logger.info('Linking KYC QA cases to customers ' + lstUpdates.size());
    List<Database.SaveResult> results = DMLUtil.updateRecords(
      lstUpdates,
      DMLUtil.ALLOW_PARTIAL_UPDATE,
      DMLUtil.SYSTEM_MODE
    );
    for (Integer i = 0; i < results.size(); i++) {
      if (results[i].isSuccess()) {
        continue;
      }
      Logger.error(
        'Error occured while linking Customer to KYC QA Case. Persona ID: ' +
        lstUpdates.get(i).CustomerOnboardingApplication__r.PersonaId__c +
        getDetailedError(results[i].getErrors()),
        Logger.Severity.HIGH
      );
    }
  }

  private string getDetailedError(List<Database.Error> errs) {
    String errorMessage = ' ';
    for (Database.Error err : errs) {
      errorMessage +=
        err.getStatusCode() +
        ': ' +
        err.getMessage() +
        ', Fields: ' +
        err.getFields();
    }
    return errorMessage;
  }

  /**
   * @description Unused
   * @param context unused
   */
  public void finish(Database.BatchableContext context) {
  }
}

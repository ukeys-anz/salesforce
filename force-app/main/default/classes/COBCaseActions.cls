/**
 * @author Karen Valeriano
 * @since  08/2023
 * @description COBCaseActions is to handle all the COB Case trigger actions
 */
public with sharing class COBCaseActions {
  private static final COBCaseRepository COB_CASE_REPO = (COBCaseRepository) Lib_InstanceProvider.forType(
    COBCaseRepository.class
  );
  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description Creates a Fraud Check case everytime an ID Ops Assists case gets changed to 'Potential Fraud' status
   * @param records Case records from trigger
   * @param oldMap map of records id and old records
   */
  public static void createFraudCheckCase(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> fraudCheckCases = new List<Case>();

    //Filter records that have status updated to 'Potential Fraud'
    //With old status NOT 'Potential Fraud'
    records = ListUtil.filter(records, oldMap)
      .changedTo(Case.Status, COBCaseConstants.COB_POTENTIAL_FRAUD_STATUS)
      .toList();

    for (Case c : records) {
      Case fraudCheckCase = new Case(
        RecordTypeId = RTCase.fraudCheck,
        ParentId = c.Id,
        OwnerId = QueryQueue.cobFraudCheckQueue.Id,
        Subject = 'Fraud Check Case',
        CustomerOnboardingApplication__c = c.CustomerOnboardingApplication__c,
        PersonaId__c = c.PersonaId__c,
        Status = COBCaseConstants.COB_ID_OPS_TO_FRAUD_CHECK_STATUS_MAP.get(
          oldMap.get(c.Id)?.Status
        )
      );

      fraudCheckCases.add(fraudCheckCase);
    }

    //Insert new child Fraud Check cases
    DML.doInsert(fraudCheckCases, new DmlConfig().systemMode());
  }

  /**
   * @description Update an ID Ops Assistance case with a corresponding Fraud Check Case Status everytime a Fraud Check case status is updated
   * @param records Case records from trigger
   * @param oldMap map of records id and old records
   */
  public static void updateIdOpsCaseStatus(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    records = ListUtil.filter(records, oldMap).changed(Case.Status).toList();
    List<Case> idOpsCases = buildUpdatedIDOpsCases(records, oldMap);
    DML.doUpdate(idOpsCases, new DmlConfig().systemMode());
  }

  @TestVisible
  private static List<Case> buildUpdatedIDOpsCases(
    List<Case> fraudCheckCases,
    Map<Id, Case> oldMap
  ) {
    List<Case> idOpsCases = new List<Case>();
    for (Case fraudCase : fraudCheckCases) {
      Case idOpsCase = new Case(Id = fraudCase.ParentId);
      if (fraudCase.Status == COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS) {
        idOpsCase.Status = COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS;
        idOpsCase.OnboardingVerificationFailedReason__c = fraudCase.OnboardingVerificationFailedReason__c;
      } else {
        idOpsCase.Status = oldMap.get(fraudCase.Id).Status;
      }
      idOpsCases.add(idOpsCase);
    }
    return idOpsCases;
  }

  /**
   * @description Cases where status has changed to something other than "Confirmed Fraud",
   * then clears verification status on associated COB's Primary ID Document.
   *
   * @param records List of Case records being processed in the current transaction
   * @param oldMap Map of previous values for the Case records, keyed by Id
   */
  public static void updatePidStatus(List<Case> records, Map<Id, Case> oldMap) {
    records = ListUtil.filter(records, oldMap)
      .oldEquals(Case.Status, COBCaseConstants.COB_DAON_FALLOUT_STATUS)
      .equals(Case.Status, COBCaseConstants.COB_NOT_A_FRAUD_STATUS)
      .toList();
    Set<Id> cobIds = ListUtil.getIds(
      records,
      Case.CustomerOnboardingApplication__c
    );
    List<CustomerOnboardingApplication__c> cobs = COB_CASE_REPO.queryCobsWithPid(
      cobIds
    );
    List<COBPrimaryIDDocument__c> pids = clearPIDVerificationStatusFromCOB(
      cobs
    );
    DML.doUpdate(pids, new DmlConfig().withoutSharing());
  }

  @TestVisible
  private static List<COBPrimaryIDDocument__c> clearPIDVerificationStatusFromCOB(
    List<CustomerOnboardingApplication__c> cobs
  ) {
    List<COBPrimaryIDDocument__c> pids = new List<COBPrimaryIDDocument__c>();
    for (CustomerOnboardingApplication__c cob : cobs) {
      if (cob.COBPrimaryIDDocuments__r.isEmpty()) {
        continue;
      }
      pids.add(
        new COBPrimaryIDDocument__c(
          Id = cob.COBPrimaryIDDocuments__r[0].Id,
          Verified_By__c = null,
          Verification_Date_Time__c = null,
          Verification_Status__c = null,
          Verification_Failed_Reason__c = null,
          Failed_Message__c = null
        )
      );
    }
    return pids;
  }
}

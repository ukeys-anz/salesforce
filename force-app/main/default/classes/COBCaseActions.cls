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
    //Filter records with status updated
    records = ListUtil.filter(records, oldMap).changed(Case.Status).toList();

    Map<Id, Case> parentIdAndChildCasedMap = (Map<Id, Case>) ListUtil.mapBy(
      records,
      Case.ParentId
    );

    //Set the Parent ID Ops Status and Onboarding Reason values
    List<Case> idOpsCases = setIDOpsCaseStatus(
      parentIdAndChildCasedMap,
      oldMap
    );

    //Update the Parent Id Ops case records
    DML.doUpdate(idOpsCases, new DmlConfig().systemMode());
  }

  /**
   * @description Get ID Ops Cases and Set their Status and OnboardingVerificationFailedReason__c accordingly
   * @param parentIdAndChildCasedMap Id Ops ids and case details
   * @param oldMap map of records id and old records
   * @return List<Case> List of cases with set status
   */
  @TestVisible
  private static List<Case> setIDOpsCaseStatus(
    Map<Id, Case> parentIdAndChildCasedMap,
    Map<Id, Case> oldMap
  ) {
    List<Case> idOpsCases = COB_CASE_REPO.getCasesByIds(
      parentIdAndChildCasedMap.keySet()
    );

    for (Case idOpsCase : idOpsCases) {
      Case fraudCheckCase = parentIdAndChildCasedMap.get(idOpsCase.Id);

      if (
        fraudCheckCase.Status == COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS
      ) {
        idOpsCase.Status = COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS;
        idOpsCase.OnboardingVerificationFailedReason__c = fraudCheckCase.OnboardingVerificationFailedReason__c;
      } else {
        idOpsCase.Status = oldMap.get(fraudCheckCase.Id).Status;
      }
    }

    return idOpsCases;
  }
}

/**
 * @author Hrushikesh
 * @since 05/2025
 * @description Action class for QualityAssessment Lending Evaluation.
 */
public with sharing class LendingEvaluationActions {
  private static final String REQUIREMENT_NOT_MEANT_PROCESS_ONLY = 'Requirements Not Met (Process only)';
  private static final String REQUIREMENT_NOT_MEANT_COMPLIANCE = 'Requirements Not Met (Compliance)';
  private static final String REQUIREMENT_MET = 'Requirements Met';

  private static Set<SObjectField> fieldsToCheckForLendingCalculation = new Set<SObjectField>{
    Quality_Assessment__c.Serviceability_Outcome__c,
    Quality_Assessment__c.Income_Serviceability_Outcome__c,
    Quality_Assessment__c.Expenses_Serviceability_Outcome__c,
    Quality_Assessment__c.Debts_Serviceability_Outcome__c,
    Quality_Assessment__c.Conduct_Outcome__c,
    Quality_Assessment__c.Purpose_of_Loan_Outcome__c,
    Quality_Assessment__c.Collateral_Valuation_Outcome__c,
    Quality_Assessment__c.Material_Change_Outcome__c,
    Quality_Assessment__c.Hypercare_Focus_Area_Outcome__c,
    Quality_Assessment__c.Other__c,
    Quality_Assessment__c.Case_Notes_Outcome__c
  };

  private static Set<SObjectField> fieldsToCheckForIsChanged = new Set<SObjectField>{
    Quality_Assessment__c.Status__c
  };

  static {
    fieldsToCheckForIsChanged.addAll(fieldsToCheckForLendingCalculation);
  }

  private static final QualityAssessmentRepository QA_REPOSITORY = (QualityAssessmentRepository) Lib_InstanceProvider.forType(
    QualityAssessmentRepository.class
  );

  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description setEvaluationOutcomeFields sets Process and Execution Outcome and Risk and Compliance Outcome fields.
   * @param records Quality_Assessment__c records
   * @param oldMap oldMap
   */
  public static void setProcessExecutionOutcome(
    List<Quality_Assessment__c> records,
    Map<Id, Quality_Assessment__c> oldMap
  ) {
    List<Quality_Assessment__c> requirmentNotMetQaRecords = ListUtil.filter(
        records
      )
      .equals(
        Quality_Assessment__c.Status__c,
        new Set<String>{ 'Complete', 'Referred' }
      )
      .anyChanged(fieldsToCheckForIsChanged)
      .anyEqual(
        fieldsToCheckForLendingCalculation,
        REQUIREMENT_NOT_MEANT_PROCESS_ONLY
      )
      .toList();

    Map<Id, Quality_Assessment__c> requirmentNotMetQaRecordsMap = new Map<Id, Quality_Assessment__c>(
      requirmentNotMetQaRecords
    );

    ListUtil.setField(
      requirmentNotMetQaRecords,
      Quality_Assessment__c.Process_Execution_Outcome__c,
      REQUIREMENT_NOT_MEANT_PROCESS_ONLY
    );

    for (Quality_Assessment__c qaRecord : records) {
      if (requirmentNotMetQaRecordsMap.containsKey(qaRecord.Id)) {
        continue;
      }
      qaRecord.Process_Execution_Outcome__c = REQUIREMENT_MET;
    }
  }

  /**
   * @description setEvaluationOutcomeFields sets Process and Execution Outcome and Risk and Compliance Outcome fields.
   * @param records Quality_Assessment__c records
   * @param oldMap oldMap
   */
  public static void setRiskAndComplianceOutcome(
    List<Quality_Assessment__c> records,
    Map<Id, Quality_Assessment__c> oldMap
  ) {
    List<Quality_Assessment__c> requirmentNotMetComplianceQaRecords = ListUtil.filter(
        records
      )
      .equals(
        Quality_Assessment__c.Status__c,
        new Set<String>{ 'Complete', 'Referred' }
      )
      .anyChanged(fieldsToCheckForIsChanged)
      .anyEqual(
        fieldsToCheckForLendingCalculation,
        REQUIREMENT_NOT_MEANT_COMPLIANCE
      )
      .toList();

    Map<Id, Quality_Assessment__c> requirmentNotMetComplianceQaRecordsMap = new Map<Id, Quality_Assessment__c>(
      requirmentNotMetComplianceQaRecords
    );

    ListUtil.setField(
      requirmentNotMetComplianceQaRecords,
      Quality_Assessment__c.Risk_and_Compliance_Outcome__c,
      REQUIREMENT_NOT_MEANT_COMPLIANCE
    );

    for (Quality_Assessment__c qaRecord : records) {
      if (requirmentNotMetComplianceQaRecordsMap.containsKey(qaRecord.Id)) {
        continue;
      }
      qaRecord.Risk_and_Compliance_Outcome__c = REQUIREMENT_MET;
    }
  }

  /**
   * @description calculateAndSetNumberOfApplication sets number of rla application for the given rla customer
   * @param records Quality_Assessment__c records
   * @param oldMap oldMap
   */
  public static void calculateAndSetNumberOfApplication(
    List<Quality_Assessment__c> records,
    Map<Id, Quality_Assessment__c> oldMap
  ) {
    List<Quality_Assessment__c> eligibleRecords = ListUtil.filter(
        records,
        oldMap
      )
      .changed(Quality_Assessment__c.Application_ID__c)
      .isNotNull(Quality_Assessment__c.Application_ID__c)
      .toList();

    Set<Id> rlaIds = ListUtil.getIds(
      eligibleRecords,
      Quality_Assessment__c.Application_ID__c
    );

    Map<Id, ResidentialLoanApplication> rlaRecords = new Map<Id, ResidentialLoanApplication>(
      QA_REPOSITORY.getRlaByIds(rlaIds)
    );

    Set<Id> accountIds = ListUtil.getIds(
      rlaRecords.values(),
      ResidentialLoanApplication.AccountId
    );

    List<AggregateResult> rlaByCustomer = QA_REPOSITORY.getRlaByCustomer(
      accountIds
    );

    Map<Id, Integer> numberOfApplicationByCustomer = getNumberOfApplicationByCustomer(
      rlaByCustomer
    );

    setNumberOfApplication(
      eligibleRecords,
      rlaRecords,
      numberOfApplicationByCustomer
    );
  }

  /**
   * @description getNumberOfApplicationByCustomer returns the map of accountId to number of application
   * @param rlaByCustomer List of AggregateResult for rla by customer
   * @return `numberOfApplicationByCustomer` number of application by customer
   */
  private static Map<Id, Integer> getNumberOfApplicationByCustomer(
    List<AggregateResult> rlaByCustomer
  ) {
    Map<Id, Integer> numberOfApplicationByCustomer = new Map<Id, Integer>();
    for (AggregateResult rla : rlaByCustomer) {
      numberOfApplicationByCustomer.put(
        (Id) rla.get('AccountId'),
        (Integer) rla.get('rlaCount')
      );
    }
    return numberOfApplicationByCustomer;
  }

  /**
   * @description setNumberOfApplication sets number of application for the given rla customer
   * @param records QA records
   * @param rlaRecords RLA records
   * @param numberOfApplicationByCustomer number of application by customer
   */
  private static void setNumberOfApplication(
    List<Quality_Assessment__c> records,
    Map<Id, ResidentialLoanApplication> rlaRecords,
    Map<Id, Integer> numberOfApplicationByCustomer
  ) {
    for (Quality_Assessment__c record : records) {
      ResidentialLoanApplication rlaRecord = rlaRecords.get(
        record.Application_ID__c
      );
      if (!numberOfApplicationByCustomer.containsKey(rlaRecord.AccountId)) {
        continue;
      }
      record.Number_of_Applications__c = numberOfApplicationByCustomer.get(
        rlaRecord.AccountId
      );
    }
  }

  /**
   * @description createQAShareRecordsForLendingEvaluation creates sharing record for the given lending evaluations
   * @param records Quality_Assessment__c records
   * @param oldMap oldMap
   */
  public static void createQAShareRecordsForLendingEvaluation(
    List<Quality_Assessment__c> records,
    Map<Id, Quality_Assessment__c> oldMap
  ) {
    List<Quality_Assessment__c> eligibleRecords = ListUtil.filter(
        records,
        oldMap
      )
      .equals(Quality_Assessment__c.Sub_Status__c, 'Evaluation Completed')
      .changed(Quality_Assessment__c.Application_ID__c)
      .isNotNull(Quality_Assessment__c.Application_ID__c)
      .toList();

    Set<Id> rlaIds = ListUtil.getIds(
      eligibleRecords,
      Quality_Assessment__c.Application_ID__c
    );

    Map<Id, ResidentialLoanApplication> rlaRecords = new Map<Id, ResidentialLoanApplication>(
      QA_REPOSITORY.getRlaByIds(rlaIds)
    );

    List<Quality_Assessment__Share> qaShareRecsToDelete = QA_REPOSITORY.getQAShareRecords(
      eligibleRecords
    );

    DML.doDelete(
      qaShareRecsToDelete,
      new DmlConfig().systemMode().withoutSharing()
    );

    List<Quality_Assessment__Share> qaShareRecords = createQAShareRecords(
      eligibleRecords,
      rlaRecords
    );

    DML.doInsert(qaShareRecords, new DmlConfig().systemMode().withoutSharing());
  }

  /**
   * @description createQAShareRecords creates share record for the given lending evaluations
   * @param records Quality_Assessment__c records
   * @param rlaRecords oldMap
   * @return `qaShareRecords` QA Share records
   */
  private static List<Quality_Assessment__Share> createQAShareRecords(
    List<Quality_Assessment__c> records,
    Map<Id, ResidentialLoanApplication> rlaRecords
  ) {
    List<Quality_Assessment__Share> qaShareRecords = new List<Quality_Assessment__Share>();
    for (Quality_Assessment__c qa : records) {
      String ownerId = rlaRecords.get(qa.Application_ID__c).OwnerId;
      if (ownerId.startsWith('00G')) {
        continue;
      }
      Quality_Assessment__Share newQAShare = new Quality_Assessment__Share(
        AccessLevel = 'Read',
        ParentId = qa.Id,
        UserOrGroupId = rlaRecords.get(qa.Application_ID__c).OwnerId,
        RowCause = Schema.Quality_Assessment__Share.RowCause.ApexSharing__c
      );
      qaShareRecords.add(newQAShare);
    }
    return qaShareRecords;
  }
}

/**
 * @author Aman
 * @since 05/2025
 * @description Action class for QualityAssessmentTriggerActions.
 */
public with sharing class QualityAssessmentTriggerActions {
  static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  static final QualityAssessmentRepository QA_REPOSITORY = (QualityAssessmentRepository) Lib_InstanceProvider.forType(
    QualityAssessmentRepository.class
  );

  private static final Set<SObjectField> FIELDS_TO_CHECK_FOR_CHANGE = new Set<SObjectField>{
    Quality_Assessment__c.Status__c,
    Quality_Assessment__c.Connection_and_Trust__c,
    Quality_Assessment__c.Energy_and_Adaptability__c,
    Quality_Assessment__c.Discover_and_Align__c,
    Quality_Assessment__c.Actions_and_Momentum__c,
    Quality_Assessment__c.Accountability_and_Next_Steps__c
  };

  private static final Set<SObjectField> FIELDS_TO_CHECK_FOR_COMPLIANCE_CHANGE = new Set<SObjectField>{
    Quality_Assessment__c.Status__c,
    Quality_Assessment__c.Risk_and_Compliance_Category__c
  };

  /**
   * @description calculates the score for the quality assessment record
   * @param records Quality_Assessment__c records
   * @param oldMap Quality_Assessment__c  oldMap
   */
  public static void calculateQAGetHelp(
    List<Quality_Assessment__c> records,
    Map<Id, Quality_Assessment__c> oldMap
  ) {
    Map<String, QA_Get_Help_Rating_Table__mdt> getHelpRatingTable = QA_Get_Help_Rating_Table__mdt.getAll();
    List<Quality_Assessment__c> eligibleRecords = ListUtil.filter(
        records,
        oldMap
      )
      .anyChanged(FIELDS_TO_CHECK_FOR_CHANGE)
      .equals(
        Quality_Assessment__c.Status__c,
        new List<String>{ 'Complete', 'Referred' }
      )
      .toList();

    List<Quality_Assessment__c> eligibleRecordsInProgress = ListUtil.filter(
        records,
        oldMap
      )
      .anyChanged(FIELDS_TO_CHECK_FOR_CHANGE)
      .equals(Quality_Assessment__c.Status__c, 'In Progress')
      .allNotNull(FIELDS_TO_CHECK_FOR_CHANGE)
      .toList();

    eligibleRecords.addAll(eligibleRecordsInProgress);

    for (Quality_Assessment__c qaRecord : eligibleRecords) {
      qaRecord.Score__c = CalculateQARatingandAssessment.calculateRatingScore(
        qaRecord
      );

      qaRecord.Advice_Outcome__c = CalculateQARatingandAssessment.calculateAdviceOutcome(
        qaRecord
      );
      qaRecord.Rating__c = CalculateQARatingandAssessment.calculateRating(
        qaRecord.Score__c,
        getHelpRatingTable
      );
    }
  }

  /**
   * @description sets the score as blank for the quality assessment record that are In Progress Status
   * @param records Quality_Assessment__c records
   * @param oldMap Quality_Assessment__c  oldMap
   */
  public static void calculateQAGetHelpForInProgress(
    List<Quality_Assessment__c> records,
    Map<Id, Quality_Assessment__c> oldMap
  ) {
    List<Quality_Assessment__c> eligibleRecordsInProgress = ListUtil.filter(
        records,
        oldMap
      )
      .anyChanged(FIELDS_TO_CHECK_FOR_CHANGE)
      .equals(Quality_Assessment__c.Status__c, 'In Progress')
      .anyEqual(FIELDS_TO_CHECK_FOR_CHANGE, null)
      .toList();

    ListUtil.setField(
      eligibleRecordsInProgress,
      new Map<SObjectField, Object>{
        Quality_Assessment__c.Score__c => null,
        Quality_Assessment__c.Advice_Outcome__c => null,
        Quality_Assessment__c.Rating__c => null
      }
    );
  }

  /**
   * @description calculates the compliance outcome for the quality assessment record
   * @param records Quality_Assessment__c records
   * @param oldMap Quality_Assessment__c  oldMap
   */
  public static void calculateComplianceOutcome(
    List<Quality_Assessment__c> records,
    Map<Id, Quality_Assessment__c> oldMap
  ) {
    List<Quality_Assessment__c> eligibleRecords = ListUtil.filter(
        records,
        oldMap
      )
      .anyChanged(FIELDS_TO_CHECK_FOR_COMPLIANCE_CHANGE)
      .equals(
        Quality_Assessment__c.Status__c,
        new List<String>{ 'Complete', 'Referred', 'In Progress' }
      )
      .toList();

    for (Quality_Assessment__c qaRecord : eligibleRecords) {
      qaRecord.Compliance_Outcome__c = CalculateQARatingandAssessment.calculateComplianceOutcome(
        qaRecord
      );

      if (qaRecord.Risk_and_Compliance_Category__c == null) {
        qaRecord.Compliance_Outcome__c = null;
      }
    }
  }

  /**
   * @description method to create sharing record
   * @param records quality assessment records to update
   * @param oldMap map hold old value in trigger context
   */
  public static void createQAShareRecord(
    List<Quality_Assessment__c> records,
    Map<Id, Quality_Assessment__c> oldMap
  ) {
    List<Quality_Assessment__c> eligibleRecords = ListUtil.filter(
        records,
        oldMap
      )
      .changedTo(Quality_Assessment__c.Sub_Status__c, 'Evaluation Completed')
      .isNotNull(Quality_Assessment__c.Interaction_Owner__c)
      .toList();

    List<Quality_Assessment__c> interactionOwnerChangeRecords = ListUtil.filter(
        records,
        oldMap
      )
      .equals(Quality_Assessment__c.Sub_Status__c, 'Evaluation Completed')
      .changed(Quality_Assessment__c.Interaction_Owner__c)
      .isNotNull(Quality_Assessment__c.Interaction_Owner__c)
      .toList();

    eligibleRecords.addAll(interactionOwnerChangeRecords);

    List<Quality_Assessment__Share> qaShareRecsToDelete = QA_REPOSITORY.getQAShareRecords(
      eligibleRecords
    );

    DML.doDelete(
      qaShareRecsToDelete,
      new DmlConfig().systemMode().withoutSharing()
    );

    List<Quality_Assessment__Share> qaShareRecords = populateQAShareRecords(
      eligibleRecords
    );

    DML.doInsert(qaShareRecords, new DmlConfig().systemMode().withoutSharing());
  }

  /**
   * @description createQAShareRecords creats a QA share record for the given QA records
   * @param records quality assessment records to update
   * @return `qaShareRecords` QA Share records
   */
  public static List<Quality_Assessment__Share> populateQAShareRecords(
    List<Quality_Assessment__c> records
  ) {
    List<Quality_Assessment__Share> qaShareRecords = new List<Quality_Assessment__Share>();
    for (Quality_Assessment__c qa : records) {
      Quality_Assessment__Share newQAShare = new Quality_Assessment__Share(
        AccessLevel = 'Read',
        ParentId = qa.Id,
        UserOrGroupId = qa.Interaction_Owner__c,
        RowCause = Schema.Quality_Assessment__Share.RowCause.ApexSharing__c
      );
      qaShareRecords.add(newQAShare);
    }
    return qaShareRecords;
  }
}

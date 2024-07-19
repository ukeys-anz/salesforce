/**
 * @author Laxmi Vuyyuru
 * @since 19/2023
 * @description Quality Assessment related actions for CMOS
 * @runTests QualityAssessmentActionsTest
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class IDRQualityAssessmentActions {
  //  public static final String COMPLETION_ERROR = 'Team Manager Response is required before Completing an Assessment.';
  // Field Names must be all lower case
  public static final Set<String> MODIFIABLE_FIELDS = new Set<String>{
    'status__c',
    'assessment_completion_date__c',
    'business_score__c',
    'case_manager_score__c'
  };
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final IDRQualityAssessmentRepository IDR_QUALITY_ASESSMENT_QUERY = (IDRQualityAssessmentRepository) Lib_InstanceProvider.forType(
    IDRQualityAssessmentRepository.class
  );
  /**
   * @description calculate Case Manager Score and Business Manager Score
   * @param records new values
   */
  public static void autoCalculateScore(List<Quality_Assessment__c> records) {
    Map<String, QA_CMOS_Scoring_Table__mdt> getHelpRules = QA_CMOS_Scoring_Table__mdt.getAll();
    for (Quality_Assessment__c qaRecord : records) {
      String fieldSetName;
      if (
        qaRecord.Status__c == QualityAssessmentActions.STATUS_COMPLETE &&
        (qaRecord.Evaluation_Type__c == 'C & Q Assessment' ||
        qaRecord.Evaluation_Type__c == 'Call Review Assessment' ||
        qaRecord.Evaluation_Type__c == 'Letter Review Assessment')
      ) {
        if (qaRecord.Evaluation_Type__c == 'C & Q Assessment') {
          fieldSetName = 'C_Q_Assessment';
        } else if (qaRecord.Evaluation_Type__c == 'Call Review Assessment') {
          fieldSetName = 'Call_Review_Assessment';
        } else {
          fieldSetName = 'Letter_Review_Assessment';
        }
        Schema.FieldSet fieldSetObj = Schema.SObjectType.Quality_Assessment__c.fieldSets.getMap()
          .get(fieldSetName);

        Decimal naCount = 0;
        Decimal caseManagerScore = 0;
        Decimal businessScore = 0;
        String ratingApiConversion;
        //Questions which are unanswered
        Decimal skippedQuestionCount = 0;
        for (Schema.FieldSetMember field : fieldSetObj.getFields()) {
          String ratingValue = String.valueOf(
            ((SObject) qaRecord).get(field.getFieldPath())
          );
          switch on ratingValue {
            when null {
              skippedQuestionCount++;
              continue;
            }
            when 'Not met' {
              ratingApiConversion = 'Not_met';
            }
            when 'Not met (outside CM control)' {
              ratingApiConversion = 'Not_met_OCC';
            }
            when 'N/A' {
              ratingApiConversion = 'N_A';
              naCount++;
            }
            when else {
              ratingApiConversion = ratingValue;
            }
          }
          QA_CMOS_Scoring_Table__mdt ruleRecord = getHelpRules.get(
            fieldSetName + '_' + ratingApiConversion
          );
          if (ruleRecord != null && ruleRecord.Case_Manager_Score__c != null) {
            caseManagerScore += ruleRecord.Case_Manager_Score__c;
          }
          if (ruleRecord != null && ruleRecord.Business_Score__c != null) {
            businessScore += ruleRecord.Business_Score__c;
          }
        }
        if (qaRecord != null) {
          if (caseManagerScore != 0) {
            qaRecord.Case_Manager_Score__c =
              caseManagerScore *
              100 /
              (fieldSetObj.getFields().size() -
              skippedQuestionCount -
              naCount);
          } else {
            qaRecord.Case_Manager_Score__c = 0;
          }
          if (businessScore != 0) {
            qaRecord.Business_score__c =
              businessScore *
              100 /
              (fieldSetObj.getFields().size() -
              skippedQuestionCount -
              naCount);
          } else {
            qaRecord.Business_Score__c = 0;
          }
        }
      }
    }
  }

  /**
   * @description Use the Quality_Assessment__c record type and evaluation type to work out the fieldset id
   * @param oAssessment Quality_Assessment__c record for determining fieldset Id
   *
   * @return String fieldset Id matching record type and Evaluation Type
   */
  public static String getFieldsetId(Quality_Assessment__c oAssessment) {
    String strFieldSetId = '';
    if (oAssessment.RecordTypeId == IDRConstants.idrtCQQualityAssessment) {
      strFieldSetId = 'C_Q_Assessment';
    } else if (
      oAssessment.RecordTypeId ==
      IDRConstants.idrtCallLetterReviewQualityAssessment
    ) {
      if (oAssessment.Evaluation_Type__c == 'Call Review Assessment') {
        strFieldSetId = 'Call_Review_Assessment';
      } else if (oAssessment.Evaluation_Type__c == 'Letter Review Assessment') {
        strFieldSetId = 'Letter_Review_Assessment';
      }
    }
    return strFieldSetId;
  }

  /**
   * @description Validate that all mandatory fields have been entered when setting status to Complete
   * @param lstNewAssessments list of new changed assessments
   * @param mpOldAssessments map of prior values
   */
  @SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')
  public static void validateStatusComplete(
    List<Quality_Assessment__c> lstNewAssessments,
    Map<Id, Quality_Assessment__c> mpOldAssessments
  ) {
    Quality_Assessment__c oOldAssessment;
    String strFieldSetId;
    Map<String, FieldSet> mpAssessmentFieldSets = Schema.SObjectType.Quality_Assessment__c.fieldSets.getMap();
    Map<String, SObjectField> mpAssessmentFields = Schema.SObjectType.Quality_Assessment__c.fields.getMap();
    List<String> cqEditableFields = fetchFieldsFromQAFieldset(
      IDRConstants.CQ_EDITABLE_RESPONSE_FIELDS
    );
    Schema.FieldSet oFieldSet;
    Boolean fLoggerUsed = false;
    for (Quality_Assessment__c oAssessment : lstNewAssessments) {
      if (
        (oAssessment.RecordTypeId == IDRConstants.idrtCQQualityAssessment ||
        oAssessment.RecordTypeId ==
        IDRConstants.idrtCallLetterReviewQualityAssessment) &&
        oAssessment.Status__c == QualityAssessmentActions.STATUS_COMPLETE
      ) {
        strFieldSetId = getFieldsetId(oAssessment);
        if (
          strFieldSetId == '' ||
          (oFieldSet = mpAssessmentFieldSets.get(
            strFieldSetId + '_mandatory'
          )) == null
        ) {
          oAssessment.addError(
            'Configuration Error: Missing/Incorrect fieldset'
          );
          Logger.error(
            'Configuration Error: Unexpected RecordType/Evaluation Type combination.',
            oAssessment.Id
          );
          fLoggerUsed = true;
        } else {
          if (
            (mpOldAssessments == null ||
            (oOldAssessment = mpOldAssessments.get(oAssessment.Id)) == null ||
            oAssessment.Status__c != oOldAssessment.Status__c)
          ) {
            //Set Assessment Completion date to current date and time on assessment closure.
            oAssessment.Assessment_Completion_Date__c = System.now();
            for (Schema.FieldSetMember field : oFieldSet.getFields()) {
              if (((SObject) oAssessment).get(field.getFieldPath()) == null) {
                oAssessment.addError(
                  field.getSObjectField(),
                  'Required when changing Status to Complete'
                );
              }
            }
          }
        }
        if (mpOldAssessments != null && oOldAssessment != null) {
          for (String strFieldName : mpAssessmentFields.keySet()) {
            if (
              !MODIFIABLE_FIELDS.contains(strFieldName) &&
              ((SObject) oAssessment).get(strFieldName) !=
              ((SObject) oOldAssessment).get(strFieldName)
            ) {
              // This is where AvoidDeeplyNestedIfStmts trips up
              if (
                oAssessment.RecordTypeId ==
                IDRConstants.idrtCQQualityAssessment &&
                cqEditableFields.contains(strFieldName)
              ) {
                continue;
              }
              oAssessment.addError(
                mpAssessmentFields.get(strFieldName),
                'Cannot be modified'
              );
            }
          }
        }
      }
    }

    if (fLoggerUsed) {
      Logger.saveLog();
    }
  }
  /**
   * @description Fetch all the fields of a specified FieldSet
   * @param fieldSetName Name of the fieldSet from which fields should be extracted
   * @return list of Fields
   */
  private static List<String> fetchFieldsFromQAFieldset(String fieldSetName) {
    Schema.FieldSet fieldSet = Schema.SObjectType.Quality_Assessment__c.fieldSets.getMap()
      .get(fieldSetName);
    List<String> fieldsInFieldSet = new List<String>();
    for (Schema.FieldSetMember field : fieldSet.getFields()) {
      fieldsInFieldSet.add(field.getFieldPath().toLowerCase());
    }
    return fieldsInFieldSet;
  }
  /**
   * @description set the assessment outcome field on CQ assessment
   * @param records list of qa records
   * @param oldMap map of old QA records
   */
  public static void setAssessmentOutcomeStatus(
    List<Quality_Assessment__c> records,
    Map<Id, Quality_Assessment__c> oldMap
  ) {
    Id cqRecordTypeId = IDRConstants.idrtCQQualityAssessment;
    for (Quality_Assessment__c qaRecord : records) {
      SObjectField changedfieldAPIName = RecordComparisonUtil.detectWhichFieldWasChangedAndNotEqualNull(
        qaRecord,
        oldMap.get(qaRecord.Id),
        IDRConstants.QA_OUTCOME_FIELDS
      );
      if (
        qaRecord.RecordTypeId != cqRecordTypeId ||
        qaRecord.Status__c != IDRConstants.STATUS_COMPLETE ||
        changedfieldAPIName == null
      ) {
        continue;
      }
      qaRecord.Assessment_Outcome_Status__c = getStatus(
        qaRecord,
        changedfieldAPIName
      );
    }
  }
  /**
   * @description return assessment outcome field based on input values
   * @param qaRecord quality assessment record
   * @param fieldAPIName api name of the field changed
   * @return String value of the assessment outcome field
   */
  private static String getStatus(
    Quality_Assessment__c qaRecord,
    SObjectField fieldAPIName
  ) {
    return IDRConstants.qaAssessmentStatusMapping.get(
      String.valueOf(qaRecord.get(fieldAPIName))
    );
  }

}

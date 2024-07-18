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
  /**
   * @description Count Type of Quality_Assessment__c records for a particular Case.
   * @param records all records of Quality Assessment
   * @param oldMap map of old QA records
   */
  public static void countRecords(
    List<Quality_Assessment__c> records,
    Map<Id, Quality_Assessment__c> oldMap
  ) {
    Map<Id, List<Quality_Assessment__c>> caseIDQualityAssessmentFinalMap = new Map<Id, List<Quality_Assessment__c>>();

    Map<Id, List<Quality_Assessment__c>> caseIDQualityAssessmentMap = getCaseIdToQualityAssessmentMap(
      records,
      oldMap
    );
    Map<Id, Case> caseMap = new Map<Id, Case>(
      IDR_QUALITY_ASESSMENT_QUERY.getCases(caseIDQualityAssessmentMap.keyset())
    );

    caseIDQualityAssessmentFinalMap = updateCaseToQualityAssessmentMap(
      IDR_QUALITY_ASESSMENT_QUERY.getQualityAssessments(
        caseIDQualityAssessmentMap.keyset(),
        records
      ),
      caseIDQualityAssessmentMap
    );

    List<Case> casesToUpdate = getCasesToUpdateCompEvaluations(
      caseIDQualityAssessmentFinalMap,
      caseMap
    );
    if (!casesToUpdate.isEmpty()) {
      DML_REPOSITORY.updateRecords(
        casesToUpdate,
        DmlRepository.ALLOW_PARTIAL,
        DmlRepository.USER_MODE
      );
    }
  }
  /**
   * @description Get a List of Case with count of Completed Evaluation
   * @param caseIDQualityAssessmentMap map with Case to QualityAssessments which needs to be processed
   * @param caseMap map with Case to Completed Evaluation String
   * @return List List of Cases with Completed Evaluation to be updated.
   */
  private static List<Case> getCasesToUpdateCompEvaluations(
    Map<Id, List<Quality_Assessment__c>> caseIDQualityAssessmentMap,
    Map<Id, Case> caseMap
  ) {
    List<Case> casesToUpdate = new List<Case>();
    for (Id caseId : caseIDQualityAssessmentMap.keySet()) {
      Case cse = caseMap.get(caseId);
      cse.IDR_Completed_Evaluations__c = updateCompletedEvaluations(
        caseMap.get(caseId),
        caseIDQualityAssessmentMap.get(caseId)
      );
      casesToUpdate.add(cse);
    }
    return casesToUpdate;
  }

  /**
   * @description Get a Map of Cases with list of Quality Assessments coming in Trigger Context
   * @param records List of New Quality Assessments coming from Trigger Context
   * @param oldMap old trigger values
   * @return Map<Id, List<Quality_Assessment__c>> Map of Cases with Quality Assessments
   */

  private static Map<Id, List<Quality_Assessment__c>> getCaseIdToQualityAssessmentMap(
    List<Quality_Assessment__c> records,
    Map<Id, Quality_Assessment__c> oldMap
  ) {
    Map<Id, List<Quality_Assessment__c>> caseIDQualityAssessmentMap = new Map<Id, List<Quality_Assessment__c>>();
    Set<String> qaRecordTypeIds = new Set<String>{
      IDRConstants.idrtCQQualityAssessment,
      IDRConstants.idrtCallLetterReviewQualityAssessment
    };

    for (Quality_Assessment__c qa : records) {
      if (!qaRecordTypeIds.contains(qa.RecordTypeId)) {
        continue;
      }
      List<Quality_Assessment__c> tempQaList = new List<Quality_Assessment__c>();
      if (
        !oldMap.isEmpty() &&
        !RecordComparisonUtil.fieldWasChanged(
          qa,
          oldMap.get(qa.id),
          Quality_Assessment__c.status__c
        )
      ) {
        continue;
      }
      if (caseIDQualityAssessmentMap.containsKey(qa.Related_Case__c)) {
        tempQaList = caseIDQualityAssessmentMap.get(qa.Related_Case__c);
      }
      tempQaList.add(qa);
      caseIDQualityAssessmentMap.put(qa.Related_Case__c, tempQaList);
    }
    return caseIDQualityAssessmentMap;
  }
  /**
   * @description Get a Map of Case with list of Quality Assessments that needs to be updated
   * @param assessments List of Quality Assessments which are already completed
   * @param mapQualityAssessments map if cases with list of Quality Assessments coming from New Trigger Context
   * @return Map<Id, List<Quality_Assessment__c>> Map of Cases with Quality Assessments which needs to be processed for counting number of completed evaluation types on cases
   */

  @TestVisible
  private static Map<Id, List<Quality_Assessment__c>> updateCaseToQualityAssessmentMap(
    List<Quality_Assessment__c> assessments,
    Map<Id, List<Quality_Assessment__c>> mapQualityAssessments
  ) {
    for (Quality_Assessment__c objQualityAssessment : assessments) {
      List<Quality_Assessment__c> listQualityAssessments = new List<Quality_Assessment__c>();
      if (
        !String.isBlank(
          objQualityAssessment.Related_Case__r.IDR_Completed_Evaluations__c
        )
      ) {
        continue;
      }
      if (
        mapQualityAssessments.containsKey(objQualityAssessment.Related_Case__c)
      ) {
        listQualityAssessments = mapQualityAssessments.get(
          objQualityAssessment.Related_Case__c
        );
      }
      listQualityAssessments.add(objQualityAssessment);
      mapQualityAssessments.put(
        objQualityAssessment.Related_Case__c,
        listQualityAssessments
      );
    }
    return mapQualityAssessments;
  }

  /**
   * @description get existing count parsed from the IDR_Completed_Evaluations__c field example value: "Call Review: 1 | Letter Review: 1 | C&Q Evaluation: 1"
   * and update with the new completing Quality Assessments
   * @param idrCase Case record associated with all the Quality Assessments
   * @param newQAList all records of Quality Assessment
   * @return String value of the completed evaluation
   */
  @TestVisible
  private static String updateCompletedEvaluations(
    Case idrCase,
    List<Quality_Assessment__c> newQAList
  ) {
    Map<String, Integer> evaluationsCountMap = getEvaluationsCountMap(
      idrCase?.IDR_Completed_Evaluations__c
    );
    for (Quality_Assessment__c qA : newQAList) {
      if (qA.Status__c != IDRConstants.STATUS_COMPLETE) {
        continue;
      }

      if (qA.Evaluation_Type__c == IDRConstants.CALL_REVIEW_EVAL) {
        evaluationsCountMap.put(
          IDRConstants.CALL_REVIEW_EVAL,
          (evaluationsCountMap.get(IDRConstants.CALL_REVIEW_EVAL) + 1)
        );
      }
      if (qA.Evaluation_Type__c == IDRConstants.LETTER_EVAL) {
        evaluationsCountMap.put(
          IDRConstants.LETTER_EVAL,
          (evaluationsCountMap.get(IDRConstants.LETTER_EVAL) + 1)
        );
      }
      if (qA.Evaluation_Type__c == IDRConstants.CQ_EVAL) {
        evaluationsCountMap.put(
          IDRConstants.CQ_EVALCOUNT,
          (evaluationsCountMap.get(IDRConstants.CQ_EVALCOUNT) + 1)
        );
      }
    }
    return getUpdatedEvaluationsString(evaluationsCountMap);
  }
  /**
   * @description get count map of IDR_Completed_Evaluations__c which is already existing on Case
   * @param evaluationsString values of IDR_Completed_Evaluations__c that present on case
   * @return Map<String, Integer> value of the IDR_Completed_Evaluations__c
   */
  @TestVisible
  private static Map<String, Integer> getEvaluationsCountMap(
    String evaluationsString
  ) {
    Map<String, Integer> evaluationsCountMap = new Map<String, Integer>();
    evaluationsCountMap.put(IDRConstants.CALL_REVIEW_EVAL, 0);
    evaluationsCountMap.put(IDRConstants.LETTER_EVAL, 0);
    evaluationsCountMap.put(IDRConstants.CQ_EVALCOUNT, 0);
    if (String.isNotBlank(evaluationsString)) {
      List<String> evaluationsParts = evaluationsString.split(' \\| ');
      for (String evaluationPart : evaluationsParts) {
        List<String> partParts = evaluationPart.split(': ');
        if (partParts.size() == 2) {
          String evaluationType = partParts[0].trim();
          Integer count = Integer.valueOf(partParts[1].trim());
          evaluationsCountMap.put(evaluationType, count);
        }
      }
    }
    return evaluationsCountMap;
  }
  /**
   * @description get the value of  IDR_Completed_Evaluations__c with count of all completed QA
   * @param evaluationsCountMap map of Evaluation types to count of completed Evalaution that needs to be updated on case field IDR_Completed_Evaluations__c
   * @return String final value of IDR_Completed_Evaluations__c after count logic processed
   */

  @TestVisible
  private static String getUpdatedEvaluationsString(
    Map<String, Integer> evaluationsCountMap
  ) {
    String callReviewCount = evaluationsCountMap.containsKey(
        IDRConstants.CALL_REVIEW_EVAL
      )
      ? String.valueOf(evaluationsCountMap.get(IDRConstants.CALL_REVIEW_EVAL))
      : '0';
    String letterReviewCount = evaluationsCountMap.containsKey(
        IDRConstants.LETTER_EVAL
      )
      ? String.valueOf(evaluationsCountMap.get(IDRConstants.LETTER_EVAL))
      : '0';
    String cAndQEvaluationCount = evaluationsCountMap.containsKey(
        IDRConstants.CQ_EVALCOUNT
      )
      ? String.valueOf(evaluationsCountMap.get(IDRConstants.CQ_EVALCOUNT))
      : '0';
    return IDRConstants.CALL_REVIEW_EVAL +
      ': ' +
      callReviewCount +
      ' | ' +
      IDRConstants.LETTER_EVAL +
      ': ' +
      letterReviewCount +
      ' | ' +
      IDRConstants.CQ_EVALCOUNT +
      ': ' +
      cAndQEvaluationCount;
  }
}

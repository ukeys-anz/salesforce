/**
 * @author Laxmi Vuyyuru
 * @since 19/2023
 * @description Quality Assessment related actions for CMOS
 * @runTests QualityAssessmentActionsTest
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class IDRQualityAssessmentActions {
  /**
   * @description calculate Case Manager Score and Business Manager Score
   * @param records new values
   */
  public static void autoCalculateScore(List<Quality_Assessment__c> records) {
    Map<String, QA_CMOS_Scoring_Table__mdt> getHelpRules = QA_CMOS_Scoring_Table__mdt.getAll();
    for (Quality_Assessment__c qaRecord : records) {
      String fieldSetName;
      if (
        qaRecord.Status__c == 'Complete' &&
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
            when 'Not met (outside CM Control)' {
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
            fieldSetName +
            '_' +
            ratingApiConversion
          );
          if (ruleRecord != null && ruleRecord.Case_Manager_Score__c != null) {
            caseManagerScore += ruleRecord.Case_Manager_Score__c;
          }
          if (ruleRecord != null && ruleRecord.Business_Score__c != null) {
            businessScore += ruleRecord.Business_Score__c;
          }
        }
        if (qaRecord != null && caseManagerScore != 0) {
          qaRecord.Case_Manager_Score__c =
            caseManagerScore *
            100 /
            (fieldSetObj.getFields().size() -
            skippedQuestionCount -
            naCount);
        }
        if (qaRecord != null && businessScore != 0) {
          qaRecord.Business_score__c =
            businessScore *
            100 /
            (fieldSetObj.getFields().size() -
            skippedQuestionCount -
            naCount);
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
  public static void validateStatusComplete(
    List<Quality_Assessment__c> lstNewAssessments,
    Map<Id, Quality_Assessment__c> mpOldAssessments
  ) {
    Quality_Assessment__c oOldAssessment;
    String strFieldSetId;
    Map<String, FieldSet> mpAssessmentFieldSets = Schema.SObjectType.Quality_Assessment__c.fieldSets.getMap();
    Schema.FieldSet oFieldSet;
    Boolean fLoggerUsed = false;
    for (Quality_Assessment__c oAssessment : lstNewAssessments) {
      if (
        oAssessment.Status__c == QualityAssessmentActions.STATUS_COMPLETE &&
        (mpOldAssessments == null ||
        (oOldAssessment = mpOldAssessments.get(oAssessment.Id)) == null ||
        oAssessment.Status__c != oOldAssessment.Status__c)
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
          for (Schema.FieldSetMember field : oFieldSet.getFields()) {
            if (((SObject) oAssessment).get(field.getFieldPath()) == null) {
              oAssessment.addError(
                'Field [' +
                field.label +
                '] is required to change Status to Complete'
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
}

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
        Schema.FieldSet fieldSetObj = Schema.SObjectType.Quality_Assessment__c.FieldSets.getMap()
          .get(fieldSetName);

        Decimal naCount = 0;
        Decimal caseManagerScore = 0;
        Decimal businessScore = 0;
        String ratingApiConversion;
        //Questions which are unanswered
        Decimal skippedQuestionCount = 0;
        for (Schema.FieldSetMember field : fieldSetObj.getFields()) {
          String ratingValue = String.valueOf(
            ((Sobject) qaRecord).get(field.getFieldPath())
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
              ratingAPIConversion = ratingValue;
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
          qaRecord.Business_Score__c =
            businessScore *
            100 /
            (fieldSetObj.getFields().size() -
            skippedQuestionCount -
            naCount);
        }
      }
    }
  }
}

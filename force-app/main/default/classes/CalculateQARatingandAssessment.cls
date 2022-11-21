/**
 * @author Prakash Baskaran
 * @since 20220721
 * @description class for calculating QA
 */

public with sharing class CalculateQARatingandAssessment {
  public static final String RISK_ASSESSMENT_YES = 'Yes - Requirements met';
  public static final String JOIN_COMPLIANCE_YES = 'Effective';
  public static final String REQUIREMENTS_MET = 'Requirements Met';
  public static final String REQUIREMENTS_NOT_MET = 'Requirements not met';
  public static final String ALMOST_THERE = 'Almost there';
  public static final String EFFECTIVE = 'Effective';
  public static final String NA_VALUE = 'N/A';
  public static final String COMPLIANCE_ONLY_EVAL_TYPE = 'Compliance Only';

  public static boolean noError = false;
  public static final Id JOIN_RECORD_TYPE_ID = Schema.SObjectType.Quality_Assessment__c.getRecordTypeInfosByDeveloperName()
    .get('Join')
    .getRecordTypeId();
  public static final Id GET_HELP_RECORD_TYPE_ID = Schema.SObjectType.Quality_Assessment__c.getRecordTypeInfosByDeveloperName()
    .get('Get_Help')
    .getRecordTypeId();

  /**
   * @description Method which gets called from quick action
   * @param recordId Id the QA record for which calculation needs to be done
   * @return Boolean True or false based on if the QA update was successful or not
   */

  @AuraEnabled
  public static Boolean calculateQA(Id recordId) {
    if (Quality_Assessment__c.SObjectType.getDescribe().isQueryable()) {
      Quality_Assessment__c qaRecord = [
        SELECT
          Id,
          Evaluation_Type__c,
          Connection_and_Trust__c,
          Discover_and_Align__c,
          Actions_and_Momentum__c,
          Accountability_and_Next_Steps__c,
          Energy_and_Adaptability__c,
          Preparation_and_Framing__c,
          Insights_and_Focus__c,
          Finishing_Touches__c,
          Risk_and_Compliance_Category__c,
          Advice_Initial_Contact__c,
          Advice_Define_Scope__c,
          Advice_Customer_understanding_of_scope__c,
          Key_scoping_and_disclaimers__c,
          Advice_Limit_scope_of_advice__c,
          Advice_Decline_advice_and_refer__c,
          Advice_Substantive_Advice_OFSN__c,
          Join_Actions_Taken__c,
          Join_Blocks_Applied_where_Appropriate__c,
          Join_Case_Data_Field_Accuracy__c,
          Join_Case_Record_Accuracy__c,
          Join_Compliance_Behaviour__c,
          Join_Compliance_Disclaimers__c,
          Join_Compliance_Identification__c,
          Join_Compliance_Information__c,
          Join_Financial_Operation_Accuracy__c,
          Join_Overall_Decision_Supported__c,
          Join_Business_Actions_Taken__c,
          Join_Business_Case_Record__c,
          Join_Business_Information__c,
          Join_Customer_Accountable__c,
          Join_Customer_Caring__c,
          Join_Customer_Interested__c,
          Join_Customer_Respect__c,
          Join_Customer_Welcoming__c,
          Advice_Fact_Find__c,
          CN_Fact_Find__c,
          Advice_Best_Interest_Duty__c,
          Advice_Dispute_Resolution__c,
          Advice_Incomplete_Inaccurate_warning__c,
          CN_Customers_Focus__c,
          CN_Substantive_Advice__c,
          CN_Out_of_Scope__c,
          CN_OFSN__c,
          CN_Scope_Provided__c,
          RecordTypeId,
          CN_Checklist__c
        FROM Quality_Assessment__c
        WHERE Id = :recordId
        LIMIT 1
      ];

      qaRecord.Calculated__c = true;
      qaRecord.Score__c = calculateRatingScore(qaRecord);
      if (qaRecord.RecordTypeId == GET_HELP_RECORD_TYPE_ID) {
        qaRecord.Compliance_Outcome__c = calculateComplianceOutcome(qaRecord);
        qaRecord.Advice_Outcome__c = calculateAdviceOutcome(qaRecord);
        Map<String, QA_Get_Help_Rating_Table__mdt> getHelpRatingTable = QA_Get_Help_Rating_Table__mdt.getAll();
        qaRecord.Rating__c = calculateRating(
          qaRecord.Score__c,
          getHelpRatingTable
        );
      } else if (qaRecord.RecordTypeId == JOIN_RECORD_TYPE_ID) {
        qaRecord.Compliance_Outcome__c = calculateComplianceOutcomeJoin(
          qaRecord
        );
        Map<String, QA_Join_Rating_Table__mdt> joinRatingTable = QA_Join_Rating_Table__mdt.getAll();
        qaRecord.Rating__c = calculateRating(
          qaRecord.Score__c,
          JoinRatingTable
        );
      }

      updateQualityAssessment(qaRecord);
      noError = true;
    } else {
      CommonUtil.logAndThrowIAE(
        'CalculateQARatingandAssessment',
        'calculateQA',
        'Not enough permissions to query Quality Assessment.'
      );
    }

    return noError;
  }

  /**
   * @description Method to calculate the final rating for QA
   * @param score The score calculated for the QA
   * @param ratingTable the get help rating table
   * @return String The final rating to be updated on the QA record.
   */

  public static String calculateRating(
    Decimal score,
    Map<String, QA_Get_Help_Rating_Table__mdt> ratingTable
  ) {
    String rating = '';

    for (String keyVal : ratingTable.keySet()) {
      if (
        score >= ratingTable.get(keyVal).Min_Value__c &&
        score <= ratingTable.get(keyVal).Max_Value__c
      ) {
        rating = ratingTable.get(keyVal).Rating__c;
      }
    }

    return rating;
  }
  /**
   * @description Method to calculate the final rating for QA
   * @param score The score calculated for the QA
   * @param ratingTable the join rating table
   * @return String The final rating to be updated on the QA record.
   */
  public static String calculateRating(
    Decimal score,
    Map<String, QA_Join_Rating_Table__mdt> ratingTable
  ) {
    String rating = '';

    for (String keyVal : ratingTable.keySet()) {
      if (
        score >= ratingTable.get(keyVal).Min_Value__c &&
        score <= ratingTable.get(keyVal).Max_Value__c
      ) {
        rating = ratingTable.get(keyVal).Rating__c;
      }
    }

    return rating;
  }

  /**
   * @description Method to update the quality assessment records
   * @param qaRecord QA record to be updated
   * @return Decimal the score value to be updated
   */

  public static Decimal calculateRatingScore(Quality_Assessment__c qaRecord) {
    Decimal score = qaRecord.Evaluation_Type__c == COMPLIANCE_ONLY_EVAL_TYPE
      ? null
      : 0;
    Map<String, Decimal> scoringMap = new Map<String, Decimal>();
    List<Schema.FieldSetMember> scoreCalcFields = new List<Schema.FieldSetMember>();

    if (qaRecord.RecordTypeId == GET_HELP_RECORD_TYPE_ID) {
      Map<String, QA_Get_Help_Scoring_Table__mdt> scoringTable = QA_Get_Help_Scoring_Table__mdt.getAll();
      scoringMap = getScoringMap(scoringTable);
      scoreCalcFields = SObjectType.Quality_Assessment__c.FieldSets.Scoring_Fieldset.getFields();
    } else if (qaRecord.RecordTypeId == JOIN_RECORD_TYPE_ID) {
      Map<String, QA_Join_Scoring_Table__mdt> scoringTable = QA_Join_Scoring_Table__mdt.getAll();
      scoringMap = getScoringMap(scoringTable);
      scoreCalcFields = SObjectType.Quality_Assessment__c.FieldSets.Join_Scoring_Fieldset.getFields();
    }
    for (Schema.FieldSetMember f : scoreCalcFields) {
      String keyVal =
        qaRecord.Evaluation_Type__c +
        f.getFieldpath() +
        (String) qaRecord.get(f.getFieldpath());
      if (scoringMap.containsKey(keyVal)) {
        score = score + scoringMap.get(keyVal);
      }
    }

    return score;
  }

  /**
   * @description Method to get the metadata mapping for scoring calculation
   * @param scoringTable get help scoring table
   * @return Map<String, Decimal> Map of key combination with the score value.
   */

  public static Map<String, Decimal> getScoringMap(
    Map<String, QA_Get_Help_Scoring_Table__mdt> scoringTable
  ) {
    Map<String, Decimal> scoringMap = new Map<String, Decimal>();
    for (String keyVal : scoringTable.keySet()) {
      scoringMap.put(
        scoringTable.get(keyVal).Evaluation_Type__c +
        scoringTable.get(keyVal).CX_Criteria_Field__c +
        scoringTable.get(keyVal).Rating__c,
        scoringTable.get(keyVal).Score__c
      );
    }
    return scoringMap;
  }
  /**
   * @description Method to get the metadata mapping for scoring calculation
   * @param scoringTable jon scoring table
   * @return Map<String, Decimal> Map of key combination with the score value.
   */

  public static Map<String, Decimal> getScoringMap(
    Map<String, QA_Join_Scoring_Table__mdt> scoringTable
  ) {
    Map<String, Decimal> scoringMap = new Map<String, Decimal>();
    for (String keyVal : scoringTable.keySet()) {
      scoringMap.put(
        scoringTable.get(keyVal).Evaluation_Type__c +
        scoringTable.get(keyVal).CX_Criteria_Field__c +
        scoringTable.get(keyVal).Rating__c,
        scoringTable.get(keyVal).Score__c
      );
    }
    return scoringMap;
  }

  /**
   * @description Method to update the quality assessment records
   * @param qaRecord QA record to be updated
   */

  public static void updateQualityAssessment(Quality_Assessment__c qaRecord) {
    if (Quality_Assessment__c.sObjectType.getDescribe().isUpdateable()) {
      List<Quality_Assessment__c> qaList = new List<Quality_Assessment__c>();
      qaList.add(qaRecord);
      List<Database.SaveResult> results = Database.Update(qaList, false);
      Logger.error('', results);
      Logger.saveLog();
    } else {
      //If the user does not have permission to update the quality assessment object log an error.
      CommonUtil.logAndThrowIAE(
        'CalculateQARatingandAssessment',
        'updateQualityAssessment',
        'Not enough permissions to update Quality Assessment.'
      );
    }
  }

  /**
   * @description Method to calculate the compliance outcome value for Get Help
   * @param qaRecord QA record for which outcome has to be calculated
   * @return String Calculated compliance outcome value
   */

  public static String calculateComplianceOutcome(
    Quality_Assessment__c qaRecord
  ) {
    String complianceOutcome = '';

    if (qaRecord.Risk_and_Compliance_Category__c == RISK_ASSESSMENT_YES) {
      complianceOutcome = REQUIREMENTS_MET;
    } else {
      complianceOutcome = REQUIREMENTS_NOT_MET;
    }

    return complianceOutcome;
  }

  /**
   * @description Method to calculate the compliance outcome value for Join
   * @param qaRecord QA record for which outcome has to be calculated
   * @return String Calculated compliance outcome value
   */

  public static String calculateComplianceOutcomeJoin(
    Quality_Assessment__c qaRecord
  ) {
    String complianceOutcome = '';

    if (
      qaRecord.Join_Compliance_Behaviour__c == JOIN_COMPLIANCE_YES &&
      qaRecord.Join_Compliance_Disclaimers__c == JOIN_COMPLIANCE_YES &&
      qaRecord.Join_Compliance_Identification__c == JOIN_COMPLIANCE_YES &&
      qaRecord.Join_Compliance_Information__c == JOIN_COMPLIANCE_YES
    ) {
      complianceOutcome = REQUIREMENTS_MET;
    } else {
      complianceOutcome = REQUIREMENTS_NOT_MET;
    }

    return complianceOutcome;
  }

  /**
   * @description Method to calculate the advice outcome value
   * @param qaRecord QA record for which outcome has to be calculated
   * @return String Calculated final advice outcome value
   */

  public static String calculateAdviceOutcome(Quality_Assessment__c qaRecord) {
    Map<String, Integer> adviceResponseCountMap = new Map<String, Integer>();
    //Fieldset containing all the advice outcome fields
    List<Schema.FieldSetMember> adviceOutcomeFields = SObjectType.Quality_Assessment__c.FieldSets.Advice_Outcome_Field_Set.getFields();

    adviceResponseCountMap = countAdviceOutcomeResponse(
      qaRecord,
      adviceOutcomeFields
    );

    String finalAdviceOutcome = '';
    Integer naCount = adviceResponseCountMap.containsKey(NA_VALUE)
      ? adviceResponseCountMap.get(NA_VALUE)
      : 0;
    if (adviceResponseCountMap.containsKey(REQUIREMENTS_NOT_MET)) {
      finalAdviceOutcome = REQUIREMENTS_NOT_MET;
    } else if (adviceResponseCountMap.containsKey(ALMOST_THERE)) {
      Integer almostThereCount = adviceResponseCountMap.get(ALMOST_THERE);
      if (
        (naCount >= 11 && almostThereCount >= 4) ||
        (naCount < 11 &&
        almostThereCount > 4)
      ) {
        finalAdviceOutcome = REQUIREMENTS_NOT_MET;
      } else if (
        (naCount >= 11 && almostThereCount >= 2) ||
        (naCount < 11 &&
        almostThereCount > 2)
      ) {
        finalAdviceOutcome = ALMOST_THERE;
      } else {
        finalAdviceOutcome = EFFECTIVE;
      }
    } else if (adviceResponseCountMap.containsKey(EFFECTIVE)) {
      finalAdviceOutcome = EFFECTIVE;
    }

    return finalAdviceOutcome;
  }

  /**
   * @description Method which counts the response values for advice outcome fields
   * @param qaRecord QA record for which outcome has to be calculated
   * @param adviceOutcomeFields List of advice supplement section feilds used for advice outcome calculation
   * @return Map<String, Integer> Map containing the response and the count for each response
   */

  public static Map<String, Integer> countAdviceOutcomeResponse(
    Quality_Assessment__c qaRecord,
    List<Schema.FieldSetMember> adviceOutcomeFields
  ) {
    Map<String, Integer> adviceResponseCountMap = new Map<String, Integer>();

    for (Schema.FieldSetMember f : adviceOutcomeFields) {
      Integer count = 1;
      String adviceResponseValue = (String) qaRecord.get(f.getFieldpath());
      if (!String.isBlank(adviceResponseValue)) {
        if (adviceResponseCountMap.containsKey(adviceResponseValue)) {
          count = adviceResponseCountMap.get(adviceResponseValue) + 1;
        }

        adviceResponseCountMap.put(adviceResponseValue, count);
      }
    }
    return adviceResponseCountMap;
  }
}

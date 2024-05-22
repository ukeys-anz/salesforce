/**
 * @author cruzb
 * @since May 2023
 * @description Controller for Credit Assessment flex card
 */
global with sharing class CreditAssessmentController implements omnistudio.VlocityOpenInterface, Callable {
  private static final String STATUS_DECLINED = 'STATE_DECLINED';
  private static final String DECLINED = 'Declined';

  private static UserRole bohCoachRole = CommonUtil.getUserRoleByDevName(
    'BOH_Coach'
  );
  private static UserRole creditAssessmentOfficerRole = CommonUtil.getUserRoleByDevName(
    'Credit_Assessment_Officer'
  );
  private static UserRole creditAssessorLeadRole = CommonUtil.getUserRoleByDevName(
    'Credit_Assessor_Lead'
  );

  /**
   * @param action String value of local method to invoke
   * @param args arg map that will contain input, output and options map
   * @return `Object`
   * @description flex card invokeable method overridden by callable interface
   */
  public Object call(String action, Map<String, Object> args) {
    Map<String, Object> input = (Map<String, Object>) args.get('input');
    Map<String, Object> output = (Map<String, Object>) args.get('output');
    Map<String, Object> options = (Map<String, Object>) args.get('options');

    return invokeMethod(action, input, output, options);
  }

  /**
   * @param methodName String value of local method to invoke
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description flex card invokeable method
   */
  public Boolean invokeMethod(
    String methodName,
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    if (methodName.equals('getCreditAssessments')) {
      return getCreditAssessments(input, output, options);
    } else if (methodName.equals('getSelectOptions')) {
      return getSelectOptions(input, output, options);
    } else if (methodName.equals('saveReferralChange')) {
      return saveReferralChange(input, output, options);
    } else if (methodName.equals('getAssessmentOutcome')) {
      return getAssessmentOutcome(input, output, options);
    } else if (methodName.equals('deleteReferralOutcome')) {
      return deleteReferralOutcome(input, output, options);
    }
    return false;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description calls callout framework and sanitizes payload for flexcard
   */
  private Boolean getCreditAssessments(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    try {
      Case c = [
        SELECT Account.OCV_Id__c
        FROM Case
        WHERE Id = :String.valueOf(input.get('recordId'))
      ];

      CreditAssessmentAPIRepository api = new CreditAssessmentAPIRepository();
      CreditReferralModel cr = api.getCreditAssessments(
        String.valueOf(input.get('creditId')),
        c.Account.OCV_ID__c
      );

      if (cr.assessments.isEmpty()) {
        return false;
      }

      assignReasonFields(cr, String.valueOf(input.get('recordId')));
      output.put(
        'object',
        JSON.deserializeUntyped(JSON.serialize(splitCurrentAndHistory(cr)))
      );
      return true;
    } catch (Exception e) {
      CreditReferralModel cr = new CreditReferralModel();
      cr.hasError = true;
      output.put('object', JSON.deserializeUntyped(JSON.serialize(cr)));
      return false;
    }
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description output is the credit assessment result details for flexcard
   */
  private Boolean getAssessmentOutcome(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    ResidentialLoanApplication rla = [
      SELECT Account.OCV_Id__c, Credit_ID__c, Status
      FROM ResidentialLoanApplication
      WHERE Id = :String.valueOf(input.get('ApplicationId'))
    ];
    if (rla.Status != STATUS_DECLINED) {
      return false;
    }

    CreditAssessmentAPIRepository api = new CreditAssessmentAPIRepository();
    CreditReferralModel cr = api.getCreditAssessments(
      rla.Credit_ID__c,
      rla.Account.OCV_ID__c
    );
    if (cr.assessments.isEmpty()) {
      return false;
    }
    AssessmentOutcome outcome = new AssessmentOutcome();
    List<AssessmentOutcomeRow> lstOutcomeRow = new List<AssessmentOutcomeRow>();

    for (CreditReferralModel.Assessment crAssessment : cr.assessments) {
      if (crAssessment?.outcome == DECLINED) {
        outcome.lastModified = crAssessment.assessTime;
        for (CreditReferralModel.Reason r : crAssessment.reasons) {
          AssessmentOutcomeRow outcomeRow = new AssessmentOutcomeRow();
          outcomeRow.reasonCode = r.reasonCode;
          outcomeRow.description = r.reasonDescription;
          lstOutcomeRow.add(outcomeRow);
        }
        outcome.rows = lstOutcomeRow;
        break;
      }
    }
    output.put('object', JSON.deserializeUntyped(JSON.serialize(outcome)));
    return true;
  }

  /**
   * @param cr CreditReferralModel
   * @param recordId case record id
   * @description picks up other reason fields from the Referral_Reason__c for flex card reference
   */
  private static void assignReasonFields(
    CreditReferralModel cr,
    String recordId
  ) {
    Case caseRecord = [
      SELECT Id, OwnerId, Status
      FROM Case
      WHERE Id = :recordId
    ];

    Set<CreditReferralModel.Reason> setCrReason = new Set<CreditReferralModel.Reason>();
    for (CreditReferralModel.Assessment crAssessment : cr.assessments) {
      if (!crAssessment.reasons.isEmpty()) {
        setCrReason.addAll(crAssessment.reasons);
      }
    }

    Set<String> setReasonCode = new Set<String>();
    Set<String> setRefOutcomeCode = new Set<String>();
    List<String> setCreatedBy = new List<String>();
    for (CreditReferralModel.Reason reason : setCrReason) {
      setReasonCode.add(reason.reasonCode);
      setRefOutcomeCode.add(reason.referralOutcomeCode);
      setCreatedBy.add(reason.createdBy);
    }

    Map<String, Referral_Reason__c> mapReasons = getReferralReasonMap(
      setReasonCode
    );
    Map<String, Reason_Outcome__c> mapOutcomes = getReferralReasonOutcomeMap(
      setRefOutcomeCode
    );
    Map<String, User> mapUsers = new Map<String, User>();

    SystemModeActions systemActions = new SystemModeActions(
      'CreditAssessmentController',
      'assignReasonFields'
    );
    String emails = '\'' + String.join(setCreatedBy, '\',\'') + '\'';
    //Remove null as a potential check so we dont get random users with no fed ids
    List<User> userList = systemActions.query(
      'SELECT Name, FederationIdentifier FROM User WHERE FederationIdentifier != null AND FederationIdentifier IN (' +
        emails +
        ')'
    );

    for (User user : userList) {
      mapUsers.put(user.FederationIdentifier, user);
    }

    if (mapReasons.isEmpty()) {
      return;
    }
    for (CreditReferralModel.Reason crReason : setCrReason) {
      Referral_Reason__c referralReason = mapReasons.get(crReason.reasonCode);
      Reason_Outcome__c refOutcome = mapOutcomes.get(
        crReason.referralOutcomeCode
      );
      User user = mapUsers.get(crReason.createdBy);
      if (referralReason == null) {
        continue;
      }

      crReason.guidanceCode = referralReason.Guidance_Code__c;
      crReason.assessmentCategory = referralReason.Assessment_Category__c;
      crReason.authorityLevel = referralReason.Authority_Level__c;
      crReason.referralOutcomeDescription = refOutcome != null &&
        String.isNotBlank(refOutcome.Outcome_Description__c)
        ? refOutcome.Outcome_Description__c
        : '';
      crReason.createdBy = user != null && String.isNotBlank(user.Name)
        ? user.Name + ','
        : '';
      crReason.editable = false;
      crReason.reasonCodeId = referralReason.Id;

      if (
        ((UserInfo.getUserRoleId() == creditAssessorLeadRole.Id) ||
        (UserInfo.getUserId() == caseRecord.OwnerId &&
        ((UserInfo.getUserRoleId() == creditAssessmentOfficerRole.Id) ||
        (UserInfo.getUserRoleId() == bohCoachRole.Id &&
        referralReason.Authority_Level__c.toUpperCase() == 'NO CAD')))) &&
        (!caseRecord.Status.contains('Closed'))
      ) {
        crReason.editable = true;
      }
    }
  }
  /**
   * @param cr CreditReferralModel
   * @return `Map<String, Object>`
   * @description adds current and history parent nodes to distinguish assessment list
   */
  private static Map<String, Object> splitCurrentAndHistory(
    CreditReferralModel cr
  ) {
    //current
    Map<String, Object> objectMap = new Map<String, Object>{
      'current' => (Object) new Map<String, Object>{
        'length' => 1,
        'assessments' => new List<CreditReferralModel.Assessment>{
          cr.assessments[0]
        }
      }
    };

    //history
    if (cr.assessments.size() > 1) {
      CreditReferralModel.Assessment[] arrHistoryAssessments = new List<CreditReferralModel.Assessment>();
      for (Integer count = 1; count < cr.assessments.size(); count++) {
        arrHistoryAssessments.add(cr.assessments[count]);
      }
      objectMap.put(
        'history',
        (Object) new Map<String, Object>{
          'length' => cr.assessments.size() - 1,
          'assessments' => arrHistoryAssessments
        }
      );
    } else {
      objectMap.put(
        'history',
        (Object) new Map<String, Object>{ 'length' => 0 }
      );
    }
    return objectMap;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description returns ui options for credit referral reason outcomes
   */
  private Boolean getSelectOptions(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    PermissionUtils.canQuery('Reason_Outcome__c');

    List<Map<String, String>> uiOptions = new List<Map<String, String>>();
    for (Reason_Outcome__c outcome : [
      SELECT Outcome_Code__c, Outcome_Description__c
      FROM Reason_Outcome__c
      WHERE Referral_Reason__c = :String.valueOf(input.get('reasonCodeId'))
    ]) {
      Map<String, String> tempMap = new Map<String, String>();
      tempMap.put('name', outcome.Outcome_Description__c);
      tempMap.put('value', outcome.Outcome_Code__c);
      uiOptions.add(tempMap);
    }

    output.put('options', uiOptions);
    return true;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description returns result from saving referral change
   */
  private Boolean saveReferralChange(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    Case c = [
      SELECT Account.OCV_Id__c, Assessment_Id__c
      FROM Case
      WHERE Id = :String.valueOf(input.get('recordId'))
    ];

    String creditId = String.valueOf(input.get('creditId'));

    //Remove the version identifier from the credit id
    if (creditId.contains('@')) {
      creditId = creditId.left(creditId.indexOf('@'));
    }

    CreditAssessmentAPIRepository creditApi = new CreditAssessmentAPIRepository();
    //Create map with payload values
    Map<String, String> payload = new Map<String, String>();
    payload.put('creditId', creditId);
    payload.put('referralOutcome', String.valueOf(input.get('refOutcome')));
    payload.put('ocvId', c.Account.OCV_ID__c);
    payload.put('assessmentId', c.Assessment_Id__c);
    payload.put('reasonCode', String.valueOf(input.get('reasonCode')));
    payload.put('applicantId', String.valueOf(input.get('applicantId')));
    payload.put('recordId', String.valueOf(input.get('recordId')));
    payload.put('propertyId', String.valueOf(input.get('propertyId')));

    return creditApi.createCreditEnquiryAssessment(payload);
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description returns result from saving referral change
   */
  private Boolean deleteReferralOutcome(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    Case c = [
      SELECT Account.OCV_Id__c, Assessment_Id__c
      FROM Case
      WHERE Id = :String.valueOf(input.get('recordId'))
    ];

    String creditId = String.valueOf(input.get('creditId'));

    //Remove the version identifier from the credit id
    if (creditId.contains('@')) {
      creditId = creditId.left(creditId.indexOf('@'));
    }

    return new CreditAssessmentAPIRepository()
      .deleteReferralOutcome(
        creditId,
        String.valueOf(input.get('assessmentId')),
        c.Account.OCV_ID__c,
        String.valueOf(input.get('outcomeId'))
      );
  }

  /**
   * @description return a map of referral reason that contains more reason data
   * @param setReasonCode a Set<String> contains reason code
   * @return `Map<String, Referral_Reason__c>`
   */
  private static Map<String, Referral_Reason__c> getReferralReasonMap(
    Set<String> setReasonCode
  ) {
    Map<String, Referral_Reason__c> mapReasons = new Map<String, Referral_Reason__c>();
    for (Referral_Reason__c referralReason : [
      SELECT
        Id,
        Reason_Code__c,
        Guidance_Code__c,
        Assessment_Category__c,
        Authority_Level__c
      FROM Referral_Reason__c
      WHERE Reason_Code__c IN :setReasonCode
    ]) {
      mapReasons.put(referralReason.Reason_Code__c, referralReason);
    }
    return mapReasons;
  }

  /**
   * @description return a map of reason outcome that contains more outcome data
   * @param setRefOutcomeCode a Set<String> contains outcome code
   * @return `Map<String, Reason_Outcome__c>`
   */
  private static Map<String, Reason_Outcome__c> getReferralReasonOutcomeMap(
    Set<String> setRefOutcomeCode
  ) {
    Map<String, Reason_Outcome__c> mapOutcomes = new Map<String, Reason_Outcome__c>();
    for (Reason_Outcome__c reasonOutcome : [
      SELECT Outcome_Code__c, Outcome_Description__c
      FROM Reason_Outcome__c
      WHERE Outcome_Code__c IN :setRefOutcomeCode
    ]) {
      mapOutcomes.put(reasonOutcome.Outcome_Code__c, reasonOutcome);
    }
    return mapOutcomes;
  }
  private class AssessmentOutcome {
    String lastModified;
    List<AssessmentOutcomeRow> rows;
  }
  private class AssessmentOutcomeRow {
    String reasonCode;
    String description;
  }
}

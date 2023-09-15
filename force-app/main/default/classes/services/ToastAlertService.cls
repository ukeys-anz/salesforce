/**
 * @author cruzb
 * @since August 2023
 * @description Service class for ToastAlertService
 * @group Service
 */
public with sharing class ToastAlertService {
  private static final String REASSESSMENT_REQUIRED_TITLE = 'The loan application has been updated.';
  private static final String REASSESSMENT_REQUIRED_MESSAGE = 'Please submit for reassessment to view the latest assessment outcome.';

  public static final Map<String, Object> RLA_MESSAGE = new Map<String, Object>{
    'Origin' => 'ResidentialLoanApplication',
    'Toast' => new Map<String, Object>{
      'title' => REASSESSMENT_REQUIRED_TITLE,
      'message' => REASSESSMENT_REQUIRED_MESSAGE
    }
  };

  /**
   * @param records trigger context
   * @param oldMap trigger context
   * @description checks if credit referral assessment outcome is updated
   * @return Set<Id> list of records that have changed
   */
  public static Set<Id> checkCRAssessmentResults(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    Set<Id> setRecordsChanged = new Set<Id>();
    for (Case caseRecord : records) {
      Case oldRecord = (Case) oldMap.get(caseRecord.Id);
      if (
        oldRecord.Assessment_Outcome__c != caseRecord.Assessment_Outcome__c &&
        (caseRecord.Assessment_Outcome__c == 'Approved' ||
        caseRecord.Assessment_Outcome__c == 'Declined' ||
        caseRecord.Assessment_Outcome__c == 'Referred')
      ) {
        setRecordsChanged.add(caseRecord.Id);
      }
    }

    return setRecordsChanged;
  }

  /**
   * @param records trigger context
   * @param oldMap trigger context
   * @description checks if Loan Application reassessment flag is updated
   * @return Set<Id> list of records that have changed
   */
  public static Set<Id> checkRLAReassessmentRequirement(
    List<ResidentialLoanApplication> records,
    Map<Id, ResidentialLoanApplication> oldMap
  ) {
    Set<Id> setRecordsChanged = new Set<Id>();
    for (ResidentialLoanApplication rlaRecord : records) {
      ResidentialLoanApplication oldRecord = oldMap.get(rlaRecord.Id);
      if (
        oldRecord.Credit_Reassess_Required__c == false &&
        rlaRecord.Credit_Reassess_Required__c == true
      ) {
        setRecordsChanged.add(rlaRecord.Id);
      }
    }
    return setRecordsChanged;
  }

  /**
   * @param jsonMessage contains json
   * @param setRecordsChanged object record ids of items changed
   * @description publish event
   * @return List<SObject> to monitor platform event
   */
  public static List<SObject> publishRecordMonitoringEvent(
    Map<String, Object> jsonMessage,
    Set<Id> setRecordsChanged
  ) {
    if (setRecordsChanged.isEmpty()) {
      return null;
    }
    jsonMessage.put('User', UserInfo.getUserId());
    jsonMessage.put('Ids', setRecordsChanged);
    return PlatformEventUtils.publishEvents(
      new List<Record_Monitoring__e>{
        new Record_Monitoring__e(Message__c = JSON.serialize(jsonMessage))
      }
    );
  }
}

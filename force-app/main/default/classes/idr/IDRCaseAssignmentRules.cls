public with sharing class IDRCaseAssignmentRules {
  public static ID getOwnerId(
    Case rec,
    Map<String, Id> queueMap,
    Case oldCase
  ) {
    if (
      rec.Origin == IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED &&
      rec.Status == IDRConstants.ESCALATED_STATUS &&
      (oldCase == null ||
      oldCase.Status != IDRConstants.ESCALATED_STATUS ||
      checkRecursive.firstCall)
    ) {
      if (
        rec.Priority == 'Customer in Collections' ||
        rec.Priority == 'Financial Hardship'
      ) {
        return queueMap.get('Specialised_Early_Resolution_Hardship');
      }
      if (
        rec.IDR_Subsequent_Issue__c == '38' ||
        rec.IDR_Subsequent_Issue_2__c == '38' ||
        rec.IDR_Subsequent_Issue_3__c == '38'
      ) {
        return queueMap.get('Specialised_EarlyRes_Responsible_Lending');
      }
      return queueMap.get('EDR_Early_Resolution');
    }
    return null;
  }
}

/**
 * @description helper class for Lending Case
 * @author Raman Gupta
 * @since May 2025
 */
public with sharing class LendingCaseHelper {
  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  /**
   * @description Below method will update the status of the case 'Closed - Approved' or 'Closed - Decline' when a success response is received.
   * @param recordId Id
   * @param approvalState String
   * @return boolean
   * @exception
   */
  public static Boolean updateCaseStatus(Id recordId, String approvalState) {
    try {
      String updatedStatus = approvalState == 'STATE_APPROVED'
        ? 'Closed - Approved'
        : 'Closed - Declined';
      Case caseRecord = new Case();
      caseRecord.Id = recordId;
      caseRecord.Status = updatedStatus;
      caseRecord.Verified_By__c = UserInfo.getUserId();
      caseRecord.System_Action__c = true;
      DML.doUpdate(caseRecord);
      return true;
    } catch (Exception e) {
      Logger.info('Failure on upadate status for case', e);
      Logger.saveLog();
      return false;
    }
  }
}

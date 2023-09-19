/**
 * @author Peter Charalambous
 * @since 08/2023
 * @description class for Residential Loan Application actions
 */
public with sharing class ResidentialLoanApplicationActions {
  private static final String HOME_LOAN_APP_DEV_NAME = 'Home_Loan_Applications_Queue';
  private static final String QUEUE_TYPE = 'Queue';
  private static Group homeLoanAppQueue;

  /**
   * @description get home loan queue
   * @return Group home loan queue
   */
  public static Group getHomeLoanAppQueue() {
    if (homeLoanAppQueue != null) {
      return homeLoanAppQueue;
    }

    homeLoanAppQueue = [
      SELECT Id
      FROM Group
      WHERE developername = :HOME_LOAN_APP_DEV_NAME AND Type = :QUEUE_TYPE
    ];
    return homeLoanAppQueue;
  }

  /**
   * @description Assign Home Loan Applications Queue as owner
   * @param rlaRecords records to assign owner
   */
  public static void assignHomeLoanAppQueue(
    List<ResidentialLoanApplication> rlaRecords
  ) {
    for (ResidentialLoanApplication rla : rlaRecords) {
      if (rla.RecordTypeId == GetHelpConstants.LOAN_APPLICATION_RT_ID) {
        rla.OwnerId = getHomeLoanAppQueue().Id;
      }
    }
  }
}

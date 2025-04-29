/**
 * @author @ramvilas
 * @since April 2025
 * @description class for Common Residential Loan Application actions
 * @runTests ResidentialLoanAppActionsTest
 */
public with sharing class CommonResidentialLoanApplicationActions {
  private static final List<String> APP_PROGRESS_BLANK_STATUSES = new List<String>{
    'STATE_EXPIRED',
    'STATE_SETTLEMENT_INITATED',
    'STATE_COMPLETED',
    'STATE_DECLINED',
    'STATE_CANCELLED'
  };
  /**
   * @description Update Application progress for Residential Loan Applications
   * @param records records to update
   * @param oldMap old records
   * @return List<ResidentialLoanApplication> updated records
   */
  public static List<ResidentialLoanApplication> updateApplicationProgressToBlank(
    List<ResidentialLoanApplication> records,
    Map<Id, ResidentialLoanApplication> oldMap
  ) {
    List<ResidentialLoanApplication> recordsComplitionStatus = ListUtil.filter(
        records,
        oldMap
      )
      .changedTo(ResidentialLoanApplication.Status, APP_PROGRESS_BLANK_STATUSES)
      .toList();
    List<ResidentialLoanApplication> recordsToUpdate = ListUtil.setField(
      recordsComplitionStatus,
      ResidentialLoanApplication.Application_Progress__c,
      null
    );

    return recordsToUpdate;
  }
}

/**
 * @author Karen Valeriano
 * @since 09/2024
 * @description  COBCaseConstants consists of all the Fraud Check and ID Ops cases constants
 */
public with sharing class COBCaseConstants {
  //IDOps and Fraud Check Case Statuses
  public static final String COB_DAON_FALLOUT_STATUS = 'Daon Fallout';
  public static final String COB_EQUIFAX_FALLOUT_STATUS = 'Equifax Fallout';
  public static final String COB_ID_CHECK_OK_STATUS = 'ID Check OK';
  public static final String COB_POTENTIAL_FRAUD_STATUS = 'Potential Fraud';
  public static final String COB_CONFIRMED_FRAUD_STATUS = 'Confirmed Fraud';
  public static final String COB_NOT_A_FRAUD_STATUS = 'Not a Fraud';
  public static final String COB_ID_OPS_DAON_OK_STATUS = 'ID Ops: Daon OK';
  public static final String COB_FAILED_OK_STATUS = 'Failed';

  //Case Reason
  public static final String CONFIRMED_FRAUD_SELFIE_WATCHLIST_REASON = 'Confirmed Fraud - Selfie Watchlist';

  //Case Subject
  public static final String DAON_FALLOUT_WATCHLIST_HIT_SUBJECT = 'ID Ops Assistance - Daon Fallout: WATCHLIST_HIT';

  //Customer Onboarding 'ID Ops'->'Fraud Check' corresponding Case statuses
  public static final Map<String, String> COB_ID_OPS_TO_FRAUD_CHECK_STATUS_MAP = new Map<String, String>{
    COB_DAON_FALLOUT_STATUS => COB_DAON_FALLOUT_STATUS,
    COB_EQUIFAX_FALLOUT_STATUS => COB_EQUIFAX_FALLOUT_STATUS
  };
}

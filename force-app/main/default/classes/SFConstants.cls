/**
 * @description SFConstants class which holds all the constants which can be used across in different classes.
 * @author Pavan Kumar Ananta
 * @since 2020
 */
public with sharing class SFConstants {
  private SFConstants() {
    // restrict instantiation
  }
  public static final Integer TIME_TO_HOUR = 60 * 60 * 1000;
  public static final Integer TIME_TO_MIN = 60 * 1000;
  public static final Integer MIN_IN_HOUR = 60;
  private static final Organization ORG_VALUE = [
    SELECT Id, IsSandbox, TrialExpirationDate
    FROM Organization
    LIMIT 1
  ];
  public static final String ORG_ID = ORG_VALUE.Id;
  public static final Boolean IS_SANDBOX =
    ORG_VALUE.IsSandbox && ORG_VALUE.TrialExpirationDate == null;
  public static final Boolean IS_SCRATCH_ORG =
    ORG_VALUE.IsSandbox && ORG_VALUE.TrialExpirationDate != null;
  public static final List<String> TIMER_PAUSE_STATUSES = new List<String>{
    'On Hold',
    'Withdrawn',
    'Resolved',
    'Closed'
  };
}

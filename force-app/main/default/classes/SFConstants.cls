/**
 * @description SFConstants class which holds all the constants which can be used across in different classes.
 * @author Pavan Kumar Ananta
 * @since 2020
 */
public without sharing class SFConstants {
  @SuppressWarnings('PMD.EmptyStatementBlock')
  private SFConstants() {
    // restrict instantiation
  }
  public static final Integer TIME_TO_HOUR = 60 * 60 * 1000;
  public static final Integer TIME_TO_MIN = 60 * 1000;
  public static final Integer MIN_IN_HOUR = 60;
  private static final Organization ORG_VALUE = [
    SELECT IsSandbox, TrialExpirationDate
    FROM Organization
    LIMIT 1
  ];
  public static final Boolean IS_SANDBOX =
    ORG_VALUE.IsSandbox && ORG_VALUE.TrialExpirationDate == null;
  public static final Boolean IS_SCRATCH_ORG =
    ORG_VALUE.IsSandbox && ORG_VALUE.TrialExpirationDate != null;
}

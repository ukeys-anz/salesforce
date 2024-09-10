/**
 * @author Tan Phan
 * @since Aug 2024
 * @description Holds cached Task Record Types.
 */
public class RTTask {
  static QueryRT base = QueryRT.of(Task.SObjectType);

  public static Id callbackRequest = base.getId('Callback_Request');
  public static Id callLog = base.getId('Call_Log');
  public static Id ccrmTask = base.getId('CCRM_Task');
  public static Id coachNudge = base.getId('Coach_Nudge');
  public static Id complianceTask = base.getId('Compliance_Task');
  public static Id emailTask = base.getId('Email_Task');
  public static Id idrSystemTask = base.getId('IDR_System_Task');
  public static Id idrTask = base.getId('IDR_Task');
  public static Id leadResponse = base.getId('Lead_Response');
  public static Id mlcrmTask = base.getId('MLCRM_Task');
  public static Id settlementTask = base.getId('Settlement_Task');
  public static Id systemicIssueTask = base.getId('Systemic_Issue_Task');
}

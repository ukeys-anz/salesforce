/**
 * @author Adnan
 * @since  09/2021
 * @description Wrapper class for building task notifications
 */
public with sharing class IDRPendCaseTaskReminderWrapper {
  /**
   * @description task record id
   */
  public Id taskId { get; set; }
  /**
   * @description case record id
   */
  public Id caseId { get; set; }
  /**
   * @description the task record
   */
  public Task taskRecord { get; set; }
  /**
   * @description the case reocrd
   */
  public Case caseRecord { get; set; }
  /**
   * @description Days remaining between due date and today
   */
  public Integer daysBetweenTaskDueDate { get; set; }
  /**
   * @description to check if the email notification is required
   */
  public Boolean emailNotificationRequired { get; set; }
  /**
   * @description user record of task owner
   */
  public User taskOwnerUserRecord { get; set; }
  /**
   * @description boolean to notify owner or not
   */
  public Boolean notifyOwner { get; set; }
  /**
   * @description boolean to notify manager or not
   */
  public Boolean notifyManager { get; set; }
  /**
   * @description user record of case owner
   */
  public User caseOwnerUserRecord { get; set; }
}

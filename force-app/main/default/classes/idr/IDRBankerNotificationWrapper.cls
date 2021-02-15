/**
 *
 * @author Afreen
 * @since 11/2020
 * @description Banker Notification Wrapper Class.
 */
public class IDRBankerNotificationWrapper {
  /**
   * @description sfObject to send notification
   */
  public Sobject sfObject { get; set; }
  /**
   * @description list of ownerids
   */
  public List<Id> recipientList { get; set; }
  /**
   * @description custom notification title
   */
  public String msgTitle { get; set; }
  /**
   * @description custom notification body
   */
  public String msgBody { get; set; }
  /**
   * @description related case record
   */
  public Case relatedCaseRecord { get; set; }

  /**
   * @description constructor with 5 parameters
   * @param sfObject to get object for sending notification
   * @param recipientList list of ownerids
   * @param msgTitle custom notification title
   * @param msgBody custom notification body
   * @param relatedCaseRecord related case record
   */
  @SuppressWarnings('PMD.ExcessiveParameterList')
  public IDRBankerNotificationWrapper(
    Sobject sfObject,
    List<Id> recipientList,
    String msgTitle,
    String msgBody,
    Case relatedCaseRecord
  ) {
    this.sfObject = sfObject;
    this.recipientList = recipientList;
    this.msgTitle = msgTitle;
    this.msgBody = msgBody;
    this.relatedCaseRecord = relatedCaseRecord;
  }
}

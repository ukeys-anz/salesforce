/**
 * @author Afreen Khan
 * @since 10/2020
 * @description  NotificationTrigggerHandler is the handler class for Notification Handler Trigger which extends Lib_TriggerHandler the trigger framework used.
 */

public with sharing class NotificationTriggerHandler extends Lib_TriggerHandler {
  private static final Map<String, String> TEMPLATE_ID_MAP = new Map<String, String>{
    IDRConstants.OPEN_STATUS => 'AgCaseOpen',
    IDRConstants.UNDER_INVESTIGATION_STATUS => 'AgCaseUdInvest',
    IDRConstants.ESCALATED_STATUS => 'AgCaseEsclt',
    IDRConstants.REOPENED_STATUS => 'AgCaseReopen',
    IDRConstants.CLOSED_STATUS => 'AgCaseClosed',
    IDRConstants.RESOLVED_STATUS => 'AgCaseRslvd',
    IDRConstants.WITHDRAWN_STATUS => 'AgCaseWthdrwn'
  };
  public static List<IDR_Notification_Event__e> idrNotifications;
  /**
   * @description Constructor to call the trigger framework
   */
  public NotificationTriggerHandler() {
    super();
  }

  /**
   * @description onAfterInsert
   */
  public override void onAfterInsert() {
    sendNotifications((List<Notification_Handler__c>) records);
  }

  /**
   * @description Publish the notification platform event.
   * @param list of  Notification_Handler__c in the current trigger  context
   */
  public static void sendNotifications(
    List<Notification_Handler__c> custNotifications
  ) {
    Set<Id> caseIds = new Set<Id>();
    idrNotifications = new List<IDR_Notification_Event__e>();

    for (Notification_Handler__c custNotification : custNotifications) {
      caseIds.add(custNotification.Case__c);
    }

    Map<Id, Case> caseMap = new Map<Id, Case>(
      [
        SELECT
          Id,
          IDR_3rdParty_Email__c,
          IDR_3rdParty_Name__c,
          IDR_3rdParty_Mobile__c,
          IDR_Customer_Number__c,
          IDR_NC_Email__c,
          IDR_NC_Is_Consent_Obtained__c,
          CaseNumber__c,
          IDR_NC_First_Name__c,
          IDR_NC_Mobile__c
        FROM Case
        WHERE id IN :caseIds
      ]
    );

    for (Notification_Handler__c custNotification : custNotifications) {
      if (
        caseMap.containsKey(custNotification.Case__c) &&
        custNotification.Status__c == IDRConstants.NOTIFICATION_PUBLISH_STATUS
      ) {
        Case c = caseMap.get(custNotification.Case__c);
        idrNotifications.add(getNotifcationEvent(c, custNotification));
      }

      if (!idrNotifications.isEmpty()) {
        List<Database.SaveResult> results = EventBus.publish(idrNotifications);
        Lib_SystemLog log = new Lib_SystemLog(
          IDRCaseActions.class.getName(),
          'sendNotifications'
        );
        log.addDatabaseSaveResult(
          'IDR_Notification_Event__e',
          results,
          idrNotifications
        );
        log.insertLog();
      }
    }
  }

  /**
   * @description Prepare and returns the notification platform event.
   *@param c Case and handler (Notification_Handler__c) to get the nofication details
   *@return notification platform event
   */
  public static IDR_Notification_Event__e getNotifcationEvent(
    Case c,
    Notification_Handler__c handler
  ) {
    IDR_Notification_Event__e notification = new IDR_Notification_Event__e();

    notification.AuthorisedEmail__c = c.IDR_3rdParty_Email__c;
    notification.AuthorisedFirstName__c = c.IDR_3rdParty_Name__c;
    notification.AuthorisedMobile__c = c.IDR_3rdParty_Mobile__c;
    notification.CAP_CIS_ID__c = c.IDR_Customer_Number__c;
    notification.Case_ID__c = c.ID;
    notification.Case_Number__c = getFormattedCaseNumberToNotify(c);
    notification.Case_Status__c = handler.Case_Status__c;
    notification.Case_Status_Change_Date__c = handler.CreatedDate;
    notification.ComplainantEmail__c = c.IDR_NC_Email__c;
    notification.ComplainantFirstName__c = c.IDR_NC_Is_Consent_Obtained__c ==
      false
      ? ''
      : c.IDR_NC_First_Name__c;
    notification.ComplainantMobile__c = c.IDR_NC_Mobile__c;
    notification.EmailFlag__c = true;
    notification.EmailTemplate__c = handler.Case_Status__c ==
      IDRConstants.ESCALATED_STATUS
      ? TEMPLATE_ID_MAP.get(IDRConstants.ESCALATED_STATUS)
      : TEMPLATE_ID_MAP.get(handler.Case_Status__c);
    notification.MessageID__c = '' + c.ID + Datetime.now().millisecond();
    notification.SMSFlag__c = true;
    notification.SMSTemplate__c = handler.Case_Status__c ==
      IDRConstants.ESCALATED_STATUS
      ? TEMPLATE_ID_MAP.get(IDRConstants.ESCALATED_STATUS)
      : TEMPLATE_ID_MAP.get(handler.Case_Status__c);

    return notification;
  }

  /**
   * @description In notifications, use  CaseNumber__c if available, CaseNumber otherwise.
   * @param c Case to get the number from
   * @return the Case number, ready to be inserted in a nofification's body
   */
  private static String getFormattedCaseNumberToNotify(Case c) {
    return String.valueOf(
      Integer.valueOf(
        String.isNotBlank(c.CaseNumber__c) ? c.CaseNumber__c : c.CaseNumber
      )
    );
  }
}

/**
 * @author Afreen Khan
 * @since 10/2020
 * @description  NotificationTrigggerHandler is the handler class for Notification Handler Trigger which extends Lib_TriggerHandler the trigger framework used.
 * without sharing: used to read Case records when publishing the event to populate the updated details from case and in batch mode.
 */
public without sharing class NotificationTriggerHandler extends Lib_TriggerHandler {
  public static List<IDR_Notification_Event__e> idrNotifications;
  private static IDR_Notification_Hours__c nHours;
  private static List<Notification_Handler__c> notificationList;
  private static List<Database.SaveResult> peSaveResults;
  private static String cusComplaintRecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID;

  /**
   * @description Constructor to call the trigger framework
   */
  public NotificationTriggerHandler() {
    super();
  }

  /**
   * @description onApplyDefaults method is called before onBeforeInsert to set the default values for the records.
   */
  public override void onApplyDefaults() {
    nHours = IDR_Notification_Hours__c.getOrgDefaults();

    preProcessNotification((List<Notification_Handler__c>) records);
  }

  /**
   * @description onAfterInsert
   */
  public override void onAfterInsert() {
    peSaveResults = sendNotifications(notificationList, false);

    updateNotification(notificationList, peSaveResults);
  }

  /**
   * @description check whether the notification is within the AEST hours, then change the status to Publish.
   * @param notificationList list of  Notification_Handler__c to be updated
   * @param peSaveResults List of Platform event Enqueued status
   */
  private static void updateNotification(
    List<Notification_Handler__c> notificationList,
    List<Database.SaveResult> peSaveResults
  ) {
    for (Integer i = 0; i < notificationList.size(); i++) {
      Database.SaveResult sr = peSaveResults[i];

      if (sr.isSuccess()) {
        notificationList[i]
          .Status__c = IDRConstants.NOTIFICATION_PUBLISH_STATUS;
      } else {
        notificationList[i]
          .Status__c = IDRConstants.NOTIFICATION_ERROR_PUBLISH_STATUS;
      }
    }
    if (
      Schema.sObjectType.Notification_Handler__c.isUpdateable() &&
      Schema.sObjectType.Notification_Handler__c.fields.Status__c.isUpdateable()
    ) {
      List<Database.saveResult> result = Database.update(
        notificationList,
        false
      );
      Logger.error('',result);
      Logger.saveLog();
    } else {
      CommonUtil.logAndThrowIAE(
        'NotificationTriggerHandler',
        'insertNotificationHandler',
        'Not enough permissions to update Notification_Handler__c.'
      );
    }
  }

  /**
   * @description check whether the notification is within the AEST hours, then change the status to Publish.
   * @param records list of  Notification_Handler__c in the current trigger  context
   */
  public static void preProcessNotification(
    List<Notification_Handler__c> records
  ) {
    notificationList = new List<Notification_Handler__c>();
    for (Notification_Handler__c handlerRecord : records) {
      if (
        System.now().hour() >= nHours.Start_Time__c &&
        System.now().hour() < nHours.End_Time__c
      ) {
        notificationList.add(handlerRecord);
      }
    }
  }

  /**
   * @description Publish the notification platform event.
   * @param custNotifications list of  Notification_Handler__c in the current trigger  context
   * @param isExecutedFromBatch boolean to verify if the method is being called from a batch
   * @return List of <Database.SaveResult> consists of status on PE enqueued status
   */
  public static List<Database.SaveResult> sendNotifications(
    List<Notification_Handler__c> custNotifications,
    Boolean isExecutedFromBatch
  ) {
    Set<Id> caseIds = new Set<Id>();
    idrNotifications = new List<IDR_Notification_Event__e>();
    peSaveResults = new List<Database.SaveResult>();

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
          Customer_Notification_Consent__c,
          Account.Source_System_ID__c,
          Account.PersonMobilePhone,
          Account.PersonContact.FirstName,
          IDR_Customer_Identifier__c,
          CaseNumber,
          IDR_NC_First_Name__c,
          IDR_NC_Mobile__c,
          RecordTypeId,
          IDR_SwicthOff_3rd_Party_Notification__c,
          IDR_SwitchOff_Customer_Notification__c,
          Origin,
          ANZx_Customer__c,
          IDR_3rdParty_Relationship_To_Complainant__c
        FROM Case
        WHERE id IN :caseIds
      ]
    );

    for (Notification_Handler__c custNotification : custNotifications) {
      if (caseMap.containsKey(custNotification.Case__c)) {
        Case c = caseMap.get(custNotification.Case__c);
        idrNotifications.add(getNotifcationEvent(c, custNotification));
      }
    }
    if (!idrNotifications.isEmpty()) {
      peSaveResults = EventBus.publish(idrNotifications);
      //If it is not exeuted from batch then log the errors here
      if (!isExecutedFromBatch) {
        Logger.error('',peSaveResults);
        Logger.saveLog();
      }
      /**** Else log the errors in batch itself
       To avoid future method being called from batch exception ****/
      return peSaveResults;
    }
    return null;
  }

  /**
   * @description Prepare and returns the notification platform event.
   * @param c Case record to get the notification details
   * @param handler Notification_Handler__c record to get the nofication details
   * @return notification platform event
   */
  public static IDR_Notification_Event__e getNotifcationEvent(
    Case c,
    Notification_Handler__c handler
  ) {
    IDR_Notification_Event__e notification = new IDR_Notification_Event__e();
    if (c.RecordTypeId == GetHelpConstants.COMPLAINT_RT_ID) {
      prepareANZPlusNotificationEvent(notification, c);
    } else if (
      CheckCaseRecordType.isNonCustomerComplaint(c) &&
      c.ANZx_Customer__c &&
      c.Origin == GetHelpConstants.ANZ_PLUS_WEB_ORIGIN
    ) {
      prepareAEMNonCustomerComplaintNotificationEvent(notification, c);
    } else {
      prepareIDRNotificationEvent(notification, c);
    }
    notification.Case_ID__c = c.ID;
    notification.Case_Number__c = getFormattedCaseNumberToNotify(c);
    notification.MessageID__c = '' + c.ID + Datetime.now().millisecond();
    notification.SMSTemplate__c = IDRConstants.CUSTOMER_NOTIFICATION_TEMPLATE_ID;
    return notification;
  }

  /**
   * @description Prepare and returns the notification platform event for ANZ plus Complaints
   * @param notification notification from getNotificationEvent method to be updated.
   * @param c Case record to get the notification details
   * @return notification platform event
   */
  public static IDR_Notification_Event__e prepareANZPlusNotificationEvent(
    IDR_Notification_Event__e notification,
    Case c
  ) {
    if (c.Customer_Notification_Consent__c == 'Yes') {
      notification.ComplainantMobile__c = c.Account.PersonMobilePhone;
      notification.ComplainantFirstName__c = String.isNotEmpty(
          c.Account.PersonContact.FirstName
        )
        ? c.Account.PersonContact.FirstName
        : '';
      notification.SMSFlag__c = true;
    }
    return notification;
  }

  /**
   * @description Prepare and returns the notification platform event for Converted AEM cases to Non-Customer Complaint
   * @param notification notification from getNotificationEvent method to be updated.
   * @param c Case record to get the notification details
   * @return notification platform event
   */
  public static IDR_Notification_Event__e prepareAEMNonCustomerComplaintNotificationEvent(
    IDR_Notification_Event__e notification,
    Case c
  ) {
    if (!c.IDR_SwitchOff_Customer_Notification__c) {
      notification.ComplainantMobile__c = c.IDR_NC_Mobile__c;
      notification.ComplainantFirstName__c = String.isNotEmpty(
          c.IDR_NC_First_Name__c
        )
        ? c.IDR_NC_First_Name__c
        : '';
      notification.SMSFlag__c = true;
    }
    return notification;
  }

  /**
   * @description Prepare and returns the notification platform event for IDR cases
   * If the cases are not ANZ plus complaints or AEM converted to Non-Customer compliant cases run this method
   * @param notification notification from getNotificationEvent method to be updated.
   * @param c Case record to get the notification details
   * @return notification platform event
   */
  public static IDR_Notification_Event__e prepareIDRNotificationEvent(
    IDR_Notification_Event__e notification,
    Case c
  ) {
    assignIDR3rdPartyNotificationValues(notification, c);
    assignIDRCustomerNotificationValues(notification, c);
    notification.EmailFlag__c = true;
    notification.EmailTemplate__c = IDRConstants.CUSTOMER_NOTIFICATION_TEMPLATE_ID;
    notification.SMSFlag__c = true;
    return notification;
  }

  /**
   * @description Prepare and returns the notification platform event for IDR cases if it is from 3rdParty
   * If the cases are not ANZ plus complaints or AEM converted to Non-Customer compliant cases run this method
   * @param notification notification from getNotificationEvent method to be updated.
   * @param c Case record to get the notification details
   * @return notification platform event
   */
  public static IDR_Notification_Event__e assignIDR3rdPartyNotificationValues(
    IDR_Notification_Event__e notification,
    Case c
  ) {
    if (!c.IDR_SwicthOff_3rd_Party_Notification__c) {
      if (
        c.IDR_3rdParty_Relationship_To_Complainant__c == '20' &&
        !String.isEmpty(c.IDR_NC_First_Name__c)
      ) {
        notification.AuthorisedFirstName__c = c.IDR_NC_First_Name__c;
      } else {
        notification.AuthorisedFirstName__c = c.IDR_3rdParty_Name__c;
      }
      notification.AuthorisedEmail__c = c.IDR_3rdParty_Email__c;
      notification.AuthorisedMobile__c = c.IDR_3rdParty_Mobile__c;
    }
    return notification;
  }

  /**
   * @description Prepare and returns the notification platform event for IDR cases if it is from a customer
   * If the cases are not ANZ plus complaints or AEM converted to Non-Customer compliant cases run this method
   * @param notification notification from getNotificationEvent method to be updated.
   * @param c Case record to get the notification details
   * @return notification platform event
   */
  public static IDR_Notification_Event__e assignIDRCustomerNotificationValues(
    IDR_Notification_Event__e notification,
    Case c
  ) {
    if (!c.IDR_SwitchOff_Customer_Notification__c) {
      notification.CAP_CIS_ID__c = c.IDR_Customer_Number__c;
      notification.Customer_Identifier__c = ((String.isNotBlank(
          c.IDR_Customer_Identifier__c
        ) && c.IDR_Customer_Identifier__c.contains('CAP ID'))
        ? 'CAP ID'
        : c.IDR_Customer_Identifier__c);
      notification.ComplainantEmail__c = (c.RecordTypeId ==
        cusComplaintRecordTypeId
        ? ''
        : c.IDR_NC_Email__c);
      notification.ComplainantFirstName__c = (c.IDR_NC_Is_Consent_Obtained__c ==
        false ||
        c.RecordTypeId == cusComplaintRecordTypeId)
        ? ''
        : c.IDR_NC_First_Name__c;
      notification.ComplainantMobile__c = c.IDR_NC_Mobile__c;
    }
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

  /**
   * @description  insertNotificationHandler method is to insert the notification handler record and then notification handler trigger will publish the PE based on AEST window. Putting it in the without sharing class so that case is created successfully with the escalated status where case ownership changes
   * @param records The records for which notifications needs to be sent out
   */
  public static void insertNotificationHandler(List<Case> records) {
    List<Notification_Handler__c> notificationHandlerList = new List<Notification_Handler__c>();
    Id customerComplaintRecordId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID;
    for (Case c : records) {
      if (
        c.RecordTypeId == customerComplaintRecordId ||
        c.RecordTypeId == GetHelpConstants.COMPLAINT_RT_ID ||
        !String.isBlank(c.IDR_NC_Mobile__c) ||
        !String.isBlank(c.IDR_NC_Email__c)
      ) {
        Notification_Handler__c handler = new Notification_Handler__c();
        handler.Case__c = c.Id;
        handler.Status__c = IDRConstants.NOTIFICATION_PENDING_PUBLISH_STATUS;

        notificationHandlerList.add(handler);
      }
    }
    if (!notificationHandlerList.isEmpty()) {
      if (
        Schema.sObjectType.Notification_Handler__c.isCreateable() &&
        Schema.sObjectType.Notification_Handler__c.fields.Case__c.isCreateable() &&
        Schema.sObjectType.Notification_Handler__c.fields.Status__c.isCreateable()
      ) {
        insert notificationHandlerList;
      } else {
        CommonUtil.logAndThrowIAE(
          'NotificationTriggerHandler',
          'insertNotificationHandler',
          'Not enough permissions to create Notification_Handler__c.'
        );
      }
    }
  }
}

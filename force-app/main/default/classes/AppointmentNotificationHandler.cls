/**
 * @author Adam Phillip Smith
 * @since 20220513
 * @description handles sending notifications for Appointments
 */
public with sharing class AppointmentNotificationHandler {
  /**
   * @description publishes a platform event to send a notification email to the customer
   * @param interactions List<Interaction> list of interactions for which to send the notification
   * @return List<Database.SaveResult> the results of the save.
   */
  public static List<Database.SaveResult> sendNotifications(
    List<Interaction> interactions
  ) {
    List<Database.SaveResult> results = new List<Database.SaveResult>();

    List<IDR_Notification_Event__e> events = createAppointmentNotificationEvents(
      interactions
    );

    if (!events.isEmpty()) {
      results = EventBus.publish(events);
      Lib_SystemLog log = new Lib_SystemLog(
        AppointmentNotificationHandler.class.getName(),
        'sendNotifications'
      );
      log.addDatabaseSaveResult('IDR_Notification_Event__e', results, events);
      log.insertLogAsync();
    }
    return results;
  }

  /**
   * @description creates a notification event from an Interaction
   * @param interactionSubject Interaction for which to create a Notification Event
   * @return IDR_Notification_Event__e instance of Application Notification Event
   */
  public static IDR_Notification_Event__e createAppointmentNotificationEvent(
    Interaction interactionSubject
  ) {
    List<Interaction> interactions = new List<Interaction>{
      interactionSubject
    };
    List<IDR_Notification_Event__e> results = createAppointmentNotificationEvents(
      new List<Interaction>{ interactionSubject }
    );
    if (!results.isEmpty()) {
      return results[0];
    }
    return null;
  }

  /**
   * @description creates a notification event from an Interaction
   * @param interactions Interactions for which to create a Notification Event
   * @return List<IDR_Notification_Event__e> instance of Application Notification Event
   */
  public static List<IDR_Notification_Event__e> createAppointmentNotificationEvents(
    List<Interaction> interactions
  ) {
    ContactRequestActions actions = new ContactRequestActions();
    Map<Id, Account> accountMap = actions.getAccountMapFromInteractions(
      interactions
    );
    Map<Id, Lead> leadMap = actions.getLeadMapFromInteractions(interactions);
    List<IDR_Notification_Event__e> result = new List<IDR_Notification_Event__e>();
    for (Interaction currentInteraction : interactions) {
      result.add(
        createAppointmentNotificationEvent(
          currentInteraction,
          accountMap,
          leadMap
        )
      );
    }
    return result;
  }

  /**
   * @description creates a notification event from an Interaction
   * @param interactionSubject Interaction for which to create a Notification Event
   * @param accountMap Map<Id,Account> map of Account Id and Account for interactions
   * @param leadMap Map<Id,Lead> map of Lead Id and Lead for interactions
   * @return IDR_Notification_Event__e instance of Application Notification Event
   */
  public static IDR_Notification_Event__e createAppointmentNotificationEvent(
    Interaction interactionSubject,
    Map<Id, Account> accountMap,
    Map<Id, Lead> leadMap
  ) {
    Account interactionAccount;
    Lead interactionLead;
    String emailAddress;
    if (interactionSubject.AccountId != null) {
      interactionAccount = accountMap.get(interactionSubject.AccountId);
      emailAddress = interactionAccount.PersonEmail;
    } else if (interactionSubject.Lead__c != null) {
      interactionLead = leadMap.get(interactionSubject.Lead__c);
      emailAddress = interactionLead.Email;
    }
    IDR_Notification_Event__e notificationEvent = new IDR_Notification_Event__e();

    notificationEvent.Date_and_Time__c = interactionSubject.StartTime;
    notificationEvent.Preferred_Channel__c = interactionSubject.InteractionType;
    notificationEvent.Location__c = interactionSubject.LocationId;
    notificationEvent.Request_Type__c = interactionSubject.Interaction_Purpose__c;
    notificationEvent.Record_Id__c = interactionSubject.Interaction_External_Id__c;
    notificationEvent.Event_Type__c = 'Appointment';
    notificationEvent.AuthorisedEmail__c = emailAddress;
    notificationEvent.EmailTemplate__c = getNotificationTemplate(
      interactionSubject
    );
    if (interactionAccount != null) {
      notificationEvent.First_Name__c = interactionAccount.FirstName;
    } else {
      notificationEvent.First_Name__c = interactionLead?.FirstName;
    }
    Integer duration = Lib_SystemLog.getDifferenceInMinutes(
      interactionSubject.StartTime,
      interactionSubject.EndTime
    );
    notificationEvent.Duration__c = duration;

    return notificationEvent;
  }

  /**
   * @description looks at an interaction and returns a template depending on what email needs to be sent
   * @param interactionSubject Interaction for which to send the email
   * @return String with Template Id
   */
  public static String getNotificationTemplate(Interaction interactionSubject) {
    String movement = 'Created';
    if (interactionSubject.Status__c == 'Cancelled') {
      movement = 'Cancelled';
    }
    return AppointmentNotificationMetadataProvider.getInstance()
      .getNotificationTemplateId(movement);
  }
}

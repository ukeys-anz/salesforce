/**
 * @author Adam Smith
 * @since 20220725
 * @description Creates IDR_Notification_Events for Interactions
 */
public with sharing class AppointmentNotificationEventCreator extends IDRNotificationEventCreator {
  private Set<Interaction> uniqueInteractions;
  private static AppointmentNotificationEventCreator instance;

  private AppointmentNotificationEventCreator() {
    uniqueInteractions = new Set<Interaction>();
  }

  /**
   * @description gets an instance of AppointmentNotificationEventCreator
   * @return instance of AppointmentNotificationEventCreator
   */
  public static AppointmentNotificationEventCreator getInstance() {
    if (instance == null) {
      instance = new AppointmentNotificationEventCreator();
    }
    return instance;
  }

  /**
   * @description adds an interaction to the set of interactions
   * @param newInteraction new Interaction to add
   */
  public void addInteraction(Interaction newInteraction) {
    if (isValidObject(newInteraction)) {
      uniqueInteractions.add(newInteraction);
    }
  }

  /**
   * @description adds a interactions to the set of interactions
   * @param interactions new Interactions to add
   */
  public void addInteractions(List<Interaction> interactions) {
    for (Interaction currentInteraction : interactions) {
      addInteraction(currentInteraction);
    }
  }

  protected override List<IDR_Notification_Event__e> createEvents() {
    List<IDR_Notification_Event__e> events = new List<IDR_Notification_Event__e>();
    Map<Id, SObject> dataMap = getData(null);

    for (Interaction currentInteraction : uniqueInteractions) {
      IDR_Notification_Event__e newEvent = createBaseIDRNotificationEvent(
        currentInteraction
      );
      if (newEvent != null) {
        newEvent = newPlatformEvent(currentInteraction, dataMap, newEvent);
        events.add(newEvent);
      }
    }

    return events;
  }

  @testVisible
  protected override IDR_Notification_Event__e newPlatformEvent(
    SObject targetsObject,
    Map<Id, SObject> dataMap,
    IDR_Notification_Event__e platformEvent
  ) {
    if (!isValidObject(targetsObject)) {
      return null;
    }
    Interaction targetInteraction = (Interaction) targetsObject;
    return newPlatformEvent(targetInteraction, dataMap, platformEvent);
  }

  /**
   * @description creates a single IDR_Notification_Event__e
   * @param targetInteraction base object to create the Event
   * @param dataMap information about the base object on other objects
   * @param notification base PlatformEvent
   * @return IDR_Notification_Event__e
   */
  @testVisible
  private IDR_Notification_Event__e newPlatformEvent(
    Interaction targetInteraction,
    Map<Id, SObject> dataMap,
    IDR_Notification_Event__e notification
  ) {
    Account interactionAccount;
    Lead interactionLead;
    String emailAddress;
    if (targetInteraction.AccountId != null) {
      interactionAccount = (Account) dataMap.get(targetInteraction.AccountId);
      emailAddress = interactionAccount?.PersonEmail;
    } else if (targetInteraction.Lead__c != null) {
      interactionLead = (Lead) dataMap.get(targetInteraction.Lead__c);
      emailAddress = interactionLead?.Email;
    }

    String externalId = targetInteraction.Interaction_Auto_Number__c;
    if (dataMap.containsKey(targetInteraction.Id)) {
      externalId = ((ContactRequest) dataMap.get(targetInteraction.Id))?.Name;
    }

    notification.Date_and_Time__c = targetInteraction.StartTime;
    notification.Preferred_Channel__c = targetInteraction.InteractionType;
    notification.Location__c = targetInteraction.LocationId;
    notification.Request_Type__c = targetInteraction.Interaction_Purpose__c;
    notification.Record_Id__c = externalId;
    notification.Event_Type__c = 'Appointment';
    notification.AuthorisedEmail__c = emailAddress;
    notification.EmailTemplate__c = getNotificationTemplate(targetInteraction);
    if (interactionAccount != null) {
      notification.First_Name__c = interactionAccount.FirstName;
    } else {
      notification.First_Name__c = interactionLead?.FirstName;
    }
    Integer duration = Lib_SystemLog.getDifferenceInMinutes(
      targetInteraction.StartTime,
      targetInteraction.EndTime
    );
    notification.Duration__c = duration;

    return notification;
  }

  /**
   * @description looks at an interaction and returns a template depending on what email needs to be sent
   * @param interactionSubject Interaction for which to send the email
   * @return String with Template Id
   */
  @testVisible
  private static String getNotificationTemplate(
    Interaction interactionSubject
  ) {
    String movement = 'Created';
    if (interactionSubject.Status__c == InteractionConstants.CANCELLED_STATUS) {
      movement = InteractionConstants.CANCELLED_STATUS;
    }
    return AppointmentNotificationMetadataProvider.getInstance()
      .getNotificationTemplateId(movement);
  }

  public override Boolean isValidObject(SObject targetObject) {
    Boolean isInteraction =
      targetObject.getSObjectType().getDescribe().getName() == 'Interaction';
    if (!isInteraction) {
      return false;
    }
    Interaction targetInteraction = (Interaction) targetObject;

    return targetInteraction.RecordTypeId ==
      InteractionConstants.APPOINTMENT_RECORD_TYPE_ID;
  }

  protected override Map<Id, SObject> getData(List<SObject> objects) {
    List<Interaction> interactions = new List<Interaction>(uniqueInteractions);
    Map<Id, Account> accountMap = InteractionActions.getAccountMapFromInteractions(
      interactions
    );
    Map<Id, Lead> leadMap = InteractionActions.getLeadMapFromInteractions(
      interactions
    );

    Set<Id> contactRequestIds = new Set<Id>();
    for (Interaction currentInteraction : interactions) {
      if (currentInteraction.ContactRequestId__c != null) {
        contactRequestIds.add(currentInteraction.ContactRequestId__c);
      }
    }
    Map<Id, String> interactionIdCRAutoNumberMap = new Map<Id, String>();
    Map<Id, ContactRequest> contactRequestMap = new Map<Id, ContactRequest>();
    if (!contactRequestIds.isEmpty()) {
      List<ContactRequest> requests = ContactRequestDMLHelper.getContactRequest(
        contactRequestIds
      );
      contactRequestMap = new Map<Id, ContactRequest>(requests);
      for (ContactRequest request : requests) {
        interactionIdCRAutoNumberMap.put(request.Interaction__c, request.Name);
      }
    }

    Map<Id, SObject> dataMap = new Map<Id, SObject>();
    dataMap.putAll(accountMap);
    dataMap.putAll(leadMap);
    dataMap.putAll(contactRequestMap);
    return dataMap;
  }

  protected override void clear() {
    uniqueInteractions = new Set<Interaction>();
  }
}

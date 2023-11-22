/**
 * @author Adam Smith
 * @since 20220725
 * @description Creates IDR_Notification_Events for Interactions
 */
public with sharing class AppointmentNotificationEventCreator extends IDRNotificationEventCreator {
  private Set<Interaction> uniqueInteractions;
  private static AppointmentNotificationEventCreator instance;
  public static final String DEFAULT_TEMPLATE_NAME = 'Created';

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
    Schema.Location interactionLocation;
    String emailAddress;
    String locationAddress;
    String appointmentDate;
    String appointmentTime;
    if (targetInteraction.AccountId != null) {
      interactionAccount = (Account) dataMap.get(targetInteraction.AccountId);
      emailAddress = interactionAccount?.PersonEmail;
    } else if (targetInteraction.Lead__c != null) {
      interactionLead = (Lead) dataMap.get(targetInteraction.Lead__c);
      emailAddress = interactionLead?.Email;
    }
    if (targetInteraction.LocationId != null) {
      interactionLocation = (Schema.Location) dataMap.get(
        targetInteraction.LocationId
      );
      locationAddress = getLocationAddress(interactionLocation);
    }
    String externalId = targetInteraction.Interaction_Auto_Number__c;
    if (dataMap.containsKey(targetInteraction.Id)) {
      externalId =
        'CR-' + ((ContactRequest) dataMap.get(targetInteraction.Id)).Name;
    }
    notification.Date_and_Time__c = targetInteraction.StartTime;
    notification.Appointment_Time__c =
      targetInteraction.StartTime.format('hh:mm a') +
      ' ' +
      'AEST/AEDT';
    notification.Preferred_Channel__c = targetInteraction.InteractionType;
    if (interactionLocation != null) {
      notification.Location__c = interactionLocation.Name;
      notification.Address__c = locationAddress;
    }
    notification.Request_Type__c = targetInteraction.Interaction_Purpose__c;
    notification.Record_Id__c = externalId;
    notification.Event_Type__c = 'Appointment';
    notification.AuthorisedEmail__c = emailAddress;

    if (targetInteraction.Status__c == InteractionConstants.CANCELLED_STATUS) {
      notification.EmailTemplate__c = AppointmentNotificationMetadataProvider.getInstance()
        .getNotificationTemplateId(InteractionConstants.CANCELLED_STATUS);
      notification.Appointment_Date__c = targetInteraction.StartTime.format(
        AppointmentNotificationMetadataProvider.getInstance()
          .getNotificationDateFormat(InteractionConstants.CANCELLED_STATUS)
      );
    } else {
      notification.EmailTemplate__c = AppointmentNotificationMetadataProvider.getInstance()
        .getNotificationTemplateId(DEFAULT_TEMPLATE_NAME);
      notification.Appointment_Date__c = targetInteraction.StartTime.format(
        AppointmentNotificationMetadataProvider.getInstance()
          .getNotificationDateFormat(DEFAULT_TEMPLATE_NAME)
      );
    }

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
    notification.ChannelMessage__c = getChannelMessage(
      targetInteraction,
      locationAddress,
      interactionLocation
    );
    return notification;
  }

  /**
   * @description looks at an interaction channel and returns the message accordingly
   * @param interactionSubject Interaction for which to send the email
   * @param locationAddress Location address of the Interaction for which to send the email
   * @param targetLocation Location Interaction for which to send the email
   * @return String with Channel Message
   */
  private static String getChannelMessage(
    Interaction interactionSubject,
    String locationAddress,
    Schema.Location targetLocation
  ) {
    Map<String, String> channelMessageMap = new Map<String, String>{
      InteractionConstants.CALL => System.Label.Appointment_Call_Channel_Message,
      InteractionConstants.VIDEO => System.Label.Appointment_Video_Channel_Message,
      InteractionConstants.IN_PERSON => 'Visit' +
      ' ' +
      targetLocation?.Name +
      ', ' +
      locationAddress
    };
    return channelMessageMap.containsKey(interactionSubject.InteractionType)
      ? channelMessageMap.get(interactionSubject.InteractionType)
      : null;
  }

  /**
   * @description return location address
   * @param interactionLocation Location of which address to be snet
   * @return String with location Address
   */
  private static String getLocationAddress(
    Schema.Location interactionLocation
  ) {
    return interactionLocation.VisitorAddress.Street +
      ', ' +
      interactionLocation.VisitorAddress.City +
      ' ' +
      interactionLocation.VisitorAddress.State +
      ', ' +
      interactionLocation.VisitorAddress.PostalCode;
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
    Map<Id, Schema.Location> locationMap = InteractionActions.getLocationMapFromInteractions(
      interactions
    );
    Set<Id> contactRequestIds = new Set<Id>();
    for (Interaction currentInteraction : interactions) {
      if (currentInteraction.ContactRequestId__c != null) {
        contactRequestIds.add(currentInteraction.ContactRequestId__c);
      }
    }

    List<ContactRequest> requests = ContactRequestDMLHelper.getContactRequest(
      contactRequestIds
    );
    Map<Id, ContactRequest> contactRequestMap = new Map<Id, ContactRequest>(
      requests
    );

    Map<Id, ContactRequest> interactionIdCRAutoNumberMap = new Map<Id, ContactRequest>();
    for (ContactRequest request : requests) {
      interactionIdCRAutoNumberMap.put(request.Interaction__c, request);
    }

    Map<Id, SObject> dataMap = new Map<Id, SObject>();
    dataMap.putAll(accountMap);
    dataMap.putAll(leadMap);
    dataMap.putAll(locationMap);
    dataMap.putAll(contactRequestMap);
    dataMap.putAll(interactionIdCRAutoNumberMap);
    return dataMap;
  }

  protected override void clear() {
    uniqueInteractions = new Set<Interaction>();
  }
}

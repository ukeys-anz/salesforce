/**
 * @author Adam Phillip Smith
 * @since 20220513
 * @description tests creating notifications for Appointments.
 */
@isTest
public with sharing class AppointmentNotificationTest {
  private final static string TEST_MOBILE = '01189998819991197253';
  private static final String STATUS_CANCELLED = 'Cancelled';
  private static final String STATUS_ASSIGNED = 'Scheduled';
  private static final String TEMPLATE_BOOKED = 'AgANZxApptBooked';
  private static final String TEMPLATE_CANCELLED = 'AgANZxApptCancelled';

  @TestSetup
  static void setup() {
    Appointment_Notification_Template__mdt createdTemplate = new Appointment_Notification_Template__mdt(
      MasterLabel = 'Created',
      Template_Id__c = TEMPLATE_BOOKED
    );

    Appointment_Notification_Template__mdt cancelledTemplate = new Appointment_Notification_Template__mdt(
      MasterLabel = 'Cancelled',
      Template_Id__c = TEMPLATE_CANCELLED
    );
    Map<String, Appointment_Notification_Template__mdt> metadataMap = new Map<String, Appointment_Notification_Template__mdt>();
    metadataMap.put(createdTemplate.MasterLabel, createdTemplate);
    metadataMap.put(cancelledTemplate.MasterLabel, cancelledTemplate);
    AppointmentNotificationMetadataProvider.getInstance().setMap(metadataMap);
  }

  static Interaction createInteraction() {
    DateTime startDate = DateTime.newInstance(DateTime.now().year() + 1, 1, 1);

    Schema.Location testLocation = new Schema.Location();
    testLocation.LocationType = 'Store';
    testLocation.Name = 'ANZX Store';
    insert testLocation;

    Interaction interactionSubject = new Interaction();
    interactionSubject.StartTime = startDate;
    interactionSubject.InteractionType = 'Email';
    interactionSubject.LocationId = testLocation.Id;
    interactionSubject.Interaction_Purpose__c = 'Other';
    interactionSubject.Status__c = STATUS_CANCELLED;
    return interactionSubject;
  }
  @isTest
  static void testSendNotification() {
    Interaction interactionSubject = createInteraction();
    interactionSubject.EndTime = interactionSubject.StartTime.addMinutes(30);
    List<Interaction> interactions = new List<Interaction>();
    interactions.add(interactionSubject);

    List<Database.SaveResult> result = AppointmentNotificationHandler.sendNotifications(
      interactions
    );
    System.assertNotEquals(null, result, 'Nothing should not come back');
    System.assertEquals(false, result.isEmpty(), 'List should not be empty');
  }

  @isTest
  static void testCreatingAppointmentNotificationEventForAccount() {
    Account testAccount = createTestAccount('Joe', 'Bloggs', '123456');
    insert testAccount;

    Interaction interactionSubject = createInteraction();
    interactionSubject.AccountId = testAccount.Id;
    interactionSubject.Status__c = STATUS_CANCELLED;
    Integer duration = 30;
    DateTime endDate = interactionSubject.StartTime.addMinutes(duration);
    interactionSubject.EndTime = endDate;

    Test.startTest();
    IDR_Notification_Event__e notificationEvent = AppointmentNotificationHandler.createAppointmentNotificationEvent(
      interactionSubject
    );
    Test.stopTest();
    System.assertNotEquals(null, notificationEvent, 'Should return an Event');

    System.assertEquals(
      interactionSubject.StartTime,
      notificationEvent.Date_and_Time__c,
      'Date_and_Time__c should be set'
    );

    System.assertEquals(
      duration,
      notificationEvent.Duration__c,
      'Duration__c should be set'
    );

    System.assertEquals(
      testAccount.FirstName,
      notificationEvent.First_Name__c,
      'First_Name__c should be set'
    );

    System.assertEquals(
      interactionSubject.LocationId,
      notificationEvent.Location__c,
      'Location__c should be set'
    );

    System.assertEquals(
      interactionSubject.InteractionType,
      notificationEvent.Preferred_Channel__c,
      'Preferred_Channel__c should be set'
    );

    System.assertEquals(
      interactionSubject.Interaction_Purpose__c,
      notificationEvent.Request_Type__c,
      'Request_Type__c should be set'
    );

    System.assertEquals(
      TEMPLATE_CANCELLED,
      notificationEvent.EmailTemplate__c,
      'EmailTemplate__c should be set'
    );
  }

  @isTest
  static void testCreatingAppointmentNotificationEventForLead() {
    Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
      .get('General')
      .getRecordTypeId();
    Lead testLead = new Lead();
    testLead.FirstName = 'Jane';
    testLead.LastName = 'Doe';
    testLead.Company = testLead.FirstName;
    testLead.RecordTypeId = leadRecordTypeId;
    insert testLead;

    Interaction interactionSubject = createInteraction();
    interactionSubject.Lead__c = testLead.Id;
    interactionSubject.Status__c = STATUS_ASSIGNED;
    Integer duration = 30;
    DateTime endDate = interactionSubject.StartTime.addMinutes(duration);
    interactionSubject.EndTime = endDate;

    IDR_Notification_Event__e notificationEvent = AppointmentNotificationHandler.createAppointmentNotificationEvent(
      interactionSubject
    );
    System.assertNotEquals(null, notificationEvent, 'Should return an Event');

    System.assertEquals(
      interactionSubject.StartTime,
      notificationEvent.Date_and_Time__c,
      'Date_and_Time__c should be set'
    );

    System.assertEquals(
      duration,
      notificationEvent.Duration__c,
      'Duration__c should be set'
    );

    System.assertEquals(
      testLead.FirstName,
      notificationEvent.First_Name__c,
      'First_Name__c should be set'
    );

    System.assertEquals(
      interactionSubject.LocationId,
      notificationEvent.Location__c,
      'Location__c should be set'
    );

    System.assertEquals(
      interactionSubject.InteractionType,
      notificationEvent.Preferred_Channel__c,
      'Preferred_Channel__c should be set'
    );

    System.assertEquals(
      interactionSubject.Interaction_Purpose__c,
      notificationEvent.Request_Type__c,
      'Request_Type__c should be set'
    );

    System.assertEquals(
      TEMPLATE_BOOKED,
      notificationEvent.EmailTemplate__c,
      'EmailTemplate__c should be set'
    );
  }

  @isTest
  static void testMinuteDifferenceCalculator() {
    DateTime startTime = DateTime.now();
    DateTime endTime = DateTime.now().addMinutes(30);

    Integer result = Lib_SystemLog.getDifferenceInMinutes(startTime, endTime);

    System.assertEquals(30, result, 'Should be 30 minute duration');
  }

  @isTest
  static void notificationTemplateTest() {
    Interaction createdInteraction = new Interaction();

    Interaction cancelledInteraction = new Interaction(
      Status__c = STATUS_CANCELLED
    );

    String createdTemplate = AppointmentNotificationHandler.getNotificationTemplate(
      createdInteraction
    );
    String cancelledTemplate = AppointmentNotificationHandler.getNotificationTemplate(
      cancelledInteraction
    );

    System.assertEquals(
      TEMPLATE_BOOKED,
      createdTemplate,
      'The newly created interaction should have a template of ' +
      TEMPLATE_BOOKED
    );
    System.assertEquals(
      TEMPLATE_CANCELLED,
      cancelledTemplate,
      'The newly created interaction should have a template of ' +
      TEMPLATE_CANCELLED
    );
  }

  /**
   * @description helper method to create a person account
   * @param firstName String the first name of the person
   * @param lastName String the last name of the person
   * @param ocvId the OCVId
   * @return Account a Person Account with Name and OCV as provided
   */
  static Account createTestAccount(
    String firstName,
    String lastName,
    String ocvId
  ) {
    Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('PersonAccount')
      .getRecordTypeId();
    Account testAccount = new Account();
    testAccount.FirstName = firstName;
    testAccount.LastName = lastName;
    testAccount.OCV_ID__c = ocvId;
    testAccount.RecordTypeId = personAccountRecordTypeId;
    testAccount.PersonMobilePhone = TEST_MOBILE;

    return testAccount;
  }
}

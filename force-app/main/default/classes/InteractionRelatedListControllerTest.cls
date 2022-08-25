/**
 *
 * @author Lance Shi
 * @since 07/2022
 * @description Tests InteractionRelatedListController for LWC
 */

@isTest
public with sharing class InteractionRelatedListControllerTest {
  public static final String CUSTOMER_PURPOSE = 'Customer';
  public static final String DIGITAL_PURPOSE = 'Digital Support';
  public static final String OPEN_STATUS = 'Open';
  public static final String STORE_LOCATION = 'Store';
  @TestSetup
  static void setup() {
    Faker faker = new Faker('AU');
    Account acc = new Account(
      Name = faker.randomString(10),
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true
    );
    insert acc;
  }

  /**
   * @description testGetInteractions tests query for interaction and appointments
   */
  @isTest
  static void testGetInteractions() {
    Account testAcc = [SELECT Id FROM Account LIMIT 1];
    Faker faker = new Faker('AU');

    Case newCase = new Case(
      Status = OPEN_STATUS,
      RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID
    );
    insert newCase;

    Schema.Location testLocation = new Schema.Location();
    testLocation.LocationType = STORE_LOCATION;
    testLocation.Name = faker.randomString(10);
    insert testLocation;

    Interaction testAppt = new Interaction(
      RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID,
      AccountId = testAcc.Id,
      StartTime = Datetime.now(),
      Interaction_Purpose__c = DIGITAL_PURPOSE,
      InteractionType = STORE_LOCATION,
      LocationId = testLocation.Id
    );

    Interaction testInteraction = new Interaction(
      RecordTypeId = GetHelpConstants.INTERACTION_GENERAL_RT_ID,
      AccountId = testAcc.Id,
      CaseId__c = newCase.Id,
      StartTime = Datetime.now(),
      Interaction_Purpose__c = CUSTOMER_PURPOSE,
      InteractionType = STORE_LOCATION,
      LocationId = testLocation.Id
    );
    List<Interaction> intList = new List<Interaction>{
      testAppt,
      testInteraction
    };
    insert intList;

    List<InteractionRelatedListController.InteractionWrapper> wrapperList = InteractionRelatedListController.getAppointments(
      testAcc.Id,
      3
    );
    System.assertEquals(1, wrapperList.size());
    System.assertEquals(testAppt.Id, wrapperList[0].interactId);

    List<InteractionRelatedListController.InteractionWrapper> intWrapperList = InteractionRelatedListController.getInteractions(
      newCase.Id,
      3
    );
    System.assertEquals(1, intWrapperList.size());
    System.assertEquals(testInteraction.Id, intWrapperList[0].interactId);
  }

  /**
   * @description testGetSObjectType tests get sobject type and field correctly
   */
  @isTest
  static void testGetSObjectType() {
    Account testAcc = [SELECT Id FROM Account LIMIT 1];
    Faker faker = new Faker('AU');

    Schema.Location testLocation = new Schema.Location();
    testLocation.LocationType = STORE_LOCATION;
    testLocation.Name = faker.randomString(10);
    insert testLocation;

    Interaction testInteraction = new Interaction(
      RecordTypeId = GetHelpConstants.INTERACTION_GENERAL_RT_ID,
      AccountId = testAcc.Id,
      StartTime = Datetime.now(),
      Interaction_Purpose__c = CUSTOMER_PURPOSE,
      InteractionType = STORE_LOCATION,
      LocationId = testLocation.Id
    );

    insert testInteraction;

    Case newCase = new Case(
      Status = OPEN_STATUS,
      RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID
    );
    insert newCase;

    String accType = InteractionRelatedListController.getSObjectType(
      testAcc.Id
    );
    System.assertEquals('Account', accType);
    InteractionRelatedListController.NewRecordWrapper nrWrapper = InteractionRelatedListController.getNewRecordInfo(
      testAcc.Id,
      true
    );
    System.assertEquals('AccountId', nrWrapper.fieldName);

    String caseType = InteractionRelatedListController.getSObjectType(
      newCase.Id
    );
    System.assertEquals('Case', caseType);
    InteractionRelatedListController.NewRecordWrapper caseWrapper = InteractionRelatedListController.getNewRecordInfo(
      newCase.Id,
      false
    );
    System.assertEquals('CaseId__c', caseWrapper.fieldName);

    String interactionType = InteractionRelatedListController.getSObjectType(
      testInteraction.Id
    );
    System.assertEquals('Interaction', interactionType);
    InteractionRelatedListController.NewRecordWrapper interactionWrapper = InteractionRelatedListController.getNewRecordInfo(
      testInteraction.Id,
      true
    );
    System.assertEquals('Appointment__c', interactionWrapper.fieldName);
  }
}

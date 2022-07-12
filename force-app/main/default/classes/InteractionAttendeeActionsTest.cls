/**
 * @author Rebecca Jan
 * @since 06/2022
 * @description test class for Interaction Attendee Actions
 */
@isTest
public with sharing class InteractionAttendeeActionsTest {
  public static final String VIC_FIRST_NAME = 'TestVictoria';
  public static final String VIC_LAST_NAME = 'Beckham';
  public static final String VIC_FULL_NAME =
    VIC_FIRST_NAME +
    ' ' +
    VIC_LAST_NAME;
  public static final String EMMA_FIRST_NAME = 'TestEmma';
  public static final String EMMA_LAST_NAME = 'Bunton';
  public static final String EMMA_FULL_NAME =
    EMMA_FIRST_NAME +
    ' ' +
    EMMA_LAST_NAME;
  public static final String GERI_FIRST_NAME = 'TestGeri';
  public static final String GERI_LAST_NAME = 'Halliwell';
  public static final String GERI_FULL_NAME =
    GERI_FIRST_NAME +
    ' ' +
    GERI_LAST_NAME;
  @testSetup
  static void setup() {
    Profile stdUserProfile = CommonUtil.getProfileByName('ANZx Standard User');
    UserRole coachRole = CommonUtil.getUserRoleByDevName('Coach');
    UserRole cardDisputeRole = CommonUtil.getUserRoleByDevName(
      'Card_Dispute_Agent'
    );
    UserRole fraudXRole = CommonUtil.getUserRoleByDevName('FraudX_Agent');

    // Create coach user
    User coachUser = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => VIC_FIRST_NAME,
        'LastName' => VIC_LAST_NAME,
        'ProfileId' => stdUserProfile.Id,
        'UserRoleId' => coachRole.Id
      }
    );
    insert coachUser;

    // Create card dispute user
    User cardDisputeUser = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => EMMA_FIRST_NAME,
        'LastName' => EMMA_LAST_NAME,
        'ProfileId' => stdUserProfile.Id,
        'UserRoleId' => cardDisputeRole.Id
      }
    );
    insert cardDisputeUser;

    // Create fraudx user
    User fraudXUser = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => GERI_FIRST_NAME,
        'LastName' => GERI_LAST_NAME,
        'ProfileId' => stdUserProfile.Id,
        'UserRoleId' => fraudXRole.Id
      }
    );
    insert fraudXUser;
  }
  /**
   * @description tests add in Role Mapping
   */
  @isTest
  static void testAddPerson() {
    InteractionAttendeeActions.RoleMapping newRoleMap = new InteractionAttendeeActions.RoleMapping();
    newRoleMap.userIdToDetails = new Map<Id, String>();
    User userData = [
      SELECT Id, UserRole.Name, Name
      FROM User
      WHERE FirstName = :VIC_FIRST_NAME
      LIMIT 1
    ];
    newRoleMap.addAttendee(userData.Id, userData.UserRole.Name);
    String serializedString = JSON.serialize(newRoleMap);
    System.assertEquals(
      '{"userIdToDetails":{"' +
      userData.Id +
      '":"Coach"}}',
      serializedString,
      'RoleMapping does not match.'
    );
  }
  /**
   * @description tests remove in Role Mapping
   */
  @isTest
  static void testRemovePerson() {
    InteractionAttendeeActions.RoleMapping newRoleMap = new InteractionAttendeeActions.RoleMapping();
    User coachUser = TestUtil.getUserByFirstName(VIC_FIRST_NAME);
    User cardUser = TestUtil.getUserByFirstName(EMMA_FIRST_NAME);
    User fraudUser = TestUtil.getUserByFirstName(GERI_FIRST_NAME);
    newRoleMap.userIdToDetails = new Map<Id, String>{
      coachUser.Id => 'Coach',
      cardUser.Id => 'Card Dispute Agent',
      fraudUser.Id => 'FraudX Agent'
    };

    newRoleMap.deleteAttendee(coachUser.Id);
    String serializedString = JSON.serialize(newRoleMap);
    System.assertEquals(
      '{"userIdToDetails":{"' +
      fraudUser.Id +
      '":"FraudX Agent","' +
      cardUser.Id +
      '":"Card Dispute Agent"}}',
      serializedString,
      'RoleMapping record does not match'
    );
  }
  /**
   * @description tests print in Role Mapping
   */
  @isTest
  static void testPrintRoles() {
    InteractionAttendeeActions.RoleMapping newRoleMap = new InteractionAttendeeActions.RoleMapping();
    User coachUser = TestUtil.getUserByFirstName(VIC_FIRST_NAME);
    User cardUser = TestUtil.getUserByFirstName(EMMA_FIRST_NAME);
    User fraudUser = TestUtil.getUserByFirstName(GERI_FIRST_NAME);
    newRoleMap.userIdToDetails = new Map<Id, String>{
      coachUser.Id => 'Coach',
      cardUser.Id => 'Card Dispute Agent',
      fraudUser.Id => 'FraudX Agent'
    };
    String attendeeRoles = newRoleMap.printAttendeeRoles();
    System.assertEquals(
      'Coach, Card Dispute Agent, FraudX Agent',
      attendeeRoles,
      'RoleMapping record does not match'
    );
  }
  /**
   * @description tests print in Role Mapping
   */
  @isTest
  static void testPrintName() {
    InteractionAttendeeActions.RoleMapping newRoleMap = new InteractionAttendeeActions.RoleMapping();
    User coachUser = TestUtil.getUserByFirstName(VIC_FIRST_NAME);
    User cardUser = TestUtil.getUserByFirstName(EMMA_FIRST_NAME);
    User fraudUser = TestUtil.getUserByFirstName(GERI_FIRST_NAME);
    newRoleMap.userIdToDetails = new Map<Id, String>{
      coachUser.Id => 'Coach',
      cardUser.Id => 'Card Dispute Agent',
      fraudUser.Id => 'FraudX Agent'
    };
    Map<Id, String> userNameMap = new Map<Id, String>{
      coachUser.Id => VIC_FULL_NAME,
      cardUser.Id => EMMA_FULL_NAME,
      fraudUser.Id => GERI_FULL_NAME
    };
    String attendees = newRoleMap.printAttendeeNames(userNameMap);
    System.assertEquals(
      VIC_FULL_NAME +
      ', ' +
      EMMA_FULL_NAME +
      ', ' +
      GERI_FULL_NAME,
      attendees,
      'RoleMapping record does not match'
    );
  }
  /**
   * @description tests remove in Role Mapping
   */
  @isTest
  static void testingDeserialize() {
    // get test class
    InteractionAttendeeActions.RoleMapping newRoleMap = new InteractionAttendeeActions.RoleMapping();
    // get test data
    User coachUser = TestUtil.getUserByFirstName(VIC_FIRST_NAME);
    User cardUser = TestUtil.getUserByFirstName(EMMA_FIRST_NAME);
    User fraudUser = TestUtil.getUserByFirstName(GERI_FIRST_NAME);
    // set up test data
    String testAttendeesRoles =
      '{"userIdToDetails":{"' +
      coachUser.Id +
      '":"Coach","' +
      fraudUser.Id +
      '":"FraudX Agent","' +
      cardUser.Id +
      '":"Card Dispute Agent"}}';
    String testAttendees =
      VIC_FULL_NAME +
      ', ' +
      EMMA_FULL_NAME +
      ', ' +
      GERI_FULL_NAME;
    // deserialize the mock data
    newRoleMap = (InteractionAttendeeActions.RoleMapping) JSON.deserialize(
      testAttendeesRoles,
      InteractionAttendeeActions.RoleMapping.class
    );
    newRoleMap.deleteAttendee(coachUser.Id);
    // serialize the response
    testAttendeesRoles = JSON.serialize(newRoleMap);
    Map<Id, String> userNameMap = new Map<Id, String>{
      coachUser.Id => VIC_FULL_NAME,
      cardUser.Id => EMMA_FULL_NAME,
      fraudUser.Id => GERI_FULL_NAME
    };
    String attendees = newRoleMap.printAttendeeNames(userNameMap);
    System.assertEquals(
      '{"userIdToDetails":{"' +
      cardUser.Id +
      '":"Card Dispute Agent","' +
      fraudUser.Id +
      '":"FraudX Agent"}}',
      testAttendeesRoles,
      'RoleMapping record does not match'
    );
    System.assertEquals(
      VIC_FULL_NAME +
      ', ' +
      EMMA_FULL_NAME +
      ', ' +
      GERI_FULL_NAME,
      testAttendees,
      'RoleMapping record does not match'
    );
  }
}

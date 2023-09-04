/**
 * @author Rebecca Jan
 * @since 06/2022
 * @description test class for Interaction Attendee Actions
 */
@isTest
public with sharing class InteractionAttendeeActionsTest {
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
        'FirstName' => 'TestCoach',
        'ProfileId' => stdUserProfile.Id,
        'UserRoleId' => coachRole.Id
      }
    );
    insert coachUser;

    // Create card dispute user
    User cardDisputeUser = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'TestCardDispute',
        'ProfileId' => stdUserProfile.Id,
        'UserRoleId' => cardDisputeRole.Id
      }
    );
    insert cardDisputeUser;

    // Create fraudx user
    User fraudXUser = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'TestFraudX',
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
    User coachUser = TestUtil.getUserByFirstName('TestCoach');
    InteractionAttendeeActions.RoleMapping newRoleMap = new InteractionAttendeeActions.RoleMapping();
    newRoleMap.userIdToDetails = new Map<Id, String>();
    User userData = [
      SELECT Id, UserRole.Name, Name
      FROM User
      WHERE Id = :coachUser.Id
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
    User coachUser = TestUtil.getUserByFirstName('TestCoach');
    User cardUser = TestUtil.getUserByFirstName('TestCardDispute');
    User fraudUser = TestUtil.getUserByFirstName('TestFraudX');
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
    User coachUser = TestUtil.getUserByFirstName('TestCoach');
    User cardUser = TestUtil.getUserByFirstName('TestCardDispute');
    User fraudUser = TestUtil.getUserByFirstName('TestFraudX');
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
    User coachUser = TestUtil.getUserByFirstName('TestCoach');
    User cardUser = TestUtil.getUserByFirstName('TestCardDispute');
    User fraudUser = TestUtil.getUserByFirstName('TestFraudX');
    newRoleMap.userIdToDetails = new Map<Id, String>{
      coachUser.Id => 'Coach',
      cardUser.Id => 'Card Dispute Agent',
      fraudUser.Id => 'FraudX Agent'
    };
    Map<Id, String> userNameMap = new Map<Id, String>{
      coachUser.Id => 'TestCoach',
      cardUser.Id => 'TestCardDispute',
      fraudUser.Id => 'TestFraudX'
    };
    String attendees = newRoleMap.printAttendeeNames(userNameMap);
    System.assertEquals(
      'TestCoach, TestCardDispute, TestFraudX',
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
    User coachUser = TestUtil.getUserByFirstName('TestCoach');
    User cardUser = TestUtil.getUserByFirstName('TestCardDispute');
    User fraudUser = TestUtil.getUserByFirstName('TestFraudX');
    // set up test data
    String testAttendeesRoles =
      '{"userIdToDetails":{"' +
      coachUser.Id +
      '":"Coach","' +
      fraudUser.Id +
      '":"FraudX Agent","' +
      cardUser.Id +
      '":"Card Dispute Agent"}}';
    // deserialize the mock data
    newRoleMap = (InteractionAttendeeActions.RoleMapping) JSON.deserialize(
      testAttendeesRoles,
      InteractionAttendeeActions.RoleMapping.class
    );
    newRoleMap.deleteAttendee(coachUser.Id);
    // serialize the response
    testAttendeesRoles = JSON.serialize(newRoleMap);
    System.assertEquals(
      '{"userIdToDetails":{"' +
      cardUser.Id +
      '":"Card Dispute Agent","' +
      fraudUser.Id +
      '":"FraudX Agent"}}',
      testAttendeesRoles,
      'RoleMapping record does not match'
    );
  }
}

/**
 * @author Lance Shi
 * @since  June 2022
 * @description Test class to cover tests for {@link InteractionContextService}
 */

@isTest
public with sharing class InteractionContextServiceTest {
  @testSetup
  static void testSetup() {
    Faker faker = new Faker('AU');
    Profile p = CommonUtil.getProfileByName('Minimum Access - External Apps');
    UserRole role = CommonUtil.getUserRoleByDevName('ANZx');

    // Insert Account, Case, & User as current user, to get around MIXED_DML_OPERATION error
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      //Create Twilio API User User
      User apiUser = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'APIUserTestForInteraction',
          'ProfileId' => p.Id,
          'UserRoleId' => role.Id
        }
      );
      insert apiUser;

      // Assign Case related PS on API User
      List<String> psNames = new List<String>{
        'Chat_Read_Write',
        'Interaction_Read_Write',
        'API_Access_Twilio',
        'API_Only',
        'Enforce_mTLS'
      };
      List<PermissionSet> psList = [
        SELECT Id
        FROM PermissionSet
        WHERE Name IN :psNames
      ];
      List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
      for (PermissionSet ps : psList) {
        psaList.add(TestUtil.createPSAssignment(apiUser.id, ps.Id));
      }
      insert psaList;
    }
  }

  @isTest
  static void testValidInput() {
    InteractionContextService.InteractionContextRequest intContext = prepareContext();

    Test.startTest();
    InteractionContextService.doPost(intContext);
    Test.stopTest();

    List<Interaction> intList = [SELECT Id, Direction__c FROM Interaction];
    System.assertEquals(
      1,
      intList.size(),
      'Interaction list size should be as expected'
    );
    System.assertEquals(
      InteractionContextService.INBOUND_DIRECTION,
      intList[0].Direction__c,
      'Interaction direction should match'
    );
  }

  @isTest
  static void testInvalidDirection() {
    Faker faker = new Faker('AU');
    User usr = TestUtil.getUserByFirstName('APIUserTestForInteraction');
    InteractionContextService.InteractionContextRequest intContext = prepareContext();
    intContext.direction = faker.randomString(10);

    Test.startTest();
    System.runAs(usr) {
      InteractionContextService.doPost(intContext);
    }
    Test.stopTest();

    List<Interaction> intList = [SELECT Id, Direction__c FROM Interaction];
    System.assertEquals(
      0,
      intList.size(),
      'Interaction list should be empty for invalid direction'
    );
  }

  static InteractionContextService.InteractionContextRequest prepareContext() {
    Faker faker = new Faker('AU');
    InteractionContextService.InteractionContextRequest intContext = new InteractionContextService.InteractionContextRequest();

    intContext.phoneNumber = String.valueOf(faker.randomDecimal(10, 0));
    intContext.direction = InteractionContextService.INBOUND_DIRECTION;

    RestRequest req = new RestRequest();
    req.requestURI = '/InteractionContextRequests/';
    req.httpMethod = 'POST';

    //Setup Response
    RestResponse res = new RestResponse();

    //Assign to context
    RestContext.request = req;
    RestContext.response = res;

    return intContext;
  }
}

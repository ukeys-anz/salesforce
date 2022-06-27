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

      // Insert Account (Customer) record
      List<String> companyNames = faker.text.realWords(2);
      Account testAccount = new Account(
        Name = companyNames[0].capitalize() + companyNames[1].capitalize(),
        OCV_ID__c = 'OCVID887766',
        ANZx_Customer__c = true,
        External_Id__c = 'OCVID887766CAPSYSID123',
        // Criteria based sharing rules cannot be tested in APEX unit tests.
        // Therefore, sharing the test Account record with user by assigning ownership.
        OwnerId = apiUser.Id
      );
      insert testAccount;
    }
  }

  @isTest
  static void testValidInput() {
    InteractionContextService.InteractionContextRequest intContext = prepareContext(
      'OCVID887766'
    );

    Test.startTest();
    InteractionContextService.doPost(intContext);
    Test.stopTest();

    List<Interaction> intList = [SELECT Id, Direction__c FROM Interaction];
    System.assertEquals(1, intList.size());
    System.assertEquals('Inbound', intList[0].Direction__c);
  }

  @isTest
  static void testInvalidDirection() {
    User usr = TestUtil.getUserByFirstName('APIUserTestForInteraction');
    InteractionContextService.InteractionContextRequest intContext = prepareContext(
      'OCVID887766'
    );
    intContext.direction = 'DummyText';

    Test.startTest();
    System.runAs(usr) {
      InteractionContextService.doPost(intContext);
    }
    Test.stopTest();

    List<Interaction> intList = [SELECT Id, Direction__c FROM Interaction];
    System.assertEquals(0, intList.size());
  }

  @isTest
  static void testInvalidOcvId() {
    User usr = TestUtil.getUserByFirstName('APIUserTestForInteraction');
    InteractionContextService.InteractionContextRequest intContext = prepareContext(
      'WrongOcv'
    );

    Test.startTest();
    System.runAs(usr) {
      InteractionContextService.doPost(intContext);
    }
    Test.stopTest();

    List<Interaction> intList = [SELECT Id, Direction__c FROM Interaction];
    System.assertEquals(0, intList.size());
  }

  static InteractionContextService.InteractionContextRequest prepareContext(
    String ocvId
  ) {
    InteractionContextService.InteractionContextRequest intContext = new InteractionContextService.InteractionContextRequest();

    intContext.phoneNumber = '0412345678';
    intContext.ocvId = ocvId;
    intContext.direction = 'Inbound';

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

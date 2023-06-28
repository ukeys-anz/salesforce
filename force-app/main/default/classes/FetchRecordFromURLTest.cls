/**
 * @author Nagendra Singh
 * @since 06/2023
 * @description  Test clas for FetchRecordFromURL to check if callable interface calls correct method based on params.
 */
@isTest
private class FetchRecordFromURLTest {
  @TestSetup
  static void setup() {
    Profile stdUserProfile = CommonUtil.getProfileByName('ANZx Standard User');
    UserRole coachRole = CommonUtil.getUserRoleByDevName('Coach');

    // Create coach user
    User coachUser = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'TestCoachInter123',
        'ProfileId' => stdUserProfile.Id,
        'UserRoleId' => coachRole.Id
      }
    );
    insert coachUser;

    List<String> coachPSs = new List<String>{
      'Case_Read_Write_Get_Help',
      'Customer_Read_Only',
      'Quality_Assessment_Read_Only',
      'Case_Read_Write_Dispute'
    };
    List<PermissionSet> coachPsList = [
      SELECT Id
      FROM PermissionSet
      WHERE Name IN :coachPSs
    ];
    List<PermissionSetAssignment> coachPsaList = new List<PermissionSetAssignment>();
    for (PermissionSet ps : coachPsList) {
      coachPsaList.add(TestUtil.createPSAssignment(coachUser.id, ps.Id));
    }
    insert coachPsaList;
  }

  @isTest
  static void testIfFetchRecordPositive() {
    Faker faker = new Faker('AU');
    // GIVEN an account with matching firstname, mobile and email with an existing lead
    Account testAccount = new Account(
      FirstName = 'John',
      LastName = 'Doe',
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true,
      RecordTypeId = GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID,
      PersonEmail = 'john.something@gmail.com',
      PersonMobilePhone = '04011231232'
    );
    insert testAccount;
    User coachUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'TestCoachInter123'
    ];
    System.runAs(coachUser) {
      FetchRecordFromURL fetchRecordFromURLCallable = new FetchRecordFromURL();

      Map<String, Object> params = new Map<String, Object>();
      params.put(
        'input',
        new Map<String, Object>{
          'ws' => '/lightning/r/Account/' +
          testAccount.Id +
          '/view',
          'recordTypeId' => GetHelpConstants.INTERACTION_STORE_RT_ID
        }
      );
      params.put('output', new Map<String, Object>());
      params.put('options', new Map<String, Object>());

      Test.startTest();
      fetchRecordFromURLCallable.call('fetchRecordFromURL', params);
      Test.stopTest();
      System.debug('params -> ' + JSON.serializePretty(params));
    }
  }
}

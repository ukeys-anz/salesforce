/**
 * @author Boobalakrishnan Duraisamy
 * @since 03/2020
 * @description Unit test class for UserProvisioningRestService and User Provisioning Request Trigger
 */
@isTest
public class UserProvisioningRequestTest {
  @testSetup
  static void testSetup() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

    //Create Manager User
    User testUser1 = (User) FakerFactory.make(new FakerUserFactory());
    testUser1.ProfileId = p.Id;
    testUser1.FederationIdentifier = 'Manager';
    insert testUser1;

    //Create Modify Request User
    User testUser2 = (User) FakerFactory.make(new FakerUserFactory());
    testUser2.ProfileId = p.Id;
    testUser2.FederationIdentifier = 'Tester';
    insert testUser2;
  }

  @isTest
  static void testUPR() {
    Faker faker = new Faker('AU');

    List<UserProvisioningRestService.UserProvisioningRequest> uprList = new List<UserProvisioningRestService.UserProvisioningRequest>();

    //Fetch business function and role from the backend to avoid Restricted picklist error in future.
    Schema.DescribeFieldResult businessFunctionResult = User_Provisioning_Request__c.Business_Function__c.getDescribe();
    List<Schema.PicklistEntry> pleBusinessFunction = businessFunctionResult.getPicklistValues();

    Schema.DescribeFieldResult businessRoleResult = User_Provisioning_Request__c.Business_Role__c.getDescribe();
    List<Schema.PicklistEntry> pleBusinessRole = businessRoleResult.getPicklistValues();

    //Prepare Grant User provisioning request test data
    UserProvisioningRestService.UserProvisioningRequest uprGrant = new UserProvisioningRestService.UserProvisioningRequest();
    uprGrant.businessFunction = 'Test BusinessFunction';
    uprGrant.businessRole = pleBusinessRole[0].getValue();
    uprGrant.requestorUUID = faker.randomString(5);
    uprGrant.requestType = 'Grant';
    uprList.add(uprGrant);

    //Prepare Modify User provisioning request test data
    UserProvisioningRestService.UserProvisioningRequest uprModify = new UserProvisioningRestService.UserProvisioningRequest();
    uprModify.businessFunction = pleBusinessFunction[0].getValue();
    uprModify.businessRole = pleBusinessRole[0].getValue();
    uprModify.requestorUUID = 'Tester';
    uprModify.managerUUID = 'Manager';
    uprModify.requestType = 'Modify';
    uprList.add(uprModify);

    //Prepare Revoke User provisioning request test data
    UserProvisioningRestService.UserProvisioningRequest uprRevoke = new UserProvisioningRestService.UserProvisioningRequest();
    uprRevoke.requestorUUID = 'Tester';
    uprRevoke.requestType = 'Revoke';
    uprList.add(uprRevoke);

    //Prepare User provisioning request without request type
    UserProvisioningRestService.UserProvisioningRequest uprError = new UserProvisioningRestService.UserProvisioningRequest();
    uprError.requestorUUID = faker.randomString(5);
    uprList.add(uprError);

    //Prepare User provisioning request without requestor UUID
    UserProvisioningRestService.UserProvisioningRequest uprError1 = new UserProvisioningRestService.UserProvisioningRequest();
    uprError1.requestType = 'Revoke';
    uprList.add(uprError1);

    //Setup request
    RestRequest req = new RestRequest();
    req.requestURI = '/UserProvisioningRequests/';
    req.httpMethod = 'POST';

    //Setup Response
    RestResponse res = new RestResponse();

    //Assign to context
    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();

    UserProvisioningRestService.doPost(uprList);

    Test.stopTest();

    List<User_Provisioning_Request__c> uprRecordList = [
      SELECT Id, Business_Function__c
      FROM User_Provisioning_Request__c
    ];
    //check if UPR record is created with same business function from request record.
    System.assertEquals(
      pleBusinessFunction[0].getValue(),
      uprRecordList[0].Business_Function__c
    );
    //check if the size of inserted User provisioning requests is 2.
    System.assertEquals(2, uprRecordList.size());
  }
}

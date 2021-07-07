/**
 * @author Aidan Majewski
 * @since 06/2021
 * @description Unit test class for User provisioning logic
 */
@isTest
public class UserProvisioningTest {
  @isTest
  static void testUserWithCallCenter() {
    Id ccId = [
      SELECT Id
      FROM CallCenter
      WHERE InternalName = 'TwilioFlexAdapterOpenCTI'
    ]
    .Id;
    List<User> userList = new List<User>();
    User callCenterUser = new User(
      FederationIdentifier = 'ABC123',
      Business_Role__c = 'Business Role',
      Business_Function__c = 'Test Business Function',
      IsActive = true
    );
    userList.add(callCenterUser);
    Set<String> businessFunctions = new Set<String>();
    businessFunctions.add('Test_Business_Function_Business_Role');

    Test.startTest();
    UserProvisioningBeforeActions.assignProfileAndRole(
      userList,
      businessFunctions
    );
    Test.stopTest();

    System.assertEquals(
      ccId,
      userList[0].CallCenterId,
      'call center id assignment failed'
    );
  }

  @isTest
  static void testUserWithoutCallCenter() {
    List<User> userList = new List<User>();
    User callCenterUser = new User(
      FederationIdentifier = 'ABC123',
      Business_Role__c = 'Content Writer',
      Business_Function__c = 'ANZx',
      IsActive = true
    );
    userList.add(callCenterUser);
    Set<String> businessFunctions = new Set<String>();
    businessFunctions.add('ANZx_Content_Writer');

    Test.startTest();
    UserProvisioningBeforeActions.assignProfileAndRole(
      userList,
      businessFunctions
    );
    Test.stopTest();

    System.assertEquals(
      null,
      userList[0].CallCenterId,
      'call center id removal failed'
    );
  }
}

/**
 * @author Boobalakrishnan Duraisamy
 * @since 07/2020
 * @description  Test class for ANZAzureADRegistrationHandler
 */
@isTest
private class ANZAzureADRegistrationHandlerTest {
  /**
   * @description This method is used to test createUser and updateUser methods from ANZAzureADRegistrationHandler
   * GIVEN a user record of existing user WHEN the createUser method is called THEN the corresponding user detail is returned.
   * GIVEN a user record of non existing user WHEN the createUser method is called THEN null value is returned.
   */
  @isTest
  static void testCreateAndUpdateUser() {
    Faker faker = new Faker('AU');
    String testFedId = faker.randomString(8);
    Profile p = CommonUtil.getProfileByName('Standard User');

    ANZAzureADRegistrationHandler handler = new ANZAzureADRegistrationHandler();

    Auth.UserData sampleData = new Auth.UserData(
      'testId',
      'testFirst',
      'testLast',
      'testFirst testLast',
      'testuser@anz.com',
      null,
      'testuserlong',
      'en_AU',
      'AzureAD',
      null,
      new Map<String, String>{
        'upn' => testFedId,
        'idToken' => 'testId',
        'refreshToken' => 'testRefresh'
      }
    );

    Test.startTest();

    //Returns null as there is no user with Federation Id - testFedId
    User u = handler.createUser(null, sampleData);

    //Create user with Federation Id - testFedId
    User testUser = TestUtil.createTestUser(
      new Map<String, Object>{
        'ProfileId' => p.Id,
        'FederationIdentifier' => testFedId
      }
    );
    insert testUser;

    //Call createUser again
    User u1 = handler.createUser(null, sampleData);

    //dummy call to updateUser for code coverage
    handler.updateUser(testUser.Id, null, sampleData);

    Test.stopTest();

    System.assertEquals(null, u, 'No user with Federation id');
    System.assertEquals(
      testUser.Id,
      u1.Id,
      'The test user id should be as expected.'
    );
  }
}

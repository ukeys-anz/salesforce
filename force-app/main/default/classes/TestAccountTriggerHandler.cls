@isTest
private class TestAccountTriggerHandler {
  @isTest
  static void testAccountWhitelist() {
    Faker faker = new Faker('AU');
    List<String> companyNames = faker.text.realWords(2);

    // GIVEN Account whitelisting is configured
    insert new Non_Prod_Settings__c(
      Enable_Account_Whitelisting__c = true,
      Account_Whitelist__c = '1234,5678'
    );

    // WHEN an Account is inserted that does not match the white list
    Account testAccount = new Account(
      Name = companyNames[0].capitalize() + companyNames[1].capitalize(),
      Fabric_ID__c = '12345',
      OCV_ID__c = faker.randomString(10)
    );

    // THEN the account insertion will fail
    try {
      insert testAccount;
      system.assert(
        false,
        'The testAccount should not have inserted due to not being whitelisted.'
      );
    } catch (exception e) {
      system.assert(
        true,
        'The testAccount should fail the above insertion attempt, making this assertion successfully.'
      );
    }

    // WHEN the Account's number is fixed to one that is whitelisted
    testAccount.Fabric_ID__c = '1234';

    // THEN the account insertion will succeed
    insert testAccount;
    system.assert(
      testAccount.ID != null,
      'The testAccount should have been given a Salesforce ID upon insertion.'
    );
  }
}

/**
 * @author Tan Phan
 * @since 03/2023
 * @description Test class for CCRMHideContactInvocable
 */
@IsTest
private class CCRMHideContactInvocableTest {
  static Faker faker = new Faker('AU');

  //CREATE Test ContactPointEmail Records
  @TestSetup
  static void setupCreateData() {
    User admin = CCRMTestDataFactory.getAdminUser();
    System.runAs(admin) {
      Account acc = CCRMTestDataFactory.createProspectBusinessAccount(
        CCRMTestDataFactory.getCCRMBaseUser().Id
      );

      Salesforce_Library_Settings__c settings = Salesforce_Library_Settings__c.getInstance(
        admin.Id
      );
      settings.Disable_Triggers__c = true;
      upsert settings;

      Date yesterday = System.today().addDays(-1);

      Contact con = [SELECT Id FROM Contact WHERE AccountId = :acc.Id];
      con.Active_To__c = yesterday;
      ContactPointAddress cpa = new ContactPointAddress(
        Name = faker.randomString(10),
        ParentId = acc.Id,
        ActiveToDate = yesterday
      );
      ContactPointEmail cpe = new ContactPointEmail(
        EmailAddress = faker.internet.companyEmail(),
        ParentId = acc.Id,
        ActiveToDate = yesterday
      );
      ContactPointPhone cpp = new ContactPointPhone(
        TelephoneNumber = faker.person.phone(true, true),
        ParentId = acc.Id,
        ActiveToDate = yesterday
      );

      upsert new List<SObject>{ con, cpa, cpe, cpp };
    }
  }

  @IsTest
  static void testFlow() {
    Test.startTest();
    System.runAs(getAutomatedProcessUser()) {
      CCRMHideContactInvocable.hideContactsInvocable();
    }
    Test.stopTest();

    Account acc = [SELECT Id FROM Account LIMIT 1];
    Contact con = [
      SELECT Id, RecordType.DeveloperName, Previous_Record_Type__c
      FROM Contact
      LIMIT 1
    ];
    System.assertEquals(
      'Hidden',
      con.RecordType.DeveloperName,
      'Contact record type should be updated to "Hidden"'
    );
    System.assertEquals(
      'Business',
      con.Previous_Record_Type__c,
      'Contact previous record type should be updated to "Business"'
    );

    ContactPointAddress cpa = [
      SELECT Id, ParentId, Previous_Related_Account__c
      FROM ContactPointAddress
      LIMIT 1
    ];
    System.assertEquals(
      null,
      cpa.ParentId,
      'ContactPointAddress parent ID should be set to blank'
    );
    System.assertEquals(
      acc.Id,
      cpa.Previous_Related_Account__c,
      'ContactPointAddress previous parent ID should be copied before setting parent ID to blank'
    );

    ContactPointEmail cpe = [
      SELECT Id, ParentId, Previous_Related_Account__c
      FROM ContactPointEmail
      LIMIT 1
    ];
    System.assertEquals(
      null,
      cpe.ParentId,
      'ContactPointEmail parent ID should be set to blank'
    );
    System.assertEquals(
      acc.Id,
      cpe.Previous_Related_Account__c,
      'ContactPointEmail previous parent ID should be copied before setting parent ID to blank'
    );

    ContactPointPhone cpp = [
      SELECT Id, ParentId, Previous_Related_Account__c
      FROM ContactPointPhone
      LIMIT 1
    ];
    System.assertEquals(
      null,
      cpp.ParentId,
      'ContactPointPhone parent ID should be set to blank'
    );
    System.assertEquals(
      acc.Id,
      cpp.Previous_Related_Account__c,
      'ContactPointPhone previous parent ID should be copied before setting parent ID to blank'
    );
  }

  static User getAutomatedProcessUser() {
    User u = [SELECT Id, Profile.Name FROM User WHERE alias = 'autoproc'];
    System.debug('autoproc # ' + u);
    return u;
  }
}

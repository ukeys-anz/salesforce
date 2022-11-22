/**
 * @author Sreekanth Dadipineni
 * @since 09/2022
 * @description CCRM ContactPointEmail Action is the test class for CCRM ContactPointEmail Actions Class.
 */
@IsTest
private class CCRMContactPointEmailActionsTest {
  static Faker faker = new Faker('AU');

  //CREATE Test ContactPointEmail Records
  @TestSetup
  static void setupCreateData() {
    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      Account acc = CCRMTestDataFactory.createProspectBusinessAccount(
        CCRMTestDataFactory.getCCRMBaseUser().Id
      );
      ContactPointEmail acpe = new ContactPointEmail();
      acpe.EmailAddress = faker.internet.companyEmail();
      acpe.Customer_Name__c = acc.Id;
      acpe.ParentId = acc.Id;
      acpe.Occurrence_Number__c = 12;
      insert acpe;
    }
  }
  @IsTest
  static void testUpdateRelatedRecord() {
    //Given when creates a new record
    ContactPointEmail cpe = [
      SELECT Id, ActiveToDate
      FROM ContactPointEmail
      WHERE Customer_Name__r.Is_Prospect__c = TRUE
      LIMIT 1
    ];
    //WHEN That ContactPointEmail is updated
    Test.startTest();
    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      cpe.ActiveToDate = date.today();
      update cpe;
    }
    Test.stopTest();

    System.assertEquals(
      null,
      [SELECT ParentId FROM ContactPointEmail WHERE Id = :cpe.Id]
      .ParentId,
      'Email should not appear'
    );
  }

  @IsTest
  static void testTrackChangedFields() {
    //GIVEN ContactPointEmail record linked to a prospect customer
    ContactPointEmail record = [
      SELECT Id, EmailAddress
      FROM ContactPointEmail
      WHERE Customer_Name__r.Is_Prospect__c = TRUE
      LIMIT 1
    ];

    //WHEN That record is updated
    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      record.EmailAddress = 1 + record.EmailAddress;
      update record;
    }
    Test.stopTest();

    //THEN a customer profile update record is created
    System.assertEquals(
      1,
      [SELECT COUNT() FROM Customer_Profile_Updates__c],
      'Customer_Profile_Updates__c record should be created when ContactPointEmail is updated'
    );
  }

  @IsTest
  static void testCheckExistingEmailOnProspect() {
    //GIVEN Banker tries to add a new email address to a prospect that already has email
    Account prospect = [
      SELECT Id
      FROM Account
      WHERE Is_Prospect__c = TRUE
      LIMIT 1
    ];
    ContactPointEmail newEmail = new ContactPointEmail(
      Customer_Name__c = prospect.Id,
      EmailAddress = faker.internet.companyEmail()
    );

    //WHEN the email is inserted
    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      CCRMContactPointEmailActions.checkExistingEmailOnProspect(
        new List<ContactPointEmail>{ newEmail }
      );
    }
    Test.stopTest();

    //THEN the new email should not be added
    System.assert(
      newEmail.hasErrors(),
      'Banker should not be able to add an extra email to prospect'
    );
  }
}

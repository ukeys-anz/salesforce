@IsTest
private class CCRMCustomerProfileUpdateHelperTest {
  static Faker faker = new Faker('AU');

  @TestSetup
  static void makeData() {
    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      Account acc = CCRMTestDataFactory.createProspectBusinessAccount(
        CCRMTestDataFactory.getCCRMBaseUser().Id
      );
    }
  }

  @IsTest
  static void testCreateCustomerProfileUpdates() {
    //GIVEN a prospect customer
    Account prospect = [
      SELECT Id, Name, ABN__c
      FROM Account
      WHERE Is_Prospect__c = TRUE
      LIMIT 1
    ];
    Map<Id, Account> oldMap = new Map<Id, Account>{
      prospect.Id => new Account(
        Id = prospect.Id,
        Name = prospect.Name,
        ABN__c = prospect.ABN__c
      )
    };

    //WHEN the customer is updated twice
    Account update1 = new Account(
      Id = prospect.Id,
      Name = prospect.Name + 1,
      ABN__c = null
    );
    Account update2 = new Account(Id = prospect.Id, Name = prospect.Name + 2);
    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        new List<Account>{ update1 },
        oldMap
      );
      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        new List<Account>{ update2 },
        oldMap
      );
    }
    Test.stopTest();

    //THEN a customer profile update record is created for the 1st update
    System.assertEquals(
      2,
      [SELECT COUNT() FROM Customer_Profile_Updates__c],
      '2 Customer_Profile_Updates__c records should be created when both customer name and tax details are updated'
    );
    //AND the second update failed
    System.assert(
      update2.hasErrors(),
      'Customer update should be blocked when there is a pending update already'
    );
  }

  @IsTest
  static void testDeleteProspectContactErrorLastRecord() {
    //GIVEN a prospect contact that is the only contact of the prospect
    Contact con = [
      SELECT Id
      FROM Contact
      WHERE Account.Is_Prospect__c = TRUE
      LIMIT 1
    ];
    //WHEN banker delete that contact
    Test.startTest();
    Exception error;
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      try {
        CCRMCustomerProfileUpdateHelper.deleteProspectContact(con.Id);
      } catch (Exception ex) {
        error = ex;
      }
    }
    Test.stopTest();
    //THEN an error occur
    System.Assert(
      error != null,
      'Banker should not be able to delete last prospect contact'
    );
  }

  @IsTest
  static void testDeleteProspectContact() {
    //GIVEN a prospect with 2 contacts
    Contact con1 = [
      SELECT Id, AccountId
      FROM Contact
      WHERE Account.Is_Prospect__c = TRUE
      LIMIT 1
    ];
    Contact con2 = new Contact(
      LastName = faker.person.lastName(),
      Phone = faker.person.phone(true, false),
      AccountId = con1.AccountId
    );
    insert con2;
    //WHEN banker delete the contacts one after another
    Test.startTest();
    Exception error;
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      CCRMCustomerProfileUpdateHelper.deleteProspectContact(con1.Id);

      try {
        CCRMCustomerProfileUpdateHelper.deleteProspectContact(con2.Id);
      } catch (Exception ex) {
        error = ex;
      }
    }
    Test.stopTest();
    //THEN the first delete success, and the 2nd delete failed.
    System.Assert(
      error != null,
      'Banker should not be able to delete contact when there is already a pending delete'
    );
  }

  @IsTest
  static void testRevertNewRecords() {
    //GIVEN a prospect with 2 contacts
    Account prospect = [
      SELECT Id, Name
      FROM Account
      WHERE Is_Prospect__c = TRUE
      LIMIT 1
    ];

    //WHEN banker added a contact to that account
    Contact con = [
      SELECT Id, AccountId
      FROM Contact
      WHERE Account.Is_Prospect__c = TRUE
      LIMIT 1
    ];
    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        new List<Contact>{ new Contact(Id = con.Id) },
        null
      );
    }
    Test.stopTest();

    //THEN that record is deleted later
    System.assertEquals(
      0,
      [SELECT COUNT() FROM Contact WHERE Id = :con.Id],
      'Contact added by banker should be deleted after Customer Update event is raised'
    );
  }

  @IsTest
  static void testTrackingRequest() {
    List<Customer_Profile_Updates__c> updates;
    ContactPointAddress newRecord = new ContactPointAddress(
      Street = faker.address.street()
    );
    ContactPointAddress oldRecord = new ContactPointAddress();

    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      updates = new CCRMCustomerProfileUpdateConfig.TrackingRequest(
          newRecord,
          oldRecord
        )
        .getUpdates();
    }
    Test.stopTest();

    System.assert(
      !updates.isEmpty() && updates[0].ToBeValue__c.contains('addressLine1'),
      '1 update record should be created and contains transformed key'
    );
  }
}

/**
 * @author Sreekanth Dadipineni
 * @since 09/2022
 * @description CCRM ContactPointAddress Action is the test class for CCRM ContactPointAddress Actions Class.
 */

@IsTest
private class CCRMContactPointAddressActionsTest {
  static Faker faker = new Faker('AU');

  //CREATE Test ContactPointAddress Records
  @TestSetup
  static void setupObjectData() {
    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      Account acc = CCRMTestDataFactory.createProspectBusinessAccount(
        CCRMTestDataFactory.getCCRMBaseUser().Id
      );
      ContactPointAddress acpa = new ContactPointAddress();
      acpa.ParentId = acpa.Customer_Name__c = acc.Id;
      acpa.Name = acpa.AddressType = 'Primary Mailing';
      acpa.Street = faker.address.street();
      acpa.City = faker.address.city();
      acpa.State = faker.address.state();
      acpa.Country = faker.address.country();
      acpa.PostalCode = faker.address.stateCode();
      acpa.Global_Address_Key__c = faker.randomString(40);
      insert acpa;

      Account accActive = CCRMTestDataFactory.createBusinessAccountWithOwner(
        CCRMTestDataFactory.getCCRMBaseUser().Id
      );

      ContactPointAddress activeCPA = new ContactPointAddress();
      activeCPA.ParentId = activeCPA.Customer_Name__c = accActive.Id;
      activeCPA.Name = activeCPA.AddressType = 'Primary Mailing';
      activeCPA.Street = faker.address.street();
      activeCPA.City = faker.address.city();
      activeCPA.State = faker.address.state();
      activeCPA.Country = faker.address.country();
      activeCPA.PostalCode = faker.address.stateCode();
      activeCPA.Global_Address_Key__c = faker.randomString(40);
      insert activeCPA;
    }
  }
  @IsTest
  static void testUpdateCpaRecord() {
    //Given when creates a new record
    ContactPointAddress cpa = [
      SELECT Id, ParentId, ActiveToDate
      FROM ContactPointAddress
      WHERE Customer_Name__r.Is_Prospect__c = TRUE
      LIMIT 1
    ];

    //WHEN That ContactPointAddress is updated
    Test.startTest();
    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      cpa.ActiveToDate = date.today();
      update cpa;
    }
    Test.stopTest();

    System.assertEquals(
      null,
      [SELECT ParentId FROM ContactPointAddress WHERE Id = :cpa.Id]
      .ParentId,
      'Address should not appear'
    );
  }

  @IsTest
  static void testTrackChangedFields() {
    //GIVEN ContactPointAddress record linked to a prospect customer
    ContactPointAddress cpa = [
      SELECT Id, ParentId, ActiveToDate, Street
      FROM ContactPointAddress
      WHERE Customer_Name__r.Is_Prospect__c = TRUE
      LIMIT 1
    ];

    //WHEN That record is updated
    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      cpa.Street = cpa.Street + 1;
      update cpa;
    }
    Test.stopTest();

    //THEN a customer profile update record is created
    System.assertEquals(
      1,
      [SELECT COUNT() FROM Customer_Profile_Updates__c],
      'Customer_Profile_Updates__c record should be created when ContactPointAddress is updated'
    );
  }

  @IsTest
  static void testCheckExistingAddressOnProspect() {
    //GIVEN Banker tries to add 2 new addresses to prospect, 1 with the same address type as current address and 1 with new address type
    Account prospect = [
      SELECT Id
      FROM Account
      WHERE Is_Prospect__c = TRUE
      LIMIT 1
    ];
    ContactPointAddress newAddress = new ContactPointAddress(
      Customer_Name__c = prospect.Id,
      AddressType = 'Principal Place of Business'
    );
    ContactPointAddress dupAddress = new ContactPointAddress(
      Customer_Name__c = prospect.Id,
      AddressType = 'Primary Mailing'
    );

    //WHEN the addresses are inserted
    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      CCRMContactPointAddressActions.checkExistingAddressOnProspectOrExistingCust(
        new List<ContactPointAddress>{ newAddress, dupAddress }
      );
    }
    Test.stopTest();

    //THEN address with different address type should be added
    System.assert(
      !newAddress.hasErrors(),
      'Banker should be able to add address of different type to prospect'
    );
    //AND address with same address type should not be added
    System.assert(
      dupAddress.hasErrors(),
      'Banker should not be able to add address of same type to prospect'
    );
  }

  @IsTest
  static void testCheckExistingAddressOnActive() {
    //GIVEN Banker tries to add 2 new addresses to active Account, 1 with the same address type as current address and 1 with new address type
    Account activeAccount = [
      SELECT Id
      FROM Account
      WHERE
        RecordTypeId = :CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID
        AND FinServ__Status__c = :CCRMConstants.ACTIVE_STATUS
        AND Source_System_Name__c = :Label.CCRM_Source_System_Name
        AND ANZx_Customer__c = FALSE
      LIMIT 1
    ];
    ContactPointAddress newAddress = new ContactPointAddress(
      Customer_Name__c = activeAccount.Id,
      AddressType = 'Principal Place of Business'
    );
    ContactPointAddress dupAddress = new ContactPointAddress(
      Customer_Name__c = activeAccount.Id,
      AddressType = 'Primary Mailing'
    );

    //WHEN the addresses are inserted
    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      CCRMContactPointAddressActions.checkExistingAddressOnProspectOrExistingCust(
        new List<ContactPointAddress>{ newAddress, dupAddress }
      );
    }
    Test.stopTest();

    //THEN address with different address type should be added
    System.assert(
      !newAddress.hasErrors(),
      'Banker should be able to add address of different type to active Account'
    );
    //AND address with same address type should not be added
    System.assert(
      dupAddress.hasErrors(),
      'Banker should not be able to add address of same type to active Account'
    );
  }
}

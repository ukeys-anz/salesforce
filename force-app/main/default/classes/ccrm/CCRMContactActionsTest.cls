/**
 * @author Tan Phan
 * @since 11/2022
 * @description Test class for {@link CCRMContactActions}
 */
@IsTest
private class CCRMContactActionsTest {
  static Faker faker = new Faker('AU');

  @TestSetup
  static void makeData() {
    Account prospectAccount;
    Account activeAccount;
    User ccrmBaseUser = CCRMTestDataFactory.getCCRMBaseUser();
    System.runAs(CCRMTestDataFactory.getOcvIntegrationUser()) {
      prospectAccount = CCRMTestDataFactory.createProspectBusinessAccount(
        CCRMTestDataFactory.getOcvIntegrationUser().Id
      );

      activeAccount = CCRMTestDataFactory.createBusinessAccountWithOwner(
        CCRMTestDataFactory.getOcvIntegrationUser().Id
      );
    }

    CCRMTestDataFactory.createAccountShare(prospectAccount.Id, ccrmBaseUser.Id);
    CCRMTestDataFactory.createAccountShare(activeAccount.Id, ccrmBaseUser.Id);
  }

  @IsTest
  static void testContactEndDate() {
    List<Contact> contactUpdateList;
    List<Contact> contactInsertList;

    System.runAs(CCRMTestDataFactory.getOcvIntegrationUser()) {
      //GIVEN contacts with value in fax, mobile and/or phone
      contactUpdateList = CCRMTestDataFactory.createContacts(
        Integer.valueOf(Label.Test_Bulk_Size),
        true
      );

      //WHEN fax, mobile and phone of 1 of the records are set to blank, and the rest still keep their fax detail
      for (Contact contact : contactUpdateList) {
        contact.Phone = contact.MobilePhone = null;
      }
      contactUpdateList[0].Fax = null;

      Test.startTest();
      contactInsertList = CCRMTestDataFactory.createContacts(
        Integer.valueOf(Label.Test_Bulk_Size),
        false
      );
      update contactUpdateList;
      Test.stopTest();
    }

    //THEN the contact without any of the details is deleted
    System.assertEquals(
      0,
      [
        SELECT COUNT()
        FROM Contact
        WHERE Id = :contactUpdateList[0].Id OR Id IN :contactInsertList
      ],
      'Contact should be deleted when fax, mobile and phone are blank'
    );
    //AND other contacts shouldn't be deleted
    System.assertEquals(
      contactUpdateList.size() - 1,
      [SELECT COUNT() FROM Contact WHERE Id IN :contactUpdateList],
      'Contacts that still have fax detail should not be deleted'
    );
  }
}

/**
 * @author Naman Garg
 * @since Oct 2024
 * @description  CommercialContactActionsHelperTest is the test class for CommercialContactActionsHelper.
 */

@isTest
public class CommercialContactActionsHelperTest {
  static Lib_MockProvider accountRepoMock;
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    accountRepoMock = Lib_MockProvider.forType(
      CommercialAccountRepository.class
    );
  }

  @isTest
  static void testGetExistingOrProspectContacts() {
    registerMocks();

    //GIVEN Account and Contact record
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<Account> accList = new List<Account>{
      new Account(
        Id = accId,
        RecordTypeId = RTAccount.businessAccount,
        Source_System_Name__c = 'CAP-CIS',
        ANZx_Customer__c = false,
        FinServ__Status__c = 'Active'
      )
    };
    List<Contact> conList = new List<Contact>{
      new Contact(
        Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType),
        RecordTypeId = RTContact.organisation,
        accountId = accId
      )
    };
    accountRepoMock.mock('fetchAccounts', accList);

    //WHEN we call the method to get Existing or Prospect contacts
    Test.startTest();
    CommercialContactActionsHelper.ContactWrapper conWrapper = CommercialContactActionsHelper.getExistingOrProspectContacts(
      conList
    );
    Test.stopTest();

    //THEN it should find 1 record
    Assert.areEqual(
      1,
      conWrapper.existingAndProspectContacts.size(),
      'Not able to form the contact wrapper'
    );
  }
}

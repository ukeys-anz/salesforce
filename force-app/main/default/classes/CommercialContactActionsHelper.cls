/**
 * @author Naman Garg
 * @since Oct 2024
 * @description  CommercialContactActionsHelper is the helper class for CommercialContactActions.
 */

public with sharing class CommercialContactActionsHelper {
  private static final String ACTIVE_STATUS = 'Active';
  private static final String INACTIVE_STATUS = 'Inactive';

  private static final CommercialContactRepository CONTACT_REPOSITORY = (CommercialContactRepository) Lib_InstanceProvider.forType(
    CommercialContactRepository.class
  );
  private static final CommercialAccountRepository ACCOUNT_REPOSITORY = (CommercialAccountRepository) Lib_InstanceProvider.forType(
    CommercialAccountRepository.class
  );

  public static List<Contact> prospectContactsList = new List<Contact>();
  public static List<Contact> existingContactsList = new List<Contact>();
  public static List<Contact> existingAndProspectContactsList = new List<Contact>();

  /**
   * @description getExistingOrProspectContact to get the contact related to Existing or Prospect Accounts
   * @param records List of commercial contact Records
   */
  public static void getExistingOrProspectContacts(List<Contact> records) {
    Id anzCCRMStandardUserProfileId = QueryProfile.anzCCRMStandardUser.Id;
    Id anzMLStandardUserProfileId = QueryProfile.anzMLStandardUser.Id;
    Id curentUserProfileId = CONTACT_REPOSITORY.getUserProfileId();
    List<Account> orgIndAccountsList = new List<Account>();
    Set<String> statusList = new Set<String>{ ACTIVE_STATUS, INACTIVE_STATUS };
    if (
      curentUserProfileId != anzCCRMStandardUserProfileId &&
      curentUserProfileId != anzMLStandardUserProfileId
    ) {
      return;
    }

    //Fetch contacts where accountId is not null
    Set<Id> accIdsSet = ListUtil.getIds(records, Contact.AccountId);

    //Query the list of Accounts related to Contacts
    List<Account> accList = ACCOUNT_REPOSITORY.fetchAccounts(accIdsSet);

    //Seggregate the Account based on Type whether its Prospect or Existing account
    //Seggregate if Prospect
    List<Account> prospectAccountsList = ListUtil.filter(accList)
      .equals(Account.Is_Prospect__c, true)
      .toList();

    Set<Id> prospectAccountIdsSet = ListUtil.getIds(
      prospectAccountsList,
      Account.Id
    );

    //Seggregate if Existing
    List<Account> orgAccountsList = ListUtil.filter(accList)
      .equals(Account.RecordTypeId, RTAccount.businessAccount)
      .toList();
    List<Account> individualAccountsList = ListUtil.filter(accList)
      .equals(Account.isPersonAccount, true)
      .toList();

    orgIndAccountsList.addAll(orgAccountsList);
    orgIndAccountsList.addAll(individualAccountsList);

    //Filtering the Individual or Organisation accounts based on criteria
    List<Account> existingAccountsList = ListUtil.filter(orgIndAccountsList)
      .equals(Account.FinServ__Status__c, statusList)
      .equals(Account.Source_System_Name__c, 'CAP-CIS')
      .equals(Account.ANZx_Customer__c, false)
      .toList();

    Set<Id> existingAccountIdsSet = ListUtil.getIds(
      existingAccountsList,
      Account.Id
    );

    //Extracting Contact based on Account type
    prospectContactsList = ListUtil.filter(records)
      .equals(Contact.AccountId, prospectAccountIdsSet)
      .toList();

    existingContactsList = ListUtil.filter(records)
      .equals(Contact.AccountId, existingAccountIdsSet)
      .toList();

    //Combining all contacts
    existingAndProspectContactsList.addAll(prospectContactsList);
    existingAndProspectContactsList.addAll(existingContactsList);
  }
}

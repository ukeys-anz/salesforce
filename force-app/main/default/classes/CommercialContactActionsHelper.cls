/**
 * @author Naman Garg
 * @since Oct 2024
 * @description  CommercialContactActionsHelper is the helper class for CommercialContactActions.
 */

public with sharing class CommercialContactActionsHelper {
  private static final String ACTIVE_STATUS = 'Active';
  private static final String INACTIVE_STATUS = 'Inactive';

  private static final CommercialAccountRepository ACCOUNT_REPOSITORY = (CommercialAccountRepository) Lib_InstanceProvider.forType(
    CommercialAccountRepository.class
  );
  /**
   * @description getExistingOrProspectContact to get the contact related to Existing or Prospect Accounts
   * @param records List of commercial contact Records
   * @return ContactWrapper return List of Existing or Prospect Contact
   */
  public static ContactWrapper getExistingOrProspectContacts(
    List<Contact> records
  ) {
    ContactWrapper contactWrapper = new ContactWrapper();
    List<Account> existingAndProspectAccounts = new List<Account>();
    Set<Id> accIdsSet = ListUtil.getIds(records, Contact.AccountId);
    List<Account> accList = ACCOUNT_REPOSITORY.fetchAccounts(accIdsSet);
    CCRMAccountActions.AccountWrapper accountWrap = new CCRMAccountActions.AccountWrapper(
      accList
    );
    existingAndProspectAccounts.addAll(accountWrap.prospectAccounts.values());
    existingAndProspectAccounts.addAll(accountWrap.existingAccounts.values());
    ContactWrapper.existingAndProspectContacts = ListUtil.filter(records)
      .notEquals(Contact.AccountId, existingAndProspectAccounts)
      .toList();
    return contactWrapper;
  }

  /**
   * @author Naman Garg
   * @since  09/2023
   * @group CCRM (Commercial CRM)
   * @description ContactWrapper wrapper class to hold Existing and Prospect Contact
   * @name ContactWrapper
   */
  public class ContactWrapper {
    public List<Contact> existingAndProspectContacts = new List<Contact>();
  }
}

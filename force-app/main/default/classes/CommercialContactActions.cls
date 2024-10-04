/**
 * @author Naman Garg
 * @since Oct 2024
 * @description  CommercialContactActions is the orchestrator class for CommercialContactTriggerHandler.
 */

public with sharing class CommercialContactActions {
  private static final CommercialContactRepository CONTACT_REPOSITORY = (CommercialContactRepository) Lib_InstanceProvider.forType(
    CommercialContactRepository.class
  );

  /**
   * @description This is used to populate the last name field on contact during creation/updation
   * @param contactList the list of contacts
   * @param oldContactMap contains old value of contact
   */
  public static void populateLastName(
    List<Contact> contactList,
    Map<Id, Contact> oldContactMap
  ) {
    Id anzCCRMStandrdUserProfileId = QueryProfile.anzCCRMStandardUser.Id;
    Id curentUserProfileId = CONTACT_REPOSITORY.getUserProfileId();
    if (curentUserProfileId != anzCCRMStandrdUserProfileId) {
      return;
    }

    List<Contact> filterConList = ListUtil.filter(contactList, oldContactMap)
      .changed(Contact.Name__c)
      .toList();

    for (Contact conRec : filterConList) {
      conRec.LastName = conRec.Name__c;
    }
  }

  /**
   * @description This is used to populate the custom name field on contact during creation/updation
   * @param contactList the list of contacts
   * @param oldContactMap contains old value of contact
   */
  public static void populateName(
    List<Contact> contactList,
    Map<Id, Contact> oldContactMap
  ) {
    String currentUsername = CONTACT_REPOSITORY.getUserName();
    if (!currentUsername.contains(Label.CCRM_OCVIntegrationUsername)) {
      return;
    }

    List<Contact> filterConList = ListUtil.filter(contactList, oldContactMap)
      .changed(Contact.LastName)
      .toList();

    for (Contact conRec : filterConList) {
      conRec.Name__c = conRec.LastName;
    }
  }
}

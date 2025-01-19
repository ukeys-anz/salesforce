/**
 * @author Tan Phan
 * @since  09/2022
 * @description CCRMContactActions is the class to handle all the CCRM (Commercial CRM) Actions related to Contact object
 * @runTests CCRMContactActionsTest
 */
public with sharing class CCRMContactActions {
  /**
   * @description Delete commercial contacts when fax, mobile and phone are blank
   * when Phone and Mobile and Fax deleted from commercial contact
   * @param records List of new contacts records
   */
  public static void deleteCommercialContactsWithoutContactDetails(
    List<Contact> records
  ) {
    Set<Id> recordIdsToDelete = new Set<Id>();
    for (Contact record : records) {
      if (
        record.RecordTypeId == CCRMConstants.CONTACT_BUSINESS_RT_ID &&
        String.isBlank(record.Phone) &&
        String.isBlank(record.MobilePhone) &&
        String.isBlank(record.Fax)
      ) {
        recordIdsToDelete.add(record.Id);
      }
    }
    if (!recordIdsToDelete.isEmpty()) {
      deleteCommercialContactAsync(recordIdsToDelete);
    }
  }

  @future
  private static void deleteCommercialContactAsync(Set<Id> recordIds) {
    DMLUtil.deleteRecords(
      [SELECT Id FROM Contact WHERE Id IN :recordIds],
      true,
      false
    );
  }
}

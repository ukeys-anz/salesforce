/**
 * @author Ashwin Mohan
 * @since 10/2024
 * @description ContactPointAddressActions related to handling ContactPointAddress object.
 * @runTests ContactPointAddressActionsTest
 */
public with sharing class ContactPointAddressActions {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description to delete expired ContactPointAddress records
   * @name deleteExpiredRecords
   * @param records the list of address records from trigger
   * @param oldMap oldMap records
   */
  public static void deleteExpiredRecords(
    List<ContactPointAddress> records,
    Map<Id, ContactPointAddress> oldMap
  ) {
    if (!Schema.sObjectType.ContactPointAddress.isDeletable()) {
      return;
    }
    List<ContactPointAddress> addressesToDelete = new List<ContactPointAddress>();
    List<ContactPointAddress> updatedATDAddresses = ListUtil.filter(
        records,
        oldMap
      )
      .changed(ContactPointAddress.ActiveToDate)
      .toList();
    for (ContactPointAddress addr : updatedATDAddresses) {
      if (addr.ActiveToDate == null || addr.ActiveToDate > System.today()) {
        continue;
      }
      addressesToDelete.add(new ContactPointAddress(Id = addr.Id));
    }
    DML_REPOSITORY.doDelete(addressesToDelete, new DmlConfig().allowPartial());
  }
}

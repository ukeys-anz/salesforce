/**
 * @author Ashwin Mohan
 * @since 11/24
 * @description Action class for Contact Point objects
 */
public with sharing class ContactPointObjectActions {
  private static final String ATLEAST_ONE_PHONE_ERROR = 'This record cannot be deleted as the customer must have at least one phone number available.';
  private static final String SUCCESS = 'Success';
  private static final ContactPointObjectActionsRepository PHONE_REPOSITORY = (ContactPointObjectActionsRepository) Lib_InstanceProvider.forType(
    ContactPointObjectActionsRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description To update ActiveToDate field from flow
   * @name updateActiveToDate
   * @param recordIds list of recordIds to update
   * @return List<String> Success or error message
   */
  @InvocableMethod(
    label='Update Active to Date'
    description='Method to update Active to Date to Today'
  )
  public static List<String> updateActiveToDate(List<String> recordIds) {
    Id recordId = recordIds[0];
    if (recordId == null) {
      return null;
    }
    if (recordId.getSobjectType().toString() == 'ContactPointPhone') {
      ContactPointPhone cppRecord = PHONE_REPOSITORY.getCustomerFromPhone(
        recordId
      );
      List<ContactPointPhone> phoneRecords = PHONE_REPOSITORY.getPhoneRecords(
        cppRecord.ParentId
      );
      if (phoneRecords.size() == 1) {
        return new List<String>{ ATLEAST_ONE_PHONE_ERROR };
      }
    }
    SObject contactPointRecord = recordId.getSobjectType().newSObject(recordId);
    contactPointRecord.put('ActiveToDate', System.today());
    DML_REPOSITORY.doUpdate(contactPointRecord);
    return new List<String>{ SUCCESS };
  }
}

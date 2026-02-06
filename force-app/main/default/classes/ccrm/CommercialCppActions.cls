/**
 * @author Naman Garg
 * @since April'25
 * @description CommercialCppActions is class to handle all the  ContactPointPhone Actions in Trigger
 */

public with sharing class CommercialCppActions {
  private static final String USAGE_TYPE_SECURITY_MOBILE = 'Security Mobile';
  @TestVisible
  private static final String NOT_ALLOWED_USAGE_TYPE_ERROR = 'You are not authorized to insert the ANZx mobile phone';
  @TestVisible
  private static final String USAGE_TYPE_CHANGE_ERROR = 'You do not have the necessary privileges to update the usage type';
  private static final String CONTACT_ADMIN_ERROR = 'You are not authorized to update Security Mobile.';

  /**
   * @description validate if insert is allowed based on usage type
   * @param records the list of Phone record to validate
   */
  public static void validateUsageType(List<ContactPointPhone> records) {
    List<SObject> securityPhoneRecords = ListUtil.filter(records)
      .equals(ContactPointPhone.UsageType, USAGE_TYPE_SECURITY_MOBILE)
      .toList();

    ListUtil.addError(securityPhoneRecords, NOT_ALLOWED_USAGE_TYPE_ERROR);
  }

  /**
   * @description prevent edit if usage type is changed or anzx mobile is changed by ML user
   * @param records the list of Phone record to validate
   * @param oldMap old record map
   */
  public static void preventEdit(
    List<ContactPointPhone> records,
    Map<Id, ContactPointPhone> oldMap
  ) {
    List<SObject> securityMobileRecords = ListUtil.filter(records)
      .equals(ContactPointPhone.UsageType, USAGE_TYPE_SECURITY_MOBILE)
      .toList();
    ListUtil.addError(securityMobileRecords, CONTACT_ADMIN_ERROR);

    List<SObject> recordWithUsageTypeChange = ListUtil.filter(records, oldMap)
      .changed(ContactPointPhone.UsageType)
      .toList();
    ListUtil.addError(recordWithUsageTypeChange, USAGE_TYPE_CHANGE_ERROR);
  }
}

/**
 * @author Ashwin Mohan
 * @since 10/2024
 * @description ContactPointEmailActions related to handling ContactPointEmail object.
 * @runTests ContactPointEmailActionsTest
 */
public with sharing class ContactPointEmailActions {
  private static final String USAGE_TYPE_SECURITY_EMAIL = 'Security Email';
  private static final ContactPointObjectActionsRepository EMAIL_REPOSITORY = (ContactPointObjectActionsRepository) Lib_InstanceProvider.forType(
    ContactPointObjectActionsRepository.class
  );
  private static final String EMAIL_EXISTS_ERROR = 'An email record of this type is already available for this customer. Please edit the existing email record for the customer.';
  private static final String USAGE_TYPE_EMAIL = 'Email';
  private static final String USAGE_TYPE_BUSINESS_EMAIL = 'Business Email';
  private static final String PROFILE_ML_USER = 'ANZ ML Standard User';
  private static final String NOT_ALLOWED_USAGE_TYPE_ERROR = 'You are not authorised to add/edit an email other than usage type of \'Email\'.';
  private static final String USAGE_TYPE_CHANGE_ERROR = 'You do not have the necessary privileges to update the usage type';
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  /**
   * @description validate if insert is allowed based on usage type
   * @param records the list of Phone record to validate
   */
  public static void validateUsageType(List<ContactPointEmail> records) {
    if (
      EMAIL_REPOSITORY.isCustomValidationsSkipped() ||
      !EMAIL_REPOSITORY.isCurrentLoggedInMLUser()
    ) {
      return;
    }
    List<SObject> emailRecordsWithNonEmailUsageType = ListUtil.filter(records)
      .notEquals(ContactPointEmail.UsageType, USAGE_TYPE_EMAIL)
      .toList();
    CommonUtil.raiseSobjectError(
      emailRecordsWithNonEmailUsageType,
      NOT_ALLOWED_USAGE_TYPE_ERROR
    );
  }

  /**
   * @description prevent edit of records when usage type is changed or usage type is anzx by ml user
   * @param records the list of Phone record to validate
   * @param oldMap oldMap records
   */
  public static void preventEdit(
    List<ContactPointEmail> records,
    Map<Id, ContactPointEmail> oldMap
  ) {
    if (
      EMAIL_REPOSITORY.isCustomValidationsSkipped() ||
      !EMAIL_REPOSITORY.isCurrentLoggedInMLUser()
    ) {
      return;
    }
    List<SObject> recordWithUsageTypeChange = ListUtil.filter(records, oldMap)
      .changed(ContactPointEmail.UsageType)
      .toList();
    CommonUtil.raiseSobjectError(
      recordWithUsageTypeChange,
      USAGE_TYPE_CHANGE_ERROR
    );
    List<SObject> emailRecordsWithNonEmailUsageType = ListUtil.filter(records)
      .notEquals(ContactPointEmail.UsageType, USAGE_TYPE_EMAIL)
      .toList();
    CommonUtil.raiseSobjectError(
      emailRecordsWithNonEmailUsageType,
      NOT_ALLOWED_USAGE_TYPE_ERROR
    );
  }

  /**
   * @description validates if already Email Record exists with same Usage type
   * @param records the list of Phone record
   */
  public static void checkExistingEmailRecords(
    List<ContactPointEmail> records
  ) {
    if (
      EMAIL_REPOSITORY.isCustomValidationsSkipped() ||
      !EMAIL_REPOSITORY.isCurrentLoggedInMLUser()
    ) {
      return;
    }
    Set<Id> accountIds = ListUtil.getIds(
      records,
      ContactPointEmail.Customer_Name__c
    );
    Map<Id, Set<String>> mapAccountIdToEmailTypes = new Map<Id, Set<String>>();
    for (
      ContactPointEmail record : EMAIL_REPOSITORY.getExistingEmailRecords(
        accountIds
      )
    ) {
      if (!mapAccountIdToEmailTypes.containsKey(record.Customer_Name__c)) {
        mapAccountIdToEmailTypes.put(
          record.Customer_Name__c,
          new Set<String>{ record.UsageType }
        );
        continue;
      }
      mapAccountIdToEmailTypes.get(record.Customer_Name__c)
        .add(record.UsageType);
    }
    for (ContactPointEmail record : records) {
      if (
        !mapAccountIdToEmailTypes.containsKey(record.Customer_Name__c) ||
        !mapAccountIdToEmailTypes.get(record.Customer_Name__c)
          ?.contains(record.UsageType)
      ) {
        continue;
      }
      record.addError(EMAIL_EXISTS_ERROR);
    }
  }

  /**
   * @description to delete expired ContactPointEmail records
   * @name deleteExpiredRecords
   * @param records the list of email records from trigger
   * @param oldMap oldMap records
   */
  public static void deleteExpiredRecords(
    List<ContactPointEmail> records,
    Map<Id, ContactPointEmail> oldMap
  ) {
    if (!Schema.sObjectType.ContactPointEmail.isDeletable()) {
      return;
    }
    List<ContactPointEmail> emailsToDelete = new List<ContactPointEmail>();
    List<ContactPointEmail> updatedATDEmails = ListUtil.filter(records, oldMap)
      .changed(ContactPointEmail.ActiveToDate)
      .toList();
    for (ContactPointEmail email : updatedATDEmails) {
      if (email.ActiveToDate == null || email.ActiveToDate > System.today()) {
        continue;
      }
      emailsToDelete.add(new ContactPointEmail(Id = email.Id));
    }
    DML_REPOSITORY.doDelete(emailsToDelete, new DmlConfig().allowPartial());
  }
}

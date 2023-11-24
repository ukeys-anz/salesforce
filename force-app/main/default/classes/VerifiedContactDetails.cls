/**
 * @author Farid Masjedi
 * @since Nov 2023
 * @description Find all verified customer phone numbers and Email addresses.
 */
public with sharing class VerifiedContactDetails {
  /**
   * @param recordId customer recordId
   * @param phoneUsageType filter all phone numbers with specific value of ContactPointPhone.UsageType ( eg: Security Mobile )
   * @param emailUsageType filter all email addresses with specific value of ContactPointEmail.UsageType ( eg: Security Email )
   * @return List<Sobject> combination of all the filtered phone numbers and email addresses
   * @description To be used on lwc for creating filtered relatedList | OTP information
   */
  @AuraEnabled(cacheable=false)
  public static List<Sobject> customerContactDetails(
    Id recordId,
    String phoneUsageType,
    String emailUsageType
  ) {
    List<Sobject> contactDetails = new List<Sobject>();
    if (
      !Schema.sObjectType.ContactPointPhone.isQueryable() ||
      !Schema.sObjectType.ContactPointEmail.isQueryable()
    ) {
      return contactDetails;
    }
    List<ContactPointPhone> phoneNumbers = [
      SELECT
        Id,
        TelephoneNumber,
        UsageType,
        Verification_Date__c,
        Verification_Status__c
      FROM ContactPointPhone
      WHERE ParentId = :recordId AND UsageType = :phoneUsageType
    ];
    List<ContactPointEmail> emailAddresses = [
      SELECT
        Id,
        EmailAddress,
        UsageType,
        Verification_Date__c,
        Verification_Status__c
      FROM ContactPointEmail
      WHERE ParentId = :recordId AND UsageType = :emailUsageType
    ];

    contactDetails.addAll((List<Sobject>) phoneNumbers);
    contactDetails.addAll((List<Sobject>) emailAddresses);

    return contactDetails;
  }
}

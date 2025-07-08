/**
 * @author Batya Aisman Sufrin
 * @since 05/2025
 * @description KYCQACustomerLinkingUtilRepository is the repository class for KYCQACustomerLinkingUtil.
 */
public with sharing class KYCQACustomerLinkingUtilRepository {
  /**
   * @description Find Accounts by OCV Ids and Date of Births
   * @param ocvIds Set of Account OCV Ids
   * @param dobList List of Account Date of Births
   * @return List<Account> list of Accounts
   */
  public List<Account> queryAccountsByOCVIdAndDOB(
    Set<String> ocvIds,
    List<Date> dobList
  ) {
    if (ocvIds.isEmpty() || dobList.isEmpty()) {
      return new List<Account>();
    }

    return [
      SELECT Id, OCV_ID__c, PersonBirthdate, External_Id__c
      FROM Account
      WHERE
        ANZx_Customer__c = TRUE
        AND OCV_ID__c IN :ocvIds
        AND PersonBirthdate IN :dobList
        AND External_Id__c != NULL
        AND (NOT External_Id__c LIKE '%_offboarded')
      WITH USER_MODE
    ];
  }

  /**
   * @description Find Accounts by Person Mobile Numbers and Date of Births
   * @param mobileNumbers Set of Account Person Mobile Numbers
   * @param dobList List of Account Date of Births
   * @return List<Account> list of Accounts
   */
  public List<Account> queryAccountsByMobileNumberAndDOB(
    Set<String> mobileNumbers,
    List<Date> dobList
  ) {
    if (mobileNumbers.isEmpty() || dobList.isEmpty()) {
      return new List<Account>();
    }

    return [
      SELECT Id, PersonMobilePhone, PersonBirthdate, External_Id__c
      FROM Account
      WHERE
        ANZx_Customer__c = TRUE
        AND PersonMobilePhone IN :mobileNumbers
        AND PersonBirthdate IN :dobList
        AND External_Id__c != NULL
        AND (NOT External_Id__c LIKE '%_offboarded')
      WITH USER_MODE
    ];
  }

  /**
   * @description Find Customer Onboarding Application by Account OCV Id & DOB
   * @param ocvIds Set of Account OCV Ids
   * @param dobs Set of Date of Births
   * @return List<CustomerOnboardingApplication__c> list of Customer Onboarding Applications
   */
  public List<CustomerOnboardingApplication__c> queryCobsByOCVIdAndDOB(
    Set<String> ocvIds,
    Set<Date> dobs
  ) {
    if (ocvIds.isEmpty() || dobs.isEmpty()) {
      return new List<CustomerOnboardingApplication__c>();
    }

    return [
      SELECT
        Id,
        OCVId__c,
        (
          SELECT Id, DateOfBirth__c
          FROM COBPrimaryIDDocuments__r
          WHERE Latest__c = TRUE AND DateOfBirth__c IN :dobs
        ),
        (
          SELECT Id, RecordTypeId
          FROM Cases__r
          WHERE RecordTypeId = :RTCase.kycQa AND AccountId = NULL
          ORDER BY CreatedDate DESC
          LIMIT 1
        )
      FROM CustomerOnboardingApplication__c
      WHERE OCVId__c IN :ocvIds
      WITH SYSTEM_MODE
    ];
  }

  /**
   * @description Find Customer Onboarding Application by Account Person Mobile Number & DOB
   * @param mobileNumbers Set of Account Person Mobile Numbers
   * @param dobs Set of Date of Births
   * @return List<CustomerOnboardingApplication__c> list of Customer Onboarding Applications
   */
  public List<CustomerOnboardingApplication__c> queryCobsByMobileNumberAndDOB(
    Set<String> mobileNumbers,
    Set<Date> dobs
  ) {
    if (mobileNumbers.isEmpty() || dobs.isEmpty()) {
      return new List<CustomerOnboardingApplication__c>();
    }

    return [
      SELECT
        Id,
        SecurityMobile__c,
        (
          SELECT Id, DateOfBirth__c
          FROM COBPrimaryIDDocuments__r
          WHERE Latest__c = TRUE AND DateOfBirth__c IN :dobs
        ),
        (
          SELECT Id, RecordTypeId
          FROM Cases__r
          WHERE RecordTypeId = :RTCase.kycQa AND AccountId = NULL
          ORDER BY CreatedDate DESC
          LIMIT 1
        )
      FROM CustomerOnboardingApplication__c
      WHERE SecurityMobile__c IN :mobileNumbers
      WITH SYSTEM_MODE
    ];
  }

  /**
   * @description Find Customer Onboarding Application by Id
   * @param cobIds Set of Customer Onboarding Application Ids
   * @return List<CustomerOnboardingApplication__c> list of Customer Onboarding Applications
   */
  public List<CustomerOnboardingApplication__c> queryCobByIds(Set<Id> cobIds) {
    if (cobIds.isEmpty()) {
      return new List<CustomerOnboardingApplication__c>();
    }

    return [
      SELECT
        Id,
        OCVId__c,
        SecurityMobile__c,
        (
          SELECT Id, DateOfBirth__c
          FROM COBPrimaryIDDocuments__r
          WHERE Latest__c = TRUE AND DateOfBirth__c != NULL
        )
      FROM CustomerOnboardingApplication__c
      WHERE Id IN :cobIds
      WITH USER_MODE
    ];
  }
}

/**
 * @author Batya Aisman Sufrin
 * @since 03/2025
 * @description Utility class for Customer Onboarding Application
 */
public with sharing class KYCQACustomerLinkingUtil {
  private static final Map<SObjectField, String> FIELD_PREFIX = new Map<SObjectField, String>{
    Account.OCV_Id__c => '',
    Account.PersonMobilePhone => '+',
    CustomerOnboardingApplication__c.OCVId__c => '',
    CustomerOnboardingApplication__c.SecurityMobile__c => '+'
  };

  private static final Map<SObjectField, SObjectField> FIELD_CORELATION_ACC_TO_COB = new Map<SObjectField, SObjectField>{
    Account.OCV_Id__c => CustomerOnboardingApplication__c.OCVId__c,
    Account.PersonMobilePhone => CustomerOnboardingApplication__c.SecurityMobile__c
  };

  private static final Map<SObjectField, SObjectField> FIELD_CORELATION_COB_TO_ACC = new Map<SObjectField, SObjectField>{
    CustomerOnboardingApplication__c.OCVId__c => Account.OCV_Id__c,
    CustomerOnboardingApplication__c.SecurityMobile__c => Account.PersonMobilePhone
  };

  private static final KYCQACustomerLinkingUtilRepository REPOSITORY = (KYCQACustomerLinkingUtilRepository) Lib_InstanceProvider.forType(
    KYCQACustomerLinkingUtilRepository.class
  );

  /**
   * @description Get Accounts by Customer Onboarding Application OCV Ids and DOB
   * Collects the OCV Id and DOB from the CustomerOnboardingApplication__c object and OCV Id from Account,
   * then constructs a map of CustomerOnboardingApplication__c Id and Accounts by matching the OCV Id and DOB.
   * @param cases List of Cases
   * @return Map<Id, Account> Map of Customer Onboarding Application Id and Account
   */
  public static Map<Id, Account> getAccountsByOCVIdAndDOB(List<Case> cases) {
    Set<Id> cobIds = ListUtil.getIds(
      cases,
      Case.CustomerOnboardingApplication__c
    );
    List<CustomerOnboardingApplication__c> cobs = REPOSITORY.queryCobByIds(
      cobIds
    );
    Map<Id, Date> cobDOBs = retrieveDOBs(cobs);

    Set<String> ocvIds = ListUtil.getStrings(cases, Case.OCV_Id__c);
    List<Account> accs = REPOSITORY.queryAccountsByOCVIdAndDOB(
      ocvIds,
      cobDOBs.values()
    );

    return getCobIdWithAccount(cobs, cobDOBs, accs, Account.OCV_Id__c);
  }

  /**
   * @description Get Accounts by Customer Onboarding Application Mobile Numbers and DOB
   * Collects the Mobile Phone and DOB from the CustomerOnboardingApplication__c object and Mobile Phone from Account,
   * then constructs a map of CustomerOnboardingApplication__c Id and Accounts by matching the Mobile Phone and DOB.
   * @param cases List of Cases
   * @return Map<Id, Account> Map of Customer Onboarding Application Id and Account
   */
  public static Map<Id, Account> getAccountsByMobileAndDOB(List<Case> cases) {
    Set<Id> cobIds = ListUtil.getIds(
      cases,
      Case.CustomerOnboardingApplication__c
    );
    List<CustomerOnboardingApplication__c> cobs = REPOSITORY.queryCobByIds(
      cobIds
    );
    Map<Id, Date> cobDOBs = retrieveDOBs(cobs);

    Set<String> mobileNumbers = retrieveMobileNumbers(cases);
    List<Account> accs = REPOSITORY.queryAccountsByMobileNumberAndDOB(
      mobileNumbers,
      cobDOBs.values()
    );

    return getCobIdWithAccount(cobs, cobDOBs, accs, Account.PersonMobilePhone);
  }

  /**
   * @description Get Customer Onboarding Application by Account OCV Ids and DOB
   * Collects the OCV Id and DOB from the Account object and OCV Id from CustomerOnboardingApplication__c,
   * then constructs a map of Account Id and CustomerOnboardingApplication__c by matching the OCV Id and DOB.
   * @param accs List of Accounts
   * @return Map<Id, CustomerOnboardingApplication__c> Map of Account Id and Customer Onboarding Application
   */
  public static Map<Id, CustomerOnboardingApplication__c> getCobByAccountOCVIdAndDOB(
    List<Account> accs
  ) {
    Logger.debug(
        'KYCQACustomerLinkingUtil.getCobByAccountOCVIdAndDOB started. Number of accounts: ' +
        accs.size()
      )
      .setPayload(JSON.serializePretty(accs));

    Set<String> ocvIds = ListUtil.getStrings(accs, Account.OCV_Id__c);
    Set<Date> dobs = (Set<Date>) ListUtil.getUniques(
      accs,
      Account.PersonBirthdate
    );

    Logger.debug(
      'Retrieving Customer Onboarding Applications by OCV Ids and DOBs.'
    );
    List<CustomerOnboardingApplication__c> cobs = REPOSITORY.queryCobsByOCVIdAndDOB(
      ocvIds,
      dobs
    );
    Logger.debug(
        'Number of Customer Onboarding Applications retrieved: ' + cobs.size()
      )
      .setPayload(JSON.serializePretty(cobs))
      .save();

    return getAccountIdsWithCOBs(
      accs,
      cobs,
      CustomerOnboardingApplication__c.OCVId__c
    );
  }

  /**
   * @description Get Customer Onboarding Application by Account
   * Collects the DOB and Person Mobile Phone from the Account object and SecurityMobile__c from CustomerOnboardingApplication__c,
   * then constructs a map of Account Id and CustomerOnboardingApplication__c by matching the DOB and Person Mobile Phone.
   * @param accs List of Accounts
   * @return Map<Id, CustomerOnboardingApplication__c> Map of Account Id and Customer Onboarding Application
   */
  public static Map<Id, CustomerOnboardingApplication__c> getCobByAccountMobileAndDOB(
    List<Account> accs
  ) {
    Logger.debug(
        'KYCQACustomerLinkingUtil.getCobByAccountMobileAndDOB started. Number of accounts: ' +
        accs.size()
      )
      .setPayload(JSON.serializePretty(accs));

    Set<String> mobiles = retrieveAccFormattedMobiles(accs);
    Set<Date> dobs = (Set<Date>) ListUtil.getUniques(
      accs,
      Account.PersonBirthdate
    );

    Logger.debug(
      'Retrieving Customer Onboarding Applications by mobiles and DOBs.'
    );
    List<CustomerOnboardingApplication__c> cobs = REPOSITORY.queryCobsByMobileNumberAndDOB(
      mobiles,
      dobs
    );
    Logger.debug(
        'Number of Customer Onboarding Applications retrieved: ' + cobs.size()
      )
      .setPayload(JSON.serializePretty(cobs))
      .save();

    return getAccountIdsWithCOBs(
      accs,
      cobs,
      CustomerOnboardingApplication__c.SecurityMobile__c
    );
  }

  /**
   * @description Get Customer Onboarding Application by Account's OCV Ids or PersonMobilePhone and DOB
   * Constructs a map of Customer Onboarding Application Id and Account by matching the OCV Id or PersonMobilePhone and DOB.
   * @param cobs List of Customer Onboarding Applications
   * @param cobDOBs Map of Customer Onboarding Application Id and Date of Birth
   * @param accs List of Accounts
   * @param accField SObjectField - Account field - OCVId or PersonMobilePhone
   * @return Map<Id, Account> Map of Customer Onboarding Application Id and Account
   */
  @TestVisible
  private static Map<Id, Account> getCobIdWithAccount(
    List<CustomerOnboardingApplication__c> cobs,
    Map<Id, Date> cobDOBs,
    List<Account> accs,
    SObjectField accField
  ) {
    Map<String, Account> accsMap = constructAccountsMapWithCombinedKey(
      accs,
      accField
    );

    SObjectField cobField = FIELD_CORELATION_ACC_TO_COB.get(accField);
    Map<Id, Account> cobIdWithAccount = new Map<Id, Account>();
    for (CustomerOnboardingApplication__c cob : cobs) {
      String cobFieldValue = (String) cob.get(cobField);

      String key = constructKey(
        FIELD_PREFIX.get(accField) + cobFieldValue,
        cobDOBs.get(cob.Id)
      );
      if (accsMap.containsKey(key)) {
        cobIdWithAccount.put(cob.Id, accsMap.get(key));
      }
    }
    return cobIdWithAccount;
  }

  /**
   * @description Get Account Ids with Customer Onboarding Applications
   * Constructs a map of Account Id and Customer Onboarding Application by matching the OCV Id or PersonMobilePhone and DOB.
   * @param accs List of Accounts
   * @param cobs List of Customer Onboarding Applications
   * @param cobField SObjectField - COB field - OCVId or SecurityMobile
   * @return Map<Id, CustomerOnboardingApplication__c> Map of Account Id and Customer Onboarding Application
   */
  @TestVisible
  private static Map<Id, CustomerOnboardingApplication__c> getAccountIdsWithCOBs(
    List<Account> accs,
    List<CustomerOnboardingApplication__c> cobs,
    SObjectField cobField
  ) {
    Map<String, CustomerOnboardingApplication__c> cobsMap = constructCOBsMapWithCombinedKey(
      cobs,
      cobField
    );

    SObjectField accField = FIELD_CORELATION_COB_TO_ACC.get(cobField);
    Map<Id, CustomerOnboardingApplication__c> accountIdWithCob = new Map<Id, CustomerOnboardingApplication__c>();
    for (Account acc : accs) {
      String accFieldValue = (String) acc.get(accField);

      String key = constructKey(accFieldValue, acc.PersonBirthdate);
      if (cobsMap.containsKey(key)) {
        accountIdWithCob.put(acc.Id, cobsMap.get(key));
      }
    }

    return accountIdWithCob;
  }

  /**
   * @description Constructs a Key for the Map
   * @param prefix Prefix for the key
   * @param dob Date of Birth
   * @return String Key of structure: `<prefix>_<dob>` where prefix is the OCV Id or Mobile Phone and dob is the Date of Birth
   */
  @TestVisible
  private static String constructKey(String prefix, Date dob) {
    return prefix + (dob != null ? '_' + dob.format() : '');
  }

  /**
   * @description Constructs a Map of Customer Onboarding Applications (while filtering COBs with PID) by combined Key
   * @param cobs List of Customer Onboarding Applications
   * @param cobField COB Field - OCVId or SecurityMobile
   * @return Map<String, CustomerOnboardingApplication__c> Map of Customer Onboarding Applications by combined key
   */
  @TestVisible
  private static Map<String, CustomerOnboardingApplication__c> constructCOBsMapWithCombinedKey(
    List<CustomerOnboardingApplication__c> cobs,
    SObjectField cobField
  ) {
    Map<String, CustomerOnboardingApplication__c> cobsMap = new Map<String, CustomerOnboardingApplication__c>();
    for (CustomerOnboardingApplication__c cob : cobs) {
      if (cob.COBPrimaryIDDocuments__r.isEmpty() || cob.Cases__r.isEmpty()) {
        continue;
      }
      String cobFieldValue = (String) cob.get(cobField);
      Date dob = cob.COBPrimaryIDDocuments__r[0].DateOfBirth__c;
      String key = constructKey(
        FIELD_PREFIX.get(cobField) + cobFieldValue,
        dob
      );
      cobsMap.put(key, cob);
    }
    return cobsMap;
  }

  /**
   * @description Constructs a Map of Accounts
   * @param accs List of Accounts
   * @param accField Account Field - OCVId or PersonMobilePhone
   * @return Map<String, Account> Map of Accounts
   */
  @TestVisible
  private static Map<String, Account> constructAccountsMapWithCombinedKey(
    List<Account> accs,
    SObjectField accField
  ) {
    Map<String, Account> accsMap = new Map<String, Account>();
    for (Account acc : accs) {
      String accFieldValue = (String) acc.get(accField);
      String key = constructKey(accFieldValue, acc.PersonBirthdate);
      accsMap.put(key, acc);
    }
    return accsMap;
  }

  /**
   * @description Get Date of Births from Customer Onboarding Applications
   * Collects the Date of Birth from the CustomerOnboardingApplication__c object.
   * @param cobs List of Customer Onboarding Applications
   * @return Map<Id, Date> Map of Customer Onboarding Application Id and Date of Birth
   */
  @TestVisible
  private static Map<Id, Date> retrieveDOBs(
    List<CustomerOnboardingApplication__c> cobs
  ) {
    Map<Id, Date> cobDOBs = new Map<Id, Date>();
    for (CustomerOnboardingApplication__c cob : cobs) {
      if (cob.COBPrimaryIDDocuments__r.isEmpty()) {
        continue;
      }
      cobDOBs.put(cob.Id, cob.COBPrimaryIDDocuments__r[0].DateOfBirth__c);
    }
    return cobDOBs;
  }

  /**
   * @description Prepare Mobile Numbers
   * @param cases List of Cases
   * @return  List<String> List of cleaned mobile numbers
   */
  @TestVisible
  private static Set<String> retrieveMobileNumbers(List<Case> cases) {
    Set<String> mobileNumbers = new Set<String>();
    for (Case c : cases) {
      mobileNumbers.add(
        '+' + c.CustomerOnboardingApplication__r.SecurityMobile__c
      );
    }

    return mobileNumbers;
  }

  /**
   * @description Get Formated Mobile Phones
   * PhoneUtils.cleanupMobile is used to standartize mobile phone number, to avoid any difference in number format
   * as there might be a difference between number format on customer and cob. exp : +61440000000 :: 61440000000
   * @param accs List of accounts
   * @return Set<String> Set of Formatted Mobile Phones
   */
  @TestVisible
  private static Set<String> retrieveAccFormattedMobiles(List<Account> accs) {
    Set<String> mobilePhones = new Set<String>();
    for (Account acc : accs) {
      String mobilePhone = PhoneUtils.cleanupMobile(acc.PersonMobilePhone);
      if (String.isBlank(acc.PersonMobilePhone)) {
        continue;
      }
      mobilePhones.add(mobilePhone);
    }
    return mobilePhones;
  }
}

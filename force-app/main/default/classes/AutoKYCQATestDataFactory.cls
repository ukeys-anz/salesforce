/**
 * @author shawg2
 * @since January 2024
 * @description Create KYCQA data for tests
 */

public with sharing class AutoKYCQATestDataFactory {
  private static final Faker FAKER = new Faker('AU');

  private static final String MOBILE1 = '61412121212';
  private static final String MOBILE2 = '61413131313';
  private static final String MOBILE3 = '61415151515';

  private static final List<String> COB_MATCHING_MOBILE_NUMBERS = new List<String>{
    MOBILE1,
    MOBILE2,
    MOBILE3
  };

  private static final List<String> CUSTOMER_MATCHING_MOBILE_NUMBERS = new List<String>{
    '+' + MOBILE1,
    '+' + MOBILE2,
    '+' + MOBILE3
  };

  private static final List<String> COB_NOT_MATCHING_MOBILE_NUMBERS = new List<String>{
    '61499999999',
    '61488888888'
  };

  private static final String PERSONA_ID1 = '0123456789';
  private static final String PERSONA_ID2 = '9876543210';
  private static final String PERSONA_ID3 = '9876543211';
  private static final String PERSONA_ID4 = '9876543212';

  private static final Set<String> PERSONA_IDS = new Set<String>{
    PERSONA_ID1,
    PERSONA_ID2,
    PERSONA_ID3,
    PERSONA_ID4
  };

  private static final String LICENCE_TYPE = 'Licence';
  private static final String PASSPORT_TYPE = 'Passport';

  private static final List<String> ID_DOC_TYPE = new List<String>{
    LICENCE_TYPE,
    PASSPORT_TYPE
  };

  private static final Map<String, String> PERSONA_ID_VERIFICATION_TYPES = new Map<String, String>{
    PERSONA_ID1 => 'MANUAL',
    PERSONA_ID2 => 'UNSPECIFIED',
    PERSONA_ID3 => 'ASSISTED',
    PERSONA_ID4 => 'STP'
  };

  private static final String CURRENT = 'Current';

  /**
   * @description @TestSetup method
   */
  public static void setup() {
    List<CustomerOnboardingApplication__c> cobAppsList = new List<CustomerOnboardingApplication__c>();
    List<COBPrimaryIDDocument__c> cobPidsList = new List<COBPrimaryIDDocument__c>();
    List<COBAddress__c> cobAddressesList = new List<COBAddress__c>();

    for (String personaId : PERSONA_IDS) {
      cobAppsList.add(createCOBAppDetails(personaId));
    }

    insert cobAppsList;

    for (CustomerOnboardingApplication__c cobApp : cobAppsList) {
      for (String idDocType : ID_DOC_TYPE) {
        cobPidsList.add(createCOBPidDetails(cobApp.Id, idDocType));
      }
      cobAddressesList.add(
        new COBAddress__c(
          CustomerOnboardingApplication__c = cobApp.Id,
          AddressQASId__c = FAKER.randomString(15),
          AddressType__c = CURRENT
        )
      );
    }

    insert cobPidsList;
    insert cobAddressesList;

    makeData();
  }

  /**
   * @description create KYCQA data for setup()
   */
  public static void makeData() {
    // Insert Account & User as current user, to get around MIXED_DML_OPERATION error
    User thisUser = new User(Id = UserInfo.getUserId());
    System.runAs(thisUser) {
      List<CustomerOnboardingApplication__c> cobAppsList = new List<CustomerOnboardingApplication__c>();

      List<Account> personAccsWithMobile = new List<Account>();
      for (String mobileNumber : COB_MATCHING_MOBILE_NUMBERS) {
        cobAppsList.add(createCOBApp(mobileNumber));
      }

      for (String mobileNumber : CUSTOMER_MATCHING_MOBILE_NUMBERS) {
        personAccsWithMobile.add(createPersonAccount(mobileNumber));
      }

      //Add COB apps with not matching mobile Numbers
      for (String mobileNumber : COB_NOT_MATCHING_MOBILE_NUMBERS) {
        cobAppsList.add(createCOBApp(mobileNumber));
      }

      insert cobAppsList;
      insert personAccsWithMobile;

      List<Entitlement> entitlements = CommonUtil.addPersonAccountEntitlements(
        personAccsWithMobile,
        GetHelpConstants.ANZ_PLUS_BASIC_SUBSCRIPTION_SLA_PROCESS_NAME,
        GetHelpConstants.BASIC_SUBSCRIPTION_ENTITLEMENT_NAME
      );
      insert entitlements;

      TestDataFactory.createANZxUser('FraudX_Agent');
    }
  }
  private static CustomerOnboardingApplication__c createCOBApp(
    String mobileNumber
  ) {
    CustomerOnboardingApplication__c cobApp = new CustomerOnboardingApplication__c(
      SecurityMobile__c = mobileNumber
    );

    return cobApp;
  }

  private static CustomerOnboardingApplication__c createCOBAppDetails(
    String personaId
  ) {
    return new CustomerOnboardingApplication__c(
      PersonaId__c = personaId,
      VerificationType__c = PERSONA_ID_VERIFICATION_TYPES.get(personaId)
    );
  }

  private static COBPrimaryIDDocument__c createCOBPidDetails(
    Id cobAppId,
    String idDocType
  ) {
    return new COBPrimaryIDDocument__c(
      CustomerOnboardingApplication__c = cobAppId,
      IdDocumentType__c = idDocType
    );
  }

  private static Account createPersonAccount(String mobileNumber) {
    Account acc = new Account(
      FirstName = FAKER.person.firstName(),
      LastName = FAKER.person.lastName(),
      OCV_ID__c = FAKER.randomString(10),
      PersonMobilePhone = mobileNumber,
      ANZx_Customer__c = true,
      RecordTypeId = GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID
    );

    return acc;
  }
}

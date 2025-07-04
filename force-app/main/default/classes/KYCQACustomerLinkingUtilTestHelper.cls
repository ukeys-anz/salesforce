/**
 * @author Batya Aisman Sufrin
 * @since 06/2025
 * @description Helper for {@link KYCQACustomerLinkingUtilTestHelper} class
 */
public with sharing class KYCQACustomerLinkingUtilTestHelper {
  public static final Faker FAKER = new Faker('AU');
  public static final String MOBILE_1 = '61412345678';
  public static final String MOBILE_2 = '61487654321';
  public static final String MOBILE_3 = '61445612912';

  public static final String COB_SECURITY_MOBILE_1 = MOBILE_1;
  public static final String COB_SECURITY_MOBILE_2 = MOBILE_2;
  public static final String COB_SECURITY_MOBILE_3 = MOBILE_3;
  public static final String COB_SECURITY_MOBILE_NO_PID = '61478232912';
  public static final String COB_DUMMY_MOBILE = '61400000000';

  public static final String ACCOUNT_PERSON_MOBILE_1 =
    '+' + COB_SECURITY_MOBILE_1;
  public static final String ACCOUNT_PERSON_MOBILE_2 =
    '+' + COB_SECURITY_MOBILE_2;
  public static final String ACCOUNT_PERSON_MOBILE_3 =
    '+' + COB_SECURITY_MOBILE_3;
  public static final String ACCOUNT_DUMMY_MOBILE = '+' + COB_DUMMY_MOBILE;

  public static final String OCV_ID_1 = '1001881026';
  public static final String OCV_ID_2 = '1001881987';
  public static final String OCV_ID_3 = '1001881257';
  public static final String OCV_ID_NO_PID = '1001881258';

  /**
   * @description Constructs a CustomerOnboardingApplication__c object with the given OCV ID and mobile number.
   * @param ocvId The OCV ID to set on the CustomerOnboardingApplication__c object.
   * @param mobile The mobile number to set on the CustomerOnboardingApplication__c object.
   * @return A new instance of CustomerOnboardingApplication__c with the specified OCV ID and mobile number.
   */
  public static CustomerOnboardingApplication__c constructCOB(
    String ocvId,
    String mobile
  ) {
    return new CustomerOnboardingApplication__c(
      Id = Lib_FakeIdGenerator.getMockId(
        CustomerOnboardingApplication__c.SObjectType
      ),
      OCVId__c = ocvId,
      SecurityMobile__c = mobile
    );
  }

  /**
   * @description Constructs a CustomerOnboardingApplication__c object with the given OCV ID, mobile number, and date of birth.
   * @param ocvId The OCV ID to set on the CustomerOnboardingApplication__c object.
   * @param mobile The mobile number to set on the CustomerOnboardingApplication__c object.
   * @param dob The date of birth to set on the COBPrimaryIDDocument__c object within the CustomerOnboardingApplication__c.
   * @return A new instance of CustomerOnboardingApplication__c with the specified OCV ID, mobile number, and date of birth.
   */
  public static CustomerOnboardingApplication__c constructCOBWithPid(
    String ocvId,
    String mobile,
    Date dob
  ) {
    return (CustomerOnboardingApplication__c) TestUtil.setFields(
      constructCOB(ocvId, mobile),
      new Map<String, Object>{
        'COBPrimaryIDDocuments__r' => new List<COBPrimaryIDDocument__c>{
          new COBPrimaryIDDocument__c(DateOfBirth__c = dob)
        }
      }
    );
  }

  /**
   * @description Constructs a CustomerOnboardingApplication__c object with the given OCV ID, mobile number, and date of birth,
   * and associates it with a Case.
   * @param ocvId The OCV ID to set on the CustomerOnboardingApplication__c object.
   * @param mobile The mobile number to set on the CustomerOnboardingApplication__c object.
   * @param dob The date of birth to set on the COBPrimaryIDDocument__c object within the CustomerOnboardingApplication__c.
   * @return A new instance of CustomerOnboardingApplication__c with the specified OCV ID, mobile number, date of birth,
   * and associated Case.
   */
  public static CustomerOnboardingApplication__c constructCOBWithPidAndCase(
    String ocvId,
    String mobile,
    Date dob
  ) {
    return (CustomerOnboardingApplication__c) TestUtil.setFields(
      constructCOB(ocvId, mobile),
      new Map<String, Object>{
        'COBPrimaryIDDocuments__r' => new List<COBPrimaryIDDocument__c>{
          new COBPrimaryIDDocument__c(DateOfBirth__c = dob)
        },
        'Cases__r' => new List<Case>{
          new Case(
            Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
            RecordTypeId = RTCase.kycQa,
            OCV_ID__c = ocvId,
            AccountId = null
          )
        }
      }
    );
  }

  /**
   * @description Constructs a CustomerOnboardingApplication__c object with the given OCV ID and mobile number,
   * and associates it with a Case without a primary ID document.
   * @param ocvId The OCV ID to set on the CustomerOnboardingApplication__c object.
   * @param mobile The mobile number to set on the CustomerOnboardingApplication__c object.
   * @return A new instance of CustomerOnboardingApplication__c with the specified OCV ID and mobile number,
   * and associated with a Case.
   * @note This method is used for cases where the CustomerOnboardingApplication__c does not have a primary ID document.
   */
  public static CustomerOnboardingApplication__c constructCOBWithCaseNoPid(
    String ocvId,
    String mobile
  ) {
    return (CustomerOnboardingApplication__c) TestUtil.setFields(
      constructCOB(ocvId, mobile),
      new Map<String, Object>{
        'Cases__r' => new List<Case>{
          new Case(
            Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
            RecordTypeId = RTCase.kycQa,
            OCV_ID__c = ocvId
          )
        }
      }
    );
  }

  /**
   * @description Constructs a CustomerOnboardingApplication__c object with the given OCV ID and mobile number,
   * and associates it with a Case without a primary ID document.
   * @param ocvId The OCV ID to set on the CustomerOnboardingApplication__c object.
   * @param mobile The mobile number to set on the CustomerOnboardingApplication__c object.
   * @param dob The date of birth to set on the COBPrimaryIDDocument__c object within the CustomerOnboardingApplication__c.
   * @return A new instance of CustomerOnboardingApplication__c with the specified OCV ID and mobile number,
   * and associated with a Case.
   * @note This method is used for cases where the CustomerOnboardingApplication__c does not have a primary ID document.
   */
  public static CustomerOnboardingApplication__c constructCOBWithPidNoCase(
    String ocvId,
    String mobile,
    Date dob
  ) {
    return (CustomerOnboardingApplication__c) TestUtil.setFields(
      constructCOB(ocvId, mobile),
      new Map<String, Object>{
        'COBPrimaryIDDocuments__r' => new List<COBPrimaryIDDocument__c>{
          new COBPrimaryIDDocument__c(DateOfBirth__c = dob)
        }
      }
    );
  }

  /**
   * @description Constructs a Case object with the given OCV ID and mobile number,
   * and associates it with a CustomerOnboardingApplication__c object.
   * @param ocvId The OCV ID to set on the Case object.
   * @param mobile The mobile number to set on the CustomerOnboardingApplication__c object associated with the Case.
   * @return A new instance of Case with the specified OCV ID and associated CustomerOnboardingApplication__c.
   * @note This method is used for cases where the CustomerOnboardingApplication__c does not have a primary ID document.
   */
  public static Case constructCaseWithCOBNoPid(String ocvId, String mobile) {
    CustomerOnboardingApplication__c cob = constructCOB(ocvId, mobile);
    return new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      RecordTypeId = RTCase.kycQa,
      OCV_Id__c = ocvId,
      CustomerOnboardingApplication__c = cob.Id,
      CustomerOnboardingApplication__r = cob
    );
  }

  /**
   * @description Constructs a Case object with the given OCV ID, mobile number, and date of birth,
   *              and associates it with a CustomerOnboardingApplication__c object that has a primary ID document.
   * @param ocvId The OCV ID to set on the Case object.
   * @param mobile The mobile number to set on the CustomerOnboardingApplication__c object associated with the Case.
   * @param dob The date of birth to set on the COBPrimaryIDDocument__c object within the CustomerOnboardingApplication__c.
   * @return A new instance of Case with the specified OCV ID, associated CustomerOnboardingApplication__c,
   *         and a primary ID document containing the date of birth.
   */
  public static Case constructCaseWithCOBAndPid(
    String ocvId,
    String mobile,
    Date dob
  ) {
    CustomerOnboardingApplication__c cobWithPid = constructCOBWithPid(
      ocvId,
      mobile,
      dob
    );
    return new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      RecordTypeId = RTCase.kycQa,
      OCV_Id__c = ocvId,
      CustomerOnboardingApplication__c = cobWithPid.Id,
      CustomerOnboardingApplication__r = cobWithPid
    );
  }

  /**
   * @description Constructs an Account object with the given OCV ID, mobile number, and date of birth.
   * @param ocvId The OCV ID to set on the Account object.
   * @param mobile The mobile number to set on the Account object.
   * @param dob The date of birth to set on the Account object.
   * @param isANZx Whether the account is an ANZx customer.
   * @return A new instance of Account with the specified OCV ID, mobile number, and date of birth.
   */
  public static Account constructAccount(
    String ocvId,
    String mobile,
    Date dob,
    Boolean isANZx
  ) {
    return new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      OCV_Id__c = ocvId,
      PersonMobilePhone = mobile,
      PersonBirthdate = dob,
      ANZx_Customer__c = isANZx
    );
  }
}

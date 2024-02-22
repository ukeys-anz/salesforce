/**
 * @author shawg2
 * @since January 2024
 * @description Test COBOrphanedKYCQABatch class
 */

@IsTest
private class COBOrphanedKYCQABatchTest {
  private static final String MOBILE1 = '61412121212';
  private static final String ACCOUNT_ID = '001000000000000AAA';

  @TestSetup
  static void setup() {
    AutoKYCQATestDataFactory.setup();
  }

  @IsTest
  static void buildUpdatesMobile() {
    Case oCase = new Case(
      CustomerOnboardingApplication__r = new CustomerOnboardingApplication__c(
        SecurityMobile__c = MOBILE1
      )
    );
    Map<String, String> mpOCVId2AccountId = new Map<String, String>();
    Map<String, String> mpMobilePhone2AccountId = new Map<String, String>{
      MOBILE1 => ACCOUNT_ID
    };
    List<Case> lstUpdates = COBOrphanedKYCQABatch.buildUpdatesList(
      new List<Case>{ oCase },
      mpOCVId2AccountId,
      mpMobilePhone2AccountId
    );

    Assert.isTrue(
      lstUpdates.size() == 1,
      'Should return exactly 1 Case for update.'
    );
    Assert.areEqual(
      ACCOUNT_ID,
      lstUpdates[0].AccountId,
      'Account Id was not updated'
    );
  }

  @IsTest
  static void buildUpdatesMobilePlus() {
    Case oCase = new Case(
      CustomerOnboardingApplication__r = new CustomerOnboardingApplication__c(
        SecurityMobile__c = MOBILE1
      )
    );
    Map<String, String> mpOCVId2AccountId = new Map<String, String>();
    Map<String, String> mpMobilePhone2AccountId = new Map<String, String>{
      '+' + MOBILE1 => ACCOUNT_ID
    };
    List<Case> lstUpdates = COBOrphanedKYCQABatch.buildUpdatesList(
      new List<Case>{ oCase },
      mpOCVId2AccountId,
      mpMobilePhone2AccountId
    );

    Assert.isTrue(
      lstUpdates.size() == 1,
      'Should return exactly 1 Case for update.'
    );
    Assert.areEqual(
      ACCOUNT_ID,
      lstUpdates[0].AccountId,
      'Account Id was not updated'
    );
  }

  @IsTest
  static void schedulerExecuteOCV() {
    List<CustomerOnboardingApplication__c> lstCOBApps = [
      SELECT Id, OCVId__c, SecurityMobile__c
      FROM CustomerOnboardingApplication__c
      WHERE SecurityMobile__c != NULL
    ];
    Assert.isTrue(lstCOBApps.size() > 0);
    String strMobile = '+' + lstCOBApps[0].SecurityMobile__c;
    // This is the PersonAccount that will be connected to the Case by matching mobile number
    List<Account> lstPersonAccounts = [
      SELECT Id, PersonMobilePhone, OCV_ID__c
      FROM Account
      WHERE PersonMobilePhone = :strMobile
    ];
    Assert.isTrue(lstPersonAccounts.size() > 0);
    // Prevent Case from matching on MobileNumber
    lstPersonAccounts[0].PersonMobilePhone += 9;
    update lstPersonAccounts;

    Case oCase = createKYCQACase(lstCOBApps[0].Id, UserInfo.getUserId());
    insert oCase;

    // setup linkage by OCVId
    lstCOBApps[0].OCVId__c = lstPersonAccounts[0].OCV_ID__c;
    update lstCOBApps;

    oCase = [
      SELECT Id, AccountId, CustomerOnboardingApplication__c, OCV_Id__c
      FROM Case
      WHERE Id = :oCase.Id
    ];
    Assert.isNull(
      oCase.AccountId,
      'AccountId should be null before batch process.'
    );
    Test.startTest();
    (new COBOrphanedKYCQAScheduler()).execute(null);
    Test.stopTest();
    oCase = [
      SELECT Id, AccountId, CustomerOnboardingApplication__c, OCV_Id__c
      FROM Case
      WHERE Id = :oCase.Id
    ];
    Assert.isNotNull(
      oCase.AccountId,
      'AccountId should not be null after batch process.'
    );
  }

  private static Case createKYCQACase(Id cobAppId, Id caseOwnerId) {
    Case c = new Case(
      Status = GetHelpConstants.OPEN_STATUS,
      RecordTypeId = GetHelpConstants.KYCQA_RT_ID,
      CustomerOnboardingApplication__c = cobAppId,
      OwnerId = caseOwnerId
    );

    return c;
  }
}

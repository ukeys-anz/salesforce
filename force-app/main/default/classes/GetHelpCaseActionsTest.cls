/**
 * @author shawg2
 * @since Jan 2024
 * @description Test class for GetHelpCaseActions
 */
@IsTest
private class GetHelpCaseActionsTest {
  @IsTest
  static void checkCustomerUpdatePendingStatus() {
    Account oAccount = TestDataFactory.createAccount(true);

    Datetime dtYesterday = Datetime.now().addDays(-1);

    List<Case> lstCases = new List<Case>{
      new Case(
        Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
        AccountId = oAccount.Id,
        RecordTypeId = GetHelpConstants.idrtProfileUpdate,
        Type = GetHelpConstants.RESIDENTIAL_ADDRESS_QA,
        Status = GetHelpConstants.CUSTOMER_UPDATE_PENDING
      ),
      new Case(
        Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
        AccountId = oAccount.Id,
        RecordTypeId = GetHelpConstants.idrtProfileUpdate,
        Type = GetHelpConstants.RESIDENTIAL_ADDRESS_QA,
        Status = GetHelpConstants.CUSTOMER_UPDATE_PENDING,
        Customer_First_Contacted__c = dtYesterday,
        Assessment_Id__c = 'Just for testing'
      ),
      new Case(
        Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
        AccountId = oAccount.Id,
        RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID
      )
    };
    Map<Id, Case> mpOldCases = new Map<Id, Case>();
    for (Case oCase : lstCases) {
      mpOldCases.put(
        oCase.Id,
        new Case(Id = oCase.Id, Status = GetHelpConstants.OPEN_STATUS)
      );
    }

    Test.startTest();

    GetHelpCaseActions.checkCustomerUpdatePendingStatus(lstCases, mpOldCases);

    Test.stopTest();

    for (Case oCase : lstCases) {
      if (oCase.RecordTypeId == GetHelpConstants.idrtProfileUpdate) {
        Assert.areNotEqual(
          null,
          oCase.Customer_First_Contacted__c,
          'Customer First Contacted should be initialised.'
        );
        if (oCase.Assessment_Id__c == 'Just for testing') {
          Assert.areEqual(
            dtYesterday,
            oCase.Customer_First_Contacted__c,
            'Customer First Contacted should not be changed.'
          );
        }
      } else {
        Assert.areEqual(
          null,
          oCase.Customer_First_Contacted__c,
          'Other record types should not have a Customer First Contacted value.'
        );
      }
    }
  }

  @IsTest
  static void onlyAllowOneOpenProfileUpdateCase() {
    Account oAccount = TestDataFactory.createAccount(true);

    List<Case> lstCases = new List<Case>{
      new Case(
        AccountId = oAccount.Id,
        RecordTypeId = GetHelpConstants.idrtProfileUpdate,
        Type = GetHelpConstants.RESIDENTIAL_ADDRESS_QA,
        Status = GetHelpConstants.OPEN_STATUS
      ),
      new Case(
        AccountId = oAccount.Id,
        RecordTypeId = GetHelpConstants.idrtProfileUpdate,
        Type = GetHelpConstants.MANUAL_ADDRESS_UPDATE_TYPE,
        Status = GetHelpConstants.WITHDRAWN_STATUS
      )
    };
    insert lstCases;

    Test.startTest();
    // Test using the same inserted Cases as if they were new again
    for (Case oCase : lstCases) {
      oCase.Id = null;
    }
    GetHelpCaseActions.onlyAllowOneOpenProfileUpdateCase(lstCases);

    Test.stopTest();

    lstCases = [
      SELECT Id, AccountId, Status, Sub_Status__c
      FROM Case
      WHERE Status = 'Closed'
    ];
    Assert.areEqual(1, lstCases.size(), 'Should have exactly 1 Closed Case.');
    Assert.areEqual(
      'No Longer Required',
      lstCases[0].Sub_Status__c,
      'Closed Case should be Sub Status: No Longer Required'
    );
  }

  @IsTest
  static void setOwnerToIDOpsQueue() {
    Account oAccount = TestDataFactory.createAccount(true);

    List<Case> lstCases = new List<Case>{
      new Case(
        AccountId = oAccount.Id,
        RecordTypeId = GetHelpConstants.idrtProfileUpdate,
        Type = GetHelpConstants.RESIDENTIAL_ADDRESS_QA,
        Status = GetHelpConstants.OPEN_STATUS
      ),
      new Case(
        AccountId = oAccount.Id,
        RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID
      )
    };

    Test.startTest();

    GetHelpCaseActions.setOwnerToIDOpsQueue(lstCases);

    Test.stopTest();

    for (Case oCase : lstCases) {
      if (oCase.RecordTypeId == GetHelpConstants.idrtProfileUpdate) {
        Assert.areEqual(
          GetHelpCaseActions.idOpsQueue.Id,
          oCase.OwnerId,
          'Profile Update cases should be assigned to the ID Ops Queue on insert'
        );
      } else {
        Assert.areNotEqual(
          GetHelpCaseActions.idOpsQueue.Id,
          oCase.OwnerId,
          'Non-Profile Update cases should not be assigned to ID Ops Queue on insert'
        );
      }
    }
  }

  @IsTest
  static void updateIDOpsWatchlistOnboardingReason() {
    List<Case> records = new List<Case>();

    //ID Ops Case with Child Case
    Case idOpsCaseWithChild = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      RecordTypeId = GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID,
      Status = GetHelpConstants.COB_DAON_FAILED_STATUS,
      Subject = 'ID Ops Assistance - ' +
        GetHelpConstants.COB_DAON_FAILED_SUBJECT_WATCHLIST_HIT
    );
    records.add(idOpsCaseWithChild);

    //Child Fraud Case of idOpsCaseWithChild
    Case fraudCheckCase = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      RecordTypeId = GetHelpConstants.FRAUD_CHECK_RT_ID,
      Status = GetHelpConstants.COB_DAON_FAILED_STATUS,
      ParentId = idOpsCaseWithChild.Id
    );
    records.add(fraudCheckCase);

    //ID Ops Case with NO Child case
    Case idOpsCaseWithNoChild = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      RecordTypeId = GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID,
      Status = GetHelpConstants.COB_DAON_FAILED_STATUS,
      Subject = 'ID Ops Assistance - ' +
        GetHelpConstants.COB_DAON_FAILED_SUBJECT_WATCHLIST_HIT
    );
    records.add(idOpsCaseWithNoChild);

    Map<Id, Case> oldMap = new Map<Id, Case>(
      records.deepClone(true, true, true)
    );

    //update the status for trigger to run
    idOpsCaseWithNoChild.Status = GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS;
    idOpsCaseWithChild.Status = GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS;

    GetHelpCaseActionsHelper.getChildCaseListMock = new Set<Id>{
      idOpsCaseWithChild.Id
    };

    Test.startTest();
    GetHelpCaseActions.updateIDOpsWatchlistOnboardingReason(records, oldMap);
    Test.stopTest();

    //Case's OnboardingVerificationFailedReason__c with child should not get updated
    Assert.isNull(
      idOpsCaseWithChild.OnboardingVerificationFailedReason__c,
      'The OnboardingVerificationFailedReason__c should not get updated'
    );

    //Case's OnboardingVerificationFailedReason__c Subject should be updated
    Assert.areEqual(
      GetHelpConstants.ONBOARDING_FAILED_REASON_CONFIRMED_FRAUD_WATCHLIST,
      idOpsCaseWithNoChild.OnboardingVerificationFailedReason__c,
      'The Onboarding Verification Failed Reason should be: ' +
      GetHelpConstants.ONBOARDING_FAILED_REASON_CONFIRMED_FRAUD_WATCHLIST
    );
  }
}

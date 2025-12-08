@isTest
private class OpportunityCreateOpenLoanappHelperTest {
  private static Id newOppId = Lib_FakeIdGenerator.getMockId(
    Schema.Opportunity.getSObjectType()
  );
  private static Id newAccId = Lib_FakeIdGenerator.getMockId(
    Schema.Account.getSObjectType()
  );
  private static Id newConId = Lib_FakeIdGenerator.getMockId(
    Schema.Contact.getSObjectType()
  );
  private static Account cust = new Account(
    Id = newAccId,
    FirstName = 'Test',
    LastName = 'Test',
    Salutation = 'Mrs',
    External_Id__c = 'CAP-CIS_4011643101',
    Name = 'Test Test',
    RecordTypeId = CCRMConstants.ACCOUNT_PERSON_RT_ID
  );
  private static Opportunity opp = new Opportunity(
    Id = newOppId,
    AccountId = newAccId,
    Name = 'Test',
    StageName = 'Needs Analysis',
    Amount = 5000,
    Customer_Needs__c = 'Home Loan - Bridging Finance',
    CloseDate = Date.today() + 5,
    Servicing_Branch__c = '1234',
    Expected_Settlement_Date__c = System.today()
  );
  private static OpportunityContactRole ocr = new OpportunityContactRole(
    OpportunityId = newOppId,
    ContactId = newConId,
    Role = 'Applicant'
  );

  @isTest
  static void createOpenLoanAppRequestBodyTest() {
    opp = (Opportunity) TestUtil.setFields(
      opp,
      new Map<String, Object>{
        'OpportunityContactRoles' => new List<OpportunityContactRole>{ ocr },
        'TPMI__c' => '1231'
      }
    );
    Test.startTest();
    LoanappModel mdl = OpportunityCreateOpenLoanappHelper.createOpenLoanAppRequestBody(
      opp,
      false
    );
    opp.Servicing_Branch__c = null;
    LoanappModel mdlWithoutBranch = OpportunityCreateOpenLoanappHelper.createOpenLoanAppRequestBody(
      opp,
      false
    );
    Test.stopTest();
    Assert.isNotNull(
      mdl.loan_application,
      'Loan application should be populated!'
    );
    Assert.areEqual(
      'TARGET_SIMPOLOGY',
      mdl.target,
      'target should be TARGET_SIMPOLOGY'
    );
    Assert.isNotNull(mdl.request_id, 'Request id should be populated');
    Assert.areEqual(
      mdl.loan_application.households[0].applicants.size(),
      1,
      'there should be 1 applicant'
    );
    Assert.areEqual(
      mdl.loan_application.preferences[0].rba_lending_purpose,
      'RBA_LENDING_PURPOSE_FURTHER_ADVANCE',
      'invalid rba_lending_purpose value, should be RBA_LENDING_PURPOSE_FURTHER_ADVANCE!'
    );
    Assert.areEqual(
      '011234',
      mdl.loan_application.branch.bsb,
      'Servicing branch is not updated correctly when having value'
    );
    Assert.areEqual(
      '000000',
      mdlWithoutBranch.loan_application.branch.bsb,
      'Servicing branch is not updated correctly when blank'
    );
  }

  @isTest
  static void getExpectedSettlementDateTest() {
    Test.startTest();
    LoanappModel.Expected_settlement_date dt = OpportunityCreateOpenLoanappHelper.getExpectedSettlementDate(
      opp
    );
    Test.stopTest();
    Assert.areEqual(dt.day.value, System.today().day(), 'invalid day value');
    Assert.areEqual(
      dt.month.value,
      System.today().month(),
      'invalid month value'
    );
    Assert.areEqual(dt.year.value, System.today().year(), 'invalid year value');
  }

  @isTest
  static void getFundsTest() {
    Test.startTest();
    LoanappModel.Funds fnds = OpportunityCreateOpenLoanappHelper.getFunds(opp);
    Test.stopTest();
    Assert.isNotNull(fnds.amount, 'funds amount should not be null');
    Assert.areEqual(fnds.amount.units, 5000, 'amount should be 5000');
    Assert.areEqual(fnds.amount.currency_code, 'AUD', 'currency should be AUD');
  }

  @isTest
  static void generateRandomUidTest() {
    Test.startTest();
    String uid = OpportunityCreateOpenLoanappHelper.generateRandomUid();
    Test.stopTest();
    Assert.isTrue(uid.startsWith('I-'), 'should start with I-');
  }
}

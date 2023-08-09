/**
 * @author Peter Charalambous
 * @since 08/2023
 * @description Test class for loan applicant group trigger handler
 */
@IsTest
public with sharing class LoanApplicantGroupTriggerHandlerTest {
  @TestSetup
  static void setup() {
    Faker faker = new Faker('AU');

    Account accnt = new Account(
      FirstName = faker.person.firstName(),
      LastName = faker.person.lastName(),
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true,
      RecordTypeId = GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID
    );
    insert accnt;

    List<ResidentialLoanApplication> rlaList = new List<ResidentialLoanApplication>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      rlaList.add(
        new ResidentialLoanApplication(
          Name = 'test app',
          AccountId = accnt.Id,
          Credit_ID__c = '123',
          Assessment_Outcome__c = 'Approved'
        )
      );
    }
    insert rlaList;
  }

  @IsTest
  static void testSopIdCopy() {
    List<ResidentialLoanApplication> rlaList = [
      SELECT Id, SOP_Id__c
      FROM ResidentialLoanApplication
    ];
    List<Loan_Applicant_Group__c> appGroups = new List<Loan_Applicant_Group__c>();
    Faker faker = new Faker('AU');
    String sopIdprefix = faker.randomString(5);
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      appGroups.add(
        new Loan_Applicant_Group__c(
          Name = 'Test group',
          Residential_Loan_Application__c = rlaList[i].Id,
          SOP_ID__c = sopIdPrefix + String.valueOf(i)
        )
      );
    }

    Test.startTest();
    Assert.isNull(rlaList[0].SOP_Id__c, 'SOP ID should be null');
    insert appGroups;
    ResidentialLoanApplication rlaAfterInsert = [
      SELECT Id, SOP_Id__c
      FROM ResidentialLoanApplication
      LIMIT 1
    ];
    Test.stopTest();

    Assert.areEqual(
      appGroups[0].SOP_ID__c,
      rlaAfterInsert.SOP_Id__c,
      'SOP Ids should match between applicant group and loan app'
    );
  }
}

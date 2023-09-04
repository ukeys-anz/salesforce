/**
 * @author Peter Charalambous
 * @since 08/2023
 * @description test class for Residential Loan Application trigger handler
 */
@isTest
public with sharing class ResidentialLoanAppTriggerHandlerTest {
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

    //Create RLA records with no owner
    List<ResidentialLoanApplication> rlaList = new List<ResidentialLoanApplication>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      rlaList.add(
        new ResidentialLoanApplication(
          Name = faker.randomString(5),
          Credit_ID__c = faker.randomString(4),
          Assessment_Outcome__c = 'Approved',
          AccountId = accnt.Id,
          RecordTypeId = GetHelpConstants.LOAN_APPLICATION_RT_ID
        )
      );
    }
    insert rlaList;
  }

  @isTest
  static void testLoanAppOwnerAssignment() {
    Faker faker = new Faker('AU');

    Group homeLoanAppQueue = [
      SELECT Id
      FROM Group
      WHERE developername = 'Home_Loan_Applications_Queue' AND Type = 'Queue'
    ];

    Test.startTest();

    List<ResidentialLoanApplication> rlaList = [
      SELECT OwnerId
      FROM ResidentialLoanApplication
      LIMIT :Integer.valueOf(Label.Test_Bulk_Size)
    ];

    for (ResidentialLoanApplication rla : rlaList) {
      Assert.areEqual(
        rla.OwnerId,
        homeLoanAppQueue.Id,
        'Owner should be Home Loan Applications Queue'
      );
    }
    Test.stopTest();
  }
}

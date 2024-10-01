/**
 * @author Deepro De
 * @since 05/2024
 * @description test class for Residential Loan Application trigger handler
 */
@isTest
private class ApplicationEventActionsTest {
  private static final Id LOAN_APP_RECORD_TYPE_ID = QueryRT.of(
      ResidentialLoanApplication.SObjectType
    )
    .getId('Loan_Application');
  /**
   * @description Create a list of Residential Loan Applications
   * @author Deepro De | 06-05-2024
   * @param recordTypeId
   * @return List<ResidentialLoanApplication>
   **/
  static List<ResidentialLoanApplication> createTestResidentialLoanAppList(
    Id recordTypeId
  ) {
    List<ResidentialLoanApplication> loanAppList = new List<ResidentialLoanApplication>();
    Faker faker = new Faker('AU');
    for (Integer counter = 0; counter < 10; counter++) {
      ResidentialLoanApplication loanApp = new ResidentialLoanApplication();
      loanApp.Id = Lib_FakeIdGenerator.getMockId(
        ResidentialLoanApplication.SObjectType
      );
      loanApp.Name = 'Test Loan Application ' + faker.randomString(4);
      loanApp.ApplicationExtIdentifier = '123456';
      loanApp.Assisted_Broker_TPMI_SAO__c = 'RE-0000' + counter;
      loanApp.RecordTypeId = recordTypeId;
      loanApp.Sync_Status__c = 'Broker Org';
      loanAppList.add(loanApp);
    }
    return loanAppList;
  }

  /**
   * @description Method for testing createCloudEventModels
   * @author Deepro De | 06-03-2024
   **/
  @isTest
  static void testCreateCloudEventModels() {
    List<ResidentialLoanApplication> newLoanApps = createTestResidentialLoanAppList(
      LOAN_APP_RECORD_TYPE_ID
    );
    Test.startTest();
    List<BrokerCloudEventModel> cloudEventModels = ApplicationEventActions.createCloudEventModels(
      newLoanApps,
      ApplicationEventActions.APPLICATION_EVENT_ADD
    );
    Test.stopTest();
    Assert.areEqual(
      10,
      cloudEventModels.size(),
      '10 Cloud Event Model instances should be created'
    );
    Assert.areEqual(
      'Broker/' + newLoanApps[0].ApplicationExtIdentifier,
      cloudEventModels[0].ce_xtargets,
      'The Loan Application Number should be reflected in the cloud event model ce_xtargets'
    );
  }
}

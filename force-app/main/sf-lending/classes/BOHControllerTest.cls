/**
 *
 * @author Raman Gupta
 * @since March 2025
 * @description Test class for {@link BOHController)
 */
@istest
public with sharing class BOHControllerTest {
  static Lib_MockProvider rlaRepoMock;
  static Lib_MockProvider rlaAPIRepoMock;

  static void registerMocks() {
    rlaRepoMock = Lib_MockProvider.forType(
        ResidentialLoanApplicationRepository.class
      )
      .mock('queryRLAById', relatedRla);
    rlaAPIRepoMock = Lib_MockProvider.forType(SOPAPIRepository.class);
  }

  static SOPViewModel mocksop = SOPViewModel.parse(
    Service.getStaticResource('mock_sop')
  );

  static SOPUpdateSOPAndPartyResponseModel mockUpdateSOPAndPartyViewModel = SOPUpdateSOPAndPartyResponseModel.parse(
    Service.getStaticResource('mock_updateSOPAndParty')
  );

  static Id rlaIds = Lib_FakeIdGenerator.getMockId(
    ResidentialLoanApplication.SObjectType
  );
  static ResidentialLoanApplication relatedRla {
    get {
      ResidentialLoanApplication rla = new ResidentialLoanApplication(
        Id = rlaIds,
        Assessment_Outcome__c = 'Approved',
        Status = 'STATE_REFERRED',
        Credit_ID__c = 'Test',
        SOP_Id__c = 'TestId',
        Name = 'TestRla',
        Account = new Account(
          Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
          FirstName = 'FakeNameB',
          OCV_ID__c = '276543221'
        )
      );
      return rla;
    }
  }

  static SOPViewModel getSOPViewModel {
    get {
      SOPViewModel sopViewModel = new SOPViewModel();
      sopViewModel.name = 'e6782045-b850-46a6-8b13-ffb8839633c9';
      sopViewModel.parties = new List<SOPViewModel.Parties>();
      SOPViewModel.Parties party = new SOPViewModel.Parties();
      party.id = 'e6782045-b850-46a6-8b13-ffb8839633c9';
      party.ocvId = '123456';
      party.spouseEarnsIncome = false;
      party.soleIncomeEarner = 'Yes';
      party.partyDependantsCount = 2;
      party.relationshipState = 'Single';
      sopViewModel.parties.add(party);
      sopViewModel.dependantsCount = 2;
      sopViewModel.isSOPDataUpdated = true;
      sopViewModel.isPartyDataUpdated = true;
      sopViewModel.etag = '13243356664';
      return sopViewModel;
    }
  }

  @isTest
  static void testUpdateSOPAndParty() {
    registerMocks();
    SOPViewModel mockUpdateSOPAndParty = new SOPViewModel(
      mockUpdateSOPAndPartyViewModel
    );
    rlaAPIRepoMock.mock('updateSOPAndParty', mockUpdateSOPAndParty);
    Id recordId = Lib_FakeIdGenerator.getMockId(
      ResidentialLoanApplication.SObjectType
    );
    Test.startTest();
    SOPViewModel result = BOHController.updateSOPAndParty(
      getSOPViewModel,
      recordId
    );
    Test.stopTest();
    Assert.isNotNull(result, 'update party callout should success');
    Assert.areEqual(
      result?.parties[0]?.soleIncomeEarner,
      'Yes',
      'parties data are populated'
    );
  }

  @isTest
  static void testUpdateSOPAndPartyException() {
    registerMocks();
    rlaAPIRepoMock.mock(
      'updateSOPAndParty',
      new CalloutException('Error calling out')
    );
    Exception resultException;
    Test.startTest();
    try {
      BOHController.updateSOPAndParty(
        getSOPViewModel,
        null
      );
    } catch (Exception exp) {
      resultException = exp;
    }
    Test.stopTest();
    Assert.isTrue(
      resultException instanceof AuraHandledException,
      'Exception should be thrown.'
    );
    Assert.areEqual(
      'Script-thrown exception',
      resultException.getMessage(),
      'Should throw invalid details exception'
    );
  }

  @isTest
  static void testGetSOP() {
    registerMocks();
    rlaAPIRepoMock.mock('getSOP', mocksop);
    Id recordId = Lib_FakeIdGenerator.getMockId(
      ResidentialLoanApplication.SObjectType
    );
    Test.startTest();
    SOPViewModel result = BOHController.getSOP(recordId);
    Test.stopTest();
    Assert.isNotNull(result, 'get sop callout success');
    Assert.areEqual(result?.dependantsCount, 0, 'parties data are populated');
  }

  @isTest
  static void testGetSOPException() {
    registerMocks();
    rlaAPIRepoMock.mock('getSOP', new CalloutException('Error calling out'));
    Test.startTest();
    SOPViewModel result = BOHController.getSOP(null);
    Test.stopTest();
    Assert.isNull(result, 'Valid Loan Record not found');
  }
}

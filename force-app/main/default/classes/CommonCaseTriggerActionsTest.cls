/**
 * @author Batya Aisman Sufrin
 * @since 04/2025
 * @description tests for {@link CommonCaseTriggerActions}
 */
@isTest
private with sharing class CommonCaseTriggerActionsTest {
  static Lib_MockProvider commonCaseTriggerRepoMock;
  static Lib_MockProvider caseDurationServiceMock;

  static void registerMocks() {
    commonCaseTriggerRepoMock = Lib_MockProvider.forType(
      CommonCaseTriggerRepository.class
    );
    caseDurationServiceMock = Lib_MockProvider.forType(
      CaseDurationService.class
    );
  }

  static Case theCase = new Case();
  static Id personAccId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
  static Account personAcc = (Account) TestUtil.setFields(
    new Account(
      Id = personAccId,
      Name = 'Person Account Name',
      RecordTypeId = RTAccount.personAccount
    ),
    new Map<String, Object>{
      'Contacts' => new List<Contact>{
        new Contact(Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType))
      }
    }
  );

  //Tests if ANZ Plus Case ContactId is populated correctly based on Account.
  @isTest
  static void testContactLookupPopulation() {
    // GIVEN a case with Person Account record
    registerMocks();
    commonCaseTriggerRepoMock.mock(
      'queryAccountsByIdSystemMode',
      new List<Account>{ personAcc }
    );

    theCase.AccountId = personAcc.Id;

    // WHEN the Case is populated with contact lookup
    Test.startTest();
    Case oldCase = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      AccountId = null
    );
    CommonCaseTriggerActions.populateContactLookupForANZPlus(
      new List<Case>{ theCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();

    // THEN Contact Name lookup should be auto-populated
    System.assertEquals(
      personAcc.PersonContactId,
      theCase.ContactId,
      'Failed to auto-populate Contact lookup to the case.'
    );
  }

  @isTest
  static void testMaskTaxNumbersDescription() {
    // GIVEN a case with a TFN in the description
    theCase.Description = 'A sample text with TFN: 1234567890';

    // WHEN the case is updated
    Test.startTest();
    CommonCaseTriggerActions.maskTaxNumbers(
      new List<Case>{ theCase },
      new Map<Id, Case>()
    );
    Test.stopTest();

    Assert.areEqual(
      'A sample text with TFN: **********',
      theCase.Description,
      'Description should be masked'
    );
  }

  @isTest
  static void testMaskTaxNumbersComments() {
    // GIVEN a case with a TFN in the comments
    theCase.Comments = 'A sample text with TFN: 1234567890';

    // WHEN the case is updated
    Test.startTest();
    CommonCaseTriggerActions.maskTaxNumbers(
      new List<Case>{ theCase },
      new Map<Id, Case>()
    );
    Test.stopTest();

    Assert.areEqual(
      'A sample text with TFN: **********',
      theCase.Comments,
      'Comments should be masked'
    );
  }

  @istest
  static void testBusinessHoursAssignment() {
    // GIVEN a case with a business hours not set
    theCase.BusinessHoursId = Lib_FakeIdGenerator.getMockId(
      BusinessHours.SObjectType
    );

    // WHEN the case is updated
    Test.startTest();
    CommonCaseTriggerActions.setBusinessHours(new List<Case>{ theCase });
    Test.stopTest();

    Assert.areEqual(
      QueryBusinessHours.anzXBusinessHours.Id,
      theCase.BusinessHoursId,
      'Case BussinessHoursId should be as expected.'
    );
  }

  //Tests duration hours field is populated during closure time
  @isTest
  static void testUpdateCaseDurationTime() {
    registerMocks();
    Map<Id, CaseDurationObject.DurationTime> caseIdToDuration = new Map<Id, CaseDurationObject.DurationTime>();
    caseIdToDuration.put(theCase.Id, new CaseDurationObject.DurationTime(5));
    caseDurationServiceMock.mock('fetchCaseDurationTime', caseIdToDuration);
    // GIVEN a case with a status changed to close
    theCase.Status = 'Closed';

    Test.startTest();
    Case oldCase = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      Status = 'Open'
    );
    CommonCaseTriggerActions.updateCaseDurationTime(
      new List<Case>{ theCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();

    Assert.isTrue(
      theCase.Case_Hour_Duration__c >= 0,
      'Case Hour Duration time should be set.'
    );
  }
}

/**
 * @author Batya Aisman Sufrin
 * @since 04/2025
 * @description tests for {@link FraudXCaseActions}
 */
@isTest
private class FraudXCaseActionsTest {
  static Map<String, String> caseTypeLabelByValue = CommonUtil.getPicklistLabelsByValues(
    Case.Type
  );
  static Case theCase = new Case();

  @isTest
  static void testPopulateFraudXCaseSubjectFraud() {
    // GIVEN Fraud Case
    theCase.RecordTypeId = RTCase.fraud;
    theCase.Type = 'Remote Access';

    // WHEN a case subject is populated
    Test.startTest();
    FraudXCaseActions.populateFraudXCaseSubject(
      new List<Case>{ theCase },
      new Map<Id, Case>()
    );
    Test.stopTest();

    // THEN Case Subject should be populated based on RecordType Name and Type
    Assert.areEqual(
      RTCase.get(theCase.RecordTypeId).Name +
        ' - ' +
        caseTypeLabelByValue.get(theCase.Type),
      theCase.Subject,
      'Fraud case subject should be as expected.'
    );
  }

  @isTest
  static void testPopulateFraudXCaseSubjectIdentity() {
    // GIVEN Identity Case
    theCase.RecordTypeId = RTCase.identity;
    theCase.Type = 'Remote Access';

    // WHEN a case subject is populated
    Test.startTest();
    FraudXCaseActions.populateFraudXCaseSubject(
      new List<Case>{ theCase },
      new Map<Id, Case>()
    );
    Test.stopTest();

    // THEN Case Subject should be populated based on RecordType Name and Type
    Assert.areEqual(
      RTCase.get(theCase.RecordTypeId).Name +
        ' - ' +
        caseTypeLabelByValue.get(theCase.Type),
      theCase.Subject,
      'Identity case subject should be as expected.'
    );
  }

  @isTest
  static void testPopulateFraudXCaseSubjectRecipientMule() {
    // GIVEN Recipien/tMule Case
    theCase.RecordTypeId = RTCase.recipientMule;
    theCase.Type = 'Remote Access';

    // WHEN a case subject is populated
    Test.startTest();
    FraudXCaseActions.populateFraudXCaseSubject(
      new List<Case>{ theCase },
      new Map<Id, Case>()
    );
    Test.stopTest();

    // THEN Case Subject should be populated based on RecordType Name and Type
    Assert.areEqual(
      RTCase.get(theCase.RecordTypeId).Name +
        ' - ' +
        caseTypeLabelByValue.get(theCase.Type),
      theCase.Subject,
      'Recipient/Mule case subject should be as expected.'
    );
  }

  @isTest
  static void testPopulateFraudXCaseSubjectScam() {
    // GIVEN Scam Case
    theCase.RecordTypeId = RTCase.scam;
    theCase.Type = 'Remote Access';

    // WHEN a case subject is populated
    Test.startTest();
    FraudXCaseActions.populateFraudXCaseSubject(
      new List<Case>{ theCase },
      new Map<Id, Case>()
    );
    Test.stopTest();

    // THEN Case Subject should be populated based on RecordType Name and Type
    Assert.areEqual(
      RTCase.get(theCase.RecordTypeId).Name +
        ' - ' +
        caseTypeLabelByValue.get(theCase.Type),
      theCase.Subject,
      'Scam case subject should be as expected.'
    );
  }

  //Test to verify Subject auto-population when Case Type has a numerical value different from the label
  @isTest
  static void testPopulateFraudXCaseSubjectNumericType() {
    // GIVEN Scam Case with numeric Type
    theCase.RecordTypeId = RTCase.scam;
    theCase.Type = '12';

    // WHEN a case subject is populated
    Test.startTest();
    FraudXCaseActions.populateFraudXCaseSubject(
      new List<Case>{ theCase },
      new Map<Id, Case>()
    );
    Test.stopTest();

    // THEN Case Subject should be populated based on RecordType Name and Type
    Assert.areEqual(
      RTCase.get(theCase.RecordTypeId).Name +
        ' - ' +
        caseTypeLabelByValue.get(theCase.Type),
      theCase.Subject,
      'Scam case subject should be as expected.'
    );
  }
}

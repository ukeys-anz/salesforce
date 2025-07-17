/**
 * @author CMOS
 * @since 03/2025
 * @description Test class for {@link IDRCaseAccessActions}
 * @group IDR(Internal Dispute Resolution)
 */
@isTest
private with sharing class IDRCaseAccessActionsTest {
  static Lib_MockProvider caseRepoMock;
  static Lib_MockProvider userMock;

  static User l1User = new User(
    Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
    FirstName = 'DummyL1User'
  );
  static User l2User = new User(
    Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
    FirstName = 'DummyL2User'
  );
  static User l3User = new User(
    Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
    FirstName = 'DummyL3User'
  );

  static Integer caseNumber = new Faker('0-9').randomInteger(6);

  static void registerMocks() {
    caseRepoMock = Lib_MockProvider.forType(IDRCaseActionsRepository.class);
    userMock = Lib_MockProvider.forType(UserInfoRepository.class);
  }

  static Case oldCaseRecord = (Case) TestUtil.setFields(
    new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      RecordTypeId = RTCase.nonCustomerComplaint,
      Status = IDRConstants.OPEN_STATUS,
      IDR_Additional_Correspondence_reviewed__c = false,
      IDR_Document_Count__c = null,
      CaseNumber__c = String.valueOf(caseNumber)
    ),
    new Map<String, Object>{ 'CaseNumber' => caseNumber }
  );

  static Case newCaseRecord = (Case) TestUtil.setFields(
    new Case(
      Id = oldCaseRecord.Id,
      Status = IDRConstants.OPEN_STATUS,
      RecordTypeId = RTCase.nonCustomerComplaint,
      IDR_Additional_Correspondence_reviewed__c = false,
      IDR_Document_Count__c = null,
      CaseNumber__c = String.valueOf(caseNumber),
      IDR_Real_Form_Ref_No__c = '123123123',
      IDR_Real_Form_Req__c = 'Yes, I have already recorded a REaL Form',
      IDR_Real_Form_Submitted__c = true
    ),
    new Map<String, Object>{ 'CaseNumber' => caseNumber }
  );
  /**
   * @description Test when case owner is a L1 user and case record is getting updated by L1 user.
   */
  @isTest
  static void testCaseOwnerL1UserUpdateByL1User() {
    registerMocks();
    userMock.mock('checkAnyPermissions', false);
    Case oldCase = oldCaseRecord;
    oldCase.OwnerId = l1User.Id;
    Case newCase = newCaseRecord;
    newCase.OwnerId = l1User.Id;
    Test.startTest();
    IDRCaseAccessActions.restrictL2L3Users(
      new List<Case>{ newCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();
    Assert.isFalse(
      newCase.hasErrors(),
      'L1 User should be able to update the case record'
    );
    Assert.isTrue(
      ApexPages.getMessages().isEmpty(),
      'No error message should be shown'
    );
  }
  /**
   * @description Test when case owner is a L1 user and case record is getting updated by L2 user.
   */
  @isTest
  static void testCaseOwnerL1UserUpdateByL2User() {
    registerMocks();
    userMock
      .mock('getUser', l1User)
      .mock('checkAnyPermissions', true)
      .mock('checkProfile', true)
      .mock('checkAnyRoles', false);
    caseRepoMock.mock('queryL2L3User', new List<User>{});
    Case oldCase = oldCaseRecord;
    oldCase.OwnerId = l1User.Id;
    Case newCase = newCaseRecord;
    newCase.OwnerId = l2User.Id;
    newCase.Status = IDRConstants.REOPENED_STATUS;
    Test.startTest();
    IDRCaseAccessActions.restrictL2L3Users(
      new List<Case>{ newCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();
    Assert.isTrue(
      newCaseRecord.hasErrors(),
      'L2 User should not be able to update the case record'
    );
    Assert.areEqual(
      true,
      newCaseRecord.getErrors()
        .get(0)
        .getMessage()
        .equals(IDRCaseAccessActions.ERROR_MSG_RESTRICT_L2_L3_USERS),
      'Error message should be as expected.'
    );
  }
  /**
   * @description Test when case owner is a L1 user and case record is getting updated by L3 user.
   */
  @isTest
  static void testCaseOwnerL1UserUpdateByL3User() {
    registerMocks();
    userMock
      .mock('getUser', l1User)
      .mock('checkAnyPermissions', true)
      .mock('checkProfile', true)
      .mock('checkAnyRoles', false);
    caseRepoMock.mock('queryL2L3User', new List<User>{});
    Case oldCase = oldCaseRecord;
    oldCase.OwnerId = l1User.Id;
    Case newCase = newCaseRecord;
    newCase.OwnerId = l3User.Id;
    newCase.Status = IDRConstants.REOPENED_STATUS;
    Test.startTest();
    IDRCaseAccessActions.restrictL2L3Users(
      new List<Case>{ newCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();
    Assert.isTrue(
      newCaseRecord.hasErrors(),
      'L3 User should not be able to update the case record'
    );
    Assert.areEqual(
      true,
      newCaseRecord.getErrors()
        .get(0)
        .getMessage()
        .equals(IDRCaseAccessActions.ERROR_MSG_RESTRICT_L2_L3_USERS),
      'Error message should be as expected.'
    );
  }
  /**
   * @description Test when case owner is a L2 user and case record is getting updated by L1 user.
   */
  @isTest
  static void testCaseOwnerL2UserUpdateByL1User() {
    registerMocks();
    userMock
      .mock('getUser', l2User)
      .mock('checkAnyPermissions', true)
      .mock('checkProfile', false)
      .mock('checkAnyRoles', false);
    caseRepoMock.mock('queryL2L3User', new List<User>{ l1User });
    Case oldCase = oldCaseRecord;
    oldCase.OwnerId = l2User.Id;
    Case newCase = newCaseRecord;
    newCase.OwnerId = l2User.Id;
    Test.startTest();
    IDRCaseAccessActions.restrictL2L3Users(
      new List<Case>{ newCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();
    Assert.isFalse(
      newCase.hasErrors(),
      'L1 User should be able to update the case record'
    );
    Assert.isTrue(
      ApexPages.getMessages().isEmpty(),
      'No error message should be shown'
    );
  }
  /**
   * @description Test when case owner is a L2 user and case record is getting updated by L2 user.
   */
  @isTest
  static void testCaseOwnerL2UserUpdateByL2User() {
    registerMocks();
    userMock
      .mock('getUser', l2User)
      .mock('checkAnyPermissions', true)
      .mock('checkProfile', false)
      .mock('checkAnyRoles', false);
    caseRepoMock.mock('queryL2L3User', new List<User>{ l2User });
    Case oldCase = oldCaseRecord;
    oldCase.OwnerId = l2User.Id;
    Case newCase = newCaseRecord;
    newCase.OwnerId = l2User.Id;
    Test.startTest();
    IDRCaseAccessActions.restrictL2L3Users(
      new List<Case>{ newCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();
    Assert.isFalse(
      newCase.hasErrors(),
      'L2 User should be able to update the case record'
    );
    Assert.isTrue(
      ApexPages.getMessages().isEmpty(),
      'No error message should be shown'
    );
  }
  /**
   * @description Test when case owner is a L3 user and case record is getting updated by L1 user.
   */
  @isTest
  static void testCaseOwnerL3UserUpdateByL1User() {
    registerMocks();
    userMock
      .mock('getUser', l3User)
      .mock('checkAnyPermissions', true)
      .mock('checkProfile', false)
      .mock('checkAnyRoles', false);
    caseRepoMock.mock('queryL2L3User', new List<User>{ l1User });
    Case oldCase = oldCaseRecord;
    oldCase.OwnerId = l3User.Id;
    Case newCase = newCaseRecord;
    newCase.OwnerId = l3User.Id;
    Test.startTest();
    IDRCaseAccessActions.restrictL2L3Users(
      new List<Case>{ newCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();
    Assert.isFalse(
      newCase.hasErrors(),
      'L1 User should be able to update the case record'
    );
    Assert.isTrue(
      ApexPages.getMessages().isEmpty(),
      'No error message should be shown'
    );
  }
  /**
   * @description Test when case owner is a L3 user and case record is getting updated by L3 user.
   */
  @isTest
  static void testCaseOwnerL3UserUpdateByL3User() {
    registerMocks();
    userMock
      .mock('getUser', l3User)
      .mock('checkAnyPermissions', true)
      .mock('checkProfile', false)
      .mock('checkAnyRoles', true);
    caseRepoMock.mock('queryL2L3User', new List<User>{ l3User });
    Case oldCase = oldCaseRecord;
    oldCase.OwnerId = l3User.Id;
    Case newCase = newCaseRecord;
    newCase.OwnerId = l3User.Id;
    Test.startTest();
    IDRCaseAccessActions.restrictL2L3Users(
      new List<Case>{ newCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();
    Assert.isFalse(
      newCase.hasErrors(),
      'L3 User should be able to update the case record'
    );
    Assert.isTrue(
      ApexPages.getMessages().isEmpty(),
      'No error message should be shown'
    );
  }
  /**
   * @description Test when a case is getting updated and old owner was a L3 user && new owner is a Group.
   */
  @isTest
  static void testgetNonEscalatedCasesforL2L3users() {
    registerMocks();
    userMock.mock('getUser', l3User);
    Case oldCase = oldCaseRecord;
    oldCase.OwnerId = l3User.Id;
    Case newCase = newCaseRecord;
    newCase.OwnerId = Lib_FakeIdGenerator.getMockId(Group.SObjectType);
    Test.startTest();
    List<Case> result = IDRCaseAccessActions.getNonEscalatedCasesforL2L3users(
      new List<Case>{ newCase },
      new Map<Id, Case>{ oldCase.Id => oldCase },
      new Set<Id>{ l3User.Id }
    );
    Test.stopTest();
    Assert.areEqual(
      result,
      new List<Case>{ newCase },
      'Result contains new case record'
    );
  }
  /**
   * @description Test when case status is changed to Reopened.
   */
  @isTest
  static void testgetStatusChangedCases() {
    Case newCase = newCaseRecord;
    newCase.Status = IDRConstants.REOPENED_STATUS;
    Test.startTest();
    List<Case> result = IDRCaseAccessActions.getStatusChangedCases(
      new List<Case>{ newCase },
      new Map<Id, Case>{ oldCaseRecord.Id => oldCaseRecord }
    );
    Test.stopTest();
    Assert.areEqual(
      result,
      new List<Case>{ newCase },
      'Result contains new case, as new Case status is changed'
    );
  }
  /**
   * @description Test when case owner is changed.
   */
  @isTest
  static void testgetOwnerChangedCases() {
    registerMocks();
    userMock.mock('getUser', l2User);
    Case oldCase = oldCaseRecord;
    oldCase.OwnerId = l3User.Id;
    Case newCase = newCaseRecord;
    newCase.OwnerId = l2User.Id;
    Test.startTest();
    List<Case> result = IDRCaseAccessActions.getOwnerChangedCases(
      new List<Case>{ newCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();
    Assert.isTrue(
      result.isEmpty(),
      'Result should be empty as case owner is changed'
    );
  }
  /**
   * @description Test when case owner is changed and profile is not Anzx Standard user.
   */
  @isTest
  static void testgetNonAnzxStandardUserCases() {
    registerMocks();
    userMock.mock('checkProfile', false).mock('getUser', l2User);
    Case oldCase = oldCaseRecord;
    oldCase.OwnerId = l3User.Id;
    Case newCase = newCaseRecord;
    newCase.OwnerId = l3User.Id;
    Test.startTest();
    List<Case> result = IDRCaseAccessActions.getNonAnzxStandardUserCases(
      new List<Case>{ newCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();
    Assert.isTrue(
      result.isEmpty(),
      'Result should be empty as case as case owner is not changed'
    );
  }
  /**
   * @description Test when case owner is changed and user is having profile as Anzx Standard user and role is not Banker nor Banker line manager.
   */
  @isTest
  static void testgetNonBankerRelatedAnzxUserCases() {
    registerMocks();
    userMock
      .mock('checkProfile', true)
      .mock('checkAnyRoles', false)
      .mock('getUser', l2User);
    Case oldCase = oldCaseRecord;
    oldCase.OwnerId = l3User.Id;
    Case newCase = newCaseRecord;
    oldCase.status = IDRConstants.ON_HOLD_STATUS;
    newCase.OwnerId = l2User.Id;
    Test.startTest();
    List<Case> result = IDRCaseAccessActions.getNonBankerRelatedAnzxUserCases(
      new List<Case>{ newCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();
    Assert.areEqual(
      result,
      new List<Case>{ newCase },
      'Result should contain new case as case owner is not a Banker'
    );
  }
  /**
   * @description Test when new owner is L2/L3 user and IDR_Complaint_Resolution_Count__c,IDR_Additional_Correspondence_reviewed__c, IDR_Document_Count__c data are not changed.
   */
  @isTest
  static void testgetExcludedCases() {
    registerMocks();
    userMock.mock('getUser', l2User);
    Case oldCase = oldCaseRecord;
    oldCase.OwnerId = l3User.Id;
    Case newCase = newCaseRecord;
    newCase.OwnerId = l2User.Id;
    Test.startTest();
    List<Case> result = IDRCaseAccessActions.getExcludedCases(
      new List<Case>{ newCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();
    Assert.areEqual(
      result,
      new List<Case>{ newCase },
      'Case is excluded from validation as none of the fields IDR_Complaint_Resolution_Count__c,IDR_Additional_Correspondence_reviewed__c && IDR_Document_Count__c have been changed'
    );
  }
}

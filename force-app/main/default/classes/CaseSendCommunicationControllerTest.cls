/**
 * @author Duc Nam Le
 * @since 08/2023
 * @description CaseSendCommunicationControllerTest class is the test class for CaseSendCommunicationController class.
 */
@isTest
private class CaseSendCommunicationControllerTest {
  private static final Faker FAKER = new Faker('AU');
  private static Lib_MockProvider caseSendCommunicationRepoMock;
  private static Group kycQAGroup = QueryQueue.pendingKYCQA;

  private static User fraudXUser = new User(
    Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
    FirstName = 'FraudXUser',
    ProfileId = QueryProfile.anzxUser.Id,
    UserRoleId = QueryRole.fraudXAgent.Id
  );
  private static CustomerOnboardingApplication__c cobApp = new CustomerOnboardingApplication__c(
    Id = Lib_FakeIdGenerator.getMockId(
      CustomerOnboardingApplication__c.SObjectType
    ),
    OCVId__c = '0123456789',
    PersonaId__c = FAKER.randomString(15),
    ElectronicVerificationAcknowledged__c = true,
    VerificationType__c = COBApplicationActionsHelper.VERIFICATION_TYPE_ASSISTED
  );
  private static Case kycQACase = new Case(
    Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
    Subject = 'KYC QA Sample',
    CustomerOnboardingApplication__r = cobApp,
    OwnerId = fraudXUser.Id,
    Status = 'Pending Documents',
    Account = new Account(OCV_ID__c = cobApp.OCVId__c),
    LastModifiedBy = fraudXUser
  );

  static void registerAndCallMock() {
    caseSendCommunicationRepoMock = Lib_MockProvider.forType(
      CaseSendCommunicationRepository.class
    );

    caseSendCommunicationRepoMock.mock(
      'getRelatedCases',
      new List<Case>{ kycQACase }
    );
    caseSendCommunicationRepoMock.mock(
      'getUsers',
      new List<User>{ fraudXUser }
    );
    caseSendCommunicationRepoMock.mock(
      'getGroups',
      new List<Group>{ kycQAGroup }
    );
  }

  @isTest
  static void testSendCommunicationSuccess() {
    registerAndCallMock();

    Test.startTest();
    CaseSendCommunicationController.sendCommunication(cobApp.Id);
    Test.stopTest();

    Assert.areEqual(
      1,
      CloudEventController.cloudEvents.size(),
      'Cloud Event should be generated'
    );

    String payload = CloudEventController.cloudEvents[0].Data_1__c;

    Assert.isTrue(
      String.isNotBlank(payload),
      'Cloud Event should be generated'
    );

    Map<String, Object> mappedResponse = (Map<String, Object>) JSON.deserializeUntyped(
      payload
    );
    Map<String, Object> mappedResponse2 = (Map<String, Object>) mappedResponse.get(
      'ce_data'
    );
    AutoKYCQACaseCloudEventModel.AutoKYCQACaseCloudEventDataModel autoKYCQACaseCloudEventDataModel = (AutoKYCQACaseCloudEventModel.AutoKYCQACaseCloudEventDataModel) JSON.deserialize(
      JSON.serialize(mappedResponse2),
      AutoKYCQACaseCloudEventModel.AutoKYCQACaseCloudEventDataModel.class
    );

    Assert.areEqual(
      kycQACase.CaseNumber,
      autoKYCQACaseCloudEventDataModel.caseNumber,
      'Case Number should match'
    );

    Assert.areEqual(
      cobApp.PersonaId__c,
      autoKYCQACaseCloudEventDataModel.customerOnboardingApplication.personaId,
      'Persona Id should match'
    );
  }

  @isTest
  static void testSendCommunicationFailure() {
    Test.startTest();
    try {
      CaseSendCommunicationController.sendCommunication(FAKER.randomString(18));
    } catch (Exception e) {
      Assert.isNotNull(e.getMessage(), 'Error should be thrown.');
    }
    Test.stopTest();
  }

  @isTest
  static void testGenerateCloudEventModel() {
    registerAndCallMock();

    Test.startTest();
    List<CloudEventModel> cloudEventModelList = CaseSendCommunicationController.generateCloudEventModel(
      new List<String>{ cobApp.Id }
    );
    Test.stopTest();

    Assert.isFalse(
      caseSendCommunicationRepoMock.getHistories('getRelatedCases').isEmpty(),
      'getRelatedCases call should have been made.'
    );
    Assert.isFalse(
      caseSendCommunicationRepoMock.getHistories('getUsers').isEmpty(),
      'getUsers call should have been made.'
    );
    Assert.isFalse(
      caseSendCommunicationRepoMock.getHistories('getGroups').isEmpty(),
      'getGroups call should have been made.'
    );
    Assert.areEqual(
      1,
      cloudEventModelList.size(),
      'Cloud Event Model should be generated'
    );
  }

  @isTest
  static void testGetCloudEventModel() {
    Test.startTest();
    List<CloudEventModel> cloudEventModelList = CaseSendCommunicationController.getCloudEventModel(
      new List<Case>{ kycQACase },
      new Map<Id, User>{ fraudXUser.Id => fraudXUser },
      new Map<Id, Group>{ kycQAGroup.Id => kycQAGroup }
    );
    Test.stopTest();

    Assert.areEqual(
      1,
      cloudEventModelList.size(),
      'Cloud Event Model should be generated'
    );
  }
}

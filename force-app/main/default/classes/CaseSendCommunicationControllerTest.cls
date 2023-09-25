/**
 * @author Duc Nam Le
 * @since 08/2023
 * @description CaseSendCommunicationControllerTest class is the test class for CaseSendCommunicationController class.
 */
@isTest
private class CaseSendCommunicationControllerTest {
  private static final Faker FAKER = new Faker('AU');

  @testSetup
  static void setup() {
    // Create an Integration User
    Profile profileIntegration = CommonUtil.getProfileByName(
      'Minimum Access - External Apps'
    );
    UserRole role = CommonUtil.getUserRoleByDevName('ANZx');
    User integrationUser = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'IntegrationTest',
        'ProfileId' => profileIntegration.Id,
        'UserRoleId' => role.Id
      }
    );
    insert integrationUser;

    System.runAs(integrationUser) {
      CustomerOnboardingApplication__c cobApp = new CustomerOnboardingApplication__c(
        OCVId__c = '0123456789',
        PersonaId__c = FAKER.randomString(15),
        ElectronicVerificationAcknowledged__c = false,
        VerificationType__c = COBApplicationActionsHelper.VERIFICATION_TYPE_ASSISTED
      );
      insert cobApp;

      COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c();
      cobPid.CustomerOnboardingApplication__c = cobApp.Id;
      cobPid.FirstName__c = FAKER.randomString(5);
      cobPid.FirstNameOCRServer__c = cobPid.FirstName__c;
      cobPid.LastName__c = FAKER.randomString(5);
      cobPid.LastNameOCRServer__c = cobPid.LastName__c;
      cobPid.MiddleNames__c = FAKER.randomString(5);
      cobPid.MiddleNamesOCRServer__c = cobPid.MiddleNames__c;
      cobPid.IdDocumentType__c = COBApplicationActionsHelper.LICENCE;
      cobPid.LicenceNumber__c = FAKER.randomString(10);
      cobPid.LicenceNumberOCRServer__c = cobPid.LicenceNumber__c;
      insert cobPid;

      COBAddress__c cobAddress = new COBAddress__c();
      cobAddress.CustomerOnboardingApplication__c = cobApp.id;
      cobAddress.AddressType__c = COBApplicationActions.CURRENT;
      cobAddress.AddressQASId__c = FAKER.randomString(15);
      insert cobAddress;
    }
  }

  @isTest
  static void testSendCommunicationSuccess() {
    CustomerOnboardingApplication__c cobApp = [
      SELECT Id, PersonaId__c
      FROM CustomerOnboardingApplication__c
      LIMIT 1
    ];
    cobApp.ElectronicVerificationAcknowledged__c = true;

    Test.startTest();
    update cobApp;
    Case kycQACase = [
      SELECT Id, CaseNumber
      FROM Case
      WHERE CustomerOnboardingApplication__c = :cobApp.Id
      LIMIT 1
    ];
    CaseSendCommunicationController.sendCommunication(kycQACase.Id);
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

    AutoKYCQACaseCloudEventModel autoKYCQACaseCloudEventModel = (AutoKYCQACaseCloudEventModel) JSON.deserialize(
      payload,
      AutoKYCQACaseCloudEventModel.class
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
      Assert.areEqual(
        'Script-thrown exception',
        e.getMessage(),
        'Error should be thrown.'
      );
    }
    Test.stopTest();
  }
}

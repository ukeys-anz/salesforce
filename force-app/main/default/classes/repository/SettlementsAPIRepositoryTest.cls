/**
 * @author Peter Charalambous
 * @since Mon Oct 23 2023
 * @description
 */
@isTest
public with sharing class SettlementsAPIRepositoryTest {
  @isTest
  static void testVerifyInsurance() {
    Faker faker = new Faker('AU');
    Proof_of_Insurance__c poi = TestDataFactory.createPOI(
      Lib_FakeIdGenerator.getMockId(Proof_of_Insurance__c.getSObjectType())
    );
    poi.Mortgage_Contract_ID__c = Faker.randomString(10);
    poi.Property_ID__c = Faker.randomString(10);
    poi.Document_Id__c = Faker.randomString(10);
    poi.Document_File_Version__c = Faker.randomString(10);
    poi.Id = Lib_FakeIdGenerator.getMockId(Proof_of_Insurance__c.getSObjectType());
    Test.startTest();
    SettlementsAPIRepository api = new SettlementsAPIRepository();
    VerifyInsuranceModel response = api.verifyInsurance(poi);
    Test.stopTest();

    Assert.areEqual(
      'STATE_VERIFIED',
      response.proofOfInsuranceVerification.state,
      'State should be verified'
    );
  }
}

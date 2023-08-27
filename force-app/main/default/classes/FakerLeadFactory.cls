/**
 * @author Ashish Kumar
 * @since 03/2023
 * @description  FakerUserFactory is used to create test lead records using Faker.
 * @group Faker
 */
public class FakerLeadFactory extends FakerFactoryBase {
  public override String objectName() {
    return 'Lead';
  }

  /**
   * @author Ashish Kumar
   * @description  FakerUserFactory is used to create test lead records using Faker.
   * @group Faker
   * @return Map<String, Object>
   */
  public override Map<String, Object> define() {
    return new Map<String, Object>{
      'FirstName' => faker.person.firstName(),
      'Email' => faker.internet.anzEmail(),
      'LastName' => faker.person.lastName(),
      'Customer_ID__c' => faker.randomCharacter(10),
      'Title' => faker.person.title(),
      'recordTypeId' => Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
        .get('MLCRM_Lead')
        .getRecordTypeId(),
      'Referrer_email__c' => 'ankit.garg@anz.com',
      'Description' => faker.randomString(80),
      'LeadSource' => 'Anz.com',
      'city' => faker.address.city(),
      'state' => faker.address.state(),
      'postalcode' => faker.address.stateCode(),
      'street' => faker.address.street(),
      'Followup_Date__c' => faker.person.randomFutureDate(),
      'Account_Number__c' => faker.person.randomString(12),
      'Expiry_Date__c' => System.today() + 10
    };
  }
}

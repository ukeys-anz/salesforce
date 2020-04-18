/**
 * @author Igor Matkovic
 * @since 09/07/2018
 * @group faker
 * @description  Sample factory class extending FakerFactoryBase
 * Marked as @isTest to not count against LOC limits
 */
@isTest
public with sharing class FakerExampleFactory extends FakerFactoryBase {
  public override String objectName() {
    return 'Contact';
  }

  public override String getLocale() {
    return 'US';
  }

  public override Map<String, Object> define() {
    return new Map<String, Object>{
      'FirstName' => this.faker.person.firstName(),
      'LastName' => this.faker.person.lastName(),
      'MiddleName' => this.faker.person.firstName()
    };
  }
}

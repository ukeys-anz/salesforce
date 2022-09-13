/**
 * @author Boobalakrishnan Duraisamy
 * @since 03/2020
 * @description  FakerUserFactory is used to create test user records using Faker.
 * @group Faker
 */
public class FakerUserFactory extends FakerFactoryBase {
  public override String objectName() {
    return 'User';
  }

  public override Map<String, Object> define() {
    return new Map<String, Object>{
      'Alias' => faker.randomString(5),
      'Email' => faker.internet.anzEmail(),
      'LastName' => faker.person.lastName(),
      'UserName' => faker.internet.email(),
      'LocaleSidKey' => 'en_AU',
      'TimeZoneSidKey' => 'Australia/Sydney',
      'LanguageLocaleKey' => 'en_US',
      'EmailEncodingKey' => 'UTF-8',
      'FederationIdentifier' => faker.randomString(8)
    };
  }
}

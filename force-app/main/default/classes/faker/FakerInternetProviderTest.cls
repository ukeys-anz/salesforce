/**
 * @author Igor Matkovic
 * @date April 2020
 * @description Test class for {@link FakerInternetProvider}
 * @group Faker
 */
@IsTest
class FakerInternetProviderTest {
  @isTest
  static void testInit() {
    Faker faker = new Faker('US');

    Test.startTest();
    System.assertNotEquals(null, faker.internet.person, 'Faker should create a right info');
    System.assertNotEquals(null, faker.internet.text, 'Faker should create a right info');
    System.assert(faker.internet.mapValues.containsKey('freeEmailDomain'), 'Faker should create a right info');
    System.assert(faker.internet.mapValues.containsKey('tld'),'Faker should create a right info');
    System.assert(faker.internet.mapValues.containsKey('urlFormats'),'Faker should create a right info');
    System.assert(faker.internet.mapValues.containsKey('emailFormats'),'Faker should create a right info');
    System.assert(faker.internet.mapValues.containsKey('safeEmailDomain'),'Faker should create a right info');
    System.assert(faker.internet.mapValues.containsKey('usernameFormats'),'Faker should create a right info');
    System.assert(faker.internet.mapValues.containsKey('webExtension'),'Faker should create a right info');
    System.assert(faker.internet.mapValues.containsKey('domainName'),'Faker should create a right info');
    System.assert(faker.internet.mapValues.containsKey('domainWord'),'Faker should create a right info');
    System.assert(faker.internet.mapValues.containsKey('webExtension'),'Faker should create a right info');
    System.assert(faker.internet.mapValues.containsKey('firstNameFemale'),'Faker should create a right info');
    System.assert(faker.internet.mapValues.containsKey('firstNameMale'),'Faker should create a right info');
    System.assert(faker.internet.mapValues.containsKey('lastName'),'Faker should create a right info');
    Test.stopTest();
  }

  @isTest
  static void testGeneratedValues() {
    Faker faker = new Faker('US');

    Test.startTest();

    System.assertNotEquals(null, faker.internet.username(),'Faker should create a right info');
    String password = faker.internet.password(5, 10);
    String email = faker.internet.email();
    String safeEmail = faker.internet.safeEmail();
    String companyEmail = faker.internet.companyEmail();
    String freeEmail = faker.internet.freeEmail();
    System.assert(email.contains('@'),'Faker should create a right info');
    System.assert(safeEmail.contains('@'),'Faker should create a right info');
    System.assert(companyEmail.contains('@'),'Faker should create a right info');
    System.assert(freeEmail.contains('@'),'Faker should create a right info');

    String tld = faker.internet.tld();
    System.assert(faker.internet.tld.contains(tld),'Faker should create a right info');

    String domainWord = faker.internet.domainWord();
    System.assert(faker.internet.domainWord.contains(domainWord),'Faker should create a right info');

    String domainName = faker.internet.domainName();
    System.assert(faker.internet.domainName.contains(domainName),'Faker should create a right info');

    String url = faker.internet.url();
    System.assert(url.contains('http'),'Faker should create a right info');

    String slug = faker.internet.slug(3, '-');
    System.assert(slug.contains('-'),'Faker should create a right info');

    String slugSecond = faker.internet.slug(3);
    System.assert(slugSecond.contains('_'),'Faker should create a right info');

    String ipv4 = faker.internet.ipv4();
    System.assert(ipv4.length() >= 7 && ipv4.length() <= 15,'Faker should create a right info');

    String localIpv4 = faker.internet.localIpv4();
    System.assert(localIpv4.contains('10.') || localIpv4.contains('192.168.'),'Faker should create a right info');

    String ipv6 = faker.internet.ipv6();
    System.assertEquals(39, ipv6.length(),'Faker should create a right info');

    String macAddress = faker.internet.macAddress();
    System.assertEquals(17, macAddress.length(),'Faker should create a right info');

    Test.stopTest();
  }
}

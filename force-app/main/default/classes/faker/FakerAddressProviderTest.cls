/**
 * @author Igor Matkovic
 * @since 09/07/2018
 * @group Faker
 * @description  Class extending FakerBase which defines FakerAddressProvider.
 * Test class for {@link FakerAddressProvider}
 */
@IsTest
class FakerAddressProviderTest {
  @isTest
  static void testInit() {
    Faker faker = new Faker('US');

    Test.startTest();
    System.assertNotEquals(
      null,
      faker.internet.person,
      'faker should create a fake info.'
    );
    System.assertNotEquals(
      null,
      faker.internet.text,
      'faker should create a fake info.'
    );

    System.assert(
      faker.address.mapValues.containsKey('city'),
      'faker should create a fake address'
    );
    System.assert(
      faker.address.mapValues.containsKey('country'),
      'faker should create a fake address'
    );
    System.assert(
      faker.address.mapValues.containsKey('state'),
      'faker should create a fake address'
    );
    System.assert(
      faker.address.mapValues.containsKey('stateCode'),
      'faker should create a fake address'
    );
    System.assert(
      faker.address.mapValues.containsKey('street'),
      'faker should create a fake address'
    );
    System.assert(
      faker.address.mapValues.containsKey('streetPrefix'),
      'faker should create a fake address'
    );
    System.assert(
      faker.address.mapValues.containsKey('streetSuffix'),
      'faker should create a fake address'
    );
    Test.stopTest();
  }

  @isTest
  static void testMethods() {
    Faker faker = new Faker('US');

    Test.startTest();
    System.assert(
      faker.address.city.contains(faker.address.city()),
      'faker should create a fake address'
    );
    System.assert(
      faker.address.country.contains(faker.address.country()),
      'faker should create a fake address'
    );
    System.assert(
      faker.address.state.contains(faker.address.state()),
      'faker should create a fake address'
    );
    System.assert(
      faker.address.stateCode.contains(faker.address.stateCode()),
      'faker should create a fake address'
    );
    System.assert(
      faker.address.streetSuffix.contains(faker.address.streetSuffix()),
      'faker should create a fake address'
    );
    System.assert(
      faker.address.streetPrefix.contains(faker.address.streetPrefix()),
      'faker should create a fake address'
    );

    String unit = faker.address.unit();
    System.assert(unit.length() > 3, 'faker should create a fake address');

    String buildingNumber = faker.address.buildingNumber();
    System.assertEquals(
      3,
      buildingNumber.length(),
      'faker should create a fake address'
    );

    String address = faker.address.address();
    System.assert(address.length() > 5, 'faker should create a fake address');

    String street = faker.address.street();
    System.assert(street.length() > 5, 'faker should create a fake address');

    Integer zip = faker.address.zip();
    System.assert(
      zip < 100000 &&
      zip > 9999,
      'faker should create a fake address'
    );

    Decimal latitude = faker.address.latitude();
    System.assert(
      latitude >= -90.0 &&
      latitude <= 90.0,
      'faker should create a fake address'
    );

    Decimal longitude = faker.address.longitude();
    System.assert(
      longitude >= -180.0 &&
      longitude <= 180.0,
      'faker should create a fake address'
    );

    Test.stopTest();
  }
}

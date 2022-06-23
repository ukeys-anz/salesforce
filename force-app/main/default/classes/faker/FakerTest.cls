/**
 * @author Igor Matkovic
 * @date April 2020
 * @description Test class for {@link Faker}
 * @group Faker
 */
@IsTest
class FakerTest {
  @isTest
  static void testInitialize() {
    Test.startTest();
    Faker faker = new Faker('US');
    System.assertNotEquals(
      null,
      faker.person,
      'Faker should generate correct information'
    );
    Test.stopTest();
  }
}

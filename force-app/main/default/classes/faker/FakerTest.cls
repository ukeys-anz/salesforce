@IsTest
class FakerTest {
  @isTest
  static void testInitialize() {
    Test.startTest();
    Faker faker = new Faker('US');
    System.assertNotEquals(null, faker.person);
    Test.stopTest();
  }
}

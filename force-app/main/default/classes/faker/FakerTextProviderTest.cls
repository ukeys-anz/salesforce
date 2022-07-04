/**
 * @author Igor Matkovic
 * @date April 2020
 * @description Test class for {@link FakerTextProvider} s
 * @group Faker
 */
@IsTest
class FakerTextProviderTest {
  @isTest
  static void testInit() {
    Faker faker = new Faker('US');

    Test.startTest();
    System.assertNotEquals(
      null,
      faker.text.text,
      'Faker should generate correct information'
    );
    System.assertNotEquals(
      null,
      faker.text.sentences,
      'Faker should generate correct information'
    );
    Test.stopTest();
  }

  @isTest
  static void testMethods() {
    Faker faker = new Faker('US');

    Test.startTest();
    List<String> realWords = faker.text.realWords(3);
    System.assertEquals(
      3,
      realWords.size(),
      'Faker should generate correct information'
    );

    String realTextLimited = faker.text.realText(100, 600);
    System.assert(
      realTextLimited.length() <= 500,
      'Faker should generate correct information'
    );
    Test.stopTest();
  }

  @isTest
  static void testInitCustom() {
    Faker faker = new Faker('US');
    faker.text.text = 'This is a non empty line 1. \n';
    faker.text.text = faker.text.text + 'This is a non empty line 2. \n';
    faker.text.text = faker.text.text + '\n';
    faker.text.text = faker.text.text + '\n';
    faker.text.text = faker.text.text + 'This is a non empty line3. ';
    Test.startTest();
    faker.text.init();
    System.assertEquals(3, faker.text.sentences.size(), faker.text.sentences);
    Test.stopTest();
  }
}

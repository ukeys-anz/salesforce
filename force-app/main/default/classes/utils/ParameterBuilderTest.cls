/**
 * @author Emma Bindi
 * @date July 2022
 * @description Test class for {@link ParameterBuilder}
 */
@isTest
public with sharing class ParameterBuilderTest {
  /**
   * @description test appendMethods in builder
   */
  @isTest
  static void testParamBuilderAppendMethods() {
    Faker faker = new Faker('AU');

    Integer randomInt = faker.randomIntegerBetween(1, 10);
    String randomString = faker.randomString(10);
    DateTime randomDate = faker.randomFutureDate();

    Test.startTest();

    ParameterBuilder builder = new ParameterBuilder();
    String paramUrlString = builder.append('intKey', randomInt)
      .append('strKey', randomString)
      .append('dateKey', randomDate)
      .get();

    Test.stopTest();

    String expectedString =
      '?' +
      'intKey=' +
      randomInt +
      '&strKey=' +
      randomString +
      '&dateKey=' +
      randomDate;

    System.assertEquals(
      expectedString,
      paramUrlString,
      'Parameter URL string should be built as expected'
    );
  }
}

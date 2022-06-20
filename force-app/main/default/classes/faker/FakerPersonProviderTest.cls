/**
 * @author Igor Matkovic
 * @date April 2020
 * @description Test class for {@link FakerPersonProvider}
 * @group Faker
 */
@IsTest
class FakerPersonProviderTest {
  @isTest
  static void testInit() {
    Faker faker = new Faker('US');

    Test.startTest();
    System.assertNotEquals(
      null,
      faker.person.nameFormatsMale,
      'Faker should generate correct information'
    );
    System.assertNotEquals(
      null,
      faker.person.nameFormatsFemale,
      'Faker should generate correct information'
    );
    System.assertNotEquals(
      null,
      faker.person.firstNameFemale,
      'Faker should generate correct information'
    );
    System.assertNotEquals(
      null,
      faker.person.firstNameMale,
      'Faker should generate correct information'
    );
    System.assertNotEquals(
      null,
      faker.person.lastName,
      'Faker should generate correct information'
    );
    System.assertNotEquals(
      null,
      faker.person.suffix,
      'Faker should generate correct information'
    );
    System.assertNotEquals(
      null,
      faker.person.gender,
      'Faker should generate correct information'
    );
    System.assertNotEquals(
      null,
      faker.person.titleMale,
      'Faker should generate correct information'
    );
    System.assertNotEquals(
      null,
      faker.person.titleFemale,
      'Faker should generate correct information'
    );
    System.assertNotEquals(
      null,
      faker.person.jobTitle,
      'Faker should generate correct information'
    );
    System.assert(
      faker.person.mapValues.containsKey('firstNameMale'),
      'Faker should generate correct information'
    );
    System.assert(
      faker.person.mapValues.containsKey('firstNameFemale'),
      'Faker should generate correct information'
    );
    System.assert(
      faker.person.mapValues.containsKey('lastName'),
      'Faker should generate correct information'
    );
    System.assert(
      faker.person.mapValues.containsKey('suffix'),
      'Faker should generate correct information'
    );
    System.assert(
      faker.person.mapValues.containsKey('titleMale'),
      'Faker should generate correct information'
    );
    System.assert(
      faker.person.mapValues.containsKey('titleFemale'),
      'Faker should generate correct information'
    );
    System.assert(
      faker.person.mapValues.containsKey('gender'),
      'Faker should generate correct information'
    );
    System.assert(
      faker.person.mapValues.containsKey('jobTitle'),
      'Faker should generate correct information'
    );
    Test.stopTest();
  }

  @isTest
  static void testGeneratedValues() {
    Faker faker = new Faker('US');

    Test.startTest();
    String name = faker.person.name();
    String firstName = faker.person.firstName();
    String lastName = faker.person.lastName();
    String suffix = faker.person.suffix();
    String title = faker.person.title();
    String gender = faker.person.gender();
    String jobTitle = faker.person.jobTitle();
    String ssn = faker.person.ssn();
    String phone = faker.person.phone();
    Date birthday = faker.person.birthday();
    String phoneAreCode = faker.person.phone(702);
    String picture = faker.person.picture(200, 200);

    System.assertNotEquals(
      null,
      name,
      'Faker should generate correct information'
    );
    System.assert(
      faker.person.firstNameMale.contains(firstName) ||
      faker.person.firstNameFemale.contains(firstName),
      'Faker should generate correct information'
    );
    System.assert(
      faker.person.lastName.contains(lastName),
      'Faker should generate correct information'
    );
    System.assert(
      faker.person.suffix.contains(suffix),
      'Faker should generate correct information'
    );
    System.assert(
      faker.person.titleMale.contains(title) ||
      faker.person.titleFemale.contains(title),
      'Faker should generate correct information'
    );
    System.assert(
      faker.person.gender.contains(gender),
      'Faker should generate correct information'
    );
    System.assert(
      faker.person.jobTitle.contains(jobTitle),
      'Faker should generate correct information'
    );

    System.assertEquals(
      11,
      ssn.length(),
      'Faker should generate correct information'
    );
    System.assertEquals(
      14,
      phone.length(),
      'Faker should generate correct information'
    );
    System.assertEquals(
      14,
      phoneAreCode.length(),
      'Faker should generate correct information'
    );
    System.assert(
      phoneAreCode.contains('(702)'),
      'Faker should generate correct information'
    );

    System.assert(
      Date.today() > birthday,
      'Faker should generate correct information'
    );
    System.assert(
      picture.contains('200'),
      'Faker should generate correct information'
    );

    Test.stopTest();
  }
}

/**
 * @author Igor Matkovic
 * @date April 2020
 * @description Test class for {@link FakerFactory}
 * @group Faker
 */
@isTest
private with sharing class FakerFactoryTest {
  @isTest
  static void testFactoryMake() {
    Test.startTest();
    Contact c = (Contact) FakerFactory.make(new FakerExampleFactory());
    System.assertNotEquals(null, c.FirstName, 'FakerFactory should work as expected.');
    Test.stopTest();
  }

  @isTest
  static void testFactoryCreate() {
    Test.startTest();
    Contact c = (Contact) FakerFactory.create(new FakerExampleFactory());
    System.assertNotEquals(null, c.FirstName, 'FakerFactory should work as expected.');
    Test.stopTest();
  }

  @isTest
  static void testFactoryMakeWithData() {
    Test.startTest();
    Contact c = (Contact) FakerFactory.make(
      new FakerExampleFactory(),
      new Map<String, Object>{ 'FirstName' => 'test123' }
    );
    System.assertEquals('test123', c.FirstName, 'FakerFactory should work as expected.');
    Test.stopTest();
  }

  @isTest
  static void testFactoryCreateWithData() {
    Test.startTest();
    Contact c = (Contact) FakerFactory.create(
      new FakerExampleFactory(),
      new Map<String, Object>{ 'FirstName' => 'test123' }
    );
    System.assertEquals('test123', c.FirstName, 'FakerFactory should work as expected.');
    Test.stopTest();
  }
}

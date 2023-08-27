/**
 * @author Aidan
 * @since Sep 2021
 * @description Test class for {@link PicklistUtilTest}
 * @group Utility
 */
@IsTest
public class PicklistUtilTest {
  /**
   * Two fields have been set up on Release__c object for testing this utility;
   * Controlling_Picklist__c and Dependent_Picklist__c
   *
   * Dependencies as follows:
   *    A    B    C
   *   (1)   1    1
   *    2   (2)  (2)
   *    3    3   (3)
   *    4    4    4
   */

  /**
   * @description
   */
  @IsTest
  static void testFieldWithOneParent() {
    // GIVEN
    // a picklist field in salesforce has only one parent value

    // WHEN
    // 'getPicklistDependencyMap()' method is called
    Test.startTest();
    Map<String, List<String>> resultMap = PicklistUtil.getCachedPicklistParentMap(
      'Release__c',
      'Dependent_Picklist__c'
    );
    Test.stopTest();

    // THEN
    // the resulting entry returns the correct parent
    List<String> test = resultMap.get('1');
    System.assertEquals(
      1,
      test.size(),
      'Child value should only have one parent value.'
    );
    System.assertEquals(
      'A',
      test[0],
      'Failed to calculate the correct parent value for dependent value.'
    );
  }

  @IsTest
  static void testFieldWithTwoParents() {
    // GIVEN
    // a picklist field in salesforce has two parent values

    // WHEN
    // 'getPicklistDependencyMap()' method is called
    Test.startTest();
    Map<String, List<String>> resultMap = PicklistUtil.getCachedPicklistParentMap(
      'Release__c',
      'Dependent_Picklist__c'
    );
    Test.stopTest();

    // THEN
    // all valid parent values are returned in an array
    List<String> test = resultMap.get('2');
    List<String> expected = new List<String>{ 'B', 'C' };
    System.assertEquals(
      2,
      test.size(),
      'Child value should only have two parents.'
    );
    System.assertEquals(
      expected,
      test,
      'Failed to calculate the correct parent value(s) for dependent value.'
    );
  }

  @IsTest
  static void testFieldWithNoParents() {
    // GIVEN
    // a picklist field in salesforce has no parent values

    // WHEN
    // 'getPicklistDependencyMap()' method is called
    Test.startTest();
    Map<String, List<String>> resultMap = PicklistUtil.getCachedPicklistParentMap(
      'Release__c',
      'Dependent_Picklist__c'
    );
    Test.stopTest();

    // THEN
    // the resulting map does not contain the entry
    System.assert(
      !resultMap.containsKey('4'),
      'Failed to skip a child value without a parent'
    );
  }

  @IsTest
  static void testFieldWithOneSibling() {
    // GIVEN
    // a parent picklist field in salesforce has multiple children values, we can return the correct parent values

    // WHEN
    // 'getPicklistDependencyMap()' method is called
    Test.startTest();
    Map<String, List<String>> resultMap = PicklistUtil.getCachedPicklistParentMap(
      'Release__c',
      'Dependent_Picklist__c'
    );
    Test.stopTest();

    // THEN
    // the resulting entry returns the correct parent
    List<String> test = resultMap.get('3');
    System.assertEquals(
      1,
      test.size(),
      'Child value should only have one parent.'
    );
    System.assertEquals(
      'C',
      test[0],
      'Failed to calculate the correct parent value for multiple dependent picklist children.'
    );
  }
}

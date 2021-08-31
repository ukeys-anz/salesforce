/**
 * @description Test class for {@link CommonUtil}
 * @author Olivier Saier
 * @since May 2021
 * @group Utils
 */
@isTest
public with sharing class CommonUtilTest {
  @isTest
  static void testGenerateUUID() {
    //WHEN UUIDs are generated
    String[] uuids = new List<String>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      uuids.add(CommonUtil.generateuUID());
    }

    //THEN they all match the UUID pattern
    Pattern uuidPattern = Pattern.compile(
      '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    );
    for (String uuid : uuids) {
      Matcher uuidMatcher = uuidPattern.matcher(uuid);
      System.assert(uuidMatcher.matches(), 'UUID should match the pattern');
    }

    //THEN They're all unique from each other
    Set<String> unique = new Set<String>();
    unique.addAll(uuids);
    System.assertEquals(
      unique.size(),
      uuids.size(),
      'The generated UUIDs should be unique from each other'
    );
  }

  @isTest
  static void logAndThrowIAETest() {
    Test.startTest();
    try {
      //WHEN I call logAndThrowIAE
      CommonUtil.logAndThrowIAE(
        'CommonUtilTest',
        'logAndThrowTest',
        'Error message'
      );

      //THEN an InsufficientAccessException exception is thrown
      System.assertEquals(
        true,
        false,
        'An exception should have been caught before reaching this assert.'
      );
    } catch (Exception ex) {
      System.assertEquals(
        'Error message',
        ex.getMessage(),
        'Error message should be thrown'
      );
      System.assertEquals(
        'CommonUtil.InsufficientAccessException',
        ex.getTypeName(),
        'InsufficientAccessException should be thrown'
      );
    }
    Test.stopTest();
  }
}

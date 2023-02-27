/**
 * @description Test class for {@link TextUtils}
 * @author Pavan Kumar Ananta
 * @since June 2020
 * @group Utils
 */
@isTest
public with sharing class TextUtilsTest {
  @isTest
  static void testMasking() {
    String inputData = 'A sample text with card 1234-5678-98 , second card 1234-5678-98 and a third 1234-5678 9876 card and a unmasked one too 1234567';
    System.assertEquals(
      'A sample text with card ******7898 , second card ******7898 and a third ********9876 card and a unmasked one too 1234567',
      TextUtils.maskData(inputData),
      'The data is masked correctly'
    );
  }

  @isTest
  static void testMaskingAnzx() {
    String inputData = 'A sample text with card 1234-5678-9812-1324 , second card 1234-5678-984567 and a third 1234-5678 9876 4567 card and a unmasked one too 12345 6789';
    System.assertEquals(
      'A sample text with card ************1324 , second card 1234-5678-984567 and a third ************4567 card and a unmasked one too 12345 6789',
      TextUtils.maskDataAnzx(inputData),
      'The data is masked correctly'
    );
  }

  @isTest
  static void testReactiveLogging() {
    String keywordStr = 'test TFN test 1234-678-90';
    System.assertEquals(
      true,
      TextUtils.reactiveLogging(keywordStr),
      'The reactiveLogging method should return true.'
    );
    String nonKeywordStr = 'test abc 1234-678-90';
    System.assertEquals(
      false,
      TextUtils.reactiveLogging(nonKeywordStr),
      'The reactiveLogging method should return false.'
    );
    String nonKeywordLongStr = 'test abc 1234-678-90-1234';
    System.assertEquals(
      true,
      TextUtils.reactiveLogging(nonKeywordLongStr),
      'The reactiveLogging method should return true.'
    );
  }

  @isTest
  static void testMaskSObjectData() {
    String inputData = 'A sample text with card 1234-5678-98 , second card 1234-5678-98 and a third 1234-5678 9876 card and a unmasked one too 1234567';
    String maskedData = TextUtils.maskData(inputData);
    List<Lead> records = new List<Lead>{
      new Lead(Description = inputData),
      new Lead(Description = inputData)
    };
    TextUtils.maskSObjectData(records, 'Description');
    for (Lead record : records) {
      System.assertEquals(
        maskedData,
        record.Description,
        'Description field from all lead records should be masked'
      );
    }
  }

  @isTest
  static void testRemoveNonAlphanumericChar() {
    String nonAlphanumericString = '0c3bde38-353f-4f86-99c6-873f86320c1b';
    System.assertEquals(
      '0c3bde38353f4f8699c6873f86320c1b',
      TextUtils.removeNonAlphanumericChar(nonAlphanumericString),
      'String should not contain non-alphanumeric characters.'
    );
  }

  @isTest
  static void testMaskAndLog() {
    String inputData = 'A sample text with TFN: 1234567890';
    String fieldName = 'Description';
    Case c = new Case(Description = inputData);
    Boolean isLoggingRequired = true;
    TextUtils.maskAndLog(inputData, fieldName, c, isLoggingRequired);
    System.assertEquals(
      'A sample text with TFN: ******7890',
      c.Description,
      'Description should be masked'
    );

    //Negative Test
    Case c2 = new Case(Description = 'Test happy 1234567980');
    TextUtils.maskAndLog(
      'Test happy 1234567980',
      fieldName,
      c2,
      isLoggingRequired
    );
    System.assertEquals(
      'Test happy 1234567980',
      c2.Description,
      'Description should not be masked'
    );
  }
}

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

  @isTest
  static void testSanitiseMobileNumber() {
    String input = '61123456789';
    String exceptedOutput = '61123456789';
    Assert.areEqual(
      exceptedOutput,
      TextUtils.sanitiseMobileNumber(input),
      'Sanitise Mobile Number ' + input + 'should be' + exceptedOutput
    );

    input = ' 61 123 456 789 ';
    Assert.areEqual(
      exceptedOutput,
      TextUtils.sanitiseMobileNumber(input),
      'Sanitise Mobile Number ' + input + 'should be' + exceptedOutput
    );

    input = '+61 123 456 789';
    Assert.areEqual(
      exceptedOutput,
      TextUtils.sanitiseMobileNumber(input),
      'Sanitise Mobile Number ' + input + 'should be' + exceptedOutput
    );

    input = '+61-123 456 789 ';
    Assert.areEqual(
      exceptedOutput,
      TextUtils.sanitiseMobileNumber(input),
      'Sanitise Mobile Number ' + input + 'should be' + exceptedOutput
    );
  }

  @IsTest
  static void testCardRelaxedMaskingRules() {
    String inputMoney = '$1234567890123456';
    String inputDateRange = '01-01-2020 01-02-2020';
    String inputNonCardNumber = '12#345678912&345';
    String inputMoneyDateBSB = '$123456 01/01/2024 014235 911111111';
    String inputCard14 = '12345678901234';
    String inputCard14Space = '1234 567890 1234';
    String inputCard14Hyphen = '1234-567890-1234';
    String inputCard15 = '123456789012345';
    String inputCard15Space = '1234 567890 12345';
    String inputCard15Hyphen = '1234-567890-12345';
    String inputCard16 = '1234567890123456';
    String inputCard16Space = '1234 5678 9012 3456';
    String inputCard16Hyphen = '1234-5678-9012-3456';

    Assert.areEqual(
      inputMoney,
      TextUtils.maskCC(inputMoney),
      'Money should not be masked'
    );
    Assert.areEqual(
      inputDateRange,
      TextUtils.maskCC(inputDateRange),
      'Date range should not be masked'
    );
    Assert.areEqual(
      inputNonCardNumber,
      TextUtils.maskCC(inputNonCardNumber),
      'Non-CC long number should not be masked'
    );
    Assert.areEqual(
      inputMoneyDateBSB,
      TextUtils.maskCC(inputMoneyDateBSB),
      'Combination of money, date, bsb, acc no. should not be masked'
    );
    Assert.areEqual(
      '**********1234',
      TextUtils.maskCC(inputCard14),
      'Diners Club 14-digit card should be masked'
    );
    Assert.areEqual(
      '**********1234',
      TextUtils.maskCC(inputCard14Space),
      'Diners Club 14-digit card should be masked'
    );
    Assert.areEqual(
      '**********1234',
      TextUtils.maskCC(inputCard14Hyphen),
      'Diners Club 14-digit card should be masked'
    );
    Assert.areEqual(
      '***********2345',
      TextUtils.maskCC(inputCard15),
      'Amex 15-digit card should be masked'
    );
    Assert.areEqual(
      '***********2345',
      TextUtils.maskCC(inputCard15Space),
      'Amex 15-digit card should be masked'
    );
    Assert.areEqual(
      '***********2345',
      TextUtils.maskCC(inputCard15Hyphen),
      'Amex 15-digit card should be masked'
    );
    Assert.areEqual(
      '************3456',
      TextUtils.maskCC(inputCard16),
      'Visa 16-digit card should be masked'
    );
    Assert.areEqual(
      '************3456',
      TextUtils.maskCC(inputCard16Space),
      'Visa 16-digit card should be masked'
    );
    Assert.areEqual(
      '************3456',
      TextUtils.maskCC(inputCard16Hyphen),
      'Visa 16-digit card should be masked'
    );
  }
}

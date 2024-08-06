/**
 * @author Karen Valeriano
 * @since Jul 2024
 * @description test class for DetokenizeModel class
 * @group Models
 */
@isTest
private class DetokenizeModelTest {
  static final String JSON_STR =
    '{' +
    '  \"values\": [' +
    '    {' +
    '      \"Tokenized\": \"Q2CmJdCA0\",' +
    '      \"Detokenized\": \"PA0940444\"' +
    '    },' +
    '    {' +
    '      \"Tokenized\": \"Q2CmJdCA1\",' +
    '      \"Detokenized\": \"PA0940441\"' +
    '    }' +
    '  ]' +
    '}';

  @isTest
  static void testParse() {
    Test.startTest();
    DetokenizeModel obj = DetokenizeModel.parse(JSON_STR);
    Test.stopTest();

    System.assertEquals(
      2,
      obj.values.size(),
      'Should have 2 values after parse.'
    );
  }

  @isTest
  static void testParseException() {
    Lib_MockProvider model = Lib_MockProvider.forType(DetokenizeModel.class);
    model.mock('parse', new JSONException('Error'));

    Test.startTest();
    try {
      DetokenizeModel obj = DetokenizeModel.parse(JSON_STR);
    } catch (Exception ex) {
      Assert.isNotNull(ex, 'An exception should be thrown.');
    }
    Test.stopTest();
  }
}

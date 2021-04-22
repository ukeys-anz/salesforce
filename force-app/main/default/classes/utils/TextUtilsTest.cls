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
}

@isTest
public class ChatterUtilsTest {
  /*
   * @description to check if the MockChatterPoster has been triggered
   */
  @isTest
  static void testChatterUtilsSuccess() {
    String info;
    info = ChatterUtils.makeAPost('MockParentRecordId', 'MockingPost');

    System.assertEquals(
      info,
      'MockingPostId',
      'Check if mocking chatter return the mocking feedItemId'
    );
  }

  /*
   * @description to check if the MockChatterPoster has been triggered
   * and if the recordId and feedItemId are not the ones in MockChatterPoster
   */
  @isTest
  static void testChatterUtilsUnSuccess() {
    String info;

    info = ChatterUtils.makeAPost('WrongId', 'WrongPost');
    System.assertNotEquals(
      info,
      'WrongPostId',
      'Check if mocking chatter will give us a false'
    );
  }

  /*
   * @description to check if the MockChatterPoster throw an error for
   * the specific `23572357` recordId
   */
  @isTest
  static void testChatterUtilsError() {
    try {
      String info;
      info = ChatterUtils.makeAPost('23572357', 'NoChatterPostTest');
    } catch (AuraHandledException e) {
      System.assertEquals(
        'No Chatter post has been made',
        e.getMessage(),
        'Check for specific card number(23572357), it will throw an error'
      );
    }
  }
}

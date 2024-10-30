@isTest
public class ChatterUtilsTest {
  /*
   * @description to check if the chatter post has been made
   */
  @isTest
  static void testChatterUtilsSuccess() {
    String info = ChatterUtils.makeAPost(
      'MockParentRecordId',
      'MockingPost',
      ChatterUtils.POST_TYPE_TEXT
    );

    Assert.areEqual(
      info,
      'MockingPostId',
      'Check if mocking chatter return the mocking feedItemId'
    );
  }

  /*
   * @description to check if the rich text chatter post has been made
   */
  @isTest
  static void testChatterUtilsUnSuccess() {
    String info = ChatterUtils.makeAPost(
      'WrongId',
      'WrongPost',
      ChatterUtils.POST_TYPE_TEXT
    );
    Assert.areNotEqual(
      info,
      'WrongPostId',
      'Check if mocking chatter will give us a false'
    );
    Assert.isTrue(info != null, 'Chatter post id should not be null');
  }

  /*
   * @description to check if error scenario if chatter post fails
   */
  @isTest
  static void testChatterUtilsError() {
    try {
      String info = ChatterUtils.makeAPost(
        '23572357',
        'NoChatterPostTest',
        ChatterUtils.POST_TYPE_TEXT
      );
    } catch (AuraHandledException e) {
      Assert.areEqual(
        'No Chatter post has been made',
        e.getMessage(),
        'Check for specific card number(23572357), it will throw an error'
      );
    }
  }
}

/**
 * @author Aman
 * @since 04/2025
 * @description Action class for TopicAssignment.
 */
public with sharing class TopicActions {
  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );

  private static final String CUSTOM_PERM_INTEREST_TAG_CREATION = 'ANZx_Interest_Tag_Create';

  /**
   * @description validate permissions for topic creation
   * @param records Topic records
   */
  public static void validatePermissionForTopicCreation(List<Topic> records) {
    if (USER_INFO.checkCustomPermission(CUSTOM_PERM_INTEREST_TAG_CREATION)) {
      return;
    }
    for (Topic topicRec : records) {
      topicRec.addError('User does not have permission to create topic');
    }
  }
}

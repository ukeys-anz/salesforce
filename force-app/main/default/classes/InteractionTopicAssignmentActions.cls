/**
 * @author Hrushikesh
 * @since 14/2025
 * @description Action class for TopicAssignment.
 */
public with sharing class InteractionTopicAssignmentActions {
  private static final String RESTRICT_INTEREST_TAG_DELETION_ERROR_MESSAGE = 'Read Only user does not have permission to delete interest tags';

  private static final InteractionInterestTagRepository INTERACTION_INTEREST_TAG_REPOSITORY = (InteractionInterestTagRepository) Lib_InstanceProvider.forType(
    InteractionInterestTagRepository.class
  );

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );

  /**
   * @description validate tag categories are valid for interest tags
   * @param records topic assignment records
   */
  public static void tagCategoryValidation(List<TopicAssignment> records) {
    Set<Id> interactionIds = ListUtil.getIds(records, TopicAssignment.EntityId);

    Map<Id, interaction> eligibleInteractionRecords = new Map<Id, Interaction>(
      INTERACTION_INTEREST_TAG_REPOSITORY.getInteractionByIds(interactionIds)
    );

    InteractionTopicAssignmentActionsHelper.validateTagCategory(
      records,
      eligibleInteractionRecords
    );
  }

  /**
   * @description validate tag count
   * @param records topic assignment records
   */
  public static void validateTagCount(List<TopicAssignment> records) {
    Set<Id> interactionIds = ListUtil.getIds(records, TopicAssignment.EntityId);

    List<TopicAssignment> topicAssignments = INTERACTION_INTEREST_TAG_REPOSITORY.getTopicAssignments(
      interactionIds
    );

    Map<Id, List<TopicAssignment>> interactionsTopicAssignments = InteractionTopicAssignmentActionsHelper.getInteractionsTopicAssignments(
      topicAssignments
    );

    Set<Id> invalidInteractionIds = InteractionTopicAssignmentActionsHelper.getInvalidInteractionIds(
      interactionsTopicAssignments
    );

    InteractionTopicAssignmentActionsHelper.validateTagCount(
      records,
      invalidInteractionIds
    );
  }

  /**
   * @description update interaction record based on topic assignment
   * @param records topic assignment records
   */
  public static void populateFieldOnInteraction(List<TopicAssignment> records) {
    try {
      Set<Id> interactionIds = InteractionTopicAssignmentActionsHelper.getValidInteractionIds(
        records
      );

      List<Interaction> interactions = INTERACTION_INTEREST_TAG_REPOSITORY.getInteractionByIds(
        interactionIds
      );

      List<TopicAssignment> topicAssignments = INTERACTION_INTEREST_TAG_REPOSITORY.getTopicAssignments(
        interactionIds
      );

      Map<Id, List<TopicAssignment>> interactionsTopicAssignments = InteractionTopicAssignmentActionsHelper.getInteractionsTopicAssignments(
        topicAssignments
      );

      InteractionTopicAssignmentActionsHelper.updateFieldsOnInteraction(
        interactions,
        interactionsTopicAssignments
      );

      DML_REPOSITORY.doUpdate(interactions, new DmlConfig().allowPartial());
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    }
  }

  /**
   * @description restricts deletion of inetrest tags if custom permission is assigned
   * @param topicAssignmentRecords topic assignment records
   */
  public static void restrictInterestTagDeletion(
    List<TopicAssignment> topicAssignmentRecords
  ) {
    if (
      !USER_INFO.checkCustomPermission('ANZx_Restrict_Interest_Tag_Deletetion')
    ) {
      return;
    }
    for (TopicAssignment record : topicAssignmentRecords) {
      record.addError(RESTRICT_INTEREST_TAG_DELETION_ERROR_MESSAGE);
    }
  }
}

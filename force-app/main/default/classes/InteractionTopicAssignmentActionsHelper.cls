/**
 * @author Hrushikesh
 * @since 14/2025
 * @description helper class for InteractionTopicAssignmentActions.
 */
public with sharing class InteractionTopicAssignmentActionsHelper {
  public static final String REASON_FOR_VISIT = 'Reason for visit';
  private static final String ACTUAL_TOPIC = 'Actual Topic';
  private static final String PRODUCT = 'Product';
  private static final String INVALID_TAG_CATEGORY_MESSAGE = 'You can not add Interest Tag with tag category as';
  private static final String MAX_TAG_CATEGORY_ERROR = 'Maximum of 5 Integrest Tags are allowed on interaction per category.';
  private static final Integer MAX_TAGS_PER_TAG_CATEGORY = 5;

  /**
   * @description validate tag category if tag ctaegory is in allowed category
   * @param records topic assignments
   * @param interactionsMap interactions map
   */
  public static void validateTagCategory(
    List<TopicAssignment> records,
    Map<Id, interaction> interactionsMap
  ) {
    for (TopicAssignment record : records) {
      Id tagCategoryId = QueryTagCategoryAssignment.getByTagId(record.TopicId)
        .TagCategoryId;
      String tagCategory = QueryTagCategory.getById(tagCategoryId).Name;
      if (String.isBlank(tagCategory)) {
        continue;
      }
      Id interactionRTId = interactionsMap.get(record.EntityId).RecordTypeId;
      String recordTypeDevName = RTInteraction.getDeveloperName(
        interactionRTId
      );
      if (
        !QueryTagCategoryValidation.getByRecordType(recordTypeDevName)
          .contains(tagCategory)
      ) {
        record.addError(INVALID_TAG_CATEGORY_MESSAGE + ' ' + tagCategory);
        Logger.info(
          INVALID_TAG_CATEGORY_MESSAGE +
            ' ' +
            tagCategory +
            ' on ' +
            record.EntityId
        );
      }
    }
    Logger.saveLog();
  }

  /**
   * @description get interaction ids whose tag category matches with reason for visit, product or actual topic
   * @param topicAssignments topic assignments
   * @return `interactionIds` interaction ids
   */
  public static Set<Id> getValidInteractionIds(
    List<TopicAssignment> topicAssignments
  ) {
    Set<Id> interactionIds = new Set<Id>();
    Set<String> validTagCategories = new Set<String>{
      REASON_FOR_VISIT,
      ACTUAL_TOPIC,
      PRODUCT
    };
    for (TopicAssignment record : topicAssignments) {
      Id tagCategoryId = QueryTagCategoryAssignment.getByTagId(record.TopicId)
        .TagCategoryId;
      String topicCategory = QueryTagCategory.getById(tagCategoryId).Name;
      if (validTagCategories.contains(topicCategory)) {
        interactionIds.add(record.EntityId);
      }
    }
    return interactionIds;
  }

  /**
   * @description getInteractionsTopicAssignments returns map of interaction id to related topic assignments
   * @param topicAssingments topic assignments
   * @return `interactionTopicAssignments` returns map of interaction id to related topic assignments
   */
  public static Map<Id, List<TopicAssignment>> getInteractionsTopicAssignments(
    List<TopicAssignment> topicAssingments
  ) {
    Map<Id, List<TopicAssignment>> interactionTopicAssignments = new Map<Id, List<TopicAssignment>>();
    for (TopicAssignment record : topicAssingments) {
      if (interactionTopicAssignments.containsKey(record.EntityId) == false) {
        interactionTopicAssignments.put(
          record.EntityId,
          new List<TopicAssignment>()
        );
      }
      interactionTopicAssignments.get(record.EntityId).add(record);
    }
    return interactionTopicAssignments;
  }

  /**
   * @description updateFieldsOnInteraction adds semicolan seperated value of on interaction fields
   * @param interactions list of interactions
   * @param interactionsTopicAssignments map of interaction id to related topic assignments
   */
  public static void updateFieldsOnInteraction(
    List<Interaction> interactions,
    Map<Id, List<TopicAssignment>> interactionsTopicAssignments
  ) {
    for (Interaction record : interactions) {
      if (!interactionsTopicAssignments.containsKey(record.Id)) {
        record.Actual_Topic__c = null;
        record.Products__c = null;
        record.Reason_For_Visit__c = null;
        continue;
      }
      List<TopicAssignment> actualTopicAssignments = getFilteredTopicAssignment(
        interactionsTopicAssignments.get(record.Id),
        ACTUAL_TOPIC
      );
      List<TopicAssignment> reasonForVisitTopicAssignments = getFilteredTopicAssignment(
        interactionsTopicAssignments.get(record.Id),
        REASON_FOR_VISIT
      );
      List<TopicAssignment> productTopicAssignments = getFilteredTopicAssignment(
        interactionsTopicAssignments.get(record.Id),
        PRODUCT
      );

      record.Actual_Topic__c = getSemicolonSeparatedValue(
        actualTopicAssignments
      );

      record.Reason_For_Visit__c = getSemicolonSeparatedValue(
        reasonForVisitTopicAssignments
      );

      record.Products__c = getSemicolonSeparatedValue(productTopicAssignments);
    }
  }

  /**
   * @description getSemicolonSeparatedValue provides semicolan separated value of tag names
   * @param topicAssignments topic assignments
   * @return String
   */
  private static String getSemicolonSeparatedValue(
    List<TopicAssignment> topicAssignments
  ) {
    List<String> topicsList = new List<String>();
    for (TopicAssignment topicAssignment : topicAssignments) {
      topicsList.add(topicAssignment.Topic.Name);
    }
    return String.join(topicsList, ';');
  }

  /**
   * @description getFilteredTopicAssignment filter topic based on tag category
   * @param topicAssignments topic assignments
   * @param tagCategory ltag category
   * @return `filteredTopicAssignment`
   */
  private static List<TopicAssignment> getFilteredTopicAssignment(
    List<TopicAssignment> topicAssignments,
    String tagCategory
  ) {
    List<TopicAssignment> filteredTopicAssignment = new List<TopicAssignment>();
    for (TopicAssignment record : topicAssignments) {
      Id tagCategoryId = QueryTagCategoryAssignment.getByTagId(record.TopicId)
        .TagCategoryId;
      String actualTagCategory = QueryTagCategory.getById(tagCategoryId).Name;
      if (actualTagCategory == tagCategory) {
        filteredTopicAssignment.add(record);
      }
    }
    return filteredTopicAssignment;
  }

  /**
   * @description getInvalidInteractionIds getInteractionIds which have more than 5 tags per category
   * @param interactionsTopicAssignments interactions to all topic assignment
   * @return invalid interaction ids
   */
  public static Set<Id> getInvalidInteractionIds(
    Map<Id, List<TopicAssignment>> interactionsTopicAssignments
  ) {
    Set<Id> invalidInteractionIds = new Set<Id>();
    for (Id recordId : interactionsTopicAssignments.keySet()) {
      List<TopicAssignment> allTopicAssignment = interactionsTopicAssignments.get(
        recordId
      );
      List<TopicAssignment> actualTopicAssignments = getFilteredTopicAssignment(
        allTopicAssignment,
        ACTUAL_TOPIC
      );
      List<TopicAssignment> reasonForVisitTopicAssignments = getFilteredTopicAssignment(
        allTopicAssignment,
        REASON_FOR_VISIT
      );
      List<TopicAssignment> productTopicAssignments = getFilteredTopicAssignment(
        allTopicAssignment,
        PRODUCT
      );
      if (
        actualTopicAssignments.size() > MAX_TAGS_PER_TAG_CATEGORY ||
        reasonForVisitTopicAssignments.size() > MAX_TAGS_PER_TAG_CATEGORY ||
        productTopicAssignments.size() > MAX_TAGS_PER_TAG_CATEGORY
      ) {
        inValidInteractionIds.add(recordId);
      }
    }
    return invalidInteractionIds;
  }

  /**
   * @description getInvalidInteractionIds getInteractionIds which have more than 5 tags per category
   * @param topicAssignments topic assignments
   * @param invalidInteractionIds invalid interaction ids
   */
  public static void validateTagCount(
    List<TopicAssignment> topicAssignments,
    Set<Id> invalidInteractionIds
  ) {
    List<TopicAssignment> invalidTopicAssignment = ListUtil.filter(
        topicAssignments
      )
      .anyEqual(
        new Set<SObjectField>{ TopicAssignment.EntityId },
        invalidInteractionIds
      )
      .toList();
    for (TopicAssignment record : invalidTopicAssignment) {
      record.addError(MAX_TAG_CATEGORY_ERROR);
    }
  }
}

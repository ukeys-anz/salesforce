/**
 * @author Hrushikesh
 * @since 14/2025
 * @description Test class for InteractionTopicAssignmentActions.
 */
@isTest
public with sharing class InteractionTopicAssignmentActionsTest {
  static Lib_MockProvider interactionIntegrestTagRepo;
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider userMock;

  private static final Id CALL_INTERACTION_ID = Lib_FakeIdGenerator.getMockId(
    Interaction.getSObjectType()
  );
  private static final Id MESSAGE_INTERACTION_ID = Lib_FakeIdGenerator.getMockId(
    Interaction.getSObjectType()
  );
  private static final Id STORE_INTERACTION_ID = Lib_FakeIdGenerator.getMockId(
    Interaction.getSObjectType()
  );
  private static final Id CARDS_TOPIC_ID = Lib_FakeIdGenerator.getMockId(
    Topic.getSObjectType()
  );
  private static final Id ANZ_PLUS_TOPIC_ID = Lib_FakeIdGenerator.getMockId(
    Topic.getSObjectType()
  );
  private static final Id ANZ_VISIT_TOPIC_ID = Lib_FakeIdGenerator.getMockId(
    Topic.getSObjectType()
  );
  private static final Id COACHING_TOPIC_ID = Lib_FakeIdGenerator.getMockId(
    Topic.getSObjectType()
  );
  private static final Id ANZ_SAVE_TOPIC_ID = Lib_FakeIdGenerator.getMockId(
    Topic.getSObjectType()
  );
  private static final Id ONE_TO_ONE_APPT_TOPIC_ID = Lib_FakeIdGenerator.getMockId(
    Topic.getSObjectType()
  );

  static void registerMocks() {
    interactionIntegrestTagRepo = Lib_MockProvider.forType(
      InteractionInterestTagRepository.class
    );
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    userMock = Lib_MockProvider.forType(UserInfoRepository.class)
      .mock('checkCustomPermission', true);
  }

  private static List<Interaction> getTestInteractions() {
    List<Interaction> interactionList = new List<Interaction>();
    Interaction callInteraction = new Interaction();
    callInteraction.RecordTypeId = QueryRT.of(Interaction.SObjectType)
      .getId('General');
    callInteraction.Name = 'Test Interaction';
    callInteraction.Actual_Topic__c = null;
    callInteraction.Reason_For_Visit__c = null;
    callInteraction.Products__c = null;
    callInteraction.Id = CALL_INTERACTION_ID;
    callInteraction.RecordType = new RecordType(
      DeveloperName = 'General',
      Id = QueryRT.of(Interaction.SObjectType).getId('General')
    );
    interactionList.add(callInteraction);

    Interaction messageInteraction = new Interaction();
    messageInteraction.RecordTypeId = QueryRT.of(Interaction.SObjectType)
      .getId('Message');
    messageInteraction.Name = 'Test Interaction';
    messageInteraction.Actual_Topic__c = null;
    messageInteraction.Reason_For_Visit__c = null;
    messageInteraction.Products__c = null;
    messageInteraction.Id = MESSAGE_INTERACTION_ID;
    messageInteraction.RecordType = new RecordType(
      DeveloperName = 'Message',
      Id = QueryRT.of(Interaction.SObjectType).getId('Message')
    );
    interactionList.add(messageInteraction);

    Interaction storeInteraction = new Interaction();
    storeInteraction.RecordTypeId = QueryRT.of(Interaction.SObjectType)
      .getId('Store');
    storeInteraction.Name = 'Test Interaction';
    storeInteraction.Actual_Topic__c = null;
    storeInteraction.Reason_For_Visit__c = null;
    storeInteraction.Products__c = null;
    storeInteraction.Id = STORE_INTERACTION_ID;
    storeInteraction.RecordType = new RecordType(
      DeveloperName = 'Store',
      Id = QueryRT.of(Interaction.SObjectType).getId('Store')
    );
    interactionList.add(storeInteraction);

    return interactionList;
  }

  private static Map<Id, String> getTestTagToTagCategoriesMap() {
    Map<Id, String> tagToTagCategoriesMap = new Map<Id, String>();
    tagToTagCategoriesMap.put(CARDS_TOPIC_ID, 'Actual Topic');
    tagToTagCategoriesMap.put(ANZ_PLUS_TOPIC_ID, 'Product');
    tagToTagCategoriesMap.put(ANZ_VISIT_TOPIC_ID, 'Reason for visit');
    return tagToTagCategoriesMap;
  }

  private static Map<Id, String> getTagToTagCategorySameCategoryMap() {
    Map<Id, String> tagToTagCategoriesMap = new Map<Id, String>();
    tagToTagCategoriesMap.put(CARDS_TOPIC_ID, 'Actual Topic');
    tagToTagCategoriesMap.put(ANZ_PLUS_TOPIC_ID, 'Actual Topic');
    tagToTagCategoriesMap.put(ANZ_VISIT_TOPIC_ID, 'Actual Topic');
    tagToTagCategoriesMap.put(COACHING_TOPIC_ID, 'Actual Topic');
    tagToTagCategoriesMap.put(ONE_TO_ONE_APPT_TOPIC_ID, 'Actual Topic');
    tagToTagCategoriesMap.put(ANZ_SAVE_TOPIC_ID, 'Actual Topic');
    return tagToTagCategoriesMap;
  }

  private static List<TopicAssignment> getTestTopicAssignments() {
    List<TopicAssignment> topicAssignments = new List<TopicAssignment>();
    TopicAssignment cardsTopicAssignment = new TopicAssignment();
    cardsTopicAssignment.TopicId = CARDS_TOPIC_ID;
    cardsTopicAssignment.EntityId = MESSAGE_INTERACTION_ID;
    cardsTopicAssignment.Topic = new Topic(Name = 'Cards');
    topicAssignments.add(cardsTopicAssignment);

    TopicAssignment anzPlusTopicAssignment = new TopicAssignment();
    anzPlusTopicAssignment.TopicId = ANZ_PLUS_TOPIC_ID;
    anzPlusTopicAssignment.EntityId = CALL_INTERACTION_ID;
    anzPlusTopicAssignment.Topic = new Topic(Name = 'ANZ Plus');
    topicAssignments.add(anzPlusTopicAssignment);

    TopicAssignment anzVisitTopicAssignment = new TopicAssignment();
    anzVisitTopicAssignment.TopicId = ANZ_VISIT_TOPIC_ID;
    anzVisitTopicAssignment.EntityId = STORE_INTERACTION_ID;
    anzVisitTopicAssignment.Topic = new Topic(Name = 'ANZ Visit');
    topicAssignments.add(anzVisitTopicAssignment);

    return topicAssignments;
  }

  private static List<TopicAssignment> getInvalidTopicAssignments() {
    List<TopicAssignment> topicAssignments = new List<TopicAssignment>();
    TopicAssignment anzVisitTopicAssignment = new TopicAssignment();
    anzVisitTopicAssignment.TopicId = ANZ_VISIT_TOPIC_ID;
    anzVisitTopicAssignment.EntityId = CALL_INTERACTION_ID;
    topicAssignments.add(anzVisitTopicAssignment);

    TopicAssignment anzVisitTopicAssignment1 = new TopicAssignment();
    anzVisitTopicAssignment1.TopicId = ANZ_VISIT_TOPIC_ID;
    anzVisitTopicAssignment1.EntityId = MESSAGE_INTERACTION_ID;
    topicAssignments.add(anzVisitTopicAssignment1);

    return topicAssignments;
  }

  private static List<TopicAssignment> getSameCategoryTopicAssignments() {
    List<TopicAssignment> topicAssignments = new List<TopicAssignment>();
    TopicAssignment cardsTopicAssignment = new TopicAssignment();
    cardsTopicAssignment.TopicId = CARDS_TOPIC_ID;
    cardsTopicAssignment.EntityId = MESSAGE_INTERACTION_ID;
    topicAssignments.add(cardsTopicAssignment);

    TopicAssignment anzPlusTopicAssignment = new TopicAssignment();
    anzPlusTopicAssignment.TopicId = ANZ_PLUS_TOPIC_ID;
    anzPlusTopicAssignment.EntityId = MESSAGE_INTERACTION_ID;
    topicAssignments.add(anzPlusTopicAssignment);

    TopicAssignment anzSaveTopicAssignment = new TopicAssignment();
    anzSaveTopicAssignment.TopicId = ANZ_SAVE_TOPIC_ID;
    anzSaveTopicAssignment.EntityId = MESSAGE_INTERACTION_ID;
    topicAssignments.add(anzSaveTopicAssignment);

    TopicAssignment anzVisitTopicAssignment = new TopicAssignment();
    anzVisitTopicAssignment.TopicId = ANZ_VISIT_TOPIC_ID;
    anzVisitTopicAssignment.EntityId = MESSAGE_INTERACTION_ID;
    topicAssignments.add(anzVisitTopicAssignment);

    TopicAssignment oneToOneTopicAssignment = new TopicAssignment();
    oneToOneTopicAssignment.TopicId = ONE_TO_ONE_APPT_TOPIC_ID;
    oneToOneTopicAssignment.EntityId = MESSAGE_INTERACTION_ID;
    topicAssignments.add(oneToOneTopicAssignment);

    TopicAssignment coachingTopicAssignment = new TopicAssignment();
    coachingTopicAssignment.TopicId = COACHING_TOPIC_ID;
    coachingTopicAssignment.EntityId = MESSAGE_INTERACTION_ID;
    topicAssignments.add(coachingTopicAssignment);
    return topicAssignments;
  }

  @isTest
  private static void testValidateTagCategory() {
    registerMocks();
    interactionIntegrestTagRepo.mock(
      'getInteractionByIds',
      getTestInteractions()
    );

    List<TopicAssignment> records = getTestTopicAssignments();
    QueryTagCategoryAssignment.tagToTagCategoryMap = getTestTagToTagCategoriesMap();
    Test.startTest();
    InteractionTopicAssignmentActions.tagCategoryValidation(records);
    Test.stopTest();

    for (TopicAssignment record : records) {
      Assert.isFalse(
        record.hasErrors(),
        'Topic Assignment should have created with no errors'
      );
    }
  }

  @isTest
  private static void testNegativeValidateTagCategory() {
    registerMocks();
    interactionIntegrestTagRepo.mock(
      'getInteractionByIds',
      getTestInteractions()
    );

    List<TopicAssignment> records = getInvalidTopicAssignments();
    QueryTagCategoryAssignment.tagToTagCategoryMap = getTestTagToTagCategoriesMap();
    Test.startTest();
    InteractionTopicAssignmentActions.tagCategoryValidation(records);
    Test.stopTest();

    for (TopicAssignment record : records) {
      Assert.isTrue(
        record.hasErrors(),
        'Call and Message Interaction can not have topic with category as Reason for visit'
      );
      Assert.isTrue(
        record.getErrors()[0]
          .getMessage()
          .contains(
            'You can not add Interest Tag with tag category as Reason for visit'
          ),
        'Error message shoud be You can not add Interest Tag with tag category as Reason for visit'
      );
    }
  }

  @isTest
  private static void testTagCategoryCount() {
    registerMocks();
    interactionIntegrestTagRepo.mock(
      'getTopicAssignments',
      getSameCategoryTopicAssignments()
    );

    List<TopicAssignment> records = getSameCategoryTopicAssignments();
    QueryTagCategoryAssignment.tagToTagCategoryMap = getTagToTagCategorySameCategoryMap();
    Test.startTest();
    InteractionTopicAssignmentActions.validateTagCount(records);
    Test.stopTest();
    for (TopicAssignment record : records) {
      Assert.isTrue(
        record.hasErrors(),
        'Maximum of 5 interest tag categories are allwed on Interaction'
      );
    }
  }

  @isTest
  private static void testPopulateFieldsOnInteraction() {
    registerMocks();
    interactionIntegrestTagRepo.mock(
      'getInteractionByIds',
      getTestInteractions()
    );
    interactionIntegrestTagRepo.mock(
      'getTopicAssignments',
      getTestTopicAssignments()
    );

    List<TopicAssignment> records = getTestTopicAssignments();
    QueryTagCategoryAssignment.tagToTagCategoryMap = getTestTagToTagCategoriesMap();
    Test.startTest();
    InteractionTopicAssignmentActions.populateFieldOnInteraction(records);
    Test.stopTest();
    List<Interaction> interactionRecords = (List<Interaction>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');
    for (Interaction record : interactionRecords) {
      if (record.Id == MESSAGE_INTERACTION_ID) {
        Assert.areEqual(
          record.Actual_Topic__c,
          'Cards',
          'Actual Topic value should be cards'
        );
      }
      if (record.Id == CALL_INTERACTION_ID) {
        Assert.areEqual(
          record.Products__c,
          'ANZ Plus',
          'Products value should be ANZ Plus'
        );
      }
      if (record.Id == STORE_INTERACTION_ID) {
        Assert.areEqual(
          record.Reason_For_Visit__c,
          'ANZ Visit',
          'Reason For Visit value should be ANZ Visit'
        );
      }
    }
  }

  @isTest
  private static void testRestrictTopicAssignmentDeletion() {
    Test.startTest();
    registerMocks();
    List<TopicAssignment> records = getTestTopicAssignments();
    InteractionTopicAssignmentActions.restrictInterestTagDeletion(records);
    Test.stopTest();
    for (TopicAssignment record : records) {
      Assert.isTrue(record.hasErrors(), 'Topic Assignment should have error');
    }
  }
}

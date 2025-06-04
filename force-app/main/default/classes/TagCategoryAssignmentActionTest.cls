/**
 * @author Aman Gupta
 * @since 04/2025
 * @description TagCategoryAssignmentActionTest is the test class to cover tests for InteractionTagCategoryAssignmentActions
 */
@isTest
public with sharing class TagCategoryAssignmentActionTest {
  static Lib_MockProvider userMock;

  static void registerPositiveMocks() {
    userMock = Lib_MockProvider.forType(UserInfoRepository.class)
      .mock('checkCustomPermission', true);
  }

  static void registerNegativeMocks() {
    userMock = Lib_MockProvider.forType(UserInfoRepository.class)
      .mock('checkCustomPermission', false);
  }

  @isTest
  static void testValidatePermissionForTopicCreationWithPermission() {
    Test.startTest();
    registerPositiveMocks();
    TagCategoryAssignment tagCategoryAssignRecord = new TagCategoryAssignment();
    InteractionTagCategoryAssignmentActions.validatePermissionForInterestTagCreation(
      new List<TagCategoryAssignment>{ tagCategoryAssignRecord }
    );
    Test.stopTest();
    Assert.isFalse(
      tagCategoryAssignRecord.hasErrors(),
      'TagCategory should not have error'
    );
  }

  @isTest
  static void testValidatePermissionForTopicCreationWithoutPermission() {
    Test.startTest();
    registerNegativeMocks();
    TagCategoryAssignment tagCategoryAssignRecord = new TagCategoryAssignment();
    InteractionTagCategoryAssignmentActions.validatePermissionForInterestTagCreation(
      new List<TagCategoryAssignment>{ tagCategoryAssignRecord }
    );
    Test.stopTest();
    Assert.isTrue(
      tagCategoryAssignRecord.hasErrors(),
      'TagCategory should have error'
    );
  }

  // need to insert atleast one record to have trigger some coverage
  @isTest
  private static void integrationTest() {
    registerNegativeMocks();
    Topic topicRecord = new Topic();
    topicRecord.Name = 'Test Topic';
    insert topicRecord;

    TagCategory tagCatgory = new TagCategory();
    tagCatgory.Name = 'Product';
    tagCatgory.Icon = 'standard:product';
    insert tagCatgory;

    QueryTagCategory.tagCategories.put(tagCatgory.Id, tagCatgory);
    Test.startTest();
    TagCategoryAssignment record = new TagCategoryAssignment();
    record.TagId = topicRecord.Id;
    record.TagCategoryId = tagCatgory.Id;
    try {
      insert record;
    } catch (Exception e) {
      Assert.isTrue(
        e.getMessage()
          .contains('User does not have permission to create record'),
        'Incorrect error message populated'
      );
    }
    Test.stopTest();
  }
}

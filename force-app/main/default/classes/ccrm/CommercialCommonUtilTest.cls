/**
 * @author       : Naman Garg
 * @since        : Nov 2024
 * @description  : Common logic for Commercials
 **/

@isTest
public class CommercialCommonUtilTest {
  @isTest
  static void testGetRichTextFields() {
    //GIVEN Map of Rich text Field
    Set<SObjectField> richTextFieldSet = new Set<SObjectField>();
    List<SobjectField> fieldList = new List<SObjectField>{
      A_Z_Review__c.Business_Details__c
    };

    //WHEN calling a getRichTextFields method
    Test.startTest();
    richTextFieldSet = CommercialCommonUtil.getRichTextFields(fieldList);
    Test.stopTest();

    //THEN it should store 1 rich text field in set
    Assert.areEqual(
      1,
      richTextFieldSet.size(),
      'Should able to find 1 rich text field'
    );
  }

  @isTest
  static void testGetRichTextFieldsNegative() {
    //GIVEN Map of Text Field
    Set<SObjectField> richTextFieldSet = new Set<SObjectField>();
    List<SobjectField> fieldList = new List<SObjectField>{
      A_Z_Review__c.Status__c
    };

    //WHEN calling a getRichTextFields method
    Test.startTest();
    richTextFieldSet = CommercialCommonUtil.getRichTextFields(fieldList);
    Test.stopTest();

    //THEN it should not able to fetch any rich text field
    Assert.areEqual(
      0,
      richTextFieldSet.size(),
      'Should not able to find any rich text field'
    );
  }

  @isTest
  static void testRestrictImagesOnInsert() {
    //GIVEN Rich Text field set and List of Record
    Id azReviewId = Lib_FakeIdGenerator.getMockId(A_Z_Review__c.SObjectType);
    Set<SObjectField> richTextFieldSet = new Set<SObjectField>{
      A_Z_Review__c.Business_Details__c,
      A_Z_Review__c.Personal_Banking__c
    };
    List<A_Z_Review__c> azReviewList = new List<A_Z_Review__c>{
      new A_Z_Review__c(Id = azReviewId, Business_Details__c = null)
    };

    //WHEN calling a restrictImages method
    Test.startTest();
    CommercialCommonUtil.restrictImages(azReviewList, null, richTextFieldSet);
    Test.stopTest();

    //THEN it shouldn't throw any error
    Assert.isFalse(
      azReviewList[0].hasErrors(),
      'Error while inserting record with Image.'
    );
  }

  @isTest
  static void testRestrictImagesOnUpdate() {
    //GIVEN Rich Text field set, List of Record and old Map
    Id azReviewId = Lib_FakeIdGenerator.getMockId(A_Z_Review__c.SObjectType);
    Set<SObjectField> richTextFieldSet = new Set<SObjectField>{
      A_Z_Review__c.Business_Details__c,
      A_Z_Review__c.Personal_Banking__c
    };
    List<A_Z_Review__c> azReviewList = new List<A_Z_Review__c>{
      new A_Z_Review__c(
        Id = azReviewId,
        Business_Details__c = null,
        Personal_Banking__c = null
      )
    };
    Map<Id, A_Z_Review__c> oldMap = new Map<Id, A_Z_Review__c>{
      azReviewId => new A_Z_Review__c(
        Id = azReviewId,
        Business_Details__c = 'Sample Banking Details',
        Personal_Banking__c = 'Sample Personal Details'
      )
    };

    //WHEN calling a restrictImages method
    Test.startTest();
    CommercialCommonUtil.restrictImages(azReviewList, oldMap, richTextFieldSet);
    Test.stopTest();

    //THEN it shouldn't throw any error
    Assert.isFalse(azReviewList[0].hasErrors(), 'Error while updating record.');
  }
}

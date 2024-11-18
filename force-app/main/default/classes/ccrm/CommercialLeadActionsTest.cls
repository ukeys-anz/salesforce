/**
 * @author       : Naman Garg
 * @since        : Nov 2024
 * @description  : Test class for CommercialLeadActions
 **/

@isTest
public class CommercialLeadActionsTest {
  @isTest
  static void testRestrictImagesInRichTextFields() {
    //GIVEN List of lead Record
    List<Lead> leadList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        RecordTypeId = RTLead.commercialLead
      )
    };

    //WHEN calling a restrictImagesInRichTextFields method
    Test.startTest();
    CommercialLeadActions.restrictImagesInRichTextFields(leadList, null);
    Test.stopTest();

    //THEN it shouldn't throw any error
    Assert.isFalse(
      leadList[0].hasErrors(),
      'Error while inserting Lead record with Image.'
    );
  }
}

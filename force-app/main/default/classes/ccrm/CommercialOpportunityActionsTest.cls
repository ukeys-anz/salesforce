/**
 * @author       : Naman Garg
 * @since        : Nov 2024
 * @description  : Test class for CommercialOpportunityActions
 **/

@isTest
public class CommercialOpportunityActionsTest {
  @isTest
  static void testRestrictImagesInRichTextFields() {
    //GIVEN List of Opportunity Record
    List<Opportunity> opportunityList = new List<Opportunity>{
      new Opportunity(
        Id = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType),
        Name = 'Sample Opportunity'
      )
    };

    //WHEN calling a restrictImagesInRichTextFields method
    Test.startTest();
    CommercialOpportunityActions.restrictImagesInRichTextFields(
      opportunityList,
      null
    );
    Test.stopTest();

    //THEN it shouldn't throw any error
    Assert.isFalse(
      opportunityList[0].hasErrors(),
      'Error while inserting Opportunity record with Image.'
    );
  }
}

/**
 * @author Mairaj Haider
 * @since 06/2022
 * @description CCRM Opportunity Line Item Test is the test class for CCRM Opportunity Line Item Actions Class.
 */
@isTest
public with sharing class CCRMOpportunityLineItemActionsTest {
  @isTest
  static void testOpportunityLineItemCreatedSuccessfully() {
    //GIVEN
    Integer count = 1;
    List<Opportunity> opps = CCRMTestDataFactory.createOpportunityRecords(
      1,
      null
    );
    OpportunityLineItem oli = CCRMTestDataFactory.createOpportunityLineItem();

    //WHEN
    insert oli;

    //THEN
    List<OpportunityLineItem> entitiesCreated = [
      SELECT ID
      FROM OpportunityLineItem
    ];
    System.assertEquals(
      entitiesCreated.size(),
      count,
      'Opportunity Line Item created successfully.'
    );
  }

  @isTest
  static void testCreatingAdditionalOpportunityLineItemWhenLegalEntityNotAddedSHouldFail() {
    //GIVEN
    Integer count = 1;
    List<Opportunity> opps = CCRMTestDataFactory.createOpportunityRecords(
      1,
      null
    );
    OpportunityLineItem oli = CCRMTestDataFactory.createOpportunityLineItem();
    insert oli;

    //WHEN
    OpportunityLineItem newOli = CCRMTestDataFactory.createOpportunityLineItem();
    try {
      insert newOli;
    } catch (Exception ex) {
      //THEN
      if (
        ex.getMessage()
          .contains(
            'Please review your previous product line item and choose a legal entity prior to selecting a new product.'
          )
      ) {
        System.assert(true, 'Error message displayed');
      } else {
        System.assert(false, 'Incorrect error message');
      }
    }
  }
}

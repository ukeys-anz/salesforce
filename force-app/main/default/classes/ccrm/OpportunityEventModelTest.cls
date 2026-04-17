/**
 * @author Akanksha Kulkarni
 * @since Nov 2025
 * @group (Commercial Broker)
 * @description Test class for OpportunityEventModel
 */
@IsTest
public class OpportunityEventModelTest {
  @IsTest
  static void testOpportunityEventDataModel() {
    // Create MasterNode records
    OpportunityEventModel.OpportunityDetails node = new OpportunityEventModel.OpportunityDetails();
    node.orderId = 'APP-001';
    node.cacheId = 'CACHE-12344';
    node.capcisId = 'CAP-CIS_4025137086';
    node.quoteReferenceNumber = '7233';
    node.opportunityId = '006Bm00000R7OndIAF';
    node.opportunityProductRowId = '00kBm000005KWbxIAG';

    // Instantiate model
    OpportunityEventModel.OpportunityEventDataModel model = new OpportunityEventModel.OpportunityEventDataModel(
      node
    );
    System.assertEquals(
      'APP-001',
      model.data.orderId,
      'First orderID should match'
    );
  }
}

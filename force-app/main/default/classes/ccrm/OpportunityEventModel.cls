/**
 * @author Akanksha Kulkarni
 * @since Nov 2025
 * @group (Commercial Broker)
 * @description Wrapper class for creating the cloud event publish structure for Opportunity.
 */
public virtual with sharing class OpportunityEventModel extends CloudEventModel {
  /**
   * @description Inner class representing the Opportunity event data model structure.
   */
  public virtual class OpportunityEventDataModel extends CloudEventModel.CloudEventDataModel {
    /**
     * @description Holds the list of serialized Opportunity payloads.
     */
    public OpportunityDetails data { get; set; }

    /**
     * @description Constructor to initialize the data list for the Opportunity event.
     * @param opportunityData List of serialized Opportunity event payloads.
     */
    public OpportunityEventDataModel(OpportunityDetails opportunityData) {
      this.data = opportunityData;
    }
  }

  /**
   * @description OpportunityDetails class for Opportunity payload
   **/
  public class OpportunityDetails {
    /**
     * @description to capture OrderID
     **/
    public String orderId { get; set; }

    /**
     * @description to capture CAPCISID
     **/
    public String capcisId { get; set; }

    /**
     * @description to capture CacheID
     **/
    public String cacheId { get; set; }

    /**
     * @description to capture QuoteReferenceNumber
     **/
    public String quoteReferenceNumber { get; set; }

    /**
     * @description to capture OpportunityId
     **/
    public String opportunityId { get; set; }

    /**
     * @description to capture OpportunityProductRowId
     **/
    public String opportunityProductRowId { get; set; }
  }
}

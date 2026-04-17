/**
 * @author Akanksha Kulkarni
 * @since Nov 2025
 * @group (Commercial Broker)
 * @description Wrapper Class for Passing Opportunity Data to GCP
 */
public virtual with sharing class CommercialOpportunityEventPayloadBuilder extends OpportunityEventModel {
  /**
   * @description Build final payload to fire Cloud Event
   * @param record Opportunity record
   * @param payload Opportunity Data
   * @param action Action to be performed
   * */
  public CommercialOpportunityEventPayloadBuilder(
    Opportunity record,
    OpportunityEventModel.OpportunityDetails payload,
    String action
  ) {
    super();

    this.ce_type = System.Label.ANZX_opportunity_event_ce_type + action;
    this.ce_source = System.Label.ANZX_opportunity_event_ce_source;
    this.ce_subject = 'Opportunity/' + record.Id;
    this.ce_partitionkey = 'Opportunity/' + record.Id;
    this.ce_dataschema = System.Label.ANZX_Main_Opportunity_Event_Proto_Data_Schema;
    this.ce_xtargets = 'GCP/' + record.Id;
    this.ce_traceparent = '';
    this.ce_data = new OpportunityEventDataModel(payload);
  }
}

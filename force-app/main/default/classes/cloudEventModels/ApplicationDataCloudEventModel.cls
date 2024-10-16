/**
 * @author Deepro De
 * @since  23/May/2024
 * @description Wrapper Class for Inserting loanAppdata into Broker ORG
 * @runTests
 **/

public virtual with sharing class ApplicationDataCloudEventModel extends BrokerCloudEventModel {
  /**
   * @description parameterized constructor for creating the header for loan application cloud event
   * @author Deepro De | 05-30-2024
   * @param loanApp
   * @param payload
   * @param action
   **/
  public ApplicationDataCloudEventModel(
    ResidentialLoanApplication loanApp,
    List<BrokerDataCloudEventModel.MasterNode> payload,
    String action
  ) {
    super();
    this.ce_type =
      System.Label.ANZX_ResidentialLoanApplication_event_ce_type + action;
    this.ce_source = 'loanapp.salesforce.anzx';
    this.ce_subject = 'ResidentialLoanApplication/' + loanApp.Name;
    this.ce_partitionkey = 'External_Id__c/' + loanApp.ApplicationExtIdentifier;
    this.ce_dataschema =
      System.Label.ANZX_Broker_Event_Proto_Data_Schema +
      '#residentialapplicationdata';
    this.ce_xtargets = 'Broker/' + loanApp.ApplicationExtIdentifier;
    this.ce_traceparent = '';
    this.ce_data = new BrokerCloudEventDataModel(payload);
  }
}

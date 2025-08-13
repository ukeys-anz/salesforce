/**
 * @author Supriya
 * @since  08/Feb
 * @description Wrapper Class for Inserting brokerdata into Broker ORG
 * @runTests  BrokerCloudEventBuilderTest
 */
@SuppressWarnings(
  'PMD.ApexDoc, PMD.ExcessivePublicCount, PMD.PropertyNamingConventions, PMD.NcssConstructorCount'
)
public virtual with sharing class BrokerDataCloudEventModel extends BrokerCloudEventModel {
  public BrokerDataCloudEventModel(
    Contact contact,
    List<BrokerDataCloudEventModel.MasterNode> payload,
    String action
  ) {
    super();
    this.ce_type = System.Label.ANZX_Broker_event_ce_type + action;
    this.ce_source = 'broker.salesforce.anzx';
    this.ce_subject = 'Contact/' + contact.Name;
    this.ce_partitionkey = 'External_Id__c/' + contact.External_Id__c;
    this.ce_sequence = contact.OCV_Event_Version__c;
    this.ce_dataschema =
      System.Label.ANZX_Broker_Event_Proto_Data_Schema + '#brokerdata';
    this.ce_xtargets = 'Broker/' + contact.External_Id__c;
    this.ce_traceparent = '';
    this.ce_data = new BrokerCloudEventDataModel(payload);
  }

  /**
   * @description Constructor to get an instance of BrokerDataCloudEventModel
   * @param financialAccount FinServ__FinancialAccount__c record
   * @param payload data to be send with the cloud event
   * @param action add/update
   */
  public BrokerDataCloudEventModel(
    FinServ__FinancialAccount__c financialAccount,
    List<BrokerDataCloudEventModel.MasterNode> payload,
    String action
  ) {
    super();
    this.ce_type = System.Label.ANZx_Broker_Contract_Event_ce_type + action;
    this.ce_source = 'broker.salesforce.anzx';
    this.ce_subject =
      'FinServ__FinancialAccount__c/' + financialAccount.Account_Key__c;
    this.ce_partitionkey = 'External_Id__c/' + financialAccount.Account_Key__c;
    this.ce_sequence = Decimal.ValueOf(Datetime.now().getTime());
    this.ce_dataschema =
      System.Label.ANZX_Broker_Event_Proto_Data_Schema + '#brokerdata';
    this.ce_xtargets =
      'FinServ__FinancialAccount__c/' + financialAccount.Account_Key__c;
    this.ce_traceparent = '';
    this.ce_data = new BrokerCloudEventDataModel(payload);
  }
  /**
   * @description Constructor to get an instance of BrokerDataCloudEventModel
   * @param loanApp ResidentialLoanApplication record
   * @param payload data to be send with the cloud event
   * @param action add/update
   */
  public BrokerDataCloudEventModel(
    ResidentialLoanApplication loanApp,
    List<BrokerDataCloudEventModel.MasterNode> payload,
    String action
  ) {
    super();
    this.ce_type = loanApp.RecordtypeId ==
      Schema.SObjectType.ResidentialLoanApplication.getRecordTypeInfosByName()
        .get('Loan Application')
        .getRecordTypeId()
      ? System.Label.ANZX_ResidentialLoanApplication_event_ce_type + action
      : System.Label.ANZx_ClassicLoanApplication_Event_ce_type + action;
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

  /**
   * @description parameterized constructor for creating the header for customer cloud event
   * @author Madhuri Edke | 07-18-2024
   * @param record Account record
   * @param payload data to be send with the cloud event
   * @param action add/update
   **/
  public BrokerDataCloudEventModel(
    Account record,
    List<BrokerDataCloudEventModel.MasterNode> payload,
    String action
  ) {
    super();
    this.ce_type = System.Label.ANZX_Customer_event_ce_type + action;
    this.ce_source = 'broker.salesforce.anzx';
    this.ce_subject = 'Account/' + record.FirstName + ' ' + record.LastName;
    this.ce_partitionkey = 'External_Id__c/' + record.External_Id__c;
    this.ce_dataschema =
      System.Label.ANZX_Broker_Event_Proto_Data_Schema + '#customerdata';
    this.ce_xtargets = 'Broker/' + record.External_Id__c;
    this.ce_traceparent = '';
    this.ce_data = new BrokerCloudEventDataModel(payload);
  }
}

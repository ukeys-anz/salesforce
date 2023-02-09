/**
 * @author Lance Shi
 * @since  01/2023
 * @description Wrapper Class for External_Case_Status__c metadata and data
 */
@SuppressWarnings(
  'PMD.ApexDoc, PMD.ExcessivePublicCount, PMD.PropertyNamingConventions'
)
public without sharing class ExternalCaseStatusCloudEventModel extends CloudEventModel {
  public ExternalCaseStatusCloudEventModel(
    External_Case_Status__c externalCaseStatus,
    Case theCase,
    String action,
    User theUser
  ) {
    super();
    String caseType = '';
    Map<String, String> caseTypeByRecordtype = new Map<String, String>{
      GetHelpConstants.ATM_DISPUTE_RT_ID => 'atm.',
      GetHelpConstants.CARD_DISPUTE_RT_ID => 'card.'
    };
    if (caseTypeByRecordtype.containsKey(theCase.RecordTypeId)) {
      caseType = caseTypeByRecordtype.get(theCase.RecordTypeId);
    }

    ce_type =
      'anzx.salesforce.case.v1.dispute.' +
      caseType +
      'externalstatus.' +
      action;
    ce_source = 'case.salesforce.anzx';
    ce_subject = 'ExternalStatusID/' + externalCaseStatus.Id;
    ce_partitionkey = 'CaseNumber/' + theCase.CaseNumber;
    ce_dataschema = System.Label.ANZX_Proto_Data_Schema + '#ExternalCaseStatus';
    String sourceSystemName = '';
    if (
      theCase.Account?.Source_System_Name__c != null &&
      theCase.Account?.Source_System_ID__c != null
    ) {
      sourceSystemName =
        ',' +
        theCase.Account.Source_System_Name__c.toLowerCase() +
        '/' +
        theCase.Account?.Source_System_ID__c;
    }
    ce_xtargets =
      'ocv/' +
      theCase.Account?.OCV_ID__c +
      sourceSystemName +
      ',casenumber/' +
      theCase.CaseNumber;
    ce_traceparent = '';
    this.ce_data = new ExternalCaseStatusCloudEventDataModel(
      externalCaseStatus,
      theCase
    );
    this.system_data = new CloudEventSystemModel(
      externalCaseStatus.LastModifiedDate,
      theUser
    );
  }

  /**
   * @description the model for External Case status cloud event data part
   */
  public class ExternalCaseStatusCloudEventDataModel extends CloudEventModel.CloudEventDataModel {
    public String caseNumber { get; set; }
    public String customerMessage { get; set; }
    public String externalStatus { get; set; }
    public String internalDescription { get; set; }
    public Boolean isOutcomeInCustomerFavour { get; set; }
    public String name { get; set; }
    public String resultCode { get; set; }
    public String resultMessage { get; set; }
    public String statusEventId { get; set; }
    public DateTime statusTimestamp { get; set; }
    /**
     * @description get an instance of ExternalCaseStatusWrapper
     */
    public ExternalCaseStatusCloudEventDataModel(
      External_Case_Status__c externalCaseStatus,
      Case theCase
    ) {
      super(externalCaseStatus);
      this.caseNumber = theCase.CaseNumber;
      this.customerMessage = externalCaseStatus.Customer_Message__c;
      this.externalStatus = externalCaseStatus.External_Status__c;
      this.internalDescription = externalCaseStatus.Internal_Description__c;
      this.isOutcomeInCustomerFavour = externalCaseStatus.Is_Outcome_in_Customer_Favour__c;
      this.name = externalCaseStatus.Name;
      this.resultCode = externalCaseStatus.Result_Code__c;
      this.resultMessage = externalCaseStatus.Result_Message__c;
      this.statusEventId = externalCaseStatus.Status_Event_ID__c;
      this.statusTimestamp = externalCaseStatus.Status_Timestamp__c;
    }
  }
}

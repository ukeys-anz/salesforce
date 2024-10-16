/**
 * @author Hrushikesh Pathak
 * @since  06/2024
 * @description Wrapper Class for External_Case_Status__c metadata and data
 */
public with sharing class ExternalCaseStatusCloudEventModelV2 extends CloudEventModel {
  /**
   * @description Constructor
   * @param externalCaseStatus Case record
   * @param theCase Account record
   * @param action action if created or updated
   * @param theUser User record
   */
  public ExternalCaseStatusCloudEventModelV2(
    External_Case_Status__c externalCaseStatus,
    Case theCase,
    String action,
    User theUser
  ) {
    super();
    String caseType = '';
    Map<String, String> caseTypeByRecordtype = new Map<String, String>{
      RTCase.atmDispute => 'atm.',
      RTCase.cardDispute => 'card.',
      RTCase.nppDispute => 'npp.',
      RTCase.payToDispute => 'payto.',
      RTCase.directEntryDispute => 'de.',
      RTCase.directDebitDispute => 'dd.',
      RTCase.bpayDispute => 'bpay.'
    };
    if (caseTypeByRecordtype.containsKey(theCase.RecordTypeId)) {
      if (
        theCase.RecordTypeId == RTCase.nppDispute &&
        theCase.Dispute_Reason__c ==
        GetHelpCaseAssignmentRules.UNAUTHORISED_TRANSACTION
      ) {
        caseType = 'nppfraud.';
      } else {
        caseType = caseTypeByRecordtype.get(theCase.RecordTypeId);
      }
    }

    ce_type =
      System.Label.ANZX_Disputes_event_ce_type_v1beta1 +
      caseType +
      'externalstatus.' +
      action;
    ce_source = 'case.salesforce.anzx';
    ce_subject = 'ExternalCaseStatusNumber/' + externalCaseStatus.Name;
    ce_partitionkey = 'CaseNumber/' + theCase.CaseNumber;
    ce_dataschema =
      System.Label.ANZX_Disputes_Event_Proto_Data_Schema_v1beta1 +
      '#ExternalCaseStatus';
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
    ce_xtargets = 'ocv/' + theCase.Account?.OCV_ID__c + sourceSystemName;
    ce_traceparent = '';
    this.ce_data = new ExternalCaseStatusCloudEventV2DataModel(
      externalCaseStatus,
      theCase,
      theUser
    );
  }

  /**
   * @description the model for External Case status cloud event data part
   */
  public class ExternalCaseStatusCloudEventV2DataModel extends CloudEventModel.CloudEventDataModel {
    /**
     * @description Case Number
     */
    public String caseNumber { get; set; }
    /**
     * @description Customer Message
     */
    public String customerMessage { get; set; }
    /**
     * @description external status
     */
    public String externalStatus { get; set; }
    /**
     * @description internal description
     */
    public String internalDescription { get; set; }
    /**
     * @description Is Outcome in customer favour
     */
    public Boolean isOutcomeInCustomerFavour { get; set; }
    /**
     * @description name
     */
    public String name { get; set; }
    /**
     * @description result code
     */
    public String resultCode { get; set; }
    /**
     * @description result message
     */
    public String resultMessage { get; set; }
    /**
     * @description status event id
     */
    public String statusEventId { get; set; }
    /**
     * @description Customer Case Status
     */
    public String customerCaseStatus { get; set; }
    /**
     * @description status time stamp
     */
    public Datetime statusTimestamp { get; set; }
    /**
     * @description customer
     */
    public AccountModel customer { get; set; }
    /**
     * @description System Data
     */
    public CloudEventSystemModel systemData { get; set; }

    /**
     * @description Constructor
     * @param externalCaseStatus Case record
     * @param theCase Account record
     * @param theUser User record
     */
    public ExternalCaseStatusCloudEventV2DataModel(
      External_Case_Status__c externalCaseStatus,
      Case theCase,
      User theUser
    ) {
      this.caseNumber = theCase.CaseNumber;
      this.customerMessage = externalCaseStatus.New_Customer_Message__c;
      this.externalStatus = externalCaseStatus.External_Status__c;
      this.internalDescription = externalCaseStatus.Internal_Description__c;
      this.isOutcomeInCustomerFavour = externalCaseStatus.Is_Outcome_in_Customer_Favour__c;
      this.name = externalCaseStatus.Name;
      this.resultCode = externalCaseStatus.Result_Code__c;
      this.resultMessage = externalCaseStatus.Result_Message__c;
      this.statusEventId = externalCaseStatus.Status_Event_ID__c;
      this.customerCaseStatus = externalCaseStatus.Customer_Status__c;
      this.statusTimestamp = externalCaseStatus.Status_Timestamp__c;
      this.customer = new AccountModel(theCase);
      this.systemData = new CloudEventSystemModel(
        theCase.LastModifiedDate,
        theUser
      );
    }
  }

  /**
   * @description Inner Wrapper Class for the customer data of All Dispute Cases
   */
  public class AccountModel {
    /**
     * @description Account's ocv id
     */
    public String ocvId { get; set; }
    /**
     * @description source system
     */
    public String sourceSystem { get; set; }
    /**
     * @description source system id
     */
    public String sourceSystemId { get; set; }

    /**
     * @description get an instance of AccountModel
     * @param theCase the Case record
     */
    public AccountModel(Case theCase) {
      this.ocvId = theCase.Account?.OCV_ID__c;
      this.sourceSystem = theCase.Account?.Source_System_Name__c;
      this.sourceSystemId = theCase.Account?.Source_System_ID__c;
    }
  }
}

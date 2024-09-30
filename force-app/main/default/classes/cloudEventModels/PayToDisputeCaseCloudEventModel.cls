/**
 * @author Hrushikesh Pathak
 * @since  05/2024
 * @description Wrapper Class for PayTo Dispute metadata and data
 */
public with sharing class PayToDisputeCaseCloudEventModel extends DisputeCaseCloudEventModelV2 {
  /**
   * @description Constructor
   * @param theCase Case record
   * @param theAccount Account record
   * @param action action if created or updated
   * @param theUser User record
   * @param theOwner Owner record
   */
  public PayToDisputeCaseCloudEventModel(
    Case theCase,
    Account theAccount,
    String action,
    User theUser,
    UserModel theOwner
  ) {
    super(theCase, theAccount);
    ce_type =
      System.Label.ANZX_Disputes_event_ce_type_v1beta1 +
      'payto.' +
      action;
    ce_dataschema =
      System.Label.ANZX_Disputes_Event_Proto_Data_Schema_v1beta1 +
      '#PayToDispute';
    this.ce_data = new PayToDisputeCaseCloudEventDataModel(
      theCase,
      theAccount,
      theOwner,
      theUser
    );
  }

  /**
   * @description the model for PayTo Dispute Case cloud event data part
   */
  public class PayToDisputeCaseCloudEventDataModel extends DisputeCaseCloudEventModelV2.DisputeCaseCloudEventDataModelV2 {
    /**
     * @description NPP Dispute Reason
     */
    public String nppDisputeReason { get; set; }
    /**
     * @description reason code
     */
    public String reasonCode { get; set; }
    /**
     * @description subtype
     */
    public String subtype { get; set; }
    /**
     * @description payment id
     */
    public String paymentId { get; set; }
    /**
     * @description receipt
     */
    public String receipt { get; set; }
    /**
     * @description mandate id
     */
    public String mandateId { get; set; }

    /**
     * @description Constructor
     * @param theCase Case record
     * @param theAccount Account record
     * @param theOwner Owner record
     * @param theUser Owner record
     */
    public PayToDisputeCaseCloudEventDataModel(
      Case theCase,
      Account theAccount,
      UserModel theOwner,
      User theUser
    ) {
      super(theCase, theAccount, theOwner, theUser);
      this.nppDisputeReason = theCase.NPP_Dispute_Reason__c;
      this.reasonCode = theCase.Reason_Code__c;
      this.subtype = theCase.NPP_Subtype__c;
      this.paymentId = theCase.Payment_ID__c;
      this.receipt = theCase.Receipt__c;
      this.mandateId = theCase.Mandate_ID__c;
    }
  }
}

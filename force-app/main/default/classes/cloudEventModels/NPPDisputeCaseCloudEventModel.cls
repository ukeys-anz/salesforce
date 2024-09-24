/**
 * @author Hrushikesh Pathak
 * @since  05/2024
 * @description Wrapper Class for NPP Dispute metadata and data
 */
public with sharing class NPPDisputeCaseCloudEventModel extends DisputeCaseCloudEventModelV2 {
  /**
   * @description Constructor
   * @param theCase Case record
   * @param theAccount Account record
   * @param action action if created or updated
   * @param theUser User record
   * @param theOwner Owner record
   */
  public NPPDisputeCaseCloudEventModel(
    Case theCase,
    Account theAccount,
    String action,
    User theUser,
    UserModel theOwner
  ) {
    super(theCase, theAccount);
    ce_type =
      System.Label.ANZX_Disputes_event_ce_type_v1beta1 +
      'npp.' +
      action;
    ce_dataschema =
      System.Label.ANZX_Disputes_Event_Proto_Data_Schema_v1beta1 +
      '#NPPDispute';
    this.ce_data = new NPPDisputeCaseCloudEventDataModel(
      theCase,
      theAccount,
      theOwner,
      theUser
    );
  }

  /**
   * @description the model for NPPDispute Case cloud event data part
   */
  public class NPPDisputeCaseCloudEventDataModel extends DisputeCaseCloudEventModelV2.DisputeCaseCloudEventDataModelV2 {
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
     * @description intended account
     */
    public IntendedAccountModel intendedAccount { get; set; }
    /**
     * @description intended amount
     */
    public FabricType.FabricMoney intendedAmount { get; set; }

    /**
     * @description Constructor
     * @param theCase Case record
     * @param theAccount Account record
     * @param theOwner Owner record
     * @param theUser Owner record
     */
    public NPPDisputeCaseCloudEventDataModel(
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
      this.intendedAccount = new IntendedAccountModel(theCase);
      if (theCase.Intended_Amount__c != null) {
        this.intendedAmount = new FabricType.FabricMoney(
          null,
          theCase.Intended_Amount__c
        );
      }
    }
  }
}

/**
 * @author Poorva Shukla
 * @since  06/2025
 * @description Wrapper Class for IMT Dispute metadata and data
 */
public with sharing class IMTDisputeCaseCloudEventModel extends DisputeCaseCloudEventModelV2 {
  private static final String BENEFICIARY_CLAIMS_NON_RECEIPT = 'Beneficiary Claims Non Receipt';
  private static final String PAYMENT_RECALL = 'Payment Recall';
  private static final String CB_BCNR = 'CB_BCNR';
  private static final String CB_CANCE_OUT = 'CB_Cance_Out';
  private static final String SINGLE_SPACE = ' ';

  /**
   * @description Constructor
   * @param theCase Case record
   * @param theAccount Account record
   * @param action action if created or updated
   * @param theUser User record
   * @param theOwner Owner record
   */
  public IMTDisputeCaseCloudEventModel(
    Case theCase,
    Account theAccount,
    String action,
    User theUser,
    UserModel theOwner
  ) {
    super(theCase, theAccount);
    ce_type =
      System.Label.ANZX_Disputes_event_ce_type_v1beta1 +
      'imt.' +
      action;
    ce_dataschema =
      System.Label.ANZX_Disputes_Event_Proto_Data_Schema_v1beta1 +
      '#IMTDispute';
    this.ce_data = new IMTDisputeCaseCloudEventDataModel(
      theCase,
      theAccount,
      theOwner,
      theUser
    );
    this.systemData = new CloudEventSystemModel(
      theCase.LastModifiedDate,
      theUser
    );
  }

  /**
   * @description the model for IMTDispute Case cloud event data part
   */
  public class IMTDisputeCaseCloudEventDataModel extends DisputeCaseCloudEventModelV2.DisputeCaseCloudEventDataModelV2 {
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
     * @description Constructor
     * @param theCase Case record
     * @param theAccount Account record
     * @param theOwner Owner record
     * @param theUser Owner record
     */
    public IMTDisputeCaseCloudEventDataModel(
      Case theCase,
      Account theAccount,
      UserModel theOwner,
      User theUser
    ) {
      super(theCase, theAccount, theOwner, theUser);
      this.subtype = theCase.Reason_Code__c;
      this.receipt = theCase.Receipt__c;
      this.reasonCode = theCase.Reason_Code__c;
      this.paymentId = theCase.Payment_ID__c;
      if (theCase.Reason_Code__c == CB_BCNR) {
        this.caseDetails.description =
          BENEFICIARY_CLAIMS_NON_RECEIPT +
          SINGLE_SPACE +
          theCase.Description;
      } else if (theCase.Reason_Code__c == CB_CANCE_OUT) {
        this.caseDetails.description =
          PAYMENT_RECALL +
          SINGLE_SPACE +
          theCase.Description;
      }
    }
  }
}

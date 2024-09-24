/**
 * @author Hrushikesh Pathak
 * @since  08/2024
 * @description Wrapper Class for ATM Dispute metadata and data for v1beta1 version
 */
public with sharing class ATMDisputeCaseCloudEventModelV2 extends DisputeCaseCloudEventModelV2 {
  /**
   * @description Constructor
   * @param theCase Case record
   * @param theAccount Account record
   * @param action action if created or updated
   * @param theUser User record
   * @param theOwner Owner record
   */
  public ATMDisputeCaseCloudEventModelV2(
    Case theCase,
    Account theAccount,
    String action,
    User theUser,
    UserModel theOwner
  ) {
    super(theCase, theAccount);
    ce_type =
      System.Label.ANZX_Disputes_event_ce_type_v1beta1 +
      'atm.' +
      action;
    ce_dataschema =
      System.Label.ANZX_Disputes_Event_Proto_Data_Schema_v1beta1 +
      '#ATMDispute';
    this.ce_data = new ATMDisputeCaseCloudEventDataModelV2(
      theCase,
      theAccount,
      theOwner,
      theUser
    );
  }

  /**
   * @description the model for ATM Dispute Case cloud event data part
   */
  public class ATMDisputeCaseCloudEventDataModelV2 extends DisputeCaseCloudEventModelV2.DisputeCaseCloudEventDataModelV2 {
    /**
     * @description Card Information
     */
    public CardInformationModel cardInfo { get; set; }
    /**
     * @description Received AMount
     */
    public FabricType.FabricMoney receivedAmount { get; set; }
    /**
     * @description Received AMount
     */
    public String merchantDescription { get; set; }
    /**
     * @description Received AMount
     */
    public String location { get; set; }
    /**
     * @description Received AMount
     */
    public FabricType.FabricMoney claimedAmount { get; set; }
    /**
     * @description Received AMount
     */
    public String bankAtm { get; set; }

    /**
     * @description Constructor
     * @param theCase Case record
     * @param theAccount Account record
     * @param theOwner Owner record
     * @param theUser Owner record
     */
    public ATMDisputeCaseCloudEventDataModelV2(
      Case theCase,
      Account theAccount,
      UserModel theOwner,
      User theUser
    ) {
      super(theCase, theAccount, theOwner, theUser);
      this.cardInfo = new CardInformationModel(theCase);
      if (theCase.Received_Amount__c != null) {
        this.receivedAmount = new FabricType.FabricMoney(
          theCase.Received_Currency__c,
          theCase.Received_Amount__c
        );
      }
      this.merchantDescription = theCase.Merchant_Description__c;
      this.location = theCase.Location__c;
      if (theCase.Claimed_Amount__c != null) {
        this.claimedAmount = new FabricType.FabricMoney(
          theCase.Received_Currency__c,
          theCase.Claimed_Amount__c
        );
      }
      this.bankAtm = theCase.Bank_ATM__c;
    }
  }
}

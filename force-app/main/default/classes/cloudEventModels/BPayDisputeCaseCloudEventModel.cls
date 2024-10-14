/**
 * @author Hrushikesh Pathak
 * @since  05/2024
 * @description Wrapper Class for BPAY Dispute metadata and data
 */
public with sharing class BPayDisputeCaseCloudEventModel extends DisputeCaseCloudEventModelV2 {
  /**
   * @description Constructor
   * @param theCase Case record
   * @param theAccount Account record
   * @param action action if created or updated
   * @param theUser User record
   * @param theOwner Owner record
   */
  public BPayDisputeCaseCloudEventModel(
    Case theCase,
    Account theAccount,
    String action,
    User theUser,
    UserModel theOwner
  ) {
    super(theCase, theAccount);
    ce_type =
      System.Label.ANZX_Disputes_event_ce_type_v1beta1 +
      'bpay.' +
      action;
    ce_dataschema =
      System.Label.ANZX_Disputes_Event_Proto_Data_Schema_v1beta1 +
      '#BPAYDispute';
    this.ce_data = new BPayDisputeCaseCloudEventDataModel(
      theCase,
      theAccount,
      theOwner,
      theUser
    );
  }

  /**
   * @description the model for BPay Dispute Case cloud event data part
   */
  public class BPayDisputeCaseCloudEventDataModel extends DisputeCaseCloudEventModelV2.DisputeCaseCloudEventDataModelV2 {
    /**
     * @description Address
     */
    public String address { get; set; }
    /**
     * @description Billing Information
     */
    public BillerInformationModel billerInfo { get; set; }
    /**
     * @description Registration Number
     */
    public String registrationNumber { get; set; }
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
    public BPayDisputeCaseCloudEventDataModel(
      Case theCase,
      Account theAccount,
      UserModel theOwner,
      User theUser
    ) {
      super(theCase, theAccount, theOwner, theUser);
      this.address = theCase.Address__c;
      this.billerInfo = new BillerInformationModel(theCase);
      this.registrationNumber = theCase.Registration_Number__c;
      this.receipt = theCase.Receipt__c;
    }
  }
}

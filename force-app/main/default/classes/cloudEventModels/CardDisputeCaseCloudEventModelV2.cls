/**
 * @author Hrushikesh Pathak
 * @since  08/2024
 * @description Wrapper Class for CARD Dispute metadata and data for v1beta1 version
 */
@SuppressWarnings('PMD.NcssConstructorCount')
public with sharing class CardDisputeCaseCloudEventModelV2 extends DisputeCaseCloudEventModelV2 {
  /**
   * @description Constructor
   * @param theCase Case record
   * @param theAccount Account record
   * @param action action if created or updated
   * @param theUser User record
   * @param theOwner Owner record
   */
  public CardDisputeCaseCloudEventModelV2(
    Case theCase,
    Account theAccount,
    String action,
    User theUser,
    UserModel theOwner
  ) {
    super(theCase, theAccount);
    ce_type =
      System.Label.ANZX_Disputes_event_ce_type_v1beta1 +
      'card.' +
      action;
    ce_dataschema =
      System.Label.ANZX_Disputes_Event_Proto_Data_Schema_v1beta1 +
      '#CardDispute';
    this.ce_data = new CardDisputeCaseCloudEventDataModelV2(
      theCase,
      theAccount,
      theOwner,
      theUser
    );
  }

  /**
   * @description the model for CARD Dispute Case cloud event data part
   */
  public class CardDisputeCaseCloudEventDataModelV2 extends DisputeCaseCloudEventModelV2.DisputeCaseCloudEventDataModelV2 {
    /**
     * @description Card Information
     */
    public CardInformationModel cardInfo { get; set; }
    /**
     * @description Transaction Status
     */
    public String transactionStatus { get; set; }
    /**
     * @description Transaction Authorised Date
     */
    public FabricType.FabricDate transactionAuthorisedDate { get; set; }
    /**
     * @description Regular Payment Cancellation Date
     */
    public FabricType.FabricDate regularPaymentCancellationDate { get; set; }
    /**
     * @description Refund Request Date
     */
    public FabricType.FabricDate refundRequestDate { get; set; }
    /**
     * @description Merchant Description
     */
    public String merchantDescription { get; set; }
    /**
     * @description Goods Or Services Returned
     */
    public String goodsOrServicesReturned { get; set; }
    /**
     * @description Date of Expected Delivery Service
     */
    public FabricType.FabricDate dateOfExpectedDeliveryService { get; set; }
    /**
     * @description Date Goods Were Returned Or Services Cancelled
     */
    public FabricType.FabricDate dateGoodsWereReturnedOrServicesCancelled {
      get;
      set;
    }
    /**
     * @description Customer Contacted Merchant
     */
    public String customerContactedMerchant { get; set; }
    /**
     * @description Amount of Credit Due
     */
    public FabricType.FabricMoney amountOfCreditDue { get; set; }
    /**
     * @description Amount Of Authorised Transaction
     */
    public FabricType.FabricMoney amountOfAuthorisedTransaction { get; set; }

    /**
     * @description Constructor
     * @param theCase Case record
     * @param theAccount Account record
     * @param theOwner Owner record
     * @param theUser Owner record
     */
    public CardDisputeCaseCloudEventDataModelV2(
      Case theCase,
      Account theAccount,
      UserModel theOwner,
      User theUser
    ) {
      super(theCase, theAccount, theOwner, theUser);
      this.cardInfo = new CardInformationModel(theCase);
      this.transactionStatus = theCase.Transaction_Status__c;
      if (theCase.Transaction_Authorised_Date__c != null) {
        this.transactionAuthorisedDate = new FabricType.FabricDate(
          theCase.Transaction_Authorised_Date__c
        );
      }
      if (theCase.Regular_Payment_Cancellation_Date__c != null) {
        this.regularPaymentCancellationDate = new FabricType.FabricDate(
          theCase.Regular_Payment_Cancellation_Date__c
        );
      }
      if (theCase.Refund_Request_Date__c != null) {
        this.refundRequestDate = new FabricType.FabricDate(
          theCase.Refund_Request_Date__c
        );
      }
      this.merchantDescription = theCase.Merchant_Description__c;
      this.goodsOrServicesReturned = theCase.Goods_Or_Services_Returned__c;
      if (theCase.Date_Of_Expected_Delivery_Service__c != null) {
        this.dateOfExpectedDeliveryService = new FabricType.FabricDate(
          theCase.Date_Of_Expected_Delivery_Service__c
        );
      }
      if (theCase.Date_Goods_Were_Returned_Or_Services_can__c != null) {
        this.dateGoodsWereReturnedOrServicesCancelled = new FabricType.FabricDate(
          theCase.Date_Goods_Were_Returned_Or_Services_can__c
        );
      }
      this.customerContactedMerchant = theCase.Customer_Contacted_Merchant__c;
      if (theCase.Amount_Of_Credit_Due__c != null) {
        this.amountOfCreditDue = new FabricType.FabricMoney(
          null,
          theCase.Amount_Of_Credit_Due__c
        );
      }
      if (theCase.Amount_Of_Authorised_Transaction__c != null) {
        this.amountOfAuthorisedTransaction = new FabricType.FabricMoney(
          null,
          theCase.Amount_Of_Authorised_Transaction__c
        );
      }
    }
  }
}

/**
 * @author Lance Shi
 * @since  01/2023
 * @description Wrapper Class for Card Dispute metadata and data
 */
@SuppressWarnings(
  'PMD.ApexDoc, PMD.ExcessivePublicCount, PMD.PropertyNamingConventions'
)
public without sharing class CardDisputeCaseCloudEventModel extends DisputeCaseCloudEventModel {
  public CardDisputeCaseCloudEventModel(
    Case theCase,
    Account theAccount,
    String action,
    User theuser,
    UserModel theOwner
  ) {
    super(theCase, theAccount);
    ce_type = System.Label.ANZX_Disputes_event_ce_type + 'card.' + action;
    ce_dataschema =
      System.Label.ANZX_Disputes_Event_Proto_Data_Schema + '#CardDispute';
    this.ce_data = new CardDisputeCaseCloudEventDataModel(
      theCase,
      theAccount,
      theOwner
    );
    this.systemData = new CloudEventSystemModel(
      theCase.LastModifiedDate,
      theUser
    );
  }

  /**
   * @description the model for CardDispute Case cloud event data part
   */
  public class CardDisputeCaseCloudEventDataModel extends DisputeCaseCloudEventModel.DisputeCaseCloudEventDataModel {
    public Decimal amountOfAuthorisedTransaction { get; set; }
    public Decimal amountOfCreditDue { get; set; }
    public String cardInPossessionDuringTransaction { get; set; }
    public String cardNumber { get; set; }
    public String cardScheme { get; set; }
    public String customerContactedMerchant { get; set; }
    public Date dateGoodsWereReturnedOrServicesCancelled { get; set; }
    public Date dateOfExpectedDeliveryService { get; set; }
    public String goodsOrServicesReturned { get; set; }
    public String hasTheCardBeenStopped { get; set; }
    public String isTheCardLostStolen { get; set; }
    public String merchantDescription { get; set; }
    public Date refundRequestDate { get; set; }
    public Date regularPaymentCancellationDate { get; set; }
    public Date transactionAuthorisedDate { get; set; }
    public String transactionStatus { get; set; }

    public CardDisputeCaseCloudEventDataModel(
      Case theCase,
      Account theAccount,
      UserModel theOwner
    ) {
      super(theCase, theAccount);
      this.owner = theOwner;
      this.amountOfAuthorisedTransaction = theCase.Amount_Of_Authorised_Transaction__c;
      this.amountOfCreditDue = theCase.Amount_Of_Credit_Due__c;
      this.cardInPossessionDuringTransaction = theCase.Card_In_Possession_During_Transaction__c;
      this.cardNumber = theCase.Card_Number__c;
      this.cardScheme = theCase.Card_Scheme__c;
      this.customerContactedMerchant = theCase.Customer_Contacted_Merchant__c;
      this.dateGoodsWereReturnedOrServicesCancelled = theCase.Date_Goods_Were_Returned_Or_Services_can__c;
      this.dateOfExpectedDeliveryService = theCase.Date_Of_Expected_Delivery_Service__c;
      this.goodsOrServicesReturned = theCase.Goods_Or_Services_Returned__c;
      this.hasTheCardBeenStopped = theCase.Has_The_Card_Been_Stopped__c;
      this.isTheCardLostStolen = theCase.Is_The_Card_Lost_Stolen__c;
      this.merchantDescription = theCase.Merchant_Description__c;
      this.refundRequestDate = theCase.Refund_Request_Date__c;
      this.regularPaymentCancellationDate = theCase.Regular_Payment_Cancellation_Date__c;
      this.transactionAuthorisedDate = theCase.Transaction_Authorised_Date__c;
      this.transactionStatus = theCase.Transaction_Status__c;
    }
  }
}

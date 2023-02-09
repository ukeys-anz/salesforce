/**
 * @author Lance Shi
 * @since  01/2023
 * @description Wrapper Class for ATM Dispute metadata and data
 */
@SuppressWarnings(
  'PMD.ApexDoc, PMD.ExcessivePublicCount, PMD.PropertyNamingConventions'
)
public without sharing class ATMDisputeCaseCloudEventModel extends DisputeCaseCloudEventModel {
  public ATMDisputeCaseCloudEventModel(
    Case theCase,
    Account theAccount,
    String action,
    User theUser,
    UserModel theOwner
  ) {
    super(theCase, theAccount);
    ce_type = 'anzx.salesforce.case.v1.atm.dispute.' + action;
    ce_dataschema = System.Label.ANZX_Proto_Data_Schema + '#ATMDispute';
    this.ce_data = new ATMDisputeCaseCloudEventDataModel(
      theCase,
      theAccount,
      theOwner
    );
    this.system_data = new CloudEventSystemModel(
      theCase.LastModifiedDate,
      theUser
    );
  }

  /**
   * @description the model for ATMDispute Case cloud event data part
   */
  public class ATMDisputeCaseCloudEventDataModel extends DisputeCaseCloudEventModel.DisputeCaseCloudEventDataModel {
    public String bankAtm { get; set; }
    public String cardInPossessionDuringTransaction { get; set; }
    public String cardNumber { get; set; }
    public String cardScheme { get; set; }
    public Decimal claimedAmount { get; set; }
    public String hasTheCardBeenStopped { get; set; }
    public String isTheCardLostStolen { get; set; }
    public String location { get; set; }
    public String merchantDescription { get; set; }
    public Decimal receivedAmount { get; set; }

    public ATMDisputeCaseCloudEventDataModel(
      Case theCase,
      Account theAccount,
      UserModel theOwner
    ) {
      super(theCase, theAccount);
      this.owner = theOwner;
      this.bankAtm = theCase.Bank_ATM__c;
      this.cardInPossessionDuringTransaction = theCase.Card_In_Possession_During_Transaction__c;
      this.cardNumber = theCase.Card_Number__c;
      this.cardScheme = theCase.Card_Scheme__c;
      this.claimedAmount = theCase.Claimed_Amount__c;
      this.hasTheCardBeenStopped = theCase.Has_The_Card_Been_Stopped__c;
      this.isTheCardLostStolen = theCase.Is_The_Card_Lost_Stolen__c;
      this.location = theCase.Location__c;
      this.merchantDescription = theCase.Merchant_Description__c;
      this.receivedAmount = theCase.Received_Amount__c;
    }
  }
}

/**
 * @author Hrushikesh Pathak
 * @since  06/2024
 * @description Wrapper Class for Disputes' metadata and data
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public virtual with sharing class DisputeCaseCloudEventModelV2 extends CaseCloudEventModel {
  /**
   * @description Constructor
   * @param theCase Case record
   * @param theAccount Account record
   */
  public DisputeCaseCloudEventModelV2(Case theCase, Account theAccount) {
    super(theCase, theAccount);
  }

  /**
   * @description the model for dispute Case cloud event data part
   */
  public virtual class DisputeCaseCloudEventDataModelV2 extends CloudEventModel.CloudEventDataModel {
    /**
     * @description Case Details
     */
    public CaseDetailsModel caseDetails { get; set; }
    /**
     * @description Financial Account
     */
    public FinancialAccountModel financialAccount { get; set; }
    /**
     * @description Transaction Info
     */
    public TransactionModel transactionInfo { get; set; }

    /**
     * @description Constructor
     * @param theCase Case record
     * @param theAccount Account record
     * @param theOwner Account record
     * @param theUser Account record
     */
    public DisputeCaseCloudEventDataModelV2(
      Case theCase,
      Account theAccount,
      UserModel theOwner,
      User theUser
    ) {
      this.caseDetails = new CaseDetailsModel(
        theCase,
        theAccount,
        theOwner,
        theUser
      );
      this.financialAccount = new FinancialAccountModel(theCase);
      this.transactionInfo = new TransactionModel(theCase);
    }
  }

  /**
   * @description Inner Wrapper Class for the Case Details
   */
  public class CaseDetailsModel {
    /**
     * @description Case Subject
     */
    public String subject { get; set; }
    /**
     * @description Case Status
     */
    public String status { get; set; }
    /**
     * @description Case Priority
     */
    public String priority { get; set; }
    /**
     * @description Case Number
     */
    public String caseNumber { get; set; }
    /**
     * @description Case Origin
     */
    public String origin { get; set; }
    /**
     * @description Case Submitted
     */
    public Boolean submitted { get; set; }
    /**
     * @description Case Submitted Time
     */
    public Datetime submittedTime { get; set; }
    /**
     * @description External Case Id
     */
    public String externalCaseId { get; set; }
    /**
     * @description External System
     */
    public String externalSystem { get; set; }
    /**
     * @description Description
     */
    public String description { get; set; }
    /**
     * @description Dispute Reason
     */
    public String disputeReason { get; set; }
    /**
     * @description Closed Date
     */
    public Datetime closedDate { get; set; }
    /**
     * @description Customer
     */
    public AccountModel customer { get; set; }
    /**
     * @description Owner
     */
    public UserModel owner { get; set; }
    /**
     * @description System Data
     */
    public CloudEventSystemModel systemData { get; set; }

    /**
     * @description get an instance of Case Details
     * @param theCase the Case record
     * @param theAccount the Case record
     * @param theOwner the Case record
     * @param theUser Account record
     */
    public CaseDetailsModel(
      Case theCase,
      Account theAccount,
      UserModel theOwner,
      User theUser
    ) {
      this.subject = theCase.Subject;
      this.status = theCase.Status;
      this.priority = theCase.Priority;
      this.caseNumber = theCase.CaseNumber;
      this.origin = theCase.Origin;
      this.submitted = theCase.Submitted__c;
      this.submittedTime = theCase.Submitted_Time__c;
      this.externalCaseId = theCase.External_Case_ID__c;
      this.externalSystem = theCase.External_System__c;
      this.description = theCase.Description;
      this.disputeReason = theCase.Dispute_Reason__c;
      this.closedDate = theCase.ClosedDate;
      this.customer = new AccountModel(theAccount);
      this.owner = theOwner;
      this.systemData = new CloudEventSystemModel(
        theCase.LastModifiedDate,
        theUser
      );
    }
  }

  /**
   * @description Inner Wrapper Class for the financial account data of All Dispute Cases
   */
  public class FinancialAccountModel {
    /**
     * @description Account BSB
     */
    public String bsb { get; set; }
    /**
     * @description Account Number
     */
    public String accountNumber { get; set; }

    /**
     * @description get an instance of FinancialAccountWrapper
     * @param theCase the Case record
     */
    public FinancialAccountModel(Case theCase) {
      this.bsb = theCase.Customer_Account_BSB__c;
      this.accountNumber = theCase.Customer_Account_Number__c;
    }
  }

  /**
   * @description Inner Wrapper Class for the transaction data of All Dispute Cases
   */
  public class TransactionModel {
    /**
     * @description Date Posted
     */
    public FabricType.FabricDate datePosted { get; set; }
    /**
     * @description Effective Date
     */
    public FabricType.FabricDate effectiveDate { get; set; }
    /**
     * @description Posted Amount
     */
    public FabricType.FabricMoney postedAmount { get; set; }
    /**
     * @description Transaction Amount
     */
    public FabricType.FabricMoney transactionAmount { get; set; }
    /**
     * @description Transaction Description
     */
    public String transactionDescription { get; set; }
    /**
     * @description Transaction Id
     */
    public String transactionId { get; set; }
    /**
     * @description Transaction UUID
     */
    public String transactionUuid { get; set; }
    /**
     * @description Made By
     */
    public String madeBy { get; set; }
    /**
     * @description Aux Dome Id
     */
    public String auxDomId { get; set; }
    /**
     * @description Transaction Status
     */
    public String status { get; set; }

    /**
     * @description get an instance of TransactionWrapper
     * @param theCase the Case record
     */
    public TransactionModel(Case theCase) {
      if (theCase.Date_Posted__c != null) {
        this.datePosted = new FabricType.FabricDate(theCase.Date_Posted__c);
      }
      if (theCase.Effective_Date__c != null) {
        this.effectiveDate = new FabricType.FabricDate(
          theCase.Effective_Date__c
        );
      }
      if (theCase.Posted_Amount__c != null) {
        this.postedAmount = new FabricType.FabricMoney(
          theCase.Posted_Currency__c,
          theCase.Posted_Amount__c
        );
      }
      if (theCase.Transaction_Amount__c != null) {
        this.transactionAmount = new FabricType.FabricMoney(
          theCase.Transaction_Currency__c,
          theCase.Transaction_Amount__c
        );
      }
      this.transactionDescription = theCase.Transaction_Description__c;
      this.transactionId = theCase.Transaction_Id__c;
      this.transactionUuid = theCase.Transaction_UUID__c;
      this.madeBy = theCase.Transaction_Made_By__c;
      this.auxDomId = theCase.AuxDomId__c;
      this.status = theCase.Transaction_Status__c;
    }
  }

  /**
   * @description Inner Wrapper Class for the Intended Account
   */
  public class IntendedAccountModel {
    /**
     * @description Account BSB
     */
    public String bsb { get; set; }
    /**
     * @description Account Number
     */
    public String accountNumber { get; set; }
    /**
     * @description Account Name
     */
    public String accountName { get; set; }
    /**
     * @description Pay Id Type
     */
    public String payIdType { get; set; }
    /**
     * @description Pay Id Value
     */
    public String payIdValue { get; set; }

    /**
     * @description get an instance of IntendedAccountModel
     * @param theCase the Case record
     */
    public IntendedAccountModel(Case theCase) {
      this.bsb = theCase.Intended_Account_BSB__c;
      this.accountNumber = theCase.Intended_Account_Number__c;
      this.accountName = theCase.Intended_Account_Name__c;
      this.payIdType = theCase.Intended_Pay_Id_Type__c;
      this.payIdValue = theCase.Intended_Pay_Id_Value__c;
    }
  }

  /**
   * @description Inner Wrapper Class for the Card Information
   */
  public class CardInformationModel {
    /**
     * @description Card Scheme
     */
    public String cardScheme { get; set; }
    /**
     * @description Card Number
     */
    public String cardNumber { get; set; }
    /**
     * @description Card In Possession During Transaction
     */
    public String cardInPossessionDuringTransaction { get; set; }
    /**
     * @description Is the Card Lost Stolen
     */
    public String isTheCardLostStolen { get; set; }
    /**
     * @description has the Card Been Stopped
     */
    public String hasTheCardBeenStopped { get; set; }
    /**
     * @description get an instance of CardInformationModel
     * @param theCase the Case record
     */
    public CardInformationModel(Case theCase) {
      this.cardScheme = theCase.Card_Scheme__c;
      this.cardNumber = theCase.Card_Number__c;
      this.cardInPossessionDuringTransaction = theCase.Card_In_Possession_During_Transaction__c;
      this.isTheCardLostStolen = theCase.Is_The_Card_Lost_Stolen__c;
      this.hasTheCardBeenStopped = theCase.Has_The_Card_Been_Stopped__c;
    }
  }

  /**
   * @description Inner Wrapper Class Biller Information
   */
  public class BillerInformationModel {
    /**
     * @description Biller Code
     */
    public String code { get; set; }
    /**
     * @description Biller Name
     */
    public String name { get; set; }
    /**
     * @description Customer Referance Number
     */
    public String customerReferenceNumber { get; set; }

    /**
     * @description get an instance of BillerInformationModel
     * @param theCase the Case record
     */
    public BillerInformationModel(Case theCase) {
      this.code = theCase.Biller_Code__c;
      this.name = theCase.Biller_Name__c;
      this.customerReferenceNumber = theCase.Customer_Reference_Number__c;
    }
  }

  /**
   * @description Inner Wrapper Class for the account data
   */
  public class AccountModel {
    /**
     * @description Account OCV Id
     */
    public String ocvId { get; set; }
    /**
     * @description Source System
     */
    public String sourceSystem { get; set; }
    /**
     * @description Source System Id
     */
    public String sourceSystemId { get; set; }

    /**
     * @description get an instance of AccountModel
     * @param theAccount the Account record
     */
    public AccountModel(Account theAccount) {
      this.ocvId = theAccount?.OCV_ID__c;
      this.sourceSystem = theAccount?.Source_System_Name__c;
      this.sourceSystemId = theAccount?.Source_System_ID__c;
    }
  }
}

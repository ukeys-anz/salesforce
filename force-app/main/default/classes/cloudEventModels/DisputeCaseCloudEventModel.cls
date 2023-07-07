/**
 * @author Lance Shi
 * @since  01/2023
 * @description Wrapper Class for Disputes' metadata and data
 */
@SuppressWarnings(
  'PMD.ApexDoc, PMD.ExcessivePublicCount, PMD.PropertyNamingConventions'
)
public virtual without sharing class DisputeCaseCloudEventModel extends CaseCloudEventModel {
  public DisputeCaseCloudEventModel(Case theCase, Account theAccount) {
    super(theCase);
    String sourceSystemName = '';
    if (
      theAccount?.Source_System_Name__c != null &&
      theAccount?.Source_System_ID__c != null
    ) {
      sourceSystemName =
        ',' +
        theAccount.Source_System_Name__c.toLowerCase() +
        '/' +
        theAccount?.Source_System_ID__c;
    }
    ce_xtargets = 'ocv/' + theAccount?.OCV_ID__c + sourceSystemName;
  }

  /**
   * @description the model for dispute Case cloud event data part
   */
  public virtual class DisputeCaseCloudEventDataModel extends CaseCloudEventModel.CaseCloudEventDataModel {
    public AccountModel customer { get; set; }
    public FinancialAccountModel financialAccount { get; set; }
    public TransactionModel transactionInformation { get; set; }
    public UserModel owner { get; set; }
    public String description { get; set; }
    public String disputeReason { get; set; }
    public String externalCaseId { get; set; }
    public String externalSystem { get; set; }
    public Boolean submitted { get; set; }
    public FabricType.Timestamp submittedTime { get; set; }

    public DisputeCaseCloudEventDataModel(Case theCase, Account theAccount) {
      super(theCase);
      this.customer = new AccountModel(theAccount);
      this.financialAccount = new FinancialAccountModel(theCase);
      this.transactionInformation = new TransactionModel(theCase);
      this.description = theCase.Description;
      this.disputeReason = theCase.Dispute_Reason__c;
      this.externalCaseId = theCase.External_Case_ID__c;
      this.externalSystem = theCase.External_System__c;
      this.submitted = theCase.Submitted__c;
      this.submittedTime = new FabricType.Timestamp(theCase.Submitted_Time__c);
    }
  }
  /**
   * @description Inner Wrapper Class for the account data of All Dispute Cases
   */
  public class AccountModel {
    public String ocvId { get; set; }
    public String sourceSystem { get; set; }
    public String sourceSystemId { get; set; }

    /**
     * @description get an instance of AccountModel
     * @param theCase the Case record
     */
    public AccountModel(Account theAccount) {
      this.ocvId = theAccount?.OCV_ID__c;
      this.sourceSystem = theAccount?.Source_System_Name__c;
      this.sourceSystemId = theAccount?.Source_System_ID__c;
    }
  }

  /**
   * @description Inner Wrapper Class for the financial account data of All Dispute Cases
   */
  public class FinancialAccountModel {
    public String bsb { get; set; }
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
    public FabricType.FabricDate datePosted { get; set; }
    public FabricType.FabricDate effectiveDate { get; set; }
    public FabricType.FabricMoney postedAmount { get; set; }
    public FabricType.FabricMoney transactionAmount { get; set; }
    public String transactionDescription { get; set; }
    public String transactionId { get; set; }
    public String transactionUuid { get; set; }

    /**
     * @description get an instance of TransactionWrapper
     * @param theCase the Case record
     */
    public TransactionModel(Case theCase) {
      this.datePosted = new FabricType.FabricDate(theCase.Date_Posted__c);
      this.effectiveDate = new FabricType.FabricDate(theCase.Effective_Date__c);
      this.postedAmount = new FabricType.FabricMoney(
        theCase.Posted_Currency__c,
        theCase.Posted_Amount__c
      );
      this.transactionAmount = new FabricType.FabricMoney(
        theCase.Transaction_Currency__c,
        theCase.Transaction_Amount__c
      );
      this.transactionDescription = theCase.Transaction_Description__c;
      this.transactionId = theCase.Transaction_Id__c;
      this.transactionUuid = theCase.Transaction_UUID__c;
    }
  }
}

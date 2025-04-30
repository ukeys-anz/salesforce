/**
 * @description model class for sop income view
 * @author @fangl6
 * @since 24/09/2024
 */
@SuppressWarnings('PMD.ExcessiveParameterList')
public with sharing class SOPIncomeViewModel {
  @AuraEnabled
  public String ownerName;
  @AuraEnabled
  public String employer;
  @AuraEnabled
  public String employmentType; //this is in api format, need to be formated to display, the api format will be used for edit debt. formatting logic ref: residentialLoanApplicationModel line: 815
  @AuraEnabled
  public String startDate;
  @AuraEnabled
  public List<IncomeItemDetails> incomeItemDetails;
  @AuraEnabled
  public TransactionIncomeItem transactionIncomeItem;
  @AuraEnabled
  public String incomeSource;
  @AuraEnabled
  public Datetime updateTime;
  @AuraEnabled
  public Boolean incomeVerified;
  @AuraEnabled
  public String etag;
  @AuraEnabled
  public String uid;
  @AuraEnabled
  public String name;
  @AuraEnabled
  public Map<String, String> partyIdToFirstNameMap;
  @AuraEnabled
  public String sopId;
  @AuraEnabled
  public String loanId;
  @AuraEnabled
  public string partyId;

  /**
   * @description view model for income item details
   */
  public class IncomeItemDetails {
    @AuraEnabled
    public String type;
    @AuraEnabled
    public String frequency;
    @AuraEnabled
    public Decimal amountValue;
    @AuraEnabled
    public String amountType;
    @AuraEnabled
    public Integer bonusPayments;
    /**
     * @description construtor to set the income item details
     * @param detail income item details
     */
    public IncomeItemDetails(SOPGetConsolidatedModel.Details detail) {
      this.type = detail.type;
      this.frequency = detail.frequency;
      this.amountValue = SOPHelper.convertAmountToDecimal(detail.amount);
      this.amountType = detail.amountType;
      this.bonusPayments = detail.bonusPayments;
    }
  }

  /**
   * @description view model for transaction income item
   */
  public class TransactionIncomeItem {
    @AuraEnabled
    public String frequency;
    @AuraEnabled
    public Decimal amountValue;
    /**
     * @description constructor to set the transaction income item
     * @param detail transaction income item
     */
    public TransactionIncomeItem(SOPGetConsolidatedModel.StreamDetails detail) {
      this.frequency = detail.frequency;
      this.amountValue = SOPHelper.convertAmountToDecimal(detail.amount);
    }
  }

  public static final String ASSET_TYPE_VERIFICATION = 'VERIFICATION_METHOD_DOCUMENT';
  public static final String INCOME_TRANSACTION_VERIFICATION = 'VERIFICATION_METHOD_TRANSACTIONS';
  public static final String INCOME_SOURCE_MANUAL = 'Manual';
  public static final String INCOME_SOURCE_TRANSACTIONS = 'Transactions';
  public static final String SALARY_WAGES_INCOME = 'INCOME_TYPE_SALARY_WAGES';

  /**
   * @description constructor for SOPIncomeViewModel
   * @param sourceData source data
   * @param partyIdToFirstNameMap party id to first name map
   * @param sopId the sop component name
   */
  public SOPIncomeViewModel(
    SOPGetConsolidatedModel.Incomes sourceData,
    Map<String, String> partyIdToFirstNameMap,
    String sopId
  ) {
    this.sopId = sopId;
    this.ownerName = sourceData.employment?.partyId != null
      ? partyIdToFirstNameMap.get(sourceData.employment.partyId)
      : null;
    this.partyId = sourceData.employment?.partyId;
    this.partyIdToFirstNameMap = partyIdToFirstNameMap;
    this.employer = sourceData.employment?.businessName;
    this.employmentType = sourceData.employment?.basis;
    this.startDate = sourceData.employment?.startDate?.getStartDateStr();
    this.updateTime = sourceData.updateTime;
    this.incomeSource = setIncomeSource(sourceData.stream);
    this.incomeVerified = setIncomeVerified(
      sourceData.verification,
      this.incomeSource
    );
    this.incomeItemDetails = setIncomeItemDetails(sourceData.details);
    this.transactionIncomeItem = setTransactionIncomeItem(sourceData.stream);
    this.etag = sourceData.etag;
    this.uid = sourceData.uid;
    this.name = sourceData.name;
  }

  /**
   * @description set income source
   * @param stream stream object from api model
   * @return  `String` income source in view model
   */
  public static String setIncomeSource(SOPGetConsolidatedModel.Stream stream) {
    return (stream == null ? INCOME_SOURCE_MANUAL : INCOME_SOURCE_TRANSACTIONS);
  }

  /**
   * @description set income verified
   * @param verification verification of api model
   * @param source income source from api
   * @return  `Boolean` income verified in view model
   */
  public static Boolean setIncomeVerified(
    SOPGetConsolidatedModel.Verification verification,
    String source
  ) {
    if (
      verification?.method == ASSET_TYPE_VERIFICATION ||
      (source == INCOME_SOURCE_TRANSACTIONS &&
      verification?.method == INCOME_TRANSACTION_VERIFICATION)
    ) {
      return true;
    }
    return false;
  }

  /**
   * @description set income item details
   * @param details details of api model
   * @return  `List<IncomeItemDetails>` income item details view model
   */
  public static List<IncomeItemDetails> setIncomeItemDetails(
    List<SOPGetConsolidatedModel.Details> details
  ) {
    List<IncomeItemDetails> itemList = new List<IncomeItemDetails>();
    for (SOPGetConsolidatedModel.Details detail : details) {
      itemList.add(new IncomeItemDetails(detail));
    }
    return itemList;
  }

  /**
   * @description set transaction income item
   * @param stream steam of api model
   * @return  `TransactionIncomeItem` transaction income item view model
   */
  public static TransactionIncomeItem setTransactionIncomeItem(
    SOPGetConsolidatedModel.Stream stream
  ) {
    if (stream == null) {
      return null;
    }
    for (SOPGetConsolidatedModel.StreamDetails detail : stream.details) {
      if (detail?.incomeType == SALARY_WAGES_INCOME) {
        return new TransactionIncomeItem(detail);
      }
    }
    return null;
  }
}

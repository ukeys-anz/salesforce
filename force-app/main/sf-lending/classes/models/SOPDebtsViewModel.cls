/**
 * @author @fangl6
 * @since 10/2024
 * @description View model for debt finance section of getConsolidatedSOP API call
 */
@SuppressWarnings('PMD.ExcessivePublicCount,PMD.TooManyFields')
public with sharing class SOPDebtsViewModel {
  @AuraEnabled
  public String ownerName;
  @AuraEnabled
  public Datetime updateTime;
  @AuraEnabled
  public String type;
  @AuraEnabled
  public String sourceType;
  @AuraEnabled
  public InstitutionalLiability institutionalLiability;
  @AuraEnabled
  public String bsb;
  @AuraEnabled
  public String accountNumber;
  @AuraEnabled
  public Decimal outstandingBalance;
  @AuraEnabled
  public Decimal outstandingBalanceNegative;
  @AuraEnabled
  public Decimal verifiedOutstandingBalance;
  @AuraEnabled
  public Decimal verifiedOutstandingBalanceNegative;
  @AuraEnabled
  public Boolean customerStatedClosed;
  @AuraEnabled
  public Boolean paidOffAndClosed;
  @AuraEnabled
  public Boolean evidenceProvided;
  @AuraEnabled
  public String status;
  @AuraEnabled
  public String termType;
  @AuraEnabled
  public String readableTermType;
  @AuraEnabled
  public Boolean validatedOutstandingBalance;
  @AuraEnabled
  public StudentLoan studentLoan;
  @AuraEnabled
  public Decimal overdraftBalance;
  @AuraEnabled
  public Decimal overdraftBalanceNegative;
  @AuraEnabled
  public String cardNumber;
  @AuraEnabled
  public Boolean hasRefinance;
  @AuraEnabled
  public String uid;
  @AuraEnabled
  public String name;
  @AuraEnabled
  public String etag;
  @AuraEnabled
  public String accountId;

  /**
   * @description Institutional Liability model
   */
  public class InstitutionalLiability {
    @AuraEnabled
    public String financialInstitution;
    @AuraEnabled
    public Decimal redrawAmount;
    @AuraEnabled
    public Decimal minimumRepayment;
    @AuraEnabled
    public Boolean paidInFull;
    @AuraEnabled
    public String paymentMethod;
    @AuraEnabled
    public String interestRate;
    @AuraEnabled
    public Integer originalInterestRateValue;
    @AuraEnabled
    public Integer interestOnlyRemainingTerm;
    @AuraEnabled
    public Boolean validatedLimit;
    @AuraEnabled
    public Integer principalInterestRemainingTerm;
    @AuraEnabled
    public String readablePrincipalInterestRemainingTerm;
    @AuraEnabled
    public Integer verifiedPrincipalInterestRemainingTerm;
    @AuraEnabled
    public String readableVerifiedPrincipalInterestRemainingTerm;
    @AuraEnabled
    public Decimal repaymentAmount;
    @AuraEnabled
    public String repaymentFrequency;
    @AuraEnabled
    public Boolean validatedPrincipalInterestRemainingTerm;
    @AuraEnabled
    public Decimal limitAmount;
    @AuraEnabled
    public Decimal limitAmountNegative;

    /**
     * @description Constructor for InstitutionalLiability
     * @param sourceData InstitutionalLiability api data
     */
    public InstitutionalLiability(
      SOPGetConsolidatedModel.InstitutionalLiability sourceData
    ) {
      this.financialInstitution = sourceData?.financialInstitution;
      if (sourceData.redrawAmount != null) {
        this.redrawAmount = SOPHelper.convertAmountToDecimal(
          sourceData.redrawAmount
        );
      }
      if (sourceData.repaymentAmount != null) {
        this.minimumRepayment = SOPHelper.convertAmountToDecimal(
          sourceData.repaymentAmount
        );
        this.repaymentAmount = SOPHelper.convertAmountToDecimal(
          sourceData.repaymentAmount
        );
      }
      this.paidInFull = sourceData?.paidInFull;
      this.paymentMethod = sourceData?.paymentMethod;
      this.interestRate = setInterestRate(sourceData.interestRate);
      this.originalInterestRateValue = sourceData.interestRate;
      this.interestOnlyRemainingTerm = sourceData?.interestOnlyRemainingTerm;
      this.validatedLimit = sourceData?.validatedLimit;
      this.principalInterestRemainingTerm = sourceData.principalInterestRemainingTerm;
      this.readablePrincipalInterestRemainingTerm = setReadableTerm(
        sourceData.principalInterestRemainingTerm
      );
      this.verifiedPrincipalInterestRemainingTerm = sourceData.verifiedPrincipalInterestRemainingTerm;
      this.readableVerifiedPrincipalInterestRemainingTerm = setReadableTerm(
        sourceData.verifiedPrincipalInterestRemainingTerm
      );

      this.repaymentFrequency = sourceData?.repaymentFrequency;
      this.validatedPrincipalInterestRemainingTerm = sourceData
        ?.validatedPrincipalInterestRemainingTerm;
      if (sourceData.limitAmount != null) {
        this.limitAmount = SOPHelper.convertAmountToDecimal(
          sourceData.limitAmount
        );
        this.limitAmountNegative = -SOPHelper.convertAmountToDecimal(
          sourceData.limitAmount
        );
      }
    }
  }

  /**
   * @description Student Loan model
   */
  public class StudentLoan {
    @AuraEnabled
    public Boolean hecsWithheldPayment;
    /**
     * @description Constructor for StudentLoan
     * @param sourceData StudentLoan api data
     */
    public StudentLoan(SOPGetConsolidatedModel.StudentLoan sourceData) {
      this.hecsWithheldPayment = sourceData.hecsWithheldPayment;
    }
  }

  /**
   * @description Constructor for Debts view model
   * @param sourceData liabilities api data
   * @param partyIdToFirstNameMap party id to first name map
   * @param refinanceSet debts being refinanced
   */
  public SOPDebtsViewModel(
    SOPGetConsolidatedModel.Liabilities sourceData,
    Map<String, String> partyIdToFirstNameMap,
    Set<String> refinanceSet
  ) {
    this.ownerName = setOwnerName(
      sourceData.ownership,
      sourceData.type,
      partyIdToFirstNameMap
    );
    this.updateTime = sourceData.updateTime;
    this.type = sourceData.type;
    this.termType = sourceData?.termType;
    this.readableTermType = sourceData?.termType == 'LIABILITY_TERM_TYPE_FIXED'
      ? 'Fixed'
      : sourceData?.termType == 'LIABILITY_TERM_TYPE_VARIABLE'
          ? 'Variable'
          : 'Unspecified';
    this.sourceType = sourceData?.sources[0];
    this.bsb = sourceData?.account?.bsb;
    this.accountNumber = sourceData?.account?.accountNumber;
    this.cardNumber =
      'xxxx xxxx xxxx ' + sourceData?.account?.accountNumber?.right(4);
    this.outstandingBalance = SOPHelper.convertAmountToDecimal(
      sourceData.outstandingBalance
    );
    this.outstandingBalanceNegative = -SOPHelper.convertAmountToDecimal(
      sourceData.outstandingBalance
    );
    this.verifiedOutstandingBalance = SOPHelper.convertAmountToDecimal(
      sourceData?.verifiedOutstandingBalance
    );
    this.verifiedOutstandingBalanceNegative = -SOPHelper.convertAmountToDecimal(
      sourceData?.verifiedOutstandingBalance
    );
    this.customerStatedClosed = sourceData?.customerStatedClosed;
    this.paidOffAndClosed = sourceData?.paidOffAndClosed;
    this.evidenceProvided = sourceData?.evidenceProvided;
    this.status = sourceData?.account?.status;
    this.accountId = sourceData?.account?.id;
    this.validatedOutstandingBalance = sourceData?.validatedOutstandingBalance;
    if (sourceData.studentLoan != null) {
      this.studentLoan = new StudentLoan(sourceData.studentLoan);
    }
    this.overdraftBalance = SOPHelper.convertAmountToDecimal(
      sourceData.outstandingBalance
    );
    this.overdraftBalanceNegative = -SOPHelper.convertAmountToDecimal(
      sourceData.outstandingBalance
    );
    if (sourceData.institutionalLiability != null) {
      this.institutionalLiability = new InstitutionalLiability(
        sourceData.institutionalLiability
      );
    }
    this.hasRefinance =
      (sourceData.type == 'LIABILITY_TYPE_HOME_LOAN' ||
      sourceData.type == 'LIABILITY_TYPE_LINE_OF_CREDIT') &&
      refinanceSet.contains(sourceData.name);
    this.uid = sourceData.uid;
    this.name = sourceData.name;
    this.etag = sourceData.etag;
  }
  /**
   * @description Set owner name
   * @param ownership ownership data
   * @param type liability type
   * @param partyIdToFirstNameMap party id to first name map
   * @return owner name
   */
  public static String setOwnerName(
    List<SOPGetConsolidatedModel.Ownership> ownership,
    String type,
    Map<String, String> partyIdToFirstNameMap
  ) {
    if (ownership == null || ownership.isEmpty()) {
      return null;
    }

    String someoneElse = ' & Someone Else';
    String firstOwnerName = partyIdToFirstNameMap.get(ownership[0].partyId);

    if (ownership.size() == 1) {
      return Integer.valueOf(ownership[0].proportion.value) == 100
        ? firstOwnerName
        : firstOwnerName + someoneElse;
    }

    String secondOwnerName = partyIdToFirstNameMap.get(ownership[1].partyId);
    // joint owner name for credit card and bnpl facility
    if (
      type == 'LIABILITY_TYPE_BPL_LOAN' ||
      type == 'LIABILITY_TYPE_BPL_FACILITY' ||
      type == 'LIABILITY_TYPE_STUDENT_LOAN'
    ) {
      return firstOwnerName != null ? firstOwnerName : secondOwnerName;
    }
    if (firstOwnerName != null && secondOwnerName != null) {
      return 'Joint';
    }
    return firstOwnerName != null
      ? firstOwnerName + someoneElse
      : secondOwnerName + someoneElse;
  }

  /**
   * @description Set readable interest rate
   * @param interest interest rate
   * @return readable interest rate
   */
  public static String setInterestRate(Integer interest) {
    if (interest == null) {
      return '';
    }
    return (Decimal.valueOf(interest) / 100).setScale(2) + '%';
  }

  /**
   * @description transform total number of months into a string of years and months
   * @param totalMonths number of months from the payload
   * @return String formatted years and months to display in the card
   */
  public static String setReadableTerm(Integer totalMonths) {
    if (totalMonths == null || totalMonths == 0) {
      return '0';
    }
    Integer years = totalMonths / 12;
    Integer months = Math.mod(totalMonths, 12);
    String result = '';
    if (years > 0) {
      result += years + ' year';
      if (years > 1) {
        result += 's';
      }
      if (months > 0) {
        result += ', ';
      }
    }
    if (months > 0) {
      result += months + ' month';
      if (months > 1) {
        result += 's';
      }
    }
    return result;
  }
}

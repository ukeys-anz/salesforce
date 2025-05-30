/**
 * @author @fangl6
 * @since 10/2024
 * @description View model for debt finance section of getConsolidatedSOP API call
 */
@SuppressWarnings(
  'PMD.ExcessivePublicCount,PMD.TooManyFields,PMD.ExcessiveParameterList'
)
public with sharing class SOPDebtsViewModel {
  private static final Map<String, String> TERM_TYPE = new Map<String, String>{
    'LIABILITY_TERM_TYPE_UNSPECIFIED' => 'Unspecified',
    'LIABILITY_TERM_TYPE_FIXED' => 'Fixed',
    'LIABILITY_TERM_TYPE_VARIABLE' => 'Variable'
  };

  private static final Map<String, String> PAYMENT_TYPE = new Map<String, String>{
    'PAYMENT_METHOD_UNSPECIFIED' => 'Unspecified',
    'PAYMENT_METHOD_PRINCIPAL_INTEREST' => 'Principal & Interest',
    'PAYMENT_METHOD_INTEREST_ONLY' => 'Interest Only',
    'PAYMENT_METHOD_METHOD_R' => 'Principal and Interest',
    'PAYMENT_METHOD_METHOD_N' => 'Not Applicable'
  };

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
  @AuraEnabled
  public Decimal undrawnAmount;
  @AuraEnabled
  public Boolean fullyDrawn;
  @AuraEnabled
  public List<String> linkedProperty;
  @AuraEnabled
  public String belongsTo;
  @AuraEnabled
  public String ownershipSplit;
  @AuraEnabled
  public String productName;
  @AuraEnabled
  public List<Map<String, String>> ownership;
  @AuraEnabled
  public List<String> assets;
  @AuraEnabled
  public String homeLoanType;
  @AuraEnabled
  public String rateType;
  @AuraEnabled
  public String repaymentType;

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
    @AuraEnabled
    public String taxDeductiblePercentage;
    @AuraEnabled
    public Double taxDeductiblePercentageOriginal;
    @AuraEnabled
    public Boolean interestRateValidated;
    @AuraEnabled
    public String initialMargin;
    @AuraEnabled
    public String initialIndexRate;
    @AuraEnabled
    public String initialIndexCode;
    @AuraEnabled
    public String subsequentMargin;
    @AuraEnabled
    public String subsequentIndexRate;
    @AuraEnabled
    public String subsequentIndexCode;
    @AuraEnabled
    public String subsequentInterestRate;
    @AuraEnabled
    public String loanPurposeCode;

    /**
     * @description Constructor for InstitutionalLiability
     * @param sourceData InstitutionalLiability api data
     */
    @SuppressWarnings('PMD.NcssConstructorCount')
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
      //Interest rate is returned as basis points (5.5% -> 550), so we need to convert it
      this.interestRate = setPercentage(sourceData.interestRate, false);
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

      this.taxDeductiblePercentage = sourceData.taxDeductiblePercentage == null
        ? '0%'
        : sourceData.taxDeductiblePercentage + '%';
      this.interestRateValidated = sourceData.interestRateValidated;
      this.taxDeductiblePercentageOriginal = sourceData.taxDeductiblePercentage;
      this.initialMargin = setPercentage(sourceData.initialMargin, true);
      this.initialIndexRate = setPercentage(sourceData.initialIndexRate, true);
      this.initialIndexCode = sourceData.initialIndexCode;
      this.subsequentMargin = setPercentage(sourceData.subsequentMargin, true);
      this.subsequentIndexRate = setPercentage(
        sourceData.subsequentIndexRate,
        true
      );
      this.subsequentIndexCode = sourceData.subsequentIndexCode;
      this.subsequentInterestRate = setPercentage(
        sourceData.subsequentInterestRate,
        true
      );
      this.loanPurposeCode = sourceData.loanPurposeCode;
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
   * @param assetPropertyLookup map of address lookup
   */
  @SuppressWarnings('PMD.NcssConstructorCount')
  public SOPDebtsViewModel(
    SOPGetConsolidatedModel.Liabilities sourceData,
    Map<String, String> partyIdToFirstNameMap,
    Set<String> refinanceSet,
    Map<String, SOPGetConsolidatedModel.Assets> assetPropertyLookup
  ) {
    this.ownerName = setOwnerName(
      sourceData.ownership,
      sourceData.type,
      partyIdToFirstNameMap
    );

    Map<String, String> ownershipMap = SOPHelper.buildOwnershipStrings(
      sourceData.ownership,
      partyIdToFirstNameMap
    );

    this.belongsTo = ownershipMap.get('belongs-to');
    this.ownershipSplit = ownershipMap.get('ownership-split');
    this.ownership = SOPHelper.setOwnership(sourceData.ownership);

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
    this.undrawnAmount = SOPHelper.convertAmountToDecimal(
      sourceData.undrawnAmount
    );
    this.fullyDrawn = sourceData.fullyDrawn;
    this.linkedProperty = SOPHelper.getAssetsFromassetPropertyLookup(
      sourceData?.assets,
      assetPropertyLookup
    );
    this.productName = sourceData?.account?.productDetails?.marketingName;
    this.assets = sourceData.assets;

    //Determine the home loan type based on the source data
    if (
      sourceData.type == 'LIABILITY_TYPE_HOME_LOAN' &&
      sourceData.sources[0] == 'LIABILITY_SOURCE_TYPE_ANZ'
    ) {
      this.rateType = TERM_TYPE.get(sourceData.termType);
      this.repaymentType = PAYMENT_TYPE.get(
        sourceData.institutionalLiability?.paymentMethod
      );

      this.homeLoanType = handleHomeLoanType(sourceData);
    }
    //Determine the personal loan type based on the source data
    if (
      sourceData.type == 'LIABILITY_TYPE_PERSONAL_LOAN' &&
      sourceData.sources[0] == 'LIABILITY_SOURCE_TYPE_ANZ'
    ) {
      this.rateType = TERM_TYPE.get(sourceData.termType);
    }
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
   * @description Set readable percentage
   * @param percentage percentage to set
   * @param noPercentSign append % sign only on strings
   * @return readable percentage
   */
  public static String setPercentage(
    Integer percentage,
    Boolean noPercentSign
  ) {
    if (percentage == null) {
      return '';
    }

    if (noPercentSign) {
      return String.valueOf((Decimal.valueOf(percentage) / 100).setScale(2));
    }

    return (Decimal.valueOf(percentage) / 100).setScale(2) + '%';
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

  /**
   * @description Set home loan type
   * @param sourceData
   * @return String home loan type
   */
  private static String handleHomeLoanType(
    SOPGetConsolidatedModel.Liabilities sourceData
  ) {
    if (!sourceData.fullyDrawn) {
      return 'Construction';
    } else if (
      sourceData.termType == 'LIABILITY_TERM_TYPE_VARIABLE' &&
      sourceData.institutionalLiability?.paymentMethod ==
      'PAYMENT_METHOD_INTEREST_ONLY'
    ) {
      return 'Variable IO';
    } else if (
      sourceData.termType == 'LIABILITY_TERM_TYPE_FIXED' &&
      sourceData.institutionalLiability?.paymentMethod ==
      'PAYMENT_METHOD_PRINCIPAL_INTEREST'
    ) {
      return 'Fixed P&I';
    } else if (
      sourceData.termType == 'LIABILITY_TERM_TYPE_FIXED' &&
      sourceData.institutionalLiability?.paymentMethod ==
      'PAYMENT_METHOD_INTEREST_ONLY'
    ) {
      return 'Fixed IO';
    } else {
      return 'Variable P&I';
    }
  }
}

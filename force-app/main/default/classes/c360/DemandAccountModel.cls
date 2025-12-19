/**
 * @author Prahlad Bhadani
 * @since  10/2025
 * @group Platform
 * @description Demand Account Model Class
 */
@SuppressWarnings(
  'PMD.TooManyFields,PMD.FieldNamingConventions,PMD.ExcessivePublicCount,PMD.ClassNamingConventions'
)
public class DemandAccountModel extends FinancialAccountEntities.FinancialAccountCalloutResponse {
  public String accountNumber;
  public String accountName;
  public String status;
  public Decimal accountBalance;
  public Decimal accountLimit;
  public String productCode;
  public String outOfBoundsProObpCode;
  public Decimal directExcessFeeToAlternativeDda;
  public String creditRating;
  public String directExcessFeeTo;
  public String securityIndicator;
  public Decimal excessFeeAmount;
  public String penaltyInterestApplicable;
  public Decimal agentCollectionItems;
  public statementCycles statementCycles;
  public Decimal agentCredits;
  public Date nextStatementDate;
  public Decimal electronicCredits;
  public String mailingCode;
  public Decimal electronicDebits;
  public String numberOfCopies;
  public Decimal paperCollectionItems;
  public String commitment;
  public Decimal paperCredits;
  public limitTypes limitTypes;
  public Decimal paperDebits;
  public currentGrossLimits currentGrossLimits;
  public Decimal annualBaseFee;
  public String serviceChargeTypeCode;
  public String directBankFeesTo;
  public String bankFeeCycleCode;
  public String creditInterestTo;
  public String waiveCode;
  public String currentInterestBasis;
  public facilityTypes facilityTypes;
  public tieredCreditInterest tieredCreditInterest;
  public dates startDates;
  public Date effectiveDate;
  public dates expiryDates;
  public String negativeInterestApplicable;
  public Date facilityStartDate;
  public String creditInterestCycle;
  public Date lastOpportunityToReprice;
  public String creditInterestCode;
  public Date nextOpportunityToReprice;
  public String accountCategory;
  public Date managersReviewDate;
  public String anzsic;
  public Date annualReviewDate;
  public String accountTitle;
  public String purposeCode;
  public accountNameLines accountNameLines;
  public String refinanceAlterationAdditionIndicator;
  public String domicileBranch;
  public String instructions;
  public String costCentre;
  public Decimal interestBasis;
  public String ownershipCode;
  public String interestCycle;
  public Decimal balance;
  public Decimal pointDifferenceMargin;
  public percentageFactors percentageFactors;
  public String subProductCode;
  public pointsDifference pointsDifferences;
  public limits limits;
  public String shortName;
  public String penaltyInterest;
  public String accountToDebitForInterest;
  public String error;
  /**
   * @description tieredCreditInterest class
   */
  public class tieredCreditInterest {
    public pointsDifference pointsDifferences;
    public limits limits;
    public percentageFactors percentageFactors;
  }
  /**
   * @description statementCycles class
   */
  public class statementCycles {
    public String statementCycle2;
    public String statementCycle1;
  }
  /**
   * @description pointsDifference class
   */
  public class pointsDifference {
    public Decimal pointsDifference1;
    public Decimal pointsDifference6;
    public Decimal pointsDifference5;
    public Decimal pointsDifference7;
    public Decimal pointsDifference4;
    public Decimal pointsDifference8;
    public Decimal pointsDifference3;
    public Decimal pointsDifference9;
    public Decimal pointsDifference2;
  }
  /**
   * @description percentageFactors class
   */
  public class percentageFactors {
    public Decimal percentageFactor1;
    public Decimal percentageFactor2;
    public Decimal percentageFactor3;
    public Decimal percentageFactor4;
    public Decimal percentageFactor5;
    public Decimal percentageFactor6;
    public Decimal percentageFactor7;
    public Decimal percentageFactor8;
    public Decimal percentageFactor9;
  }
  /**
   * @description limitTypes class
   */
  public class limitTypes {
    public String type1;
    public String type2;
    public String type3;
  }
  /**
   * @description limits class
   */
  public class limits {
    public Decimal limit1;
    public Decimal limit2;
    public Decimal limit3;
    public Decimal limit4;
    public Decimal limit5;
    public Decimal limit6;
    public Decimal limit7;
    public Decimal limit8;
    public Decimal limit9;
  }
  /**
   * @description facilityTypes class
   */
  public class facilityTypes {
    public String type1;
    public String type2;
    public String type3;
  }

  /**
   * @description currentGrossLimits class
   */
  public class currentGrossLimits {
    public Decimal limit1;
    public Decimal limit2;
    public Decimal limit3;
  }
  /**
   * @description accountNameLines class
   */
  public class accountNameLines {
    public String accountNameLine1;
    public String accountNameLine2;
    public String accountNameLine3;
  }

  /**
   * @description dates class
   */
  public class dates {
    public Date data1;
    public Date data2;
    public Date data3;
  }

  /**
   * @description CacheFinancialAccountModel class
   */
  public class CacheFinancialAccountModel extends FinancialAccountModelBase {
  }
  /**
   * @description getCacheFinancialAccountModel method
   * @return CacheFinancialAccountModel
   */
  public CacheFinancialAccountModel getCacheFinancialAccountModel() {
    CacheFinancialAccountModel faBase = new CacheFinancialAccountModel();
    faBase.accountNumber = this.accountNumber;
    faBase.accountName = this.accountName;
    faBase.status = this.status;
    faBase.productCode = this.productCode;
    return faBase;
  }
}

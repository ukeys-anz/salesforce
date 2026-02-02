/**
 * @author Prahlad Bhadani
 * @since  10/2025
 * @group Platform
 * @description Liability Account Model Class
 */
@SuppressWarnings(
  'PMD.TooManyFields,PMD.FieldNamingConventions,PMD.ExcessivePublicCount,PMD.ClassNamingConventions'
)
public with sharing class LiabilityAccountModel extends FinancialAccountEntities.FinancialAccountCalloutResponse {
  public String accountNumber;
  public String accountName;
  public String status;
  public Decimal accountBalance;
  public Decimal accountLimit;
  public String productCode;
  public String bankingCodeOfPractice;
  public String anzsic;
  public String accountSecuritisationIndicator;
  public String accountTitle;
  public String purposeCode;
  public accountNameLines accountNameLines;
  public String creditRating;
  public String commitment;
  public String securityIndicator;
  public String serviceBranch;
  public Decimal unavailableFunds;
  public String domicileBranch;
  public String facilityType;
  public String costCentre;
  public Date facilityStartDate;
  public String ownershipCode;
  public Date lastOpportunityToReprice;
  public Decimal balance;
  public Date nextOpportunityToReprice;
  public Date limitExpiryDate;
  public String subProductCode;
  public Date annualReviewDate;
  public String code;
  public String shortName;
  public String refinanceAlterationAdditionalIndicator;
  public String riinc;
  public Date lastLimitChangeDate;
  public String error;

  /**
   * @description accountNameLines class
   */
  public class accountNameLines {
    public String accountNameLine3;
    public String accountNameLine2;
    public String accountNameLine1;
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

/**
 * @author Peter Charalambous
 * @since Tue Nov 19 2024
 * @description Add/Edit debt model
 */

public with sharing class SOPAddEditDebtModel extends CalloutModel {
  /**
   * @description Parent ID
   */
  @AuraEnabled
  public String parent { get; set; }

  /**
   * @description Liability details
   */
  @AuraEnabled
  public Liability liability { get; set; }

  /**
   * @description UID of debt
   */
  @AuraEnabled
  public String uid { get; set; }

  /**
   * @description Name of debt
   */
  @AuraEnabled
  public String name { get; set; }

  /**
   * @description etag of debt
   */
  @AuraEnabled
  public String etag { get; set; }

  /**
   * @description Liability model
   */
  public class Liability {
    /**
     * @description UID of debt
     */
    @AuraEnabled
    public String uid { get; set; }

    /**
     * @description Name of debt
     */
    @AuraEnabled
    public String name { get; set; }

    /**
     * @description etag of debt
     */
    @AuraEnabled
    public String etag { get; set; }
    /**
     * @description Type of liability
     */
    @AuraEnabled
    public String type { get; set; }

    /**
     * @description Institutional liability details
     */
    @AuraEnabled
    public InstitutionalLiability institutionalLiability { get; set; }

    /**
     * @description Outstanding balance
     */
    @AuraEnabled
    public FabricType.Fabric_money outstandingBalance { get; set; }

    /**
     * @description Balance owing of debt
     */
    @AuraEnabled
    public Decimal outstandingBalanceValue {
      get;
      set {
        if (value != null) {
          this.outstandingBalanceValue = value;
          this.outstandingBalance = new FabricType.Fabric_money(
            'AUD',
            this.outstandingBalanceValue
          );
        }
        this.outstandingBalanceValue = null;
      }
    }

    /**
     * @description Outstanding balance
     */
    @AuraEnabled
    public FabricType.Fabric_money verifiedOutstandingBalance { get; set; }

    /**
     * @description Balance owing of debt
     */
    @AuraEnabled
    public Decimal verifiedOutstandingBalanceValue {
      get;
      set {
        if (value != null) {
          this.verifiedOutstandingBalanceValue = value;
          this.verifiedOutstandingBalance = new FabricType.Fabric_money(
            'AUD',
            this.verifiedOutstandingBalanceValue
          );
        }
        this.verifiedOutstandingBalanceValue = null;
      }
    }

    /**
     * @description Account details
     */
    @AuraEnabled
    public Account account { get; set; }

    /**
     * @description Sources of the debt
     */
    @AuraEnabled
    public List<String> sources { get; set; }

    /**
     * @description Ownership details
     */
    @AuraEnabled
    public List<Ownership> ownership { get; set; }

    /**
     * @description Student loan details
     */
    @AuraEnabled
    public StudentLoan studentLoan { get; set; }

    /**
     * @description Indicates if the debt is paid off and closed
     */
    @AuraEnabled
    public Boolean paidOffAndClosed { get; set; }

    /**
     * @description Indicates if debt evidence has been provided
     */
    @AuraEnabled
    public Boolean evidenceProvided { get; set; }

    /**
     * @description Indicates if the customer advised debt is closed
     */
    @AuraEnabled
    public Boolean customerStatedClosed { get; set; }

    /**
     * @description validated outstanding balance
     */
    @AuraEnabled
    public Boolean validatedOutstandingBalance { get; set; }

    /**
     * @description Term Type
     */
    @AuraEnabled
    public String termType { get; set; }
  }

  /**
   * @description InstitutionalLiability model
   */
  public class InstitutionalLiability {
    /**
     * @description Limit amount
     */
    @AuraEnabled
    public FabricType.Fabric_money limitAmount { get; set; }

    /**
     * @description Balance owing of debt
     */
    @AuraEnabled
    public Decimal limitValue {
      get;
      set {
        if (value != null) {
          this.limitValue = value;
          this.limitAmount = new FabricType.Fabric_money(
            'AUD',
            this.limitValue
          );
        }
        this.limitValue = null;
      }
    }

    /**
     * @description Financial institution name
     */
    @AuraEnabled
    public String financialInstitution { get; set; }

    /**
     * @description Indicates if the liability is paid in full
     */
    @AuraEnabled
    public Boolean paidInFull { get; set; }

    /**
     * @description Repayment amount
     */
    @AuraEnabled
    public FabricType.Fabric_money repaymentAmount { get; set; }

    /**
     * @description Repayment amount value
     */
    @AuraEnabled
    public Decimal repaymentAmountValue {
      get;
      set {
        if (value != null) {
          this.repaymentAmountValue = value;
          this.repaymentAmount = new FabricType.Fabric_money(
            'AUD',
            this.repaymentAmountValue
          );
        }
        this.repaymentAmountValue = null;
      }
    }

    /**
     * @description Debt type
     */
    @AuraEnabled
    public String debtType { get; set; }

    /**
     * @description Repayment frequency
     */
    @AuraEnabled
    public String repaymentFrequency {
      get;
      set {
        this.repaymentFrequency = value;
        if (this.debtType == 'LIABILITY_TYPE_CREDIT_CARD' && !this.paidInFull) {
          this.repaymentFrequency = 'FREQUENCY_MONTHLY';
        }
        this.debtType = null;
      }
    }

    /**
     * @description Remaining term for principal and interest
     */
    @AuraEnabled
    public Integer principalInterestRemainingTerm { get; set; }

    /**
     * @description Remaining term for bureau principal and interest
     */
    @AuraEnabled
    public Integer verifiedPrincipalInterestRemainingTerm { get; set; }

    /**
     * @description Use updated credit limit for UMI
     */
    @AuraEnabled
    public Boolean validatedLimit { get; set; }

    /**
     * @description Use updated credit limit for UMI
     */
    @AuraEnabled
    public FabricType.Fabric_money minimumRepayment { get; set; }

    /**
     * @description Minimum monthly repayment value
     */
    @AuraEnabled
    public Decimal minimumMonthRepaymentValue {
      get;
      set {
        if (value != null) {
          this.minimumMonthRepaymentValue = value;
          this.minimumRepayment = new FabricType.Fabric_money(
            'AUD',
            this.minimumMonthRepaymentValue
          );
        }
        this.minimumMonthRepaymentValue = null;
      }
    }

    /**
     * @description debt interest rate
     */
    @AuraEnabled
    public Decimal interestRate { get; set; }

    /**
     * @description Redraw amount
     */
    @AuraEnabled
    public FabricType.Fabric_money redrawAmount { get; set; }

    /**
     * @description Redraw amount value
     */
    @AuraEnabled
    public Decimal redrawAmountValue {
      get;
      set {
        if (value != null) {
          this.redrawAmountValue = value;
          this.redrawAmount = new FabricType.Fabric_money(
            'AUD',
            this.redrawAmountValue
          );
        }
        this.redrawAmountValue = null;
      }
    }

    /**
     * @description Use updated remaining term for UMI
     */
    @AuraEnabled
    public Boolean validatedPrincipalInterestRemainingTerm { get; set; }
  }

  /**
   * @description Account model
   */
  public class Account {
    /**
     * @description Financial institution name
     */
    @AuraEnabled
    public String financialInstitution { get; set; }

    /**
     * @description Account id
     */
    @AuraEnabled
    public String id { get; set; }

    /**
     * @description Account bsb
     */
    @AuraEnabled
    public String bsb { get; set; }

    /**
     * @description Account number
     */
    @AuraEnabled
    public String accountNumber { get; set; }

    /**
     * @description Account status
     */
    @AuraEnabled
    public String status { get; set; }
  }

  /**
   * @description Ownership model
   */
  public class Ownership {
    /**
     * @description Party ID
     */
    @AuraEnabled
    public String partyId { get; set; }

    /**
     * @description Ownership proportion
     */
    @AuraEnabled
    public Proportion proportion { get; set; }
  }

  /**
   * @description Proportion model
   */
  public class Proportion {
    /**
     * @description Value of the ownership proportion
     */
    @AuraEnabled
    public String value { get; set; }
  }

  /**
   * @description StudentLoan model
   */
  public class StudentLoan {
    /**
     * @description Indicates if HECS is withheld from payment
     */
    @AuraEnabled
    public Boolean hecsWithheldPayment { get; set; }
  }
}

/**
 * @author Vidhya Raghavan
 * @since December 2022
 * @description model for Home Loan accounts
 * @group Models
 */

@SuppressWarnings(
  'PMD.VariableNamingConventions, PMD.FieldNamingConventions, PMD.ExcessivePublicCount'
)
public with sharing class HomeLoanModel extends CalloutModel {
  @AuraEnabled
  public List<HomeLoanAccount> accounts;
  /**
   * @description account detail list is the parent containing all information related to the account
   */

  public class HomeLoanAccount {
    @AuraEnabled
    public String account_number;
    @AuraEnabled
    public String bsb;
    @AuraEnabled
    public String account_name;
    @AuraEnabled
    public Balances balances;
    @AuraEnabled
    public ProductDetails product_details;
    @AuraEnabled
    public string state;
    @AuraEnabled
    public AccountDate open_date;
    @AuraEnabled
    public AccountDate close_date;
    @AuraEnabled
    public LoanDetails loan_details;

    /**
     * @description returns the calculated paid off value
     * @return `paidOffValue`
     */
    @AuraEnabled
    public Decimal getPaidOff() {
      try {
        Decimal currentBalanceValue = this.balances.current_balance.value;
        Decimal loanAmountValue = this.loan_details.loan_amount.value;
        return currentBalanceValue + loanAmountValue;
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    }
  }

  /**
   * @description Repayment amount with currency code units and nanos
   */

  public class RepaymentAmount {
    @AuraEnabled
    public String currency_code;
    @AuraEnabled
    public String units;
    @AuraEnabled
    public Integer nanos;
    /**
     * @description calculate the value of the amount charged
     */
    @AuraEnabled
    public Decimal value {
      get {
        //Need to check if units and nanos exist as they aren't always returned
        Decimal unitValue = String.isNotBlank(this.units)
          ? decimal.valueOf(this.units)
          : 0;
        Decimal nanoValue = this.nanos != null ? this.nanos : 0;
        return unitValue + (nanoValue / 1000000000);
      }
    }
  }

  /**
   * @description Loan amount with currency code units and nanos
   */
  public class LoanAmount {
    @AuraEnabled
    public String currency_code;
    @AuraEnabled
    public String units;
    @AuraEnabled
    public Integer nanos;
    /**
     * @description calculate the value of the amount charged
     */
    @AuraEnabled
    public Decimal value {
      get {
        //Need to check if units and nanos exist as they aren't always returned
        Decimal unitValue = String.isNotBlank(this.units)
          ? decimal.valueOf(this.units)
          : 0;
        Decimal nanoValue = this.nanos != null ? this.nanos : 0;
        return unitValue + (nanoValue / 1000000000);
      }
    }
  }

  /**
   * @description Loan Details with currency code units and nanos
   */
  public class LoanDetails {
    @AuraEnabled
    public LoanAmount loan_amount;
    @AuraEnabled
    public RepaymentAmount repayment_amount;
    @AuraEnabled
    public string repayment_frequency;
    @AuraEnabled
    public LoanStartDate loan_start_date;
    @AuraEnabled
    public NextPaymentDate next_payment_date;
    @AuraEnabled
    public LoanAmount redraw_amount;
    @AuraEnabled
    public string repayment_type;
    @AuraEnabled
    public integer loan_term;
    @AuraEnabled
    public Interest interests;
    @AuraEnabled
    public string valid_at;
  /**
   * @return `redraw_amount.value` model class constructed from api response
   * @description null and blank check for redraw available field
   */
    @AuraEnabled
    public Decimal getRedrawAvailable() {
      try {
        if (redraw_amount != null) {
          return redraw_amount.value;
        } else {
          return 0;
        }
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    }
  }

  /**
   * @description Loan Start Date with with year month and day
   */
  public class LoanStartDate {
    @AuraEnabled
    public Integer year;
    @AuraEnabled
    public Integer month;
    @AuraEnabled
    public Integer day;
  }

  /**
   * @description Next payment Date with year month and day
   */
  public class NextPaymentDate {
    @AuraEnabled
    public Integer year;
    @AuraEnabled
    public Integer month;
    @AuraEnabled
    public Integer day;
  }

  /**
   * @description Product Details Date with marketing code and name
   */
  public class ProductDetails {
    @AuraEnabled
    public string marketing_code;
    @AuraEnabled
    public string name;
  }

  /**
   * @description balance information related to the account
   */
  public class Balance {
    @AuraEnabled
    public String currency_code;
    @AuraEnabled
    public String units;
    @AuraEnabled
    public Integer nanos;
    /**
     * @description calculate the value of the amount charged
     */
    @AuraEnabled
    public Decimal value {
      get {
        //Need to check if units and nanos exist as they aren't always returned
        Decimal unitValue = String.isNotBlank(this.units)
          ? decimal.valueOf(this.units)
          : 0;
        Decimal nanoValue = this.nanos != null ? this.nanos : 0;
        return unitValue + (nanoValue / 1000000000);
      }
    }
  }

  /**
   * @description Balances information
   */
  public class Balances {
    @AuraEnabled
    public Balance current_balance;
  }

  /**
   * @description Interest information
   */
  public class Interest {
    @AuraEnabled
    public Decimal rate;
  }

  /**
   * @description open date
   */
  public class AccountDate {
    public Integer year;
    public Integer month;
    public Integer day;
  }

  /**
   * @param json input string to deserialize
   * @return `AccountDetailsList`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static HomeLoanModel parse(String json) {
    return (HomeLoanModel) deserialize(json, HomeLoanModel.class);
  }
}

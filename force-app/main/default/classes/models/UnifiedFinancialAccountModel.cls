/**
 * @author Kopal Goswami
 * @since February 2025
 * @description model for financial accounts
 * @group Models
 * ExcessivePublicCount Surpressed : UnifiedFinancialModel to have all the public methods and attributes together.
 */
@SuppressWarnings(
  'PMD.ExcessivePublicCount, PMD.VariableNamingConventions, PMD.FieldNamingConventions, PMD.TooManyFields'
)
public with sharing class UnifiedFinancialAccountModel extends CalloutModel {
  @AuraEnabled
  public List<AccountList> accounts;

  /**
   * @description Constructor was initialising the accounts
   * @param accounts list of financial accounts
   */
  public UnifiedFinancialAccountModel(List<AccountList> accounts) {
    this.accounts = accounts;
  }

  @AuraEnabled
  public String balanceTitle;
  @AuraEnabled
  public String sectionHeaderTitle;
  @AuraEnabled
  public Boolean isSaving;
  @AuraEnabled
  public Boolean isHomeLoan;
  @AuraEnabled
  public Boolean isOthers;
  @AuraEnabled
  public String productCode;
  @AuraEnabled
  public String label;
  @AuraEnabled
  public Decimal sortOrder;
  @AuraEnabled
  public String accountType;

  /**
   * @description Accounts information related to the account
   */
  public class AccountList implements GenericObject {
    @AuraEnabled
    public String finserv_product_name;
    @AuraEnabled
    public String finserv_product_display_name;
    @AuraEnabled
    public Date finserv_opendate;
    @AuraEnabled
    public Date finserv_closedate;
    @AuraEnabled
    public String finserv_status;
    @AuraEnabled
    public String finserv_ownership;
    @AuraEnabled
    public Decimal finserv_sortorder;
    @AuraEnabled
    public Boolean finserv_showgoal;
    @AuraEnabled
    public String account_number;
    @AuraEnabled
    public Id id;
    @AuraEnabled
    public String bsb;
    @AuraEnabled
    public String account_name;
    @AuraEnabled
    public Balances balances;
    @AuraEnabled
    public ProductDetails product_details;
    @AuraEnabled
    public String state;
    @AuraEnabled
    public Open_date open_date;
    @AuraEnabled
    public Close_date close_date;
    @AuraEnabled
    public LoanDetails loan_details;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public List<String> operations;
    @AuraEnabled
    public Deposit_details deposit_details;
    @AuraEnabled
    public Ownership ownership;

    /**
     * @description Returns the value of the specified field.
     * @param fieldName The name of the field to retrieve the value for.
     * @return The value of the specified field.
     */
    public Object get(String fieldName) {
      switch on fieldName {
        when 'id' {
          return this.id;
        }
        when 'account_number' {
          return this.account_number;
        }
      }
      throw new IllegalArgumentException(
        'Field not yet supported: ' + fieldName
      );
    }

    /**
     * @description returns the calculated paid off value
     * @return `paidOffValue`
     */
    @AuraEnabled
    public Decimal getPaidOff() {
      try {
        Decimal currentBalanceValue = (this.balances != null)
          ? this.balances?.current_balance?.value
          : 0.0;
        Decimal loanAmountValue = (this.loan_details != null)
          ? this.loan_details?.loan_amount?.value
          : 0.0;
        return currentBalanceValue + loanAmountValue;
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    }
  }

  /**
   * @description Balances information
   */
  public class Balances {
    @AuraEnabled
    public Boolean balance_up_to_date;
    @AuraEnabled
    public String balance_update_time;
    @AuraEnabled
    public Account_limit account_limit;
    @AuraEnabled
    public Available_limit available_limit;
    @AuraEnabled
    public Balance balance;
    @AuraEnabled
    public Balance current_balance;
    @AuraEnabled
    public Ledger_balance ledger_balance;
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
   * @description Current Balance information related to the account
   */
  public class Current_balance {
    @AuraEnabled
    public Integer nanos;
    @AuraEnabled
    public String currency_code;
    @AuraEnabled
    public String units;

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
   * @description Account Limit information related to the account
   */
  public class Account_limit {
    @AuraEnabled
    public String currency_code;
  }

  /**
   * @description Available Limit information related to the account
   */
  public class Available_limit {
    @AuraEnabled
    public Integer nanos;
    @AuraEnabled
    public String currency_code;
    @AuraEnabled
    public String units;
  }

  /**
   * @description Ledger balance information related to the account
   */
  public class Ledger_balance {
    @AuraEnabled
    public Integer nanos;
    @AuraEnabled
    public String currency_code;
    @AuraEnabled
    public String units;
  }

  /**
   * @description Deposit Details information related to the account
   */
  public class Deposit_details {
    @AuraEnabled
    public Boolean details_up_to_date;
    @AuraEnabled
    public DateTime valid_at;
    @AuraEnabled
    public Integer bucket_count;
    @AuraEnabled
    public Double deposit_rate;
    @AuraEnabled
    public Debit_interest_details debit_interest_details;
    @AuraEnabled
    public List<TieredRates> tiered_rates;
  }

  /**
   * @description Debit Interest Details information related to the account
   */
  public class Debit_interest_details {
    @AuraEnabled
    public Interest_rate interest_rate;
  }

  /**
   * @description tiered rate information related to the account
   */
  public class TieredRates {
    @AuraEnabled
    public String from_operator;
    @AuraEnabled
    public String to_operator;
    @AuraEnabled
    public String units;
    @AuraEnabled
    public List<Tiers> tiers;
  }

  /**
   * @description Interest Rate information related to the account
   */
  public class Interest_rate {
    @AuraEnabled
    public Decimal rate_with_excess_points;
    @AuraEnabled
    public Decimal rate_with_margin;
  }

  /**
   * @description tiers information related to the account
   */
  public class Tiers {
    @AuraEnabled
    public Double rate;
    @AuraEnabled
    public Max max;
    @AuraEnabled
    public Min min;
  }

  /**
   * @description Open Date information related to the account
   */
  public class Open_date {
    public Integer day;
    public Integer month;
    public Integer year;
    /**
     * @description Convert Integer values of days, month and year in String
     */
    @AuraEnabled
    public String value {
      get {
        String openDate = (this.day != null &&
          this.month != null &&
          this.year != null)
          ? (this.year + '-' + this.month + '-' + this.day)
          : null;
        return openDate;
      }
    }
  }

  /**
   * @description Closed date information related to the account
   */
  public class Close_date {
    public Integer day;
    public Integer month;
    public Integer year;
    /**
     * @description Convert Integer values of days, month and year in String format
     */
    @AuraEnabled
    public String value {
      get {
        String closeDate = (this.day != null &&
          this.month != null &&
          this.year != null)
          ? (this.year + '-' + this.month + '-' + this.day)
          : null;
        return closeDate;
      }
    }
  }

  /**
   * @description Ownership information related to the account
   */
  public class Ownership {
    @AuraEnabled
    public String type;
  }

  /**
   * @description marketing product information related to the account
   */
  public class ProductDetails {
    @AuraEnabled
    public String marketing_code;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String product_code;
    @AuraEnabled
    public String sub_product_code;
    @AuraEnabled
    public List<String> transact_options;
  }

  /**
   * @description Max information related to the account
   */
  public class Max {
    @AuraEnabled
    public Integer nanos;
    @AuraEnabled
    public String currency_code;
    @AuraEnabled
    public String units;
  }

  /**
   * @description Min information related to the account
   */
  public class Min {
    @AuraEnabled
    public Integer nanos;
    @AuraEnabled
    public String currency_code;
    @AuraEnabled
    public String units;
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
   * @description Interest information
   */
  public class Interest {
    @AuraEnabled
    public Decimal rate;
  }

  /**
   * @param finAccounts input string to deserialize
   * @return `UnifiedFinancialAccountModel`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static UnifiedFinancialAccountModel parse(String finAccounts) {
    return (UnifiedFinancialAccountModel) deserialize(
      finAccounts,
      UnifiedFinancialAccountModel.class
    );
  }
}

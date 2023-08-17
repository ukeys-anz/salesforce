/**
 * @author Kopal Goswami
 * @since August 2023
 * @description model for financial accounts
 * @group Models
 * ExcessivePublicCount Surpressed : FinancialAccountModel to have all the public methods and attributes together.
 */
@SuppressWarnings(
  'PMD.ExcessivePublicCount, PMD.VariableNamingConventions, PMD.FieldNamingConventions'
)
public with sharing class FinancialAccountModelV1 extends CalloutModel {
  public List<Accounts> accounts;

  /**
   * @description Account Limit information related to the account
   */
  public class Account_limit {
    public String currency_code;
  }

  /**
   * @description Accounts information related to the account
   */
  public class Accounts {
    public String account_name;
    public String account_number;
    public Balances balances;
    public String bsb;
    public Deposit_details deposit_details;
    public String name;
    public Open_date open_date;
    public Close_date close_date;
    public List<String> operations;
    public Ownership ownership;
    public String state;
    public Product_details product_details;
  }

  /**
   * @description Available Limit information related to the account
   */
  public class Available_limit {
    public String currency_code;
    public Integer nanos;
    public String units;
  }

  /**
   * @description Balance information related to the account
   */
  public class Balance {
    public String currency_code;
    public Integer nanos;
    public String units;
  }

  /**
   * @description Balances information related to the account
   */
  public class Balances {
    public Account_limit account_limit;
    public Available_limit available_limit;
    public Balance balance;
    public Boolean balance_up_to_date;
    public String balance_update_time;
    public Current_balance current_balance;
    public Ledger_balance ledger_balance;
  }

  /**
   * @description Current Balance information related to the account
   */
  public class Current_balance {
    public String currency_code;
    public Integer nanos;
    public String units;
  }

  /**
   * @description Debit Interest Details information related to the account
   */
  public class Debit_interest_details {
    public Interest_rate interest_rate;
  }

  /**
   * @description Deposit Details information related to the account
   */
  public class Deposit_details {
    public Debit_interest_details debit_interest_details;
    public String deposit_rate;
    public Boolean details_up_to_date;
    public List<TieredRates> tiered_rates;
    public DateTime valid_at;
    public Integer bucket_count;
  }

  /**
   * @description Interest Rate information related to the account
   */
  public class Interest_rate {
    public Decimal rate_with_excess_points;
    public Decimal rate_with_margin;
  }

  /**
   * @description Ledger balance information related to the account
   */
  public class Ledger_balance {
    public String currency_code;
    public Integer nanos;
    public String units;
  }

  /**
   * @description Max information related to the account
   */
  public class Max {
    public String currency_code;
    public String units;
    public Integer nanos;
  }

  /**
   * @description Min information related to the account
   */
  public class Min {
    public String currency_code;
    public String units;
    public Integer nanos;
  }

  /**
   * @description Open Date information related to the account
   */
  public class Open_date {
    public Integer day;
    public Integer month;
    public Integer year;
  }

  /**
   * @description Closed date information related to the account
   */
  public class Close_date {
    public Integer day;
    public Integer month;
    public Integer year;
  }

  /**
   * @description Ownership information related to the account
   */
  public class Ownership {
    public String type;
  }

  /**
   * @description marketing product information related to the account
   */
  public class Product_details {
    public String marketing_code;
    public String name;
    public String product_code;
    public String sub_product_code;
    public List<String> transact_options;
  }

  /**
   * @description tiered rate information related to the account
   */
  public class TieredRates {
    public String from_operator;
    public List<Tiers> tiers;
    public String to_operator;
    public String units;
  }

  /**
   * @description tiers information related to the account
   */
  public class Tiers {
    public Max max;
    public Min min;
    public Double rate;
  }

  /**
   * @param json input string to deserialize
   * @return `FinancialAccountModelV1`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static FinancialAccountModel parse(String json) {
    FinancialAccountModelV1 finAccModelV1 = (FinancialAccountModelV1) deserialize(
      json,
      FinancialAccountModelV1.class
    );
    return FinancialAccountModelConverter.convertToFinancialAccountModel(
      finAccModelV1
    );
  }
}

/**
 * @author Peter Charalambous
 * @since December 2021
 * @description model for financial accounts
 * @group Models
 */
@SuppressWarnings(
  'PMD.ExcessivePublicCount, PMD.VariableNamingConventions, PMD.FieldNamingConventions'
)
public with sharing class FinancialAccountModel extends CalloutModel {
  /**
   * @description marketing product information related to the account
   */
  public class MarketingProduct {
    public String code;
    public String name;
  }

  /**
   * @description tier information related to the account
   */
  public class Tiers {
    public Balance min;
    public Balance max;
    public Double rate;
  }

  public List<AccountList> account_list;
  public String next_page_token;

  /**
   * @description tiered rates related to the account
   */
  public class TieredRates {
    public List<Tiers> tiers;
  }

  /**
   * @description balance information related to the account
   */
  public class Balance {
    public String currency_code;
    public String units;
    public Integer nanos;
    /**
     * @description calculate the value of the amount charged
     */
    public Double value {
      get {
        //Need to check if units and nanos exist as they aren't always returned
        Double unitValue = String.isNotBlank(this.units)
          ? double.valueOf(this.units)
          : 0;
        Double nanoValue = this.nanos != null ? this.nanos : 0;
        return unitValue + (nanoValue / 1000000000);
      }
    }
  }

  /**
   * @description account list is the parent containing all information related to the account
   */
  public class AccountList {
    public String account_number;
    public String bsb;
    public String name;
    public Balance balance;
    public Balance current_balance;
    public String balance_valid_at;
    public Boolean is_balance_current;
    public String created_at;
    public Integer bucket_count;
    public MarketingProduct marketing_product;
    public List<String> allowed_transact_options;
    public String status;
    public Object opened_at;
    public Object closed_at;
    public Double interest_rate;
    public List<TieredRates> tiered_rates;
  }

  /**
   * @param json input string to deserialize
   * @return `FinancialAccountModel`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static FinancialAccountModel parse(String json) {
    return (FinancialAccountModel) deserialize(
      json,
      FinancialAccountModel.class
    );
  }
}

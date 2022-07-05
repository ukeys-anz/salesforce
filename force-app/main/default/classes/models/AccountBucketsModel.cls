/**
 * @author Peter Charalambous
 * @since December 2021
 * @description model for account buckets
 * @group Models
 * ExcessivePublicCount Surpressed : AccountBucketsModel to have all the public methods and attributes together.
 */
// Suppressing below warnings as response returns snake case values, which triggers PMD warnings
@SuppressWarnings(
  'PMD.VariableNamingConventions, PMD.ExcessivePublicCount, PMD.FieldNamingConventions'
)
public with sharing class AccountBucketsModel extends CalloutModel {
  /**
   * @description the goal information
   */
  public class Goal {
    @AuraEnabled
    public String name;
    @AuraEnabled
    public Balance target_amount;
    @AuraEnabled
    public TargetDate target_date;
    @AuraEnabled
    public String theme;
    @AuraEnabled
    public FieldValue emoji;
    @AuraEnabled
    public FieldValue color;
    @AuraEnabled
    public Boolean is_open;
    @AuraEnabled
    public String closed_at;
    @AuraEnabled
    public String updated_at;
  }

  @AuraEnabled
  public List<AccountBuckets> account_buckets;
  @AuraEnabled
  public String next_page_token;

  /**
   * @description any field that returns with a value key
   */
  public class FieldValue {
    @AuraEnabled
    public String value;
  }

  /**
   * @description the parent containing all bucket information
   */
  public class AccountBuckets {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String account_number;
    @AuraEnabled
    public String created_at;
    @AuraEnabled
    public Boolean is_default;
    @AuraEnabled
    public Balance balance;
    @AuraEnabled
    public String balance_valid_at;
    @AuraEnabled
    public Boolean is_balance_current;
    @AuraEnabled
    public Goal goal;
  }

  /**
   * @description balance information
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
   * @description target date information
   */
  public class TargetDate {
    @AuraEnabled
    public FieldValue year;
    @AuraEnabled
    public FieldValue month;
    @AuraEnabled
    public FieldValue day;
  }

  /**
   * @param json input string to deserialize
   * @return `AccountBucketsModel`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static AccountBucketsModel parse(String json) {
    return (AccountBucketsModel) deserialize(json, AccountBucketsModel.class);
  }
}

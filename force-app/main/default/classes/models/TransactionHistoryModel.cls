/**
 * Suppressing PMD naming convention warnings as some fields return in snake case formatting from the API.
 * ExcessivePublicCount Surpressed : TransactionHistoryModel to have all the public methods and attributes together.
 */
@SuppressWarnings(
  'PMD.ExcessivePublicCount, PMD.FieldNamingConventions, PMD.VariableNamingConventions, PMD.TooManyFields, PMD.PropertyNamingConventions'
)
/**
 * @author Peter Charalambous
 * @since March 2021
 * @description Model for transaction history API
 */
public with sharing class TransactionHistoryModel extends CalloutModel {
  public static final String TIMEZONE = 'Australia/Sydney'; // According to AZNX-1314, all transactions to be aligned to Melbourne (AEST/AEDT) time as opposed to the coach’s local geographic time
  // Salesforce only supports 'Australia/Sydney' which is the same timezone with Melbourne timezone

  @AuraEnabled
  public String count;
  @AuraEnabled
  public Embedded embedded;
  @AuraEnabled
  public Links links;

  /**
   * @description embedded is the parent containing all information, such as transaction, categories, merchants and tags
   */
  public class Embedded {
    @AuraEnabled
    public List<Transactions> transactions;
    @AuraEnabled
    public List<Categories> categories;
    @AuraEnabled
    public List<Tags> tags;
    @AuraEnabled
    public List<Merchants> merchants;
  }

  /**
   * @description transactions is the parent containing all information of the transaction
   */
  public class Transactions {
    @AuraEnabled
    public String transaction_id;
    @AuraEnabled
    public Account account;
    @AuraEnabled
    public DateTime transaction_time;
    /**
     * @description transaction date in user's local time
     */
    @AuraEnabled
    public String transactionDateLocal {
      get {
        return DateTimeUtils.getLocalTime(
          this.transaction_time,
          TIMEZONE,
          'yyyy-MM-dd HH:mm:ss.SSS Z' /* Intentionally leaving a space before Z so JS understands that this datetime already
           has timezone it it and does not try to convert it again*/
        );
      }
    }
    @AuraEnabled
    public String last_update_time;
    @AuraEnabled
    public String status;
    @AuraEnabled
    public String long_desc;
    @AuraEnabled
    public String short_desc;
    @AuraEnabled
    public Amount amount;
    @AuraEnabled
    public International_amount international_amount;
    @AuraEnabled
    public String enrichment_id;
    @AuraEnabled
    public List<String> categories;
    @AuraEnabled
    public FieldValue merchant_id;
    @AuraEnabled
    public List<String> tags;
    @AuraEnabled
    public String type;
    @AuraEnabled
    public Card card;
    @AuraEnabled
    public Cash cash;
    @AuraEnabled
    public Bpay bpay;
    @AuraEnabled
    public Pay_anyone pay_anyone;
    @AuraEnabled
    public Transfer transfer;
    @AuraEnabled
    public Interest interest;
    @AuraEnabled
    public String primary_anzx_category;
    @AuraEnabled
    public DateTime transaction_posted_time;
    /**
     * @description transaction posted date/time in user's local time
     */
    @AuraEnabled
    public String transaction_posted_date {
      get {
        if (this.transaction_posted_time != null) {
          return DateTimeUtils.getLocalTime(
            this.transaction_posted_time,
            TIMEZONE,
            'yyyy-MM-dd HH:mm:ss.SSS Z' /* Intentionally leaving a space before Z so JS understands that this datetime already
             has timezone it it and does not try to convert it again*/
          );
        }

        return null;
      }
    }
    @AuraEnabled
    public String transaction_value_time;
    @AuraEnabled
    public Boolean is_npp_details_available;
    @AuraEnabled
    public String traceId;
    @AuraEnabled
    public String origination_id;
    @AuraEnabled
    public FieldValue ob_transaction_type;
    @AuraEnabled
    public FieldValue ob_extension_u_type;
    @AuraEnabled
    public FieldValue payment_crn;
    @AuraEnabled
    public FieldValue merchant_category_code;
    @AuraEnabled
    public FieldValue de_user_id;
    @AuraEnabled
    public FieldValue aux_dom;
    @AuraEnabled
    public String original_anzx_category;
    @AuraEnabled
    public String title;
  }

  /**
   * @description details of the merchant involved in the transaction
   */
  public class Merchants {
    @AuraEnabled
    public String merchant_id;
    @AuraEnabled
    public String lastUpdateTime;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String alternateName;
    @AuraEnabled
    public Boolean isSensitive;
    @AuraEnabled
    public String presence;
    @AuraEnabled
    public Address address;
    @AuraEnabled
    public FieldValue phone_number;
    @AuraEnabled
    public FieldValue website_url;
    @AuraEnabled
    public Boolean is_sensitive;
    @AuraEnabled
    public Image_details image_details;
    @AuraEnabled
    public FieldValue email;
  }

  /**
   * @description tags associated with the transaction
   */
  public class Tags {
    @AuraEnabled
    public String tag_id;
    @AuraEnabled
    public String name;
  }

  /**
   * @description categories associated with the transaction
   */
  public class Categories {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String categorySet; // actual value is set but is reserved
    @AuraEnabled
    public String type;
    @AuraEnabled
    public FieldValue image_url_light_large;
    @AuraEnabled
    public FieldValue color_hex;
  }

  /**
   * @description the bsb and account number of the transaction
   */
  public class Account {
    @AuraEnabled
    public String bsb;
    @AuraEnabled
    public String transactionAccountNumber; // actual value is number but is reserved
  }

  /**
   * @description the image details of the merchant
   */
  public class Image_details {
    @AuraEnabled
    public FieldValue light_url;
    @AuraEnabled
    public FieldValue dark_url;
  }

  /**
   * @description the source account of the transfer
   */
  public class Source_account {
    @AuraEnabled
    public Account account;
    @AuraEnabled
    public FieldValue bucket_id;
  }

  /**
   * @description the exchange rate of the transaction
   */
  public class Exchange_rate {
    @AuraEnabled
    public Double value;
  }

  /**
   * @description the address information of the merchant
   */
  public class Address {
    @AuraEnabled
    public FieldValue line_one;
    @AuraEnabled
    public FieldValue line_two;
    @AuraEnabled
    public FieldValue state;
    @AuraEnabled
    public FieldValue suburb;
    @AuraEnabled
    public FieldValue postcode;
    @AuraEnabled
    public FieldValue country;
    @AuraEnabled
    public Coordinates coordinates;
  }

  /**
   * @description the internation amount details
   */
  public class International_amount {
    @AuraEnabled
    public Amount charged;
    @AuraEnabled
    public Exchange_rate exchange_rate;
  }

  /**
   * @description the amount of the transaction
   */
  public class Amount {
    @AuraEnabled
    public String currency_code;
    @AuraEnabled
    public String units;
    @AuraEnabled
    // change to int
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
   * @description the merchant location details
   */
  public class Coordinates {
    @AuraEnabled
    public Integer lat_lon_precision;
    @AuraEnabled
    public Double latitude;
    @AuraEnabled
    public Double longitude;
  }

  /**
   * @description the value of nested fields
   */
  public class FieldValue {
    @AuraEnabled
    public String value;
  }

  /**
   * @description the link to the current set of transactions
   */
  public class Self {
    @AuraEnabled
    public String href;
  }

  /**
   * @description information related to the type of card/cash transaction
   */
  public class Cash {
    @AuraEnabled
    public String card_scheme;
    @AuraEnabled
    public String method;
    @AuraEnabled
    public String wallet;
    @AuraEnabled
    public String last_four_digits;
  }

  /**
   * @description details of other entity invovled in transaction
   */
  public class Other_entity {
    @AuraEnabled
    public String name;
    @AuraEnabled
    public FieldValue alias_id;
    @AuraEnabled
    public FieldValue alias_name;
    @AuraEnabled
    public Account account;
  }

  /**
   * @description the card details used for the transaction
   */
  public class Card {
    @AuraEnabled
    public String last_four_digits;
    @AuraEnabled
    public String scheme;
    @AuraEnabled
    public String method;
    @AuraEnabled
    public String wallet;
  }

  /**
   * @description transfer information related to the transaction
   */
  public class Transfer {
    @AuraEnabled
    public String payment_id;
    @AuraEnabled
    public String platform;
    @AuraEnabled
    public FieldValue message;
    @AuraEnabled
    public FieldValue payment_receipt_number;
    @AuraEnabled
    public Source_account source_account;
    @AuraEnabled
    public Source_account destination_account;
  }

  /**
   * @description bpay information related to the transaction
   */
  public class Bpay {
    @AuraEnabled
    public FieldValue biller_name;
    @AuraEnabled
    public FieldValue biller_code;
    @AuraEnabled
    public FieldValue customer_reference_number;
  }

  /**
   * @description links to load the current, next, previous and first set of transactions
   */
  public class Links {
    @AuraEnabled
    public Self self;
    @AuraEnabled
    public Self first;
    @AuraEnabled
    public Self prev;
    @AuraEnabled
    public Self next;
  }

  /**
   * @description pay anyone information related to the transaction
   */
  public class Pay_anyone {
    @AuraEnabled
    public String payment_id;
    @AuraEnabled
    public String platform;
    @AuraEnabled
    public FieldValue message;
    @AuraEnabled
    public Other_entity other_entity;
    @AuraEnabled
    public FieldValue npp_customer_reference_number;
    @AuraEnabled
    public String clearing_method;
    @AuraEnabled
    public String clearing_sub_method;
    @AuraEnabled
    public FieldValue payment_receipt_number;
    @AuraEnabled
    public FieldValue fabric_payee_id;
  }

  /**
   * @description interest information related to the transaction
   */
  public class Interest {
    @AuraEnabled
    public String sub_type;
  }

  /**
   * @param json input string to deserialize
   * @return `TransactionHistoryModel`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static TransactionHistoryModel parse(String json) {
    return (TransactionHistoryModel) deserialize(
      json,
      TransactionHistoryModel.class
    );
  }
}

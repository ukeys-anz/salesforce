/**
 * Suppressing PMD naming convention warnings as some fields return in snake case formatting from the API.
 */
@SuppressWarnings(
  'PMD.ExcessivePublicCount, PMD.FieldNamingConventions, PMD.VariableNamingConventions'
)
/**
 * @author Peter Charalambous
 * @since March 2021
 * @description Model for transaction history API
 */
public with sharing class TransactionHistoryModel extends CalloutModel {
  @AuraEnabled
  public String count;
  @AuraEnabled
  public String total;
  @AuraEnabled
  public List<Transactions> transactions;
  @AuraEnabled
  public Links links;
  public static final String TIMEZONE = 'Australia/Sydney'; // According to AZNX-1314, all transactions to be aligned to Melbourne (AEST/AEDT) time as opposed to the coach’s local geographic time
  // Salesforce only supports 'Australia/Sydney' which is the same timezone with Melbourne timezone

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
   * @description the exchange rate of the transaction
   */
  public class ExchangeRate {
    @AuraEnabled
    public Double value;
  }

  /**
   * @description the image details of the merchant
   */
  public class Image_details {
    @AuraEnabled
    public BillerName light_url;
  }

  /**
   * @description the address information of the merchant
   */
  public class Address {
    @AuraEnabled
    public BillerName line_one;
    @AuraEnabled
    public BillerName state;
    @AuraEnabled
    public BillerName suburb;
    @AuraEnabled
    public BillerName postcode;
    @AuraEnabled
    public Coordinates coordinates;
  }

  /**
   * @description the amount of the transaction
   */
  public class Amount {
    @AuraEnabled
    public String transactionType; // actual value is type but is reserved
    @AuraEnabled
    public Charged charged;
    @AuraEnabled
    public Charged converted;
    @AuraEnabled
    public ExchangeRate exchangeRate;
  }

  /**
   * @description the merchant location details
   */
  public class Coordinates {
    @AuraEnabled
    public Double latitude;
    @AuraEnabled
    public Double longitude;
    @AuraEnabled
    public String lat_lon_precision;
  }

  /**
   * @description the link to the current set of transactions
   */
  public class Self {
    @AuraEnabled
    public String href;
  }

  /**
   * @description transaction information
   */
  public class Transactions {
    @AuraEnabled
    public String transactionId;
    @AuraEnabled
    public Account account;
    @AuraEnabled
    public DateTime transactionDate;
    /**
     * @description transaction date in user's local time
     */
    @AuraEnabled
    public String transactionDateLocal {
      get {
        return DateTimeUtils.getLocalTime(
          this.transactionDate,
          TIMEZONE,
          'yyyy-MM-dd HH:mm:ss.SSS Z' /* Intentionally leaving a space before Z so JS understands that this datetime already
           has timezone it it and does not try to convert it again*/
        );
      }
    }
    @AuraEnabled
    public String lastUpdated;
    @AuraEnabled
    public String status;
    @AuraEnabled
    public String transactionType; // actual value is number but is reserved
    @AuraEnabled
    public String longDesc;
    @AuraEnabled
    public Amount amount;
    @AuraEnabled
    public String enrichmentId;
    @AuraEnabled
    public Bpay bpay;
    @AuraEnabled
    public PayAnyone payAnyone;
    @AuraEnabled
    public List<Tags> tags;
    @AuraEnabled
    public Merchant merchant;
  }

  /**
   * @description details of other entity invovled in transaction
   */
  public class OtherEntity {
    @AuraEnabled
    public String name;
    @AuraEnabled
    public BillerName aliasId;
    @AuraEnabled
    public BillerName aliasName;
  }

  /**
   * @description details of the merchant involved in the transaction
   */
  public class Merchant {
    @AuraEnabled
    public String merchant_id;
    @AuraEnabled
    public String last_updated;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public BillerName chain_name;
    @AuraEnabled
    public Address address;
    @AuraEnabled
    public BillerName phone_number;
    @AuraEnabled
    public BillerName website_url;
    @AuraEnabled
    public Image_details image_details;
    @AuraEnabled
    public BillerName email;
  }

  /**
   * @description details of the charge placed on the transaction
   */
  public class Charged {
    @AuraEnabled
    public Decimal value;
    @AuraEnabled
    public String currencyCode;
  }

  /**
   * @description bpay information
   */
  public class Bpay {
    @AuraEnabled
    public BillerName billerName;
    @AuraEnabled
    public BillerName billerCode;
    @AuraEnabled
    public BillerName referenceNum;
  }

  /**
   * @description links to load current, next and previous set of transactions
   */
  public class Links {
    @AuraEnabled
    public Self self;
    @AuraEnabled
    public Self first;
    @AuraEnabled
    public Self next;
  }

  /**
   * @description bpay biller name
   */
  public class BillerName {
    @AuraEnabled
    public String value;
  }

  /**
   * @description pay anyone information
   */
  public class PayAnyone {
    @AuraEnabled
    public String paymentId;
    @AuraEnabled
    public BillerName message;
    @AuraEnabled
    public OtherEntity otherEntity;
  }

  /**
   * @description tags associated with the transaction
   */
  public class Tags {
    @AuraEnabled
    public String tagId;
    @AuraEnabled
    public String name;
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

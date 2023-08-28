/**
 * Suppressing PMD naming convention warnings as some fields return in snake case formatting from the API.
 * ExcessivePublicCount Surpressed : TransactionHistoryModel to have all the public methods and attributes together.
 */
@SuppressWarnings(
  'PMD.ExcessivePublicCount, PMD.FieldNamingConventions, PMD.VariableNamingConventions, PMD.TooManyFields, PMD.PropertyNamingConventions'
)
/**
 * @author Kopal, Nilesh
 * @since 25/08/2023
 * @description Model for transaction history API V1
 */
public class TransactionHistoryModelV1 extends CalloutModel {
  public String count;
  public List<Enrichments> enrichments;
  public Links links;
  public List<Merchants> merchants;
  public List<Tags> tags;
  public String total;
  public List<Transactions> transactions;

  /**
   * @description the bsb and account number of the transaction
   */
  public class Account {
    public String account_number;
    public String bsb;
  }

  /**
   * @description the address information of the merchant
   */
  public class Address {
    public String country;
    public String line_one;
    public String line_two;
    public String postcode;
    public String state;
    public String suburb;
  }

  /**
   * @description the amount of the transaction
   */
  public class Amount {
    public String currency_code;
    public String units;
    // change to int
    public Integer nanos;
  }

  /**
   * @description transfer information related to the transaction
   */
  public class Transfer {
    public String puid;
    public String message;
    public String payment;
    public String payment_reference;
    public Source_account source_account;
    public Source_account destination_account;
  }

  /**
   * @description the source account of the transfer
   */
  public class Source_account {
    public String account_number;
    public String bsb;
    public String bucket;
  }

  /**
   * @description information related to the type of card/cash transaction
   */
  public class Card {
    public String last_four_digits;
    public String method;
    public String scheme;
    public String wallet;
    public String cof_categorization; //added
  }

  /**
   * @description information related to the type of cash transaction
   */
  public class Cash {
    public String card_scheme;
    public String method;
    public String wallet;
    public String card_last_four_digits;
  }

  /**
   * @description Criteria associated with the Enrichments
   */
  public class Criteria {
    public String transaction_description;
  }

  /**
   * @description Enrichments associated with the transactions
   */
  public class Enrichments {
    public Criteria criteria;
    public String merchant;
    public Integer merchant_match_confidence;
    public String name;
    public String uid;
  }

  /**
   * @description the image details of the merchant
   */
  public class Images {
    public String light_uri;
    public String dark_uri;
  }

  /**
   * @description the internation amount details
   */
  public class International {
    public Amount amount;
    public String country_code;
    public Double exchange_rate;
  }

  /**
   * @description links to load the current, next, previous and first set of transactions
   */
  public class Links {
    public Self self;
    public Self first;
    public Self prev;
    public Self next;
  }

  /**
   * @description details of the merchant involved in the transaction
   */
  public class Merchants {
    public Address address;
    public String chain_name;
    public String chain_id;
    public Images images;
    public String name;
    public String phone_number;
    public String presence;
    public String title;
    public String uid;
    public String update_time;
    public String website_uri;
    public String email;
    @AuraEnabled
    public String alternate_name;
  }

  /**
   * @description the link to the current set of transactions
   */
  public class Self {
    public String uri;
  }

  /**
   * @description tags associated with the transaction
   */
  public class Tags {
    public DateTime create_time;
    public String name;
    public String title;
    public String uid;
    public DateTime update_time;
  }

  /**
   * @description bpay information related to the transaction
   */
  public class Bpay {
    public String payment;
    public String biller_code;
    public String biller_name;
    public String crn;
    public String puid;
    public String payment_reference;
    public String contact;
  }

  /**
   * @description interest information related to the transaction
   */
  public class Interest {
    public String sub_type;
  }

  /**
   * @description pay anyone information related to the transaction
   */
  public class Payment {
    public String puid;
    public String npp_customer_reference;
    public String message;
    public String clearing_method;
    public String clearing_sub_method;
    public String platform;
    public Other_entity other_entity;
  }

  /**
   * @description details of other entity invovled in transaction
   */
  public class Other_entity {
    public String name;
    public String alias_id;
    public String alias_name;
    public Account account;
  }

  /**
   * @description details of OpenBanking invovled in transaction
   */
  public class OpenBanking {
    public String type;
    public Boolean detail_available;
    public String extension_u_type;
    public String purpose_code;
  }

  /**
   * @description transactions is the parent containing all information of the transaction
   */
  public class Transactions {
    public Account account;
    public Amount amount;
    public String aux_dom;
    public Card card;
    public Cash cash;
    public List<String> categories;
    public String cheque_serial_number;
    public String country_code;
    public String enrichment;
    public International international;
    public String long_description;
    public String merchant;
    public String merchant_category_code;
    public String name;
    public DateTime origin_time;
    public String original_anzx_category;
    public String origination_system_id;
    public DateTime post_time;
    public String primary_anzx_category;
    public Boolean reportable;
    public String short_description;
    public String status;
    public List<String> tags;
    public String title;
    public String type;
    public String uid;
    public String update_time;
    public String value_time;
    public String direct_entry_user_id;
    public Bpay bpay;
    public String trace_id;
    public Payment payment;
    public Interest interest;
    public Transfer transfer;
    public OpenBanking open_banking;
  }

  /**
   * @param json input string to deserialize
   * @return `TransactionHistoryModel`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static TransactionHistoryModel parse(String json) {
    TransactionHistoryModelV1 transModelV1 = (TransactionHistoryModelV1) deserialize(
      json,
      TransactionHistoryModelV1.class
    );
    return TransactionHistoryModelConvertor.convertToTransactionHistoryModel(
      transModelV1
    );
  }
}

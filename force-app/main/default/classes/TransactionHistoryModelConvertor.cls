/**
 * Suppressing PMD naming convention warnings as some fields return in snake case formatting from the API.
 * ExcessivePublicCount Surpressed : TransactionHistoryModel to have all the public methods and attributes together.
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity,')
/**
 * @author Shivam Swaraj ,Kopal Goswami
 * @since August 2023
 * @description Model for transaction history API Uplift to V1
 */
public class TransactionHistoryModelConvertor {
  /**
   * @description FinancialAccountModelConverter converts the v1 response back to v1beta1 response
   * @param sourceModel Holds the values of v1
   * @return TransactionHistoryModel which holds the converted value of v1beta1
   */
  public static TransactionHistoryModel convertToTransactionHistoryModel(
    TransactionHistoryModelV1 sourceModel
  ) {
    TransactionHistoryModel transModel = new TransactionHistoryModel();
    transModel.embedded = convertEmbedd(
      sourceModel.merchants,
      sourceModel.transactions,
      sourceModel.tags
    );
    transModel.count = sourceModel.count;
    transModel.links = convertLinks(sourceModel.links);

    return transModel;
  }

  /**
   * @description  converts the v1 response back to v1beta1 response
   * @param sourceMerchantList Holds the values of v1
   * @param sourceTransactionList Holds the values of v1
   * @param sourceTagList Holds the values of v1
   * @return TransactionHistoryModel.Embedded which holds the converted value of v1beta1
   */
  private static TransactionHistoryModel.Embedded convertEmbedd(
    List<TransactionHistoryModelV1.Merchants> sourceMerchantList,
    List<TransactionHistoryModelV1.Transactions> sourceTransactionList,
    List<TransactionHistoryModelV1.Tags> sourceTagList
  ) {
    TransactionHistoryModel.Embedded embedded = new TransactionHistoryModel.Embedded();

    List<TransactionHistoryModel.Merchants> destMerchants = new List<TransactionHistoryModel.Merchants>();
    List<TransactionHistoryModel.Transactions> destTransactions = new List<TransactionHistoryModel.Transactions>();
    List<TransactionHistoryModel.Tags> destTagsList = new List<TransactionHistoryModel.Tags>();

    if (sourceTransactionList != null && !sourceTransactionList.isEmpty()) {
      destTransactions.addAll(convertTransaction(sourceTransactionList));
    }

    //forming Merchant Details
    if (sourceMerchantList != null && !sourceMerchantList.isEmpty()) {
      for (
        TransactionHistoryModelV1.Merchants sourceMerchant : sourceMerchantList
      ) {
        TransactionHistoryModel.Merchants destMerchant = new TransactionHistoryModel.Merchants();
        //Direct Mapping
        destMerchant.merchant_id = sourceMerchant.uid;
        destMerchant.name = sourceMerchant.name;
        destMerchant.lastUpdateTime = sourceMerchant.update_time;
        destMerchant.presence = sourceMerchant.presence;
        destMerchant.website_url = convertFieldValue(
          sourceMerchant.website_uri
        );
        destMerchant.phone_number = convertFieldValue(
          sourceMerchant.phone_number
        );
        destMerchant.email = convertFieldValue(sourceMerchant.email);
        destMerchant.alternateName = sourceMerchant.alternate_name;

        //address mapping
        destMerchant.address = convertAddress(sourceMerchant.address);

        //image_details
        destMerchant.image_details = convertImage(sourceMerchant.images);
        destMerchants.add(destMerchant);
      }
    }

    //Mapping of Tags
    if (sourceTagList != null && !sourceTagList.isEmpty()) {
      for (TransactionHistoryModelV1.Tags tagMapping : sourceTagList) {
        TransactionHistoryModel.Tags destTagsMapping = new TransactionHistoryModel.Tags();
        destTagsMapping.tag_id = tagMapping.uid;
        destTagsMapping.name = tagMapping.name;
        destTagsList.add(destTagsMapping);
      }
    }
    embedded.merchants = destMerchants;
    embedded.transactions = destTransactions;
    embedded.tags = destTagsList;

    return embedded;
  }
  private static List<TransactionHistoryModel.Transactions> convertTransaction(
    List<TransactionHistoryModelV1.Transactions> sourceTransactionList
  ) {
    List<TransactionHistoryModel.Transactions> destTransactions = new List<TransactionHistoryModel.Transactions>();
    for (
      TransactionHistoryModelV1.Transactions sourceTransaction : sourceTransactionList
    ) {
      TransactionHistoryModel.Transactions destTransaction = new TransactionHistoryModel.Transactions();
      //Direct Mapping
      destTransaction.transaction_id = sourceTransaction.uid;
      destTransaction.transaction_time = sourceTransaction.origin_time;
      destTransaction.last_update_time = sourceTransaction.update_time;
      destTransaction.status = sourceTransaction.status;
      destTransaction.long_desc = sourceTransaction.long_description;
      destTransaction.short_desc = sourceTransaction.short_description;
      destTransaction.enrichment_id = sourceTransaction.enrichment;
      destTransaction.type = sourceTransaction.type;
      destTransaction.primary_anzx_category = sourceTransaction.primary_anzx_category;
      destTransaction.transaction_posted_time = sourceTransaction.post_time;
      destTransaction.transaction_value_time = sourceTransaction.value_time;
      destTransaction.is_npp_details_available = sourceTransaction.reportable;
      destTransaction.original_anzx_category = sourceTransaction.original_anzx_category;
      destTransaction.title = sourceTransaction.title;
      destTransaction.traceId = sourceTransaction.trace_id;
      destTransaction.origination_id = sourceTransaction.origination_system_id;
      destTransaction.de_user_id = convertFieldValue(
        sourceTransaction.direct_entry_user_id
      );

      //Open Banking Mapping
      if (sourceTransaction.open_banking != null) {
        destTransaction.ob_transaction_type = convertFieldValue(
          sourceTransaction.open_banking.type
        );
        destTransaction.ob_extension_u_type = convertFieldValue(
          sourceTransaction.open_banking.extension_u_type
        );
      }
      //Amount Mapping
      if (sourceTransaction.Amount != null) {
        destTransaction.amount = convertAmount(sourceTransaction.Amount);
      }
      //InternationalAmount Mapping
      if (sourceTransaction.international != null) {
        destTransaction.international_amount = convertInternationalAmount(
          sourceTransaction.international
        );
      }
      //Account Mapping
      if (sourceTransaction.account != null) {
        destTransaction.account = convertAccount(sourceTransaction.account);
      }
      //Mapping Merchant_category_code
      destTransaction.merchant_category_code = convertFieldValue(
        sourceTransaction.merchant_category_code
      );
      //Mapping Merchant_Id
      destTransaction.merchant_id = convertFieldValue(
        sourceTransaction.merchant
      );
      //Mapping aux_dom
      destTransaction.aux_dom = convertFieldValue(sourceTransaction.aux_dom);
      //Mapping Card
      if (sourceTransaction.card != null) {
        destTransaction.card = convertCard(sourceTransaction.card);
      }
      //Mapping Cash
      if (sourceTransaction.Cash != null) {
        destTransaction.cash = convertCash(sourceTransaction.cash);
      }
      //Mapping Bpay
      if (sourceTransaction.Bpay != null) {
        destTransaction.bpay = convertBpay(sourceTransaction.Bpay);
      }
      //Mapping Transfer
      System.debug(
        'sourceTransaction.transfer --> ' + sourceTransaction.transfer
      );
      if (sourceTransaction.transfer != null) {
        destTransaction.transfer = convertTransfer(sourceTransaction.transfer);
      }

      //Mapping Tags
      if (sourceTransaction.tags != null && !sourceTransaction.tags.isEmpty()) {
        destTransaction.tags = convertTags(sourceTransaction.Tags);
      }
      //Mapping Payment
      if (sourceTransaction.Payment != null) {
        destTransaction.pay_anyone = convertPayment(sourceTransaction.Payment);
      }
      //Mapping Interest
      if (sourceTransaction.Interest != null) {
        destTransaction.interest = convertInterest(sourceTransaction.Interest);
      }
      destTransactions.add(destTransaction);
    }
    return destTransactions;
  }

  private static List<String> convertTags(List<String> sourceTags) {
    List<String> tagsList = new List<String>();
    for (String tag : sourceTags) {
      tagsList.add(tag);
    }
    return tagsList;
  }

  private static TransactionHistoryModel.Account convertAccount(
    TransactionHistoryModelV1.Account sourceAccount
  ) {
    TransactionHistoryModel.Account destAccount = new TransactionHistoryModel.Account();
    if (sourceAccount != null) {
      destAccount.bsb = sourceAccount.bsb;
      destAccount.transactionAccountNumber = sourceAccount.account_number;
    }
    return destAccount;
  }

  private static TransactionHistoryModel.Amount convertAmount(
    TransactionHistoryModelV1.Amount sourceAmount
  ) {
    TransactionHistoryModel.Amount destAmount = new TransactionHistoryModel.Amount();
    if (sourceAmount != null) {
      destAmount.currency_code = sourceAmount.currency_code;
      destAmount.units = sourceAmount.units;
      destAmount.nanos = sourceAmount.nanos;
    }
    return destAmount;
  }

  private static TransactionHistoryModel.Pay_anyone convertPayment(
    TransactionHistoryModelV1.Payment sourcePayment
  ) {
    TransactionHistoryModel.Pay_anyone destPayanyone = new TransactionHistoryModel.Pay_anyone();
    if (sourcePayment != null) {
      destPayanyone.payment_id = sourcePayment.puid;
      destPayanyone.platform = sourcePayment.platform;
      destPayanyone.npp_customer_reference_number = convertFieldValue(
        sourcePayment.npp_customer_reference
      );
      destPayanyone.message = convertFieldValue(sourcePayment.message);
      destPayanyone.clearing_method = sourcePayment.clearing_method;
      destPayanyone.clearing_sub_method = sourcePayment.clearing_sub_method;
      destPayanyone.other_entity = convertOtherEntity(
        sourcePayment.other_entity
      );
    }
    return destPayanyone;
  }

  private static TransactionHistoryModel.Other_entity convertOtherEntity(
    TransactionHistoryModelV1.Other_entity sourceOtherEntity
  ) {
    TransactionHistoryModel.Other_entity destOtherEntity = new TransactionHistoryModel.Other_entity();
    if (sourceOtherEntity != null) {
      destOtherEntity.name = sourceOtherEntity.name;
      destOtherEntity.alias_id = convertFieldValue(sourceOtherEntity.alias_id);
      destOtherEntity.alias_name = convertFieldValue(
        sourceOtherEntity.alias_name
      );
      destOtherEntity.account = convertAccount(sourceOtherEntity.account);
    }
    return destOtherEntity;
  }

  private static TransactionHistoryModel.Interest convertInterest(
    TransactionHistoryModelV1.Interest sourceInterest
  ) {
    TransactionHistoryModel.Interest destInterest = new TransactionHistoryModel.Interest();
    if (sourceInterest != null) {
      destInterest.sub_type = sourceInterest.sub_type;
    }
    return destInterest;
  }

  private static TransactionHistoryModel.international_amount convertInternationalAmount(
    TransactionHistoryModelV1.International sourceInternationalAmount
  ) {
    TransactionHistoryModel.international_amount destInternationalAmount = new TransactionHistoryModel.international_amount();
    if (sourceInternationalAmount != null) {
      destInternationalAmount.charged = convertAmount(
        sourceInternationalAmount.amount
      );
      destInternationalAmount.exchange_rate = convertExchangeRate(
        sourceInternationalAmount
      );
    }
    return destInternationalAmount;
  }

  private static TransactionHistoryModel.Exchange_rate convertExchangeRate(
    TransactionHistoryModelV1.International sourceInternational
  ) {
    TransactionHistoryModel.Exchange_rate destExchangeRate = new TransactionHistoryModel.Exchange_rate();
    if (sourceInternational != null) {
      destExchangeRate.value = sourceInternational.exchange_rate;
    }
    return destExchangeRate;
  }

  private static TransactionHistoryModel.Card convertCard(
    TransactionHistoryModelV1.Card sourceCard
  ) {
    TransactionHistoryModel.Card destCard = new TransactionHistoryModel.Card();
    if (sourceCard != null) {
      destCard.last_four_digits = sourceCard.last_four_digits;
      destCard.method = sourceCard.method;
      destCard.scheme = sourceCard.scheme;
      destCard.wallet = sourceCard.wallet;
    }
    return destCard;
  }

  private static TransactionHistoryModel.Cash convertCash(
    TransactionHistoryModelV1.Cash sourceCash
  ) {
    TransactionHistoryModel.Cash destCash = new TransactionHistoryModel.Cash();
    if (sourceCash != null) {
      destCash.card_last_four_digits = sourceCash.card_last_four_digits;
      destCash.method = sourceCash.method;
      destCash.card_scheme = sourceCash.card_scheme;
      destCash.wallet = sourceCash.wallet;
    }
    return destCash;
  }

  private static TransactionHistoryModel.Bpay convertBpay(
    TransactionHistoryModelV1.Bpay sourceBpay
  ) {
    TransactionHistoryModel.Bpay destBpay = new TransactionHistoryModel.Bpay();
    if (sourceBpay != null) {
      destBpay.biller_code = convertFieldValue(sourceBpay.biller_code);
      destBpay.biller_name = convertFieldValue(sourceBpay.biller_name);
      destBpay.customer_reference_number = convertFieldValue(sourceBpay.crn);
    }
    return destBpay;
  }

  private static TransactionHistoryModel.Transfer convertTransfer(
    TransactionHistoryModelV1.Transfer sourceTransfer
  ) {
    TransactionHistoryModel.Transfer destTransfer = new TransactionHistoryModel.Transfer();
    if (sourceTransfer != null) {
      destTransfer.payment_id = sourceTransfer.puid;
      destTransfer.message = convertFieldValue(sourceTransfer.message);
      destTransfer.payment_receipt_number = convertFieldValue(
        sourceTransfer.payment_reference
      );
      destTransfer.source_account = convertSourceAccount(
        sourceTransfer.source_account
      );
      destTransfer.destination_account = convertSourceAccount(
        sourceTransfer.destination_account
      );
    }
    return destTransfer;
  }

  private static TransactionHistoryModel.Source_account convertSourceAccount(
    TransactionHistoryModelV1.Source_account sourceTransferAccount
  ) {
    TransactionHistoryModel.Source_account destSourceAccount = new TransactionHistoryModel.Source_account();
    TransactionHistoryModel.Account destAccount = new TransactionHistoryModel.Account();
    destAccount.bsb = sourceTransferAccount.bsb;
    destAccount.transactionAccountNumber = sourceTransferAccount.account_number;
    if (sourceTransferAccount != null) {
      destSourceAccount.account = destAccount;
      destSourceAccount.bucket_id = convertFieldValue(
        sourceTransferAccount.bucket
      );
    }
    return destSourceAccount;
  }

  private static TransactionHistoryModel.Address convertAddress(
    TransactionHistoryModelV1.Address sourceAddress
  ) {
    TransactionHistoryModel.Address destAddress = new TransactionHistoryModel.Address();
    if (sourceAddress != null) {
      destAddress.line_one = convertFieldValue(sourceAddress.line_one);
      destAddress.suburb = convertFieldValue(sourceAddress.suburb);
      destAddress.state = convertFieldValue(sourceAddress.state);
      destAddress.postcode = convertFieldValue(sourceAddress.postcode);
      destAddress.country = convertFieldValue(sourceAddress.country);
    }
    return destAddress;
  }

  private static TransactionHistoryModel.Image_details convertImage(
    TransactionHistoryModelV1.Images sourceImage
  ) {
    TransactionHistoryModel.Image_details destImage = new TransactionHistoryModel.Image_details();
    if (sourceImage != null) {
      destImage.dark_url = convertFieldValue(sourceImage.dark_uri);
      destImage.light_url = convertFieldValue(sourceImage.light_uri);
      return destImage;
    }
    return null;
  }

  private static TransactionHistoryModel.FieldValue convertFieldValue(
    String sourceFieldValue
  ) {
    TransactionHistoryModel.FieldValue destFieldValue = new TransactionHistoryModel.FieldValue();
    if (!String.isBlank(sourceFieldValue)) {
      destFieldValue.value = sourceFieldValue;
      return destFieldValue;
    }
    return null;
  }

  private static TransactionHistoryModel.Links convertLinks(
    TransactionHistoryModelV1.Links sourceLinks
  ) {
    TransactionHistoryModel.Links destLinks = new TransactionHistoryModel.Links();
    if (sourceLinks != null) {
      destLinks.first = convertSelf(sourceLinks.first);
      destLinks.self = convertSelf(sourceLinks.self);
      destLinks.prev = convertSelf(sourceLinks.prev);
      destLinks.next = convertSelf(sourceLinks.next);
    }
    return destLinks;
  }

  private static TransactionHistoryModel.Self convertSelf(
    TransactionHistoryModelV1.Self sourceSelf
  ) {
    TransactionHistoryModel.Self destSelf = new TransactionHistoryModel.Self();
    if (sourceSelf != null && !String.isBlank(sourceSelf.uri)) {
      destSelf.uri = sourceSelf.uri;
    }

    return destSelf;
  }
}

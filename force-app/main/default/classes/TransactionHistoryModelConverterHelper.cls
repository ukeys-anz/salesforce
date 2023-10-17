/**
 * @author Kopal Goswami
 * @since August 2023
 * @description Model for transaction history API Uplift helper class
 */
public with sharing class TransactionHistoryModelConverterHelper {
  /**
   * @description Transform bpay v1 node back to v1beta1
   * @param sourceBpay Transaction API v1 Bpay Node
   * @return transactionHistoryModel.Bpay TransactionAPI v1beta1 Node
   */
  public static TransactionHistoryModel.Bpay convertBpay(
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

  /**
   * @description Transform Transfer v1 node back to v1beta1
   * @param sourceTransfer Transaction API v1 Transfer Node
   * @return TransactionHistoryModel.Transfer TransactionAPI v1beta1 Node
   */
  public static TransactionHistoryModel.Transfer convertTransfer(
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

  /**
   * @description Transform Source Account v1 node back to v1beta1
   * @param sourceTransferAccount Transaction API v1 Transfer Node
   * @return TransactionHistoryModel.Source_account TransactionAPI v1beta1 Node
   */
  public static TransactionHistoryModel.Source_account convertSourceAccount(
    TransactionHistoryModelV1.Source_account sourceTransferAccount
  ) {
    TransactionHistoryModel.Source_account destSourceAccount = new TransactionHistoryModel.Source_account();

    if (sourceTransferAccount != null) {
      TransactionHistoryModel.Account destAccount = new TransactionHistoryModel.Account();
      destAccount.bsb = sourceTransferAccount.bsb;
      destAccount.transactionAccountNumber = sourceTransferAccount.account_number;
      destSourceAccount.account = destAccount;
      destSourceAccount.bucket_id = convertFieldValue(
        sourceTransferAccount.bucket
      );
    }
    return destSourceAccount;
  }

  /**
   * @description Transform Interest v1 node back to v1beta1
   * @param sourceInterest Transaction API v1 Transfer Node
   * @return TransactionHistoryModel.Interest TransactionAPI v1beta1 Node
   */
  public static TransactionHistoryModel.Interest convertInterest(
    TransactionHistoryModelV1.Interest sourceInterest
  ) {
    TransactionHistoryModel.Interest destInterest = new TransactionHistoryModel.Interest();
    if (sourceInterest != null) {
      destInterest.sub_type = sourceInterest.sub_type;
    }
    return destInterest;
  }

  /**
   * @description generic method used for node conversion
   * @param sourceFieldValue any String field requiring conversion from v1 to common value node
   * @return TransactionHistoryModel.FieldValue converted to v1beta1
   */
  public static TransactionHistoryModel.FieldValue convertFieldValue(
    String sourceFieldValue
  ) {
    TransactionHistoryModel.FieldValue destFieldValue = new TransactionHistoryModel.FieldValue();
    if (!String.isBlank(sourceFieldValue)) {
      destFieldValue.value = sourceFieldValue;
      return destFieldValue;
    }
    return null;
  }

  /**
   * @description Transform card v1 node back to v1beta1
   * @param sourceCard Transaction API v1 card Node
   * @return TransactionHistoryModel.Card TransactionAPI v1beta1 Node
   */
  public static TransactionHistoryModel.Card convertCard(
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

  /**
   * @description Transform card v1 node back to v1beta1
   * @param sourceCash Transaction API v1 cash Node
   * @return TransactionHistoryModel.Cash TransactionAPI v1beta1 Node
   */
  public static TransactionHistoryModel.Cash convertCash(
    TransactionHistoryModelV1.Card sourceCash
  ) {
    TransactionHistoryModel.Cash destCash = new TransactionHistoryModel.Cash();
    if (sourceCash != null) {
      destCash.card_last_four_digits = sourceCash.last_four_digits;
      destCash.method = sourceCash.method;
      destCash.card_scheme = sourceCash.scheme;
      destCash.wallet = sourceCash.wallet;
    }
    return destCash;
  }

  /**
   * @description Transaction Initiator Name Mapping
   * @param sourcePersonaId PersonaId received from staffToken
   * @param mapPersonaIdAndCustomerName  Map holding Pesona Id and Customer Name
   * @return the name of the person who initiates the transaction
   */
  public static String convertPersonaIdtoTransactionInitiator(
    String sourcePersonaId,
    Map<String, String> mapPersonaIdAndCustomerName
  ) {
    String desttransactionInitiator;
    if (sourcePersonaId != null && mapPersonaIdAndCustomerName != null) {
      if (mapPersonaIdAndCustomerName.containsKey(sourcePersonaId)) {
        desttransactionInitiator = mapPersonaIdAndCustomerName.get(
          sourcePersonaId
        );
      } else {
        desttransactionInitiator = 'Co-Owner';
      }
    }
    return desttransactionInitiator;
  }
}

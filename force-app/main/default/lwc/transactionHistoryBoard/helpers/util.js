//This function checks if an optional value exists and returns it else
//returns unknown
export function getOptionalFieldValue(field) {
  return field ? field.value : "Unknown";
}

/* 
This function checks the type returned with the transaction, then calls the necessary function
to process the optional fields related to that transaction. The below mapping shows the transaction type
and the key associated with it in the transaction, taken from the fabric proto doc
  Mappings: https://github.com/anzx/fabricapis/blob/28e579f0a95a94ff45eaf667197f81c0a3b0d7a6/proto/fabric/type/transactions/v1beta1/transaction.proto#L116
    card - TRANSACTION_TYPE_CARD
    cash - TRANSACTION_TYPE_DEPOSIT_WITHDRAWAL
    pay_anyone - [TRANSACTION_TYPE_BSB_ACC_NUM, TRANSACTION_TYPE_PAYID]
    bpay - TRANSACTION_TYPE_BPAY
    empty - [TRANSACTION_TYPE_UNSPECIFIED]
    transfer - TRANSACTION_TYPE_TRANSFER 
 */
export function processTransaction(transaction) {
  switch (transaction.type) {
    case "TRANSACTION_TYPE_TRANSFER":
      return processTransfer(transaction);
    case "TRANSACTION_TYPE_BPAY":
      return processBPAY(transaction);
    case "TRANSACTION_TYPE_BSB_ACC_NUM":
    case "TRANSACTION_TYPE_PAYID":
      return processPayAnyone(transaction);
    default:
      return transaction;
  }
}

//Handle processing of optional transfer fields
function processTransfer(transaction) {
  transaction.transfer.message = getOptionalFieldValue(
    transaction.transfer.message
  );

  return transaction;
}

//Handle processing of optional bpay fields
function processBPAY(transaction) {
  transaction.bpay.biller_name = getOptionalFieldValue(
    transaction.bpay.biller_name
  );
  transaction.bpay.biller_code = getOptionalFieldValue(
    transaction.bpay.biller_code
  );
  transaction.bpay.customer_reference_number = getOptionalFieldValue(
    transaction.bpay.customer_reference_number
  );

  return transaction;
}

//Handle processing of optional pay anyone fields
function processPayAnyone(transaction) {
  transaction.pay_anyone.message = getOptionalFieldValue(
    transaction.pay_anyone.message
  );
  transaction.pay_anyone.other_entity.alias_id = getOptionalFieldValue(
    transaction.pay_anyone.other_entity.alias_id
  );

  transaction.pay_anyone.other_entity.alias_name = getOptionalFieldValue(
    transaction.pay_anyone.other_entity.alias_name
  );

  return transaction;
}

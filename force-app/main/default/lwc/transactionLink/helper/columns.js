export const ACCOUNT_COLUMNS = [
  { label: "Product", fieldName: "Product_Name_Display__c", type: "text" },
  { label: "Account Number", fieldName: "Account_Number__c", type: "text" },
  {
    label: "Ownership",
    fieldName: "Ownership__c",
    type: "text"
  }
];

export const TXN_COLUMNS = [
  {
    label: "",
    fieldName: "",
    type: "icon",
    cellAttributes: {
      iconName: { fieldName: "dynamicIcon" },
      iconPosition: "right"
    },
    initialWidth: 20,
    hideDefaultActions: true
  },
  {
    label: "Name",
    fieldName: "Title",
    type: "text"
  },
  { label: "Transaction Id", fieldName: "TransactionId", type: "text" },
  { label: "Amount", fieldName: "Amount", type: "currency", initialWidth: 100 },
  {
    label: "Date",
    fieldName: "TransactionDate",
    type: "date",
    typeAttributes: {
      weekday: "short",
      day: "2-digit",
      month: "short",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
      hour12: true
    },
    initialWidth: 250
  }
];

export const REVIEW_TXN_COLUMNS = [
  { label: "Name", fieldName: "Title", type: "text" },
  { label: "Transaction Id", fieldName: "TransactionId", type: "text" },
  { label: "Amount", fieldName: "Amount", type: "currency" },
  {
    label: "Date",
    fieldName: "TransactionDate",
    type: "date",
    typeAttributes: {
      weekday: "short",
      day: "2-digit",
      month: "short",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
      hour12: true
    }
  }
];

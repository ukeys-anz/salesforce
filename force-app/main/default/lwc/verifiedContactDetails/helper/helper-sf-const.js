export const checkBoxFields = ["Verification_Status__c"];
export const dateFields = ["Verification_Date__c"];
export const fieldsWithUrl = ["recordUrl"];
export const recordTitleField = ["UsageType"];

export const fieldNameToObjectNameMap = {
  "Security Mobile": "ContactPointPhone",
  "Security Email": "ContactPointEmail"
};

export const infoFields = [
  "EmailAddress",
  "TelephoneNumber",
  "Verification_Date__c",
  "Verification_Status__c"
];

export const removeFieldToObjectNameMap = ["EmailAddress", "TelephoneNumber"];

export const fieldLabelMap = {
  Id: "Id",
  EmailAddress: "Email Address",
  TelephoneNumber: "Telephone Number",
  UsageType: "Usage Type",
  Verification_Date__c: "Verification Date",
  Verification_Status__c: "Verification Status",
  recordUrl: "recordUrl"
};

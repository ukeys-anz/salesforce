import ACCOUNT_ID from "@salesforce/schema/Case.AccountId";
import ISSUE_TYPE from "@salesforce/schema/Case.Type";
import ISSUE_SUB_TYPE from "@salesforce/schema/Case.Sub_Type__c";
import PRIORITY from "@salesforce/schema/Case.Priority";
import PRODUCT_OR_SERVICE_NAME from "@salesforce/schema/Case.Product__c";
import SUBSEQUENT_ISSUE_TYPE from "@salesforce/schema/Case.IDR_Subsequent_Issue__c";
import CUSTOMER_TYPE from "@salesforce/schema/Case.IDR_Complainant_Type__c";
import AGE from "@salesforce/schema/Case.IDR_NC_Age__c";
import GENDER from "@salesforce/schema/Case.IDR_NC_Gender__c";
import POSTCODE from "@salesforce/schema/Case.IDR_NC_Postcode__c";
import DESCRIPTION from "@salesforce/schema/Case.Description";
import CUSTOMER_DESIRED_OUTCOME from "@salesforce/schema/Case.IDR_Complainant_Desired_Outcome__c";
import CUSTOMER_NOTIFICATION_CONSENT from "@salesforce/schema/Case.Customer_Notification_Consent__c";
import IS_A_RESPONSE_REQUESTED from "@salesforce/schema/Case.IDR_Is_Written_Resp_Requested__c";
import FIRST_NAME from "@salesforce/schema/Case.IDR_NC_First_Name__c";
import LAST_NAME from "@salesforce/schema/Case.IDR_NC_Last_Name__c";
import SWITCH_OFF_CUSTOMER_NOTIFICATION from "@salesforce/schema/Case.IDR_SwitchOff_Customer_Notification__c";

const GENERAL_ENQUIRY_FIELDS = [
  ACCOUNT_ID,
  PRIORITY,
  ISSUE_TYPE,
  ISSUE_SUB_TYPE,
  DESCRIPTION
];

const ANZ_PLUS_COMPLAINT_FIELDS = [
  ACCOUNT_ID,
  PRIORITY,
  ISSUE_TYPE,
  SUBSEQUENT_ISSUE_TYPE,
  PRODUCT_OR_SERVICE_NAME,
  DESCRIPTION,
  CUSTOMER_DESIRED_OUTCOME,
  CUSTOMER_NOTIFICATION_CONSENT,
  IS_A_RESPONSE_REQUESTED
];

const NON_CUSTOMER_COMPLAINT_FIELDS = [
  CUSTOMER_TYPE,
  FIRST_NAME,
  LAST_NAME,
  AGE,
  GENDER,
  POSTCODE,
  SWITCH_OFF_CUSTOMER_NOTIFICATION,
  PRIORITY,
  ISSUE_TYPE,
  SUBSEQUENT_ISSUE_TYPE,
  PRODUCT_OR_SERVICE_NAME,
  DESCRIPTION,
  CUSTOMER_DESIRED_OUTCOME,
  IS_A_RESPONSE_REQUESTED
];

const FIELD_LIST_MAP = {
  General_Inquiry: GENERAL_ENQUIRY_FIELDS,
  ANZx_Complaint: ANZ_PLUS_COMPLAINT_FIELDS,
  Non_Customer_Complaint: NON_CUSTOMER_COMPLAINT_FIELDS
};

const LOOKUP_FIELDS = [ACCOUNT_ID, PRODUCT_OR_SERVICE_NAME];

export const fieldListArray = (selectedRecordTypeName) =>
  FIELD_LIST_MAP[selectedRecordTypeName].map((f) => f.fieldApiName);
export const lookUpArray = () => LOOKUP_FIELDS.map((f) => f.fieldApiName);

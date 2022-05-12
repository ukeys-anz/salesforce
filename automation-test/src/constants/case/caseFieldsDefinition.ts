import { FieldDefinition } from "types/field";
import CaseFields from "./caseFields";

export default new Map<string, FieldDefinition>([
  [CaseFields.Account_Name, { label: CaseFields.Account_Name, type: "lookup" }],
  [
    CaseFields.Amount_Of_Authorised_Transaction,
    { label: CaseFields.Amount_Of_Authorised_Transaction, type: "number" }
  ],
  [
    CaseFields.Amount_Of_Credit_Due,
    { label: CaseFields.Amount_Of_Credit_Due, type: "number" }
  ],
  [
    CaseFields.Card_In_Possession_During_Transaction,
    {
      label: CaseFields.Card_In_Possession_During_Transaction,
      type: "picklist"
    }
  ],
  [
    CaseFields.Channel_Received,
    { label: CaseFields.Channel_Received, type: "picklist" }
  ],
  [
    CaseFields.Customer_Contacted_Merchant,
    { label: CaseFields.Customer_Contacted_Merchant, type: "picklist" }
  ],
  [
    CaseFields.Customer_Desired_Outcome,
    { label: CaseFields.Customer_Desired_Outcome, type: "textarea" }
  ],
  [
    CaseFields.Date_Of_Authorised_Transaction,
    { label: CaseFields.Date_Of_Authorised_Transaction, type: "date" }
  ],
  [
    CaseFields.Date_Of_Expected_Delivery_Service,
    { label: CaseFields.Date_Of_Expected_Delivery_Service, type: "date" }
  ],
  [
    CaseFields.Description_of_Issue,
    { label: CaseFields.Description_of_Issue, type: "textarea" }
  ],
  [
    CaseFields.Dispute_Reason,
    { label: CaseFields.Dispute_Reason, type: "picklist" }
  ],
  [
    CaseFields.External_System,
    { label: CaseFields.External_System, type: "picklist" }
  ],
  [
    CaseFields.Good_Returned_Or_Service_Cancelled_Date,
    { label: CaseFields.Good_Returned_Or_Service_Cancelled_Date, type: "date" }
  ],
  [
    CaseFields.Goods_Or_Services_Returned,
    { label: CaseFields.Goods_Or_Services_Returned, type: "picklist" }
  ],
  [
    CaseFields.Has_The_Card_Been_Stopped,
    { label: CaseFields.Has_The_Card_Been_Stopped, type: "picklist" }
  ],
  [
    CaseFields.Intended_Account_BSB,
    { label: CaseFields.Intended_Account_BSB, type: "text" }
  ],
  [
    CaseFields.Intended_Account_Name,
    { label: CaseFields.Intended_Account_Name, type: "text" }
  ],
  [
    CaseFields.Intended_Account_Number,
    { label: CaseFields.Intended_Account_Number, type: "text" }
  ],
  [
    CaseFields.Is_The_Card_Lost_Stolen,
    { label: CaseFields.Is_The_Card_Lost_Stolen, type: "picklist" }
  ],
  [
    CaseFields.Is_a_Written_Response_Requested,
    { label: CaseFields.Is_a_Written_Response_Requested, type: "picklist" }
  ],
  [
    CaseFields.Is_this_a_Business_Customer,
    { label: CaseFields.Is_this_a_Business_Customer, type: "picklist" }
  ],
  [CaseFields.Issue_Type, { label: CaseFields.Issue_Type, type: "picklist" }],
  [CaseFields.Priority, { label: CaseFields.Priority, type: "picklist" }],
  [
    CaseFields.Product_or_Service_Name,
    { label: CaseFields.Product_or_Service_Name, type: "lookup" }
  ],
  [
    CaseFields.Received_Amount,
    { label: CaseFields.Received_Amount, type: "number" }
  ],
  [
    CaseFields.Refund_Request_Date,
    { label: CaseFields.Refund_Request_Date, type: "date" }
  ],
  [
    CaseFields.Regular_Payment_Cancellation_Date,
    { label: CaseFields.Regular_Payment_Cancellation_Date, type: "date" }
  ],
  [
    CaseFields.Subsequent_Issue_Type,
    { label: CaseFields.Subsequent_Issue_Type, type: "picklist" }
  ],
  [
    CaseFields.What_Happened_with_Merchant,
    { label: CaseFields.What_Happened_with_Merchant, type: "text" }
  ]
]);

export enum UserRole {
  Coach = "Coach",
  Coach_Lead = "Coach Lead",
  FraudX_Agent = "FraudX Agent",
  Content_Writer = "Content Writer",
  Quality_Analyst = "Quality Analyst",
  Qualtrics_Automation_User = "Qualtrics Integration User",
  Support_Coach = "Support Coach",
  OCV_Automation_User = "OCV Integration Automation Test User",
  Business_Admin = "Business Admin"
}

export const enum Queue {
  Support_Coach_Queue = "Support Coach Queue",
  Content_Writers_Queue = "Content Writers Queue",
  Coach_Queue = "Coach Queue"
}

export const enum TransactionType {
  Card = "Card",
  Deposit_Withdrawal = "Deposit Withdrawal",
  BSB_ACC = "BSB/ACC"
}

export const enum SObject {
  Account = "Account",
  Case = "Case",
  Knowledge = "Knowledge",
  Quality_Assessment = "Quality Assessment",
  Lead = "Lead",
  Financial_Account = "Financial Account"
}

export const enum SObjectAPIName {
  Account = "Account",
  Case = "Case",
  Knowledge = "Knowledge__kav",
  Quality_Assessment = "Quality_Assessment__c",
  Lead = "Lead"
}

export const enum OwnerType {
  Users = "Users",
  Queues = "Queues"
}

export const enum Access {
  Edit = "Edit",
  Read_Only = "Read-Only"
}

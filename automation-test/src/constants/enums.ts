export const enum UserRole {
  COACH = "Coach",
  COACH_LEAD = "Coach Lead",
  FRAUDX_AGENT = "FraudX Agent",
  CONTENT_WRITER = "Content Writer",
  SUPER_SUPPORT_ADMIN = "Super Support Admin",
  QUALITY_ANALYST = "Quality Analyst"
}

export const enum Queue {
  SUPPORT_COACH_QUEUE = "Support Coach Queue",
  CONTENT_WRITERS_QUEUE = "Content Writers Queue"
}

export const enum TransactionType {
  CARD = "Card",
  DEPOSIT_WITHDRAWAL = "Deposit Withdrawal",
  BSB_ACC = "BSB/ACC"
}

export const enum SObject {
  Account = "Account",
  Case = "Case",
  Knowledge = "Knowledge",
  Quality_Assessment = "Quality Assessment"
}

export const enum SObjectAPIName {
  Account = "Account",
  Case = "Case",
  Knowledge = "Knowledge__kav",
  Quality_Assessment = "Quality_Assessment__c"
}

export const enum OwnerType {
  Users = "Users",
  Queues = "Queues"
}

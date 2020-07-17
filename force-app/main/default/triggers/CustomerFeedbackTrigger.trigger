trigger CustomerFeedbackTrigger on Customer_Feedback__c(before insert) {
  CustomerFeedbackTriggerHandler handler = new CustomerFeedbackTriggerHandler();
}
trigger TwilioDetail on Twilio_Details__c(before insert, before update) {
  TwilioDetailHandler handler = new TwilioDetailHandler();
}

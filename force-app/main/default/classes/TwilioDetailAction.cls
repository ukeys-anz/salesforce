/**
 * @author Aman
 * @since 04/2025
 * @description Action class to handle operations Twilio_Details__c records.
 */
public with sharing class TwilioDetailAction {
  /**
   * @description Masks the Summary__c field for eligible Twilio_Details__c records.
   * @param records List of Twilio_Details__c records to check.
   * @param oldMap Map of previous Twilio_Details__c records to compare against.
   */
  public static void maskSummary(
    List<Twilio_Details__c> records,
    Map<Id, Twilio_Details__c> oldMap
  ) {
    try {
      List<Twilio_Details__c> eligibleRecords = ListUtil.filter(records, oldMap)
        .changed(Twilio_Details__c.Summary__c)
        .toList();
      for (Twilio_Details__c twilioDetail : eligibleRecords) {
        twilioDetail.Summary__c = TextUtils.maskDataAnzx(
          twilioDetail.Summary__c
        );
      }
    } catch (Exception ex) {
      Logger.error('Error while masking Summary field.', ex);
      Logger.saveLog();
    }
  }
}

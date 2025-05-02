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
    List<Twilio_Details__c> eligibleRecords = getEligibleRecordsToUpdate(
      records,
      oldMap
    );
    for (Twilio_Details__c twilioDetail : eligibleRecords) {
      twilioDetail.Summary__c = TextUtils.maskDataAnzx(twilioDetail.Summary__c);
    }
  }

  /**
   * @description Returns a list of Twilio_Details__c records eligible for updating the Summary__c field.
   * @param records List of Twilio_Details__c records to check.
   * @param oldMap Map of previous Twilio_Details__c records to compare against.
   * @return List of eligible Twilio_Details__c records.
   */
  public static List<Twilio_Details__c> getEligibleRecordsToUpdate(
    List<Twilio_Details__c> records,
    Map<Id, Twilio_Details__c> oldMap
  ) {
    if (oldMap.isEmpty()) {
      return records;
    }
    List<Twilio_Details__c> eligibleRecords = new List<Twilio_Details__c>();
    for (Twilio_Details__c record : records) {
      if (
        RecordComparisonUtil.fieldWasChanged(
          record,
          oldMap.get(record.Id),
          Twilio_Details__c.Summary__c
        )
      ) {
        eligibleRecords.add(record);
      }
    }
    return eligibleRecords;
  }
}

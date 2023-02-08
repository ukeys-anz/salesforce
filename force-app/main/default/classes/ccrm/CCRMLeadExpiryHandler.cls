/**
 * @author Sahil S
 * @since  09/2021
 * @description Handler class for CCRMLeadExpiryBatch, for updating Leads with Expired status.
 */
public with sharing class CCRMLeadExpiryHandler {
  /**
   * @description method to updated selected Leads with Status as 'Expired'
   * @name updateExpiredLeads
   * @param leadList list of lead records that are having Expiry_Date__C passed are needed to be updated.
   */
  public static void updateExpiredLeads(List<Lead> leadList) {
    List<Lead> updatedLeads = new List<Lead>();
    for (Lead leadRecord : leadList) {
      leadRecord.Status = CCRMConstants.STATUS_EXPIRED;
      updatedLeads.add(leadRecord);
    }

    try {
      if (Schema.sObjectType.Lead.isUpdateable() && !updatedLeads.isEmpty()) {
        List<Database.SaveResult> results = Database.update(
          updatedLeads,
          false
        );
        Logger.error(
          'Error occured while updating Lead Status to Expired.',
          results
        );
        Logger.saveLog();
      }
    } catch (Exception e) {
      Logger.error(
        'Error occured while updating Lead Status to Expired. ' +
        'More details: ' +
        e.getMessage(),
        e
      );
      Logger.saveLog();
    }
  }
}

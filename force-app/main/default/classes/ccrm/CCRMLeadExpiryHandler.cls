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
        Database.update(updatedLeads, true);
      }
    } catch (Exception e) {
      lib_systemLog log = new lib_systemLog(
        CCRMLeadExpiryHandler.class.getName(),
        'updateExpiredLeads'
      );
      log.error(
        '',
        'Error occured while updating Lead Status to Expired. ' +
        'More details: ' +
        e.getMessage()
      );

      // Cannot use async method here, as Future method cannot be called from a future or batch method.
      log.insertLog();
    }
  }
}

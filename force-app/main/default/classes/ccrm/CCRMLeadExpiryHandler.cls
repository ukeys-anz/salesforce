/**
 * @author Sahil S
 * @since  09/2021
 * @description Handler class for CCRMLeadExpiryBatch, for updating Leads with Expired status.
 */
public with sharing class CCRMLeadExpiryHandler {
  private class CustomSharingException extends Exception {
  }
  /**
   * @description method to updated selected Leads with Status as 'Expired'
   * @name updateExpiredLeads
   * @param leadList list of lead records that are having Expiry_Date__C passed are needed to be updated.
   */
  public static void updateExpiredLeads(List<Lead> leadList) {
    List<Lead> updatedLeads = markLeadAsExpired(leadList);
    saveUpdatedLeads(updatedLeads);
  }

  /**
   * @description This method returns a list of leads that has been updated as expired
   * @name markLeadAsExpired
   * @param leadList list of records to be expired
   * @return list of updated leads
   * @author Ashish Kumar
   */
  @TestVisible
  private static List<Lead> markLeadAsExpired(List<Lead> leadList) {
    List<Lead> updatedLeads = new List<Lead>();
    Group objGrp;
    Set<Id> idsOfMLExpiredLead = new Set<Id>();
    for (Lead leadRecord : leadList) {
      if (objGrp == null && CCRMLeadUtil.isMLCRMLeadType(leadRecord)) {
        objGrp = [
          SELECT Id
          FROM Group
          WHERE Name = 'ML Expired Leads' AND Type = 'Queue'
          LIMIT 1
        ];
      }
      if (CCRMLeadUtil.isMLCRMLeadType(leadRecord)) {
        leadRecord.Status = CCRMConstants.STATUS_EXPIRED;
        leadRecord.OwnerId = objGrp.Id;
        idsOfMLExpiredLead.add(leadRecord.Id);
      } else if (CCRMLeadUtil.isCCRMLeadType(leadRecord)) {
        leadRecord.Status = CCRMConstants.STATUS_OUTCOME;
        leadRecord.Lead_Outcome__c = CCRMConstants.STATUS_EXPIRED;
      }
      updatedLeads.add(leadRecord);
    }
    return updatedLeads;
  }

  /**
   * @description This method returns a list of leads that has been updated to expiry
   * @name saveUpdatedLeads
   * @param updatedLeads list of updated leads
   * @author Ashish Kumar
   */
  @TestVisible
  private static void saveUpdatedLeads(List<Lead> updatedLeads) {
    try {
      if (Schema.sObjectType.Lead.isUpdateable() && !updatedLeads.isEmpty()) {
        List<Database.SaveResult> results = Database.update(
          updatedLeads,
          false,
          AccessLevel.USER_MODE
        );
        List<WrapSharingError> lstOfSharingError;
        for (Database.SaveResult saveResult : results) {
          if (!saveResult.isSuccess()) {
            lstOfSharingError = new List<WrapSharingError>();
            for (Database.Error error : saveResult.getErrors()) {
              lstOfSharingError.add(
                new WrapSharingError(saveResult.getId(), error.getMessage())
              );
            }
          }
        }
        if (lstOfSharingError != null && !lstOfSharingError.isEmpty()) {
          Logger.error(
            'Error occured while updating Lead Status to Expired.',
            processSharingException(lstOfSharingError)
          );
          Logger.saveLog();
        }
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

  /**
   * @description This method is return custom error message related to sharing record error
   * @name processSharingException
   * @param lstOfSharingError list of record on which error occurs
   * @return Exception exception object
   * @author Ashish Kumar
   * @US CC-4418
   */
  private static Exception processSharingException(
    List<wrapSharingError> lstOfSharingError
  ) {
    Schema.DescribeFieldResult objDescribe = LogEntry__c.ExceptionMessage__c.getDescribe();
    Integer lengthOfField = objDescribe.getLength();
    return new CustomSharingException(
      JSON.serializePretty(lstOfSharingError).length() > lengthOfField
        ? JSON.serializePretty(lstOfSharingError).substring(0, lengthOfField)
        : JSON.serializePretty(lstOfSharingError)
    );
  }

  /**
   * @description This is wrapper class to create JSON in userid and recordid mapping
   * @name WrapSharingError
   * @author Ashish Kumar
   * @US CC-4418
   */
  public class WrapSharingError {
    public String recordId;
    public String errMsg;

    /**
     * @description This is constructor to create JSON in userid and recordid mapping
     * @name WrapSharingError
     * @param recordId sobject recordid for which sharing failed
     * @param errMsg error message
     * @author Ashish Kumar
     * @US CC-4418
     */
    public WrapSharingError(String recordId, String errMsg) {
      this.recordId = recordId;
      this.errMsg = errMsg;
    }
  }
}
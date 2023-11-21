/**
 * @author  Laxmi Teja Vuyyuru
 * @since 11/2023
 * @description  ComplaintResolutionTriggerHandler is the handler class for Complaint Resolution Trigger for clearing the Remedy dependent values
 * based on Complaint Remedy and Complaint Sub Remedy
 */
public with sharing class IDRComplaintResolutionActions {
  /**
   * @description populateDependentFields method is called onBeforeInsert and onBeforeUpdate
   * to populate the dependent values based on Complaint Remedy or Complaint Sub Remedy.
   * * @param crNewList List of complaint resolution records
   */
  public static void populateDependentFields(
    List<Complaint_Resolution__c> crNewList
  ) {
    for (Complaint_Resolution__c crObj : crNewList) {
      Boolean populateDurationOfRemedy =
        crObj.IDR_Complaint_Sub_Remedy__c == '16' ||
        crObj.IDR_Complaint_Sub_Remedy__c == '20' ||
        crObj.IDR_Complaint_Sub_Remedy__c == 'Repayment arrangement';
      Boolean populateOtherRemedy = crObj.IDR_Complaint_Sub_Remedy__c == '99';
      Boolean populateRewardPoints =
        crObj.IDR_Complaint_Sub_Remedy__c == 'Reward Points';
      Boolean populateProductManufacturer =
        crObj.IDR_Complaint_Remedy__c == '3';
      Boolean populatePaymentAmountProvided =
        crObj.IDR_Complaint_Remedy__c == '1' ||
        crObj.IDR_Complaint_Sub_Remedy__c == '18' ||
        crObj.IDR_Complaint_Sub_Remedy__c == '10';
      crObj.IDR_Duration_of_Remedy__c = populateDurationOfRemedy
        ? crObj.IDR_Duration_of_Remedy__c
        : null;
      crObj.IDR_Other_Remedy_Provided__c = populateOtherRemedy
        ? crObj.IDR_Other_Remedy_Provided__c
        : null;
      crObj.IDR_Financial_Remedy_Points__c = populateRewardPoints
        ? crObj.IDR_Financial_Remedy_Points__c
        : null;
      crObj.IDR_Provided_details_to_Manufacturer__c = populateProductManufacturer
        ? crObj.IDR_Provided_details_to_Manufacturer__c
        : false;
      crObj.IDR_Financial_Compensation__c = populatePaymentAmountProvided
        ? crObj.IDR_Financial_Compensation__c
        : null;
    }
  }
}

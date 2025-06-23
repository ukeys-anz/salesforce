/**
 * @author CMOS
 * @since 05/2025
 * @description  CustomerInformationUpdateTriggerHandler is the handler class for Updating Customer Info.
 */
public with sharing class CustomerInformationUpdateTriggerHandler extends Lib_TriggerHandler {
  Set<Id> eligibleRecordTypes = new Set<Id>{
    RTCase.anzxComplaint,
    RTCase.customerComplaint,
    RTCase.generalInquiryCmos
  };
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public CustomerInformationUpdateTriggerHandler() {
    super();
  }
  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of Complaint and Non Complaint record types
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record type  is either Complaint shell complaint Complaint or anzx complaint else false
   */
  public override Boolean isValidRecord(SObject record) {
    Id caseRTId = ((Case) record).RecordTypeId;
    return eligibleRecordTypes.contains(caseRTId);
  }
  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    List<Case> filteredCases = ListUtil.filter(records, oldMap)
      .notEquals(
        Case.IDR_Customer_Identifier__c,
        IDRConstants.CUSTOMER_IDENTIFIER_CACHE
      )
      .changed(Case.AccountId)
      .toList();
    UpdateCustomerInformation.updateCustomer(filteredCases);
  }
  /**
   * @description onAfterUpdate to handle before update trigger actions.
   */
  public override void onBeforeInsert() {
    List<Case> filteredCases = ListUtil.filter(records)
      .notEquals(
        Case.IDR_Customer_Identifier__c,
        IDRConstants.CUSTOMER_IDENTIFIER_CACHE
      )
      .toList();
    UpdateCustomerInformation.updateCustomer(filteredCases);
  }
}

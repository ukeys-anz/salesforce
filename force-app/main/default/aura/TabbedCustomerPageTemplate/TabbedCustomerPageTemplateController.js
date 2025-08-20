({
  // TO DO: THIS WILL BE A THROW AWAY WORK AND WILL BE REMOVED IN PHASE2
  /* Description: 
    This method is Used: 
    1. To identify the account type (ANZ Plus or Classic) based on ANZx_Customer__c or Was_ANZx_Customer__c fields
    2. To set the selected tab based on the account type
    */
  handleRecordUpdated: function (component) {
    const account = component.get("v.account");
    const isAnzPlusAccount =
      account.ANZx_Customer__c || account.Was_ANZx_Customer__c;
    component.set("v.isAnzPlusAccount", isAnzPlusAccount);
    component.set(
      "v.selectedTab",
      isAnzPlusAccount ? "WhatsHappening" : "CustomerInformation"
    );
  },
  /* Description: 
    This method is used to set value for isAnzPlusAccount to show all tabs if recordId is not present
    Use Case: When Admin edits the page, all tabs should be visible for edit/view 
    */
  doInit: function (component) {
    if (!component.get("v.recordId")) {
      component.set("v.isAnzPlusAccount", true);
    }
  }
});

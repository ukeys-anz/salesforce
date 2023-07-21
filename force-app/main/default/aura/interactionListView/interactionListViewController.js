({
  init: function (component, event, helper) {
    // fetch workspace api to set label to the enclosing tab
    const workspaceAPI = component.find("interactionWorkspaceAPI");

    // fetch the recordtype developername from URL for passing it to apex. for fetching interaction
    const recordTypeDeveloperName = component.get("v.pageReference").state
      .c__recordTypeDeveloperName;

    // fetch the recordId from URL, this can be anything Account, Lead, Case, Coaching Summary etc
    const anyRecordId = component.get("v.pageReference").state.c__anyRecordId;
    component.set("v.anyRecordId", anyRecordId);
    component.set("v.recordTypeDeveloperName", recordTypeDeveloperName);
    workspaceAPI
      .getEnclosingTabId()
      .then(function (enclosedTabId) {
        workspaceAPI.setTabLabel({
          tabId: enclosedTabId,
          label: recordTypeDeveloperName + " List View"
        });
      })
      .catch(function (error) {
        console.log(error);
      });
  }
});

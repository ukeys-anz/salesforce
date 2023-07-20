({
  init: function (component, event, helper) {
    const workspaceAPI = component.find("interactionWorkspaceAPI");
    const recordTypeDeveloperName = component.get("v.pageReference").state
      .c__recordTypeDeveloperName;
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

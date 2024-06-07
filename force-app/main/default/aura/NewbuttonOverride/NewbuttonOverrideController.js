({
  init: function (component, event, helper) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: "Record cannot be created",
      message: "You cannot create new record from Save and New button."
    });
    toastEvent.fire();

    let workspaceAPI = component.find("workspace");
    workspaceAPI.getFocusedTabInfo().then(function (response) {
      workspaceAPI.closeTab({ tabId: response.tabId });
    });
  }
});

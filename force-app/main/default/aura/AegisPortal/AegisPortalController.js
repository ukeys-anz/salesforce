({
  doInit: function (component, event, helper) {
    var action = component.get("c.getAegisUrl");
    //Passing parameters
    action.setParams({
      recordId: component.get("v.recordId"),
      objectType: component.get("v.objectType")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = JSON.stringify(response.getReturnValue());
        component.set("v.url", response.getReturnValue());
      } else {
        var errorMsg = action.getError()[0].message;
        component.set("v.errorStr", errorMsg);
      }
    });
    $A.enqueueAction(action);
  },
  openTabWithSubtab: function (component, event, helper) {
    var aegisURL = component.get("v.url");
    if ($A.util.isUndefined(aegisURL)) {
      helper.showToast(
        "error",
        component.get("v.errorStr"),
        "Aegis Portal Error!"
      );
    } else {
      var recordId = component.get("v.recordId");
      var objectType = component.get("v.objectType");
      var workspaceAPI = component.find("workspace");
      workspaceAPI
        .openTab({
          url: "/lightning/r/" + objectType + "/" + recordId + "/view",
          focus: true
        })
        .then(function (response) {
          workspaceAPI
            .openSubtab({
              parentTabId: response,
              url: aegisURL,
              focus: true
            })
            .then(function (subtabId) {
              // the subtab has been created, use the Id to set the label
              workspaceAPI.setTabLabel({
                tabId: subtabId,
                label: "Aegis portal"
              });
              // the subtab has been created, use the Id to set the icon
              workspaceAPI.setTabIcon({
                tabId: subtabId,
                icon: "standard:knowledge",
                iconAlt: "SubTab Label Name"
              });
              workspaceAPI.focusTab({ tabId: response });
              workspaceAPI.focusTab({ tabId: subtabId });
            })
            .catch(function (error) {
              helper.showToast("error", error, "Aegis Portal Error!");
            });
        })
        .catch(function (error) {
          helper.showToast("error", error, "Aegis Portal Error!");
        });
    }
  }
});

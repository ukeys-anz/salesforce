({
  doInit: function (component, event, helper) {
    var action = component.get("c.getAccount");
    action.setParams({
      accountId: component.get("v.recordId") //Passing parameter
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = JSON.stringify(response.getReturnValue());
        if (result.startsWith("http")) {
          component.set("v.url", response.getReturnValue());
        } else {
          component.set(
            "v.errorStr",
            JSON.stringify(response.getReturnValue())
          );
          component.set("v.showError", true);
        }
      } else {
        helper.showToast(
          "error",
          "Failed to retrieve account details, please contact system administrator for assistance.",
          "Error!"
        );
      }
    });
    $A.enqueueAction(action);
  },
  openTabWithSubtab: function (component, event, helper) {
    var aegisURL = component.get("v.url");
    var accId = component.get("v.recordId");
    var navService = component.find("navService");
    var workspaceAPI = component.find("workspace");
    workspaceAPI
      .openTab({
        url: "/lightning/r/Account/" + accId + "/view",
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
            helper.showToast(
              "error",
              "Could not set Aegis Tab Icon. Please reload screen or Contact your Salesforce administrator for help.",
              "Error!"
            );
          });
      })
      .catch(function (error) {
        helper.showToast(
          "error",
          "Could not set Aegis Tab label. Please reload screen or Contact your Salesforce administrator for help.",
          "Error!"
        );
      });
    if ($A.util.isUndefined(aegisURL)) {
      helper.showToast("error", component.get("v.errorStr"), "Error!");
    }
  }
});

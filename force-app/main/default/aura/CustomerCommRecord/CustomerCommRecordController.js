({
  doInit: function (component, event, helper) {
    var action = component.get("c.getCustomerCommUrl");
    //Passing account ID as parameters to get URL in response.
    action.setParams({
      recordId: component.get("v.recordId")
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
  handleViewAll: function (cmp, event, helper) {
    var recordId = cmp.get("v.recordId");
    var workspaceAPI = cmp.find("workspace");
    let parentTabId = "";
    workspaceAPI.getEnclosingTabId().then(function (enclosingTabId) {
      parentTabId = enclosingTabId;
      workspaceAPI
        .getTabInfo({ tabId: enclosingTabId })
        .then(function (tabInfo) {
          workspaceAPI
            .openSubtab({
              parentTabId: enclosingTabId,
              pageReference: {
                type: "standard__component",
                attributes: {
                  componentName: "c__customerCommRecordDashboardContainer"
                },
                state: {
                  uid: "1",
                  c__vizUrlValue: cmp.get("v.url")
                }
              }
            })
            .then(function (subtabId) {
              workspaceAPI
                .setTabLabel({
                  tabId: subtabId,
                  label: "Comm Records"
                })
                .then(function (tabInfo) {
                  workspaceAPI.setTabIcon({
                    tabId: tabInfo.tabId,
                    icon: "standard:marketing_actions"
                  });
                });
            })
            .catch(function (error) {
              console.log("error");
            });
        });
    });
  }
});

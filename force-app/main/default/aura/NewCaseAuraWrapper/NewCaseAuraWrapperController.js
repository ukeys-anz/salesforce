({
  init: function(component, event, helper) {
    // If there is only one recordtype assigned to the user take him to default case creation
    if (!component.get("v.pageReference").state.recordTypeId) {
      helper.goToNewCaseWithDefaultRecordType(component);
      return;
    }
    // Get the selected record type dev name
    helper.getRtDevName(component, function(rt) {
      if (rt == "Non_Customer_Complaint" || rt == "Customer_Complaint") {
        component.set(
          "v.recordTypeId",
          component.get("v.pageReference").state.recordTypeId
        );
        component.set("v.recordTypeDevName", rt);
        component.set("v.showComponent", true);
        // for cases that are not complaints, open the standard new case form
      } else {
        //workaround for console because the new case form opens in a new tab, so need to close the previous one
        var workspaceAPI = component.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response) {
          if (response == true) {
            workspaceAPI.getFocusedTabInfo().then(function(response) {
              var firstTabId = response.tabId;
              workspaceAPI
                .openConsoleURL({
                  url:
                    "/lightning/o/Case/new?count=1&nooverride=1&recordTypeId=" +
                    component.get("v.pageReference").state.recordTypeId,
                  focus: true
                })
                .then(function(activeTabId) {
                  workspaceAPI.closeTab({ tabId: firstTabId });
                });
            });
          } else {
            helper.goToStandardNewCasePage(component, event);
          }
        });
      }
    });
  },
  handleNavigateRecord: function(component, event) {
    var caseId = event.getParam("caseId");
    var workspaceAPI = component.find("workspace");
    workspaceAPI.isConsoleNavigation().then(function(response) {
      if (response == true) {
        workspaceAPI.getFocusedTabInfo().then(function(response) {
          var firstTabId = response.tabId;
          workspaceAPI
            .openConsoleURL({
              url: "/lightning/r/Case/" + caseId + "/view",
              focus: true
            })
            .then(function(activeTabId) {
              workspaceAPI.closeTab({ tabId: firstTabId });
            });
        });
      } else {
        helper.goToViewRecord(component, event, outputVar.value.Id);
      }
    });
  }
});

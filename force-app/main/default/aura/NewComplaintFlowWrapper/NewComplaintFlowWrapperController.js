({
  init: function(component, event, helper) {
    // Get the selected record type dev name
    helper.getRtDevName(component, function(rt) {
      // Find the component whose aura:id is "newcomplaintflow"
      var flow = component.find("newcomplaintflow");
      // Pass RT to flow
      var inputVariables = [
        {
          name: "RecordTypeId",
          type: "String",
          value: component.get("v.pageReference").state.recordTypeId
        },
        {
          name: "RecordTypeDevName",
          type: "String",
          value: rt
        }
      ];
      // In that component, start the flow by referencing the flow's Unique Name.
      if (rt == "Non_Customer_Complaint" || rt == "Customer_Complaint")
        flow.startFlow("New_Complaint", inputVariables);
      // for cases that are not complaints, open the standard new case form
      else {
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
  handleStatusChange: function(component, event, helper) {
    if (event.getParam("status") === "FINISHED") {
      // get Case Id from flow output values and redirect
      var outputVariables = event.getParam("outputVariables");
      var outputVar;
      for (var i = 0; i < outputVariables.length; i++) {
        outputVar = outputVariables[i];
        if (outputVar.name === "Complaint") {
          //workaround for console because the new case form opens in a new tab, so need to close the previous one
          var workspaceAPI = component.find("workspace");
          workspaceAPI.isConsoleNavigation().then(function(response) {
            if (response == true) {
              workspaceAPI.getFocusedTabInfo().then(function(response) {
                var firstTabId = response.tabId;
                workspaceAPI
                  .openConsoleURL({
                    url: "/lightning/r/Case/" + outputVar.value.Id + "/view",
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
          break;
        }
      }
    }
  }
});

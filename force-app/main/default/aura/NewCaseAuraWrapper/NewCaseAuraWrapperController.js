({
  init: function (component, event, helper) {
    // If there is only one recordtype assigned to the user take him to default case creation
    if (!component.get("v.pageReference").state.recordTypeId) {
      helper.goToNewCaseWithDefaultRecordType(component);
      return;
    }
    //Make the context record id available to the wrapped LWC
    component.set("v.contextRecordId", helper.getContextRecordId(component));
    // Get the selected record type dev name and either show the LWC or redirect to the standard from
    helper.getRtDevName(component, function (rt) {
      if (helper.isComplaintCase(rt)) {
        helper.setComplaintParameters(component, rt)
        // for cases that are not complaints, open the standard new case form
      } else {
        //workaround for console because the new case form opens in a new tab, so need to close the previous one
        helper.handleNonComplaintCase(component)
      }
    });
  },
  urlchange: function (component, event, helper) {
    // This is to perform intended actions from 'goToNewCaseWithDefaultRecordType()' method, if the URL (including "inContextOfRef" parameter) was not readily available at the time of calling the init() method.
    // 'urlchange' method will only be called if;
    // * The user has access to only one record type. And,
    // * If it's not the first time where the user tries to create a new case without a page refresh (the first time it works fine).

    // If there is only one recordtype assigned to the user take him to default case creation
    if (
      !component.get("v.pageReference").state.recordTypeId &&
      helper.getURLParameterByName(component, "inContextOfRef")
    ) {
      helper.goToNewCaseWithDefaultRecordType(component);
      return;
    }
  },
  handleNavigateRecord: function (component, event) {
    var caseId = event.getParam("caseId");
    var workspaceAPI = component.find("workspace");
    workspaceAPI.isConsoleNavigation().then(function (response) {
      if (response == true) {
        workspaceAPI.getFocusedTabInfo().then(function (response) {
          var firstTabId = response.tabId;
          workspaceAPI
            .openConsoleURL({
              url: "/lightning/r/Case/" + caseId + "/view",
              focus: true
            })
            .then(function (activeTabId) {
              workspaceAPI.closeTab({ tabId: firstTabId });
            });
        });
      } else {
        helper.goToViewRecord(component, event, outputVar.value.Id);
      }
    });
  }
});

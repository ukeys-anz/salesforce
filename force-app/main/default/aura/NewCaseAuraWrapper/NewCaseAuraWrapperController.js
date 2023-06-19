({
  init: function (component, event, helper) {
    // Always reset showComponent and showOmni to false, so the lwc does not show along with record type selection page.
    // This happens in non-console app when user selected 'Customer Complaint' or 'Non-Customer Complaint' record type previously.
    component.set("v.showComponent", false);
    component.set("v.showOmni", false);

    //Make the context record id available to the wrapped LWC
    component.set("v.contextRecordId", helper.getContextRecordId(component));
    // Retrieve a list of record types available to the current user
    helper
      .handleGetCaseRecordTypes(component, event, helper)
      .then(function (r) {
        // If no record types are returned then show the warning modal
        if (component.get("v.caseRecordTypes") == null) {
          component.set("v.showWarningModal", true);
        }
        // Else if there is only one recordtype assigned to the user take them to default case creation
        else if (component.get("v.caseRecordTypes").length == 1) {
          helper.goToNewCaseWithDefaultRecordType(component);
          return;
        }
        // Else if there are more than 1 record types assigned to the user, show custom record type selection page
        else if (component.get("v.caseRecordTypes").length > 1) {
          component.set("v.showRecordTypeSelection", true);
        }
      });
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
  },

  // Handle select record type
  handleSelectRecordType: function (component, event, helper) {
    helper.uncheckPreviouslySelectedRadio(component);
    // Set the selected record type Id
    component.set("v.selectedRecordTypeId", event.target.value);
    // Set the selected record type name
    component.set("v.selectedRecordTypeName", event.target.name);
  },

  // Handle cancel
  handleCancel: function (component, event, helper) {},

  // Handle next
  handleNext: function (component, event, helper) {
    // Check if one record type has been selected
    if (component.get("v.selectedRecordTypeId")) {
      // Get the record type name
      let rt = component.get("v.selectedRecordTypeName");
      // If record type name is complaint, then proceed accordingly
      if (helper.isComplaintCase(rt)) {
        helper.setComplaintParameters(component, rt);
      } else {
        // Otherwise, handle as non-complaint case
        helper.handleNonComplaintCase(component);
      }
    }
  },

  // Handle close modal
  handleClose: function (component) {
    let workspaceAPI = component.find("workspace");
    workspaceAPI.getFocusedTabInfo().then(function (response) {
      workspaceAPI.closeTab({ tabId: response.tabId });
    });
  }
});

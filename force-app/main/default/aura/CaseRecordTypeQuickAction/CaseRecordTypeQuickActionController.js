({
  init: function (component, event, helper) {
    // Retrieve a list of record types available to the current user
    helper
      .handleGetCaseRecordTypes(component, event, helper)
      .then(function (r) {
        // If no record types are returned then show the warning modal
        if (component.get("v.caseRecordTypes") == null) {
          component.set("v.showError", true);
        }
        // Else if there are more than 1 record types assigned to the user, show custom record type selection page
        else if (component.get("v.caseRecordTypes").length >= 1) {
          component.set("v.showRecordTypes", true);
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

  // Handle close modal
  handleClose: function (component) {
    var dismissActionPanel = $A.get("e.force:closeQuickAction");
    dismissActionPanel.fire();
  },

  // Handle populating defaults and navigating user to case edit form
  handleNext: function (component, event, helper) {
    var action = component.get("c.getCaseDetailsById");
    action.setParams({
      caseId: component.get("v.recordId"),
      newRecordTypeId: component.get("v.selectedRecordTypeId")
    });
    action.setCallback(this, function (response) {
      $A.get("e.force:closeQuickAction").fire();
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = JSON.parse(response.getReturnValue());
        var autoFillFieldsString = "";
        for (var i in result) {
          autoFillFieldsString =
            autoFillFieldsString + "," + i + "=" + result[i];
        }
        component.set("v.autoFillFieldsString", autoFillFieldsString);
        helper.handleNavig(component);
      } else {
        console.error("Failed with state: " + state);
        this.showToast(
          "error",
          "Failed to retrieve case details, please contact system administrator for assistance.",
          "Error!"
        );
      }
    });
    $A.enqueueAction(action);
  }
});

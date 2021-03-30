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

  // Handle navigating user to case edit form
  handleNext: function (component) {
    $A.get("e.force:closeQuickAction").fire();
    var navService = component.find("navService");
    var pageReference = {
      type: "standard__recordPage",
      attributes: {
        recordId: component.get("v.recordId"),
        objectApiName: "Case",
        actionName: "edit"
      },
      state: {
        defaultFieldValues:
          "RecordTypeId=" + component.get("v.selectedRecordTypeId")
      }
    };
    navService.navigate(pageReference);
  }
});

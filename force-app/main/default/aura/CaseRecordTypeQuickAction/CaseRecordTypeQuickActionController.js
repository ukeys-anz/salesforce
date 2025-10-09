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
    let button = component.find("nextButton");
    button.set("v.disabled", false);
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
    var selectedRecordTypeName = component.get("v.selectedRecordTypeName");
    var action = component.get("c.getCaseDetailsById");
    action.setParams({
      caseId: component.get("v.recordId"),
      newRecordTypeId: component.get("v.selectedRecordTypeId")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state !== "SUCCESS") {
        helper.showToast(
          "error",
          "Failed to retrieve case details, please contact system administrator for assistance.",
          "Error!"
        );
        return;
      }
      let parsedResult = JSON.parse(response.getReturnValue());
      let result = response.getReturnValue();
      if (
        helper.checkForProductCategoryCustomer(
          component,
          parsedResult,
          selectedRecordTypeName
        )
      ) {
        helper.showToast(
          "error",
          "Product category is mandatory before converting it to a complaint.",
          "Error!"
        );
        return;
      }
      if (
        helper.checkForNonCustomer(
          component,
          parsedResult,
          selectedRecordTypeName
        )
      ) {
        helper.showToast(
          "error",
          "Non Customer complaint cannot be recorded if a Customers profile has been retrieved.",
          "Error!"
        );
        return;
      }
      if (
        helper.checkForCustomer(component, parsedResult, selectedRecordTypeName)
      ) {
        helper.showToast(
          "error",
          "Customer complaint cannot be recorded if a Customers details are not populated.",
          "Error!"
        );
        return;
      }
      if (
        helper.checkForPostcodeForNC(
          component,
          parsedResult,
          selectedRecordTypeName
        )
      ) {
        helper.showToast(
          "error",
          "Postcode is mandatory before converting this to a Non Customer Complaint.",
          "Error!"
        );
        return;
      }
      let autoFillFieldsString = "";
      for (var i in parsedResult) {
        autoFillFieldsString =
          autoFillFieldsString + "," + i + "=" + parsedResult[i];
      }
      if (autoFillFieldsString.startsWith(",")) {
        // drop the leading ','
        autoFillFieldsString = autoFillFieldsString.substring(1);
      }
      component.set("v.autoFillFieldsString", autoFillFieldsString);
      component.set("v.defaultFieldsValueString", result);
      let aemCaseFlag = component.get("v.caseRecord.ANZx_Customer__c");
      helper.handleNavig(component, aemCaseFlag);
    });
    $A.enqueueAction(action);
  }
});

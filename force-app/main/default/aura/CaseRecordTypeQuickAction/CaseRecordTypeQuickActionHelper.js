({
  // Handle get available case record types
  handleGetCaseRecordTypes: function (component, event, helper) {
    return new Promise(
      $A.getCallback(function (resolve, reject) {
        var action = component.get("c.getCaseRecordTypesChangeRTBtn");
        action.setParams({
          caseId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
          var state = response.getState();
          if (state === "SUCCESS") {
            let rsp = response.getReturnValue();
            component.set("v.caseRecordTypes", JSON.parse(rsp));
            resolve({ r: component.get("v.caseRecordTypes") });
          } else {
            console.error("Failed with state: " + state);
            this.showToast(
              "error",
              "Failed to retrieve case record types, please contact system administrator for assistance.",
              "Error!"
            );
          }
        });
        $A.enqueueAction(action);
      })
    );
  },

  // Handle unchecking previous selected radio
  uncheckPreviouslySelectedRadio: function (component) {
    let selectedRecordTypeId = component.get("v.selectedRecordTypeId");
    if (selectedRecordTypeId) {
      let selectedRadioButton = document.getElementById(selectedRecordTypeId);
      if (selectedRadioButton.checked) selectedRadioButton.checked = false;
    }
  },

  // Handle show toast
  showToast: function (notificationType, messageText, messageTitle) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: messageTitle,
      message: messageText,
      type: notificationType
    });
    toastEvent.fire();
  },
  // Handle navigating user to case edit form
  handleNavig: function (component) {
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
          "RecordTypeId=" +
          component.get("v.selectedRecordTypeId") +
          component.get("v.autoFillFieldsString")
      }
    };
    navService.navigate(pageReference);
  }
});

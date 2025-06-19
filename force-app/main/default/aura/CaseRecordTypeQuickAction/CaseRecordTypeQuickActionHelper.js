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
  handleNavig: function (component, aemCaseFlag) {
    if (aemCaseFlag) {
      component.set("v.showLWC", true);
      component.set("v.showRTs", false);
    } else {
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
          recordTypeId: component.get("v.selectedRecordTypeId"),
          defaultFieldValues: component.get("v.autoFillFieldsString")
        }
      };
      navService.navigate(pageReference);
    }
  },

  checkForProductCategoryCustomer: function (
    component,
    parsedResult,
    selectedRecordTypeName
  ) {
    return (
      !parsedResult.IDR_Product_Category__c &&
      (selectedRecordTypeName == component.get("v.customerRecordType") ||
        selectedRecordTypeName == component.get("v.noncustomerRecordType"))
    );
  },
  checkForNonCustomer: function (
    component,
    parsedResult,
    selectedRecordTypeName
  ) {
    return (
      component.get("v.caseRecord.ANZx_Customer__c") === false &&
      (parsedResult.AccountId ||
        parsedResult.IDR_Customer_Number__c ||
        parsedResult.IDR_Customer_Identifier__c) &&
      selectedRecordTypeName == component.get("v.noncustomerRecordType")
    );
  },
  checkForCustomer: function (component, parsedResult, selectedRecordTypeName) {
    return (
      component.get("v.caseRecord.ANZx_Customer__c") === false &&
      (!parsedResult.IDR_Customer_Number__c ||
        !parsedResult.IDR_Customer_Identifier__c) &&
      selectedRecordTypeName == component.get("v.customerRecordType")
    );
  }
});

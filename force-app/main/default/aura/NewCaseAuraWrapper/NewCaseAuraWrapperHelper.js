({
  goToStandardNewCasePage: function (component, event) {
    this.handleCaseRecordOpenEvent(
      component,
      component.get("v.selectedRecordTypeId")
    );
  },

  goToViewRecord: function (component, event, recordId) {
    var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      recordId: recordId,
      slideDevName: "detail"
    });
    navEvt.fire();
  },
  goToNewCaseWithDefaultRecordType: function (component) {
    // If there is no record type selected (because user is assigned with only 1 record type), then use that record type Id
    let recordTypeId = component.get("v.selectedRecordTypeId")
      ? component.get("v.selectedRecordTypeId")
      : component.get("v.caseRecordTypes")[0].Id;

    if (component.get("v.caseRecordTypes")[0].Name == "Complaint") {
      this.setComplaintParameters(
        component,
        component.get("v.caseRecordTypes")[0].Name
      );
    } else {
      this.handleCaseRecordOpenEvent(component, recordTypeId);
    }
  },
  handleCaseRecordOpenEvent: function (component, recordTypeId) {
    // Read from URL param 'inContextOfRef' to identify parent record ID
    var parentIdParameter = this.getURLParameterByName(
      component,
      "inContextOfRef"
    );
    var parentInfo = this.extractParentInfo(parentIdParameter);
    // Manually populating the related parent Account record ID when new case creation was originated from a related list
    if (this.isParentObjectAccount(parentInfo)) {
      let workspaceAPI = component.find("workspace");
      workspaceAPI.getFocusedTabInfo().then((response) => {
        var navigationUrl =
          "/lightning/o/Case/new?count=1&nooverride=1&recordTypeId=" +
          recordTypeId;
        this.handleConsoleCaseCreationFromAccountPage(
          component,
          workspaceAPI,
          navigationUrl,
          parentInfo,
          response.tabId
        );
      });
    } else {
      this.openCaseRecordPage(component, recordTypeId, {});
    }
  },
  // Pre-populate Chat Topic lookup if parent object is Account
  extractParentInfo: function (urlParameter) {
    if (urlParameter) {
      var context = JSON.parse(window.atob(urlParameter));

      return {
        parentRecID: context.attributes.recordId,
        parentObjectName: context.attributes.objectApiName
      };
    } else return {};
  },
  openCaseRecordPage: function (
    component,
    recordTypeId,
    defaultFieldValuesObj
  ) {
    var navigationUrl =
      "/lightning/o/Case/new?count=1&nooverride=1&recordTypeId=" + recordTypeId;
    let defaultValuesString;
    for (const [key, value] of Object.entries(defaultFieldValuesObj)) {
      let defaultValuePair = `${key} = ${value}`;
      defaultValuesString += defaultValuePair;
    }
    if (defaultValuesString) navigationUrl += defaultValuesString;
    let workspaceAPI = component.find("workspace");
    workspaceAPI.getFocusedTabInfo().then((response) => {
      this.navigateToNewCaseClosePreviousTab(
        workspaceAPI,
        navigationUrl,
        response.tabId
      );
    });
  },
  getURLParameterByName: function (component, name) {
    name = name.replace(/[\[\]]/g, "\\$&");
    var url = window.location.href;
    var regex = new RegExp("[?&]" + name + "(=1.([^&#]*)|&|#|$)");
    var results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return "";
    return decodeURIComponent(results[2].replace(/\+/g, " "));
  },
  getContextRecordId: function (component) {
    var value = this.getURLParameterByName(component, "inContextOfRef");
    if (value) {
      var context = JSON.parse(window.atob(value));
      return context.attributes.recordId;
    }
    return null;
  },
  navigateToNewCaseClosePreviousTab: function (
    workspaceAPI,
    navigationUrl,
    firstTabId
  ) {
    workspaceAPI
      .openConsoleURL({
        url: navigationUrl,
        focus: true
      })
      .then(function (activeTabId) {
        workspaceAPI.closeTab({ tabId: firstTabId });
      });
  },
  showToast: function (notificationType, messageText, messageTitle) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: messageTitle,
      message: messageText,
      type: notificationType
    });
    toastEvent.fire();
  },
  startSpinner: function (component) {
    component.set("v.loading", true);
  },
  stopSpinner: function (component) {
    if (component.get("v.loading")) {
      component.set("v.loading", false);
    }
  },
  addParentInfoToUrl: function (navigationUrl, parentInfo) {
    return (
      navigationUrl +
      "&ws=%2Flightning%2Fr%2F" +
      parentInfo.parentObjectName +
      "%2F" +
      parentInfo.parentRecID +
      "%2Fview"
    );
  },
  isParentObjectAccount: function (parentInfo) {
    return parentInfo.parentRecID && parentInfo.parentObjectName == "Account";
  },
  isComplaintCase: function (recordType) {
    return (
      recordType == "Non_Customer_Complaint" ||
      recordType == "Customer_Complaint" ||
      recordType == "Complaint"
    );
  },
  setComplaintParameters: function (component, recordType) {
    component.set(
      "v.recordTypeId",
      component.get("v.pageReference").state.recordTypeId
    );
    component.set("v.recordTypeDevName", recordType);
    if (recordType == "Complaint") {
      component.set("v.showComponent", false);
      component.set("v.showOmni", true);
    } else {
      component.set("v.showOmni", false);
      component.set("v.showComponent", true);
    }
    // Hide the record type selection page
    component.set("v.showRecordTypeSelection", false);
  },
  handleNonComplaintCase: function (component) {
    let workspaceAPI = component.find("workspace");

    workspaceAPI.isConsoleNavigation().then((isConsole) => {
      if (isConsole) {
        this.handleConsoleAppCaseCreation(component, workspaceAPI);
      } else {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          url:
            "/lightning/o/Case/new?count=1&nooverride=1&recordTypeId=" +
            component.get("v.selectedRecordTypeId")
        });
        urlEvent.fire();
      }
    });
  },
  handleConsoleAppCaseCreation: function (component, workspaceAPI) {
    workspaceAPI.getFocusedTabInfo().then((response) => {
      //Reading Parent Record ID from URL to manipulate the console URL to open New Case window as a sub-tab.
      var parentIdParameter = this.getURLParameterByName(
        component,
        "inContextOfRef"
      );

      var navigationUrl =
        "/lightning/o/Case/new?count=1&nooverride=1&recordTypeId=" +
        component.get("v.selectedRecordTypeId");

      var parentInfo = this.extractParentInfo(parentIdParameter);

      if (parentInfo.parentRecID) {
        navigationUrl = this.addParentInfoToUrl(navigationUrl, parentInfo);
      }

      if (this.isParentObjectAccount(parentInfo)) {
        this.handleConsoleCaseCreationFromAccountPage(
          component,
          workspaceAPI,
          navigationUrl,
          parentInfo,
          response.tabId
        );
      } else {
        this.navigateToNewCaseClosePreviousTab(
          workspaceAPI,
          navigationUrl,
          response.tabId
        );
      }
    });
  },
  handleConsoleCaseCreationFromAccountPage: function (
    component,
    workspaceAPI,
    navigationUrl,
    parentInfo,
    tabId
  ) {
    //Setting 'defaultFieldValues' to pre-populate the parent Account lookup.
    navigationUrl =
      navigationUrl + "&defaultFieldValues=AccountId=" + parentInfo.parentRecID;

    // When raising a case from the account page, the new record type selection page is open as a subtab
    // therefore after the user selects a record type and proceed, we need to open the form as a sub tab and close the previous one
    this.navigateToNewCaseClosePreviousSubTab(
      workspaceAPI,
      navigationUrl,
      tabId
    );
  },

  // Handle get available case record types
  handleGetCaseRecordTypes: function (component, event, helper) {
    return new Promise(
      $A.getCallback(function (resolve, reject) {
        var action = component.get("c.getCaseRecordTypes");
        action.setCallback(this, function (response) {
          var state = response.getState();
          if (state === "SUCCESS") {
            let rsp = response.getReturnValue();
            let recordTypes = JSON.parse(rsp);
            let cmpInstanceIdentifier = Date.now();
            component.set("v.cmpInstanceIdentifier", cmpInstanceIdentifier);
            // This cmpInstanceIdentifier is a key for each instance of this aura component
            // Each record type's id will have this key as a part of it, so the uncheckPreviouslySelectedRadio() can work
            // if the user has multiple instances of this aura component open
            recordTypes.forEach((rt) => {
              rt.elementId = rt.Id + cmpInstanceIdentifier;
            });
            // Sort record types alphabetically
            recordTypes.sort((a, b) => a.Name.localeCompare(b.Name));
            component.set("v.caseRecordTypes", recordTypes);
            resolve({ r: component.get("v.caseRecordTypes") });
          } else {
            this.showToast("error", "Failed with state: " + state, "Error!");
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
      let selectedRadioButton = document.getElementById(
        selectedRecordTypeId + component.get("v.cmpInstanceIdentifier")
      );
      if (selectedRadioButton.checked) selectedRadioButton.checked = false;
    }
  },

  // Open the URL as a new sub tab, and close the previous sub tab
  navigateToNewCaseClosePreviousSubTab: function (
    workspaceAPI,
    navigationURL,
    parentTabId
  ) {
    workspaceAPI.getFocusedTabInfo().then(function (response) {
      const urlParams = new URLSearchParams(response.url);
      // When a user refresh the account page, this count param will always be 1, we only
      // need to run closeTab when count is > 2 otherwise workspace API will throw error when trying to close previous tab
      let count = urlParams.get("count");
      let prevSubTabId = response.tabId;
      workspaceAPI
        .openSubtab({
          parentTabId: parentTabId,
          url: navigationURL,
          focus: true
        })
        .then(() => {
          if (count > 1) workspaceAPI.closeTab({ tabId: prevSubTabId });
        });
    });
  }
});

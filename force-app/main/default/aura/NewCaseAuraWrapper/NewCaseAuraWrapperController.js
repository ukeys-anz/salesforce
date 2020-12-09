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
        workspaceAPI.isConsoleNavigation().then(function (response) {
          if (response == true) {
            workspaceAPI.getFocusedTabInfo().then(function (response) {
              var firstTabId = response.tabId;

              //Reading Parent Record ID from URL to manipulate the console URL to open New Case window as a sub-tab.
              var value = helper.getURLParameterByName(
                component,
                "inContextOfRef"
              );

              var chatTopicCheckPending = false;

              var navigationUrl =
                "/lightning/o/Case/new?count=1&nooverride=1&recordTypeId=" +
                component.get("v.pageReference").state.recordTypeId;

              if (value) {
                var context = JSON.parse(window.atob(value));
                var parentRecID = context.attributes.recordId;
                var parentObjectName = context.attributes.objectApiName;

                if (parentRecID) {
                  navigationUrl =
                    navigationUrl +
                    "&ws=%2Flightning%2Fr%2F" +
                    parentObjectName +
                    "%2F" +
                    parentRecID +
                    "%2Fview";

                  if (parentObjectName == "Account") {
                    //Setting 'defaultFieldValues' to pre-populate the parent Account lookup.
                    navigationUrl =
                      navigationUrl +
                      "&defaultFieldValues=AccountId=" +
                      parentRecID;

                    // Fetch active Chat Topic ID (if there is any) related to the Customer
                    chatTopicCheckPending = true;
                    helper.getActiveChatTopicID(
                      component,
                      parentRecID,
                      function (topicID) {
                        //Also pre-populating/linking Chat Topic record, if the Case is related to an on-going active chat.
                        var defaultFieldValues = "";
                        if (topicID) {
                          var array = topicID.split("|");
                          if (array.length == 1) {
                            navigationUrl =
                              navigationUrl +
                              ",Chat_Topic__c=" +
                              topicID +
                              ",Origin=Chat";
                          } else {
                            // only comes here if array length > 1
                            // Saving '|' separated IDs on a custom field to help in troubleshooting
                            navigationUrl =
                              navigationUrl +
                              ",Auto_matched_Chat_Topic_IDs__c=" +
                              topicID;
                          }
                        }

                        helper.navigateToNewCaseClosePreviousTab(
                          workspaceAPI,
                          navigationUrl,
                          firstTabId
                        );
                      }
                    );
                  }
                }
              }

              // Check to stop page navigation if Chat Topic linking logic/callback is pending
              if (!chatTopicCheckPending) {
                helper.navigateToNewCaseClosePreviousTab(
                  workspaceAPI,
                  navigationUrl,
                  firstTabId
                );
              }
            });
          } else {
            helper.goToStandardNewCasePage(component, event);
          }
        });
      }
    });
  },
  urlchange: function (component, event, helper) {
    // This is to perform intended actions from 'goToNewCaseWithDefaultRecordType()' method, if the URL (including "inContextOfRef" parameter) was not readily available at the time od calling the init() method.
    // 'urlchange' mwthod will only be called if;
    // * The user has access to only one record type. And,
    // * If it's not the first time he/she tries to create a new case without a page refresh (the first time it works fine).

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

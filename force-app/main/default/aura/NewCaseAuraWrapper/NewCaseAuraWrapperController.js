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

              if (value) {
                var context = JSON.parse(window.atob(value));
                var parentRecID = context.attributes.recordId;
                var parentObjectName = context.attributes.objectApiName;

                if (parentRecID) {
                  // Fetch active Chat Topic ID (if there is any) related to the Customer
                  if (parentObjectName == "Account") {
                    helper.getActiveChatTopicID(
                      component,
                      parentRecID,
                      function (topicID) {
                        //Setting 'defaultFieldValues' to pre-populate the parent Account lookup.
                        //Also pre-populating/linking Chat Topic record, if the Case is related to an on-going active chat.
                        var defaultFieldValues = "";
                        if (topicID) {
                          var array = topicID.split("|");
                          if (array.length == 1) {
                            defaultFieldValues =
                              "&defaultFieldValues=AccountId=" +
                              parentRecID +
                              ",Chat_Topic__c=" +
                              topicID;
                          } else {
                            // only comes here if array length > 1
                            // Saving '|' separated IDs on a custom field to help in troubleshooting
                            defaultFieldValues =
                              "&defaultFieldValues=AccountId=" +
                              parentRecID +
                              ",Auto_matched_Chat_Topic_IDs__c=" +
                              topicID;
                          }
                        } else {
                          defaultFieldValues =
                            "&defaultFieldValues=AccountId=" + parentRecID;
                        }

                        workspaceAPI
                          .openConsoleURL({
                            url:
                              "/lightning/o/Case/new?count=1&nooverride=1&recordTypeId=" +
                              component.get("v.pageReference").state
                                .recordTypeId +
                              "&ws=%2Flightning%2Fr%2F" +
                              parentObjectName +
                              "%2F" +
                              parentRecID +
                              "%2Fview" +
                              defaultFieldValues,
                            focus: true
                          })
                          .then(function (activeTabId) {
                            workspaceAPI.closeTab({ tabId: firstTabId });
                          });
                      }
                    );

                    // TODO: Have to manually pre-pupulate parent lookup for objects other than Account
                    // Only addressing the console sub-tab behaviour for now
                  } else {
                    workspaceAPI
                      .openConsoleURL({
                        url:
                          "/lightning/o/Case/new?count=1&nooverride=1&recordTypeId=" +
                          component.get("v.pageReference").state.recordTypeId +
                          "&ws=%2Flightning%2Fr%2F" +
                          parentObjectName +
                          "%2F" +
                          parentRecID +
                          "%2Fview",
                        focus: true
                      })
                      .then(function (activeTabId) {
                        workspaceAPI.closeTab({ tabId: firstTabId });
                      });
                  }
                } else {
                  workspaceAPI
                    .openConsoleURL({
                      url:
                        "/lightning/o/Case/new?count=1&nooverride=1&recordTypeId=" +
                        component.get("v.pageReference").state.recordTypeId,
                      focus: true
                    })
                    .then(function (activeTabId) {
                      workspaceAPI.closeTab({ tabId: firstTabId });
                    });
                }
              }
            });
          } else {
            helper.goToStandardNewCasePage(component, event);
          }
        });
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
  }
});

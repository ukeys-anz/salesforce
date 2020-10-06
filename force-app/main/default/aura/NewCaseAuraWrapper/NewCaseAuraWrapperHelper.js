({
  getRtDevName: function (component, callback) {
    // Identify which record type was selected
    var action = component.get("c.getCaseRecordTypeDevNameById");
    action.setParams({
      id: component.get("v.pageReference").state.recordTypeId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        if (callback) {
          callback(response.getReturnValue());
        }
      } else {
        console.log("Failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
  },
  goToStandardNewCasePage: function (component, event) {
    var newCaseRecord = $A.get("e.force:createRecord");

    // Read from URL param 'inContextOfRef' to identify parent record ID
    var value = this.getURLParameterByName(component, "inContextOfRef");
    if (value) {
      var context = JSON.parse(window.atob(value));
      var parentRecID = context.attributes.recordId;
      var parentObjectName = context.attributes.objectApiName;

      // Manually populating the related parent Account record ID, and recordTypeId when new case creation was originated from a related list
      if (parentRecID) {
        // Pre-populate Chat Topic lookup if parent object is Account
        if (parentObjectName == "Account") {
          // Fetch active Chat Topic ID (if there is any) related to the Customer
          this.getActiveChatTopicID(component, parentRecID, function (topicID) {
            //Setting 'defaultFieldValues' to pre-populate the parent Account lookup.
            //Also pre-populating/linking Chat Topic record, if the Case is related to an on-going active chat.
            if (topicID) {
              var array = topicID.split("|");
              if (array.length == 1) {
                newCaseRecord.setParams({
                  entityApiName: "Case",
                  recordTypeId: component.get("v.pageReference").state
                    .recordTypeId,
                  defaultFieldValues: {
                    AccountId: parentRecID,
                    Chat_Topic__c: topicID
                  }
                });
              } else {
                // only comes here if array length > 1
                // Saving '|' separated IDs on a custom field to help in troubleshooting
                newCaseRecord.setParams({
                  entityApiName: "Case",
                  recordTypeId: component.get("v.pageReference").state
                    .recordTypeId,
                  defaultFieldValues: {
                    AccountId: parentRecID,
                    Auto_matched_Chat_Topic_IDs__c: topicID
                  }
                });
              }

              newCaseRecord.fire();
            }
          });
        } else {
          //Setting 'defaultFieldValues' to pre-populate the parent Account lookup.
          newCaseRecord.setParams({
            entityApiName: "Case",
            recordTypeId: component.get("v.pageReference").state.recordTypeId,
            defaultFieldValues: {
              AccountId: parentRecID
            }
          });
          newCaseRecord.fire();
        }
      } else {
        newCaseRecord.setParams({
          entityApiName: "Case",
          recordTypeId: component.get("v.pageReference").state.recordTypeId
        });
        newCaseRecord.fire();
      }
    }
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
    var newCaseRecord = $A.get("e.force:createRecord");

    // Read from URL param 'inContextOfRef' to identify parent record ID
    var value = this.getURLParameterByName(component, "inContextOfRef");
    if (value) {
      var context = JSON.parse(window.atob(value));
      var parentRecID = context.attributes.recordId;
      var parentObjectName = context.attributes.objectApiName;

      // Manually populating the related parent Account record ID when new case creation was originated from a related list
      if (parentRecID) {
        // Pre-populate Chat Topic lookup if parent object is Account
        if (parentObjectName == "Account") {
          // Fetch active Chat Topic ID (if there is any) related to the Customer
          this.getActiveChatTopicID(component, parentRecID, function (topicID) {
            //Setting 'defaultFieldValues' to pre-populate the parent Account lookup.
            //Also pre-populating/linking Chat Topic record, if the Case is related to an on-going active chat.
            var defaultFieldValues = "";
            if (topicID) {
              var array = topicID.split("|");
              if (array.length == 1) {
                newCaseRecord.setParams({
                  entityApiName: "Case",
                  defaultFieldValues: {
                    AccountId: parentRecID,
                    Chat_Topic__c: topicID,
                    Origin: "Chat"
                  }
                });
              } else {
                // only comes here if array length > 1
                // Saving '|' separated IDs on a custom field to help in troubleshooting
                newCaseRecord.setParams({
                  entityApiName: "Case",
                  defaultFieldValues: {
                    AccountId: parentRecID,
                    Auto_matched_Chat_Topic_IDs__c: topicID
                  }
                });
              }
              newCaseRecord.fire();
            } else {
              // Chat Topic population faild, fallback option
              newCaseRecord.setParams({
                entityApiName: "Case",
                defaultFieldValues: {
                  AccountId: parentRecID
                }
              });
              newCaseRecord.fire();
            }
          });
        } else {
          // in case if the Parent object isn't Account
          newCaseRecord.setParams({
            entityApiName: "Case"
          });
          newCaseRecord.fire();
        }
      } else {
        // in case there isn't a parent record ID
        newCaseRecord.setParams({
          entityApiName: "Case"
        });
        newCaseRecord.fire();
      }
    }
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
  getActiveChatTopicID: function (component, parentRecID, callback) {
    // Identify which record type was selected
    var action = component.get("c.getActiveChatTopicIDsByCustomer");
    action.setParams({
      accountID: parentRecID
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        if (callback) {
          callback(response.getReturnValue());
        }
      } else {
        console.log("Failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
  }
});

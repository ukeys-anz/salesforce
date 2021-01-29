import { open } from "inspector";

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
    this.handleCaseRecordOpenEvent(component,  component.get("v.pageReference").state.recordTypeId)
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
    this.handleCaseRecordOpenEvent(component, "")
  },
  handleCaseRecordOpenEvent: function(component, recordTypeId){
    var newCaseRecord = $A.get("e.force:createRecord");

    // Read from URL param 'inContextOfRef' to identify parent record ID
    var value = this.getURLParameterByName(component, "inContextOfRef");
    if (value) {
      
      var parentInfo = extractParentInfo(value)
      // Manually populating the related parent Account record ID when new case creation was originated from a related list
      if (parentInfo.parentRecID && parentInfo.parentObjectName == "Account") {            
        

          // Fetch active Chat Topic ID (if there is any) related to the Customer
          this.getActiveChatTopicID(component, parentRecID, this.getCaseRecordOpenBaseonChatCallBack(recordTypeId));
        } 
       else {
         this.openCaseRecordPage(recordTypeId);        
      }
    }
  },
  // Pre-populate Chat Topic lookup if parent object is Account     
  extractParentInfo: function(urlParameter){
      var context = JSON.parse(window.atob(value));

      return { parentRecID : context.attributes.recordId,
         parentObjectName : context.attributes.objectApiName
      }
  },
  getCaseRecordOpenBaseonChatCallBack: function(recordTypeId){
    
   component.set("v.loading", true);

   function openCaseRecordPageBasedOnChatTopic(topicID){
      //Setting 'defaultFieldValues' to pre-populate the parent Account lookup.
      //Also pre-populating/linking Chat Topic record, if the Case is related to an on-going active chat.
      var defaultFieldValues = {};
      if (topicID) {
        
        if (isSingleChatTopic(topicID)) {
      
          defaultFieldValues =  {
              AccountId: parentRecID,
              Twilio_Channel_SID__c: topicID,
              Origin: "Chat"
            }
      
        } else {
          // only comes here if array length > 1
          // Saving '|' separated IDs on a custom field to help in troubleshooting           
            defaultFieldValues = {
              AccountId: parentRecID,
              Auto_matched_Chat_Topic_IDs__c: topicID
            }               
        }

      } else {
        // Chat Topic population faild, fallback option            
          defaultFieldValues = {
            AccountId: parentRecID
          }           
      }
      this.openCaseRecordPage(recordTypeId, defaultFieldValues);
      // Stop loading spinner
      component.set("v.loading", false);
    }
    return openCaseRecordPageBasedOnChatTopic
  },
  isSingleChatTopic: function(topicID){
    return topicID.split("|").length == 1;
  },
  openCaseRecordPage: function(recordTypeId = "", defaultFieldValuesObj = {} ){
    var paramValue = {
      entityApiName: "Case",
      defaultFieldValues: defaultFieldValuesObj
    }
    if(recordTypeId){
      paramValue.recordTypeId = recordTypeId
    }

    newCaseRecord.setParams(paramValue);
    newCaseRecord.fire();
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
        callback("");
        console.log("Failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
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
  showToast: function (notificationType, messageText) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: "Success!",
      message: messageText,
      type: notificationType
    });
    toastEvent.fire();
  }
});

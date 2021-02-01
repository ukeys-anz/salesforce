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

    // Read from URL param 'inContextOfRef' to identify parent record ID
    var parentIdParameter = this.getURLParameterByName(component, "inContextOfRef");

      var parentInfo = this.extractParentInfo(parentIdParameter)
      // Manually populating the related parent Account record ID when new case creation was originated from a related list
      if (this.isParentObjectAccount(parentInfo)) {            
        

          // Fetch active Chat Topic ID (if there is any) related to the Customer
          this.getActiveChatTopicID(component, parentInfo.parentRecID, this.getCaseRecordOpenBaseonChatCallBack(component,parentInfo.parentRecID,recordTypeId));
        } 
       else {
         this.openCaseRecordPage(recordTypeId,{});        
      }
  },
  // Pre-populate Chat Topic lookup if parent object is Account     
  extractParentInfo: function(urlParameter){
    if(urlParameter)
    {
      var context = JSON.parse(window.atob(urlParameter));

      return { parentRecID : context.attributes.recordId,
         parentObjectName : context.attributes.objectApiName
      }
    }else 
    return {}
  },
  getCaseRecordOpenBaseonChatCallBack: function(component,parentRecID,recordTypeId){
    
   this.startSpinner(component)

   return topicID => {
      var defaultFieldValues = {};
      if (topicID) {
        
        if (this.isMultipleChatTopic(topicID)) {          
          defaultFieldValues = {
            AccountId: parentRecID,
            Auto_matched_Chat_Topic_IDs__c: topicID
          }              
      
        } else {
                 
          defaultFieldValues =  {
            AccountId: parentRecID,
            Twilio_Channel_SID__c: topicID,
            Origin: "Chat"
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
       this.stopSpinner(component)
    }
   
  },
  isMultipleChatTopic: function(topicID){
    return topicID.split("|").length > 1;
  },
  openCaseRecordPage: function(recordTypeId, defaultFieldValuesObj){
    var newCaseRecord = $A.get("e.force:createRecord");
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
    this.startSpinner(component);
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
  },
  startSpinner: function(component){
    component.set("v.loading", true);
  },
  stopSpinner: function(component){
    if (component.get("v.loading")) {
      component.set("v.loading", false);
    }
  },
  addParentInfoToUrl: function(navigationUrl, parentInfo){
    return navigationUrl +
    "&ws=%2Flightning%2Fr%2F" +
    parentInfo.parentObjectName +
    "%2F" +
    parentInfo.parentRecID +
    "%2Fview";

  },
  isParentObjectAccount: function(parentInfo){
    return parentInfo.parentRecID && parentInfo.parentObjectName == "Account"
  },
  isComplaintCase: function(recordType){
    return recordType == "Non_Customer_Complaint" || recordType == "Customer_Complaint"
  },
  setComplaintParameters: function(component, recordType){
    component.set(
      "v.recordTypeId",
      component.get("v.pageReference").state.recordTypeId
    );
    component.set("v.recordTypeDevName", recordType);
    component.set("v.showComponent", true);
  },
  handleNonComplaintCase: function(component){
    let workspaceAPI = component.find("workspace");

    workspaceAPI.isConsoleNavigation().then(isConsole => {
      if(isConsole){
        this.handleConsoleAppCaseCreation(component, workspaceAPI)
      }else {
        this.goToStandardNewCasePage(component, event);
      }
    })    
  },
  handleConsoleAppCaseCreation: function(component, workspaceAPI){
       workspaceAPI.getFocusedTabInfo().then(firstTabId => {

      //Reading Parent Record ID from URL to manipulate the console URL to open New Case window as a sub-tab.
      var parentIdParameter = this.getURLParameterByName(
        component,
        "inContextOfRef"
      );

      var navigationUrl =
        "/lightning/o/Case/new?count=1&nooverride=1&recordTypeId=" +
        component.get("v.pageReference").state.recordTypeId;

     
      var parentInfo = this.extractParentInfo(parentIdParameter);

      if (parentInfo.parentRecID) {
        navigationUrl = this.addParentInfoToUrl(navigationUrl, parentInfo)
      }
          

      if (this.isParentObjectAccount(parentInfo)) {
        this.handleConsoleCaseCreationFromAccountPage(component,workspaceAPI, navigationUrl, parentInfo, firstTabId)
      }else{

         this.navigateToNewCaseClosePreviousTab(
            workspaceAPI,
            navigationUrl,
            firstTabId
          )
      }
    })
    
  },
  handleConsoleCaseCreationFromAccountPage: function(component, workspaceAPI, navigationUrl, parentInfo, tabId){
    //Setting 'defaultFieldValues' to pre-populate the parent Account lookup.
    navigationUrl = navigationUrl +"&defaultFieldValues=AccountId=" +  parentInfo.parentRecID

    this.getActiveChatTopicID(
      component,
      parentInfo.parentRecID,
      this.handleConsoleChatCaseCreationCallback(component,navigationUrl, workspaceAPI, tabId)
    );
  },
  handleConsoleChatCaseCreationCallback: function(component,navigationUrl, workspaceAPI, tabId){
    return (topicID) => {
      //Also pre-populating/linking Chat Topic record, if the Case is related to an on-going active chat.
      var defaultFieldValues = "";
      if (topicID) {
   
        if (this.isMultipleChatTopic(topicID)) {
          navigationUrl =
            navigationUrl +
            ",Auto_matched_Chat_Topic_IDs__c=" +
            topicID;

          this.showToast(
            "warning",
            "More than one Active Chat Topics found ! Chat Topic will not be auto-populated on Case."
          );
         
        } else {
          navigationUrl =
          navigationUrl +
          ",Twilio_Channel_SID__c=" +
          topicID +
          ",Origin=Chat";

        this.showToast(
          "success",
          "Active Chat Topic was successfully auto-populated on Case !"
        );
        }
      }

      // Stop loading spinner
      this.stopSpinner(component)

      this.navigateToNewCaseClosePreviousTab(
        workspaceAPI,
        navigationUrl,
        tabId
      );
    }
  }
  
})



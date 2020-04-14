({
  getRtDevName: function(component, callback) {
    // Identify which record type was selected
    var action = component.get("c.getCaseRecordTypeDevNameById");
    action.setParams({
      id: component.get("v.pageReference").state.recordTypeId
    });
    action.setCallback(this, function(response) {
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
  goToStandardNewCasePage: function(component, event) {
   var newCaseRecord = $A.get("e.force:createRecord");

   // Read from URL param 'inContextOfRef' to identify parent record ID
   var value = this.getURLParameterByName(component, 'inContextOfRef');
   if(value){
     var context = JSON.parse(window.atob(value));
     var parentRecID = context.attributes.recordId;

     // Manually populating the related parent Account record ID, and recordTypeId when new case creation was originated from a related list
     if(parentRecID){
       newCaseRecord.setParams({
         entityApiName: "Case",
         recordTypeId: component.get("v.pageReference").state.recordTypeId,
         "defaultFieldValues":{
           "AccountId" : parentRecID,
           }
       });

     } else {
      newCaseRecord.setParams({
        entityApiName: "Case",
        recordTypeId: component.get("v.pageReference").state.recordTypeId
      });
     }
   }

   newCaseRecord.fire();
  },
  goToViewRecord: function(component, event, recordId) {
    var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      recordId: recordId,
      slideDevName: "detail"
    });
    navEvt.fire();
  },
  goToNewCaseWithDefaultRecordType: function(component) {
    var newCaseRecord = $A.get("e.force:createRecord");
    
    // Read from URL param 'inContextOfRef' to identify parent record ID
    var value = this.getURLParameterByName(component, 'inContextOfRef');
    if(value){
      var context = JSON.parse(window.atob(value));
      var parentRecID = context.attributes.recordId;

      // Manually populating the related parent Account record ID when new case creation was originated from a related list
      if(parentRecID){
        newCaseRecord.setParams({
          entityApiName: "Case",
          "defaultFieldValues":{
            "AccountId" : parentRecID,
            }
        });

      } else {
        newCaseRecord.setParams({
          entityApiName: "Case"
        });
      }
    }

    newCaseRecord.fire();
  },
  getURLParameterByName: function(component, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    }
});

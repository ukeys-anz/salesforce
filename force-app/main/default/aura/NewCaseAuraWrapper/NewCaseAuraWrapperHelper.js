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
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      url:
        "/lightning/o/Case/new?count=1&nooverride=1&recordTypeId=" +
        component.get("v.pageReference").state.recordTypeId
    });
    urlEvent.fire();
  },
  goToViewRecord: function(component, event, recordId) {
    var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      recordId: recordId,
      slideDevName: "detail"
    });
    navEvt.fire();
  }
});

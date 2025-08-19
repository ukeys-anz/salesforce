({
  handleInit: function (component, event, helper) {
    var actionAPI = component.find("quickActionAPI");
    actionAPI.getSelectedActions().then(function (result) {
      //LWC
      if (helper.processLWC(component, result.actions)) {
        return;
      }
    });
  },
  closeAction: function () {
    $A.get("e.force:closeQuickAction").fire();
  }
});

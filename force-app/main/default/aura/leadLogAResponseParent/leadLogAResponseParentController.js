({
  handleRefreshActivityTimeline: function (component, event, helper) {
    $A.get("e.force:closeQuickAction").fire();
    $A.get("e.force:refreshView").fire();
  },

  closeModalPopUp: function (component, event, helper) {
    $A.get("e.force:closeQuickAction").fire();
  }
});

({
  UPDATE_SUCCESS_MSG:
    "Changes successfully submitted, please note it may take a couple of seconds before these changes are confirmed.",
  UPDATE_SUCCESS_CAP_DOWN_MSG:
    "Changes have been submitted during CAP downtime ( 12:00AM to 1:30AM AEST), please note your changes will be processed at 1.30AM AEST.",

  showToast: function (message) {
    const toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      type: "warning",
      message: message
    });
    toastEvent.fire();
  },

  handleEventReceived: function (event) {
    const userId = $A.get("$SObjectType.CurrentUser.Id");
    if (event.data.payload.CreatedById != userId) {
      return;
    }
    this.showToast(this.UPDATE_SUCCESS_MSG);
    $A.get("e.force:refreshView").fire();
  }
});

({
  UPDATE_SUCCESS_MSG:
    "Changes successfully submitted, please note it may take a couple of seconds before these changes are confirmed.",
  UPDATE_SUCCESS_CAP_DOWN_MSG:
    "Changes have been submitted during CAP downtime, please note your changes will be processed once CAP is back online.",

  showToast: function (message) {
    const toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      type: "warning",
      duration: 15000,
      message: message
    });
    toastEvent.fire();
  },

  handleEventReceived: function (event) {
    const userId = $A.get("$SObjectType.CurrentUser.Id");
    if (event.data.payload.CreatedById != userId) {
      return;
    }

    const timestamp = new Date(event.data.payload.CreatedDate);

    if (timestamp.getHours() >= 0 && timestamp.getHours() <= 7) {
      this.showToast(this.UPDATE_SUCCESS_CAP_DOWN_MSG);
    } else {
      this.showToast(this.UPDATE_SUCCESS_MSG);
    }
    $A.get("e.force:refreshView").fire();
  }
});

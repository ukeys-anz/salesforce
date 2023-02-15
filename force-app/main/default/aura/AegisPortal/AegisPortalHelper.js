({
  // Handle show toast
  showToast: function (notificationType, messageText, messageTitle) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: messageTitle,
      message: messageText,
      type: notificationType
    });
    toastEvent.fire();
  }
});

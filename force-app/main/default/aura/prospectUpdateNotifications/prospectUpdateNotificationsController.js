({
  handleInit: function (cmp, event, helper) {
    cmp.find("empApi").subscribe(
      "/event/Customer_Profile_Update_Event__e",
      -1,
      $A.getCallback((platformEvent) => {
        helper.handleEventReceived(platformEvent);
      })
    );
  }
});

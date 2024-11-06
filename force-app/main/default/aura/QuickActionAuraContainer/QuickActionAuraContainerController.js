({
  handleInit: function (component) {
    console.log("handleInit called at - ", new Date());
    //this is in place for debugging the prod incident - INC7138580
    try {
      var actionAPI = component.find("quickActionAPI");
      actionAPI.getSelectedActions().then(function (result) {
        console.log("quickActionAPI successful at - ", new Date());
        console.log("result.actions -  ", result.actions);
        var recordIdToBePassed =
          result.actions[0].actionName.split(".")[1] +
          "," +
          result.actions[0].recordId;
        component.set("v.recordIdToBePassed", recordIdToBePassed);
        component.set("v.loadComplete", true);
        console.log(
          "recordIdToBePassed after processing - ",
          recordIdToBePassed
        );
        console.log("Processing end time - ", new Date());
      });
    } catch (e) {
      console.log("error occurred in quickActionAPI - ", JSON.stringify(e));
      console.log("error occurred in quickActionAPI - ", e);
    }
  }
});

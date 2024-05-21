({
  handleInit: function (component) {
    var actionAPI = component.find("quickActionAPI");
    actionAPI.getSelectedActions().then(function (result) {
      var recordIdToBePassed =
        result.actions[0].actionName.split(".")[1] +
        "," +
        result.actions[0].recordId;
      component.set("v.recordIdToBePassed", recordIdToBePassed);
      component.set("v.loadComplete", true);
    });
  }
});

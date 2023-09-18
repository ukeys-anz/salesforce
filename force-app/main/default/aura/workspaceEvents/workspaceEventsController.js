({
  onTabFocused: function (component, event, helper) {
    var workspaceAPI = component.find("workspace");
    workspaceAPI.getFocusedTabInfo().then(function (response) {
      var message = {
        tabInfo: response
      };
      component.find("ConsoleTabFocus").publish(message);
    });
  }
});

({
  handleClose: function (component, event) {
    const workspaceAPI = component.find("workspace");

    workspaceAPI.getFocusedTabInfo().then(function (response) {
      workspaceAPI.closeTab({ tabId: response.tabId });
    });
  }
});

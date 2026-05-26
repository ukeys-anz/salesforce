({
  init: function (component) {
    let workspaceAPI = component.find("workspace");
    workspaceAPI
      .getFocusedTabInfo()
      .then(function (response) {
        let focusedTabId = response.tabId;
        workspaceAPI.setTabLabel({
          tabId: focusedTabId,
          label: "New AI Draft Evaluation"
        });
        workspaceAPI.setTabIcon({
          tabId: focusedTabId,
          icon: "standard:assessment",
          iconAlt: "AI Draft Evaluation"
        });
      })
      .catch(function (error) {
        console.error("Error setting tab label and icon: ", error);
      });
  }
});

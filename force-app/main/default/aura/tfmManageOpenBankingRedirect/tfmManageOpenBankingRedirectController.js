({
  handleInit: function (component, event, helper) {
    var workspaceAPI = component.find("workspace");
    var recordId = component.get("v.recordId");
    workspaceAPI
      .getFocusedTabInfo()
      .then(function (response) {
        var focusedTabId = response.tabId;
        workspaceAPI.openSubtab({
          parentTabId: focusedTabId,
          pageReference: {
            type: "standard__navItemPage",
            attributes: {
              apiName: "TFMManageOpenBankingPage"
            },
            state: { c__recordId: recordId }
          },
          focus: true
        });
      })
      .catch(function (error) {
        console.log(error);
      });
  }
});

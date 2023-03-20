({
  init: function (cmp, evt, helper) {
    const SUBTAB_ICON = "standard:file";
    const COMPONENT_ID = "cfaasFileSubtab";

    let workspaceAPI = cmp.find(COMPONENT_ID);
    let pageRef = cmp.get("v.pageReference");
    let recordId = pageRef.state.c__recordId;
    let title = pageRef.state.c__cmpTitle;
    cmp.set("v.recordId", recordId);
    cmp.set("v.cmpTitle", title);

    if (!recordId) {
      helper.showToast("error", "Record Id is null", "Error!");
    }
    if (!title) {
      helper.showToast("error", "Component Title is null", "Error!");
    }

    workspaceAPI
      .getAllTabInfo()
      .then(function (response) {
        workspaceAPI
          .openTab({
            url: pageRef.state.ws,
            focus: false
          })
          .then(function (response) {
            workspaceAPI.openSubtab({
              parentTabId: response,
              focus: true
            });

            workspaceAPI
              .getFocusedTabInfo()
              .then(function (response) {
                var focusedTabId = response.tabId;

                workspaceAPI.setTabLabel({
                  tabId: focusedTabId,
                  label: title
                });

                workspaceAPI.setTabIcon({
                  tabId: focusedTabId,
                  icon: SUBTAB_ICON,
                  iconAlt: title
                });
              })
              .catch(function (error) {
                helper.showToast("error", error, "Error!");
              });
          })
          .catch(function (error) {
            helper.showToast("error", error, "Error!");
          });

        //delete the new tab if one already exists/opened
        helper.removeDuplicatedTab(response, workspaceAPI);
      })
      .catch(function (error) {
        helper.showToast("error", error, "Error!");
      });
  }
});

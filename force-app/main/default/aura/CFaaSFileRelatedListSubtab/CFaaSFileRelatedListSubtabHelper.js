({
  showToast: function (notificationType, messageText, messageTitle) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: messageTitle,
      message: messageText.message,
      type: notificationType
    });
    toastEvent.fire();
  },
  removeDuplicatedTab: function (response, workspaceAPI) {
    const PAGE_REFERENCE_TYPE = "standard__component";
    const PAGE_REFERENCE_COMPONENT_NAME = "c__CFaaSFileRelatedListSubtab";

    try {
      response.forEach((tab) => {
        let subTabs = tab.subtabs;
        let sameSubtabCount = 0;
        let subtabIdToDelete = null;

        for (const s of subTabs) {
          if (
            s.pageReference.type === PAGE_REFERENCE_TYPE &&
            s.pageReference.attributes.componentName ===
              PAGE_REFERENCE_COMPONENT_NAME
          ) {
            sameSubtabCount++;

            if (sameSubtabCount > 1) {
              subtabIdToDelete = s.tabId;
              break;
            }
          }
        }
        if (subtabIdToDelete) {
          workspaceAPI.closeTab({ tabId: subtabIdToDelete });
        }
      });
    } catch (error) {
      this.showToast("error", error, "Error!");
    }
  }
});

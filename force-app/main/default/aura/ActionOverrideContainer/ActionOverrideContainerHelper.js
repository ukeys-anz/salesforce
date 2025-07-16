({
  config: {
    AccessControl__x: {
      new: "c:pdiCreateAccessControl"
    }
  },
  getParentDetails: function (context) {
    if (!context || !context.startsWith("1.")) {
      return {};
    }
    try {
      const details = JSON.parse(window.atob(context.substr(2)));
      return {
        parentId: details.attributes.recordId,
        parentObjectApiName: details.attributes.objectApiName
      };
    } catch (error) {
      return {};
    }
  },
  loadLwc: function (cmp, data) {
    try {
      const objectConfig = this.config[data.objectApiName];
      const targetLwc = objectConfig[data.actionName];
      this.createLwc(cmp, targetLwc, data);
    } catch (error) {
      this.toast("Action not supported.", "info");
      this.closeTab(cmp);
    }
  },
  createLwc: function (cmp, lwcName, data) {
    $A.createComponent(lwcName, data, (lwcCmp, status) => {
      if (status !== "SUCCESS") {
        this.toast("Error loading component", "error");
        this.closeTab(cmp);
        return;
      }
      const body = cmp.get("v.body");
      body.push(lwcCmp);
      cmp.set("v.body", body);
    });
  },
  closeTab: function (cmp) {
    const workspaceAPI = cmp.find("workspace");
    workspaceAPI.getEnclosingTabId().then(({ tabId }) => {
      workspaceAPI.closeTab({ tabId });
    });
  },
  toast: function (message, variant) {
    const toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      message: message,
      type: variant
    });
    toastEvent.fire();
  }
});

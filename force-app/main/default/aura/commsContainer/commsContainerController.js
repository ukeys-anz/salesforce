({
  doInit: function (cmp, event, helper) {
    try {
      var workspaceAPI = cmp.find("workspace");
      workspaceAPI.openTab({
        pageReference: {
          type: "standard__component",
          attributes: {
            componentName: "c:createComms"
          },
          state: {
            c__recordId: cmp.get("v.recordId")
          }
        }
      });
    } catch (err) {
      console.log("error:" + err);
    }
  }
});

({
  doInit: function (cmp, e, helper) {
    const pageRef = cmp.get("v.pageReference");
    const { recordId, objectApiName, actionName } = pageRef.attributes;
    const { parentId, parentObjectApiName } = helper.getParentDetails(
      pageRef.state.inContextOfRef
    );
    helper.loadLwc(cmp, {
      recordId,
      objectApiName,
      actionName,
      parentId,
      parentObjectApiName
    });
  }
});

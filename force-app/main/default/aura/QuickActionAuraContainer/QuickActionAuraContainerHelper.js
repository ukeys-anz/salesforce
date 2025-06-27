({
  processLWC: function (cmp, actions) {
    //actionName format: ObjectName.lwc_lwcComponentName (e.g. PersonDigitalIdentity__x.lwc_disconnectANZAccounts)
    const { actionName, recordId } = actions[0];
    const idx = actionName.indexOf(".lwc_");
    if (idx === -1) {
      return false;
    }
    cmp.set("v.isLWC", true);

    const lwcCmp = actionName.substr(idx + 5);
    $A.createComponent(
      "c:" + lwcCmp,
      {
        recordId: recordId,
        oncloseaction: cmp.getReference("c.closeAction")
      },
      function (lwcComponent, status, error) {
        if (status === "SUCCESS") {
          // Append the new component to the body
          const body = cmp.get("v.body");
          body.push(lwcComponent);
          cmp.set("v.body", body);
        } else if (status === "INCOMPLETE") {
          cmp.set("v.lwcErrorMessage", "Incomplete");
        } else if (status === "ERROR") {
          cmp.set("v.lwcErrorMessage", error);
        }
      }
    );
    return true;
  }
});

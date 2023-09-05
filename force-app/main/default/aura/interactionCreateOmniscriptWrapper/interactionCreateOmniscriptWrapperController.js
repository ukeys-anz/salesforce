({
  doInit: function (component, event, helper) {
    const navService = component.find("navService");
    let recordTypeId = component.get("v.pageReference").state.recordTypeId;
    if (typeof recordTypeId === undefined) {
      const base64Context = component.get("v.pageReference").state
        .inContextOfRef;
      if (base64Context.startsWith("1. ")) {
        base64Context = base64Context.substring(2);
      }
      const addressableContext = JSON.parse(window.atob(base64Context));
      recordTypeId = addressableContext.attributes.recordTypeId;
    }
    const wsState = component.get("v.pageReference").state.ws;

    //Retrieving account id from page reference
    let regex = new RegExp("\\/(001\\w*)\\/", "g");
    let match = regex.exec(wsState);
    if (match) {
      component.set("v.acccountPrefill", '{"accountId":"' + match[1] + '"}');
    }

    component.set("v.recordTypeIdFromParam", recordTypeId);
    const fetchRTs = component.get("c.getRecordTypeDeveloperName");
    fetchRTs.setParams({
      recordTypeId: recordTypeId
    });

    //Building Page reference for other record types apart from Store
    const pageReference = {
      type: "standard__objectPage",
      attributes: {
        objectApiName: "Interaction",
        actionName: "new"
      },
      state: {
        nooverride: "1",
        recordTypeId: component.get("v.recordTypeIdFromParam")
      }
    };

    const pageReferenceWhenNoRecordTypeExists = {
      type: "standard__objectPage",
      attributes: {
        objectApiName: "Interaction",
        actionName: "new"
      },
      state: {
        nooverride: "1"
      }
    };
    if (recordTypeId) {
      component.set("v.pageReference", pageReference);
    } else {
      component.set("v.pageReference", pageReferenceWhenNoRecordTypeExists);
    }

    //Fetch developer name of the record type and verify if it is store.
    //If Store then open omniscript flow ,if not open the standard new page.
    fetchRTs.setCallback(this, function (response) {
      const returnValue = response.getReturnValue();
      const mapOfDeveloperNameAndIds = JSON.parse(returnValue);
      const rtDeveloperName =
        mapOfDeveloperNameAndIds[component.get("v.recordTypeIdFromParam")]
          .DeveloperName;
      if (rtDeveloperName === "Store") {
        component.set("v.boolIsStore", true);
        component.set("v.spinner", false);
      } else if (rtDeveloperName === "General") {
        component.set("v.boolIsGeneral", true);
        component.set("v.spinner", false);
      } else if (rtDeveloperName === "Message") {
        component.set("v.boolIsChat", true);
        component.set("v.spinner", false);
      } else {
        component.set("v.spinner", false);
        navService.navigate(pageReference, true);
      }
    });
    component.set("v.spinner", false);
    if (recordTypeId) {
      $A.enqueueAction(fetchRTs);
    } else {
      navService.navigate(pageReferenceWhenNoRecordTypeExists, true);
    }
  }
});

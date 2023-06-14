({
  doInit: function (component, event, helper) {
    const navService = component.find("navService");
    const recordTypeId = component.get("v.pageReference").state.recordTypeId;
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

    component.set("v.pageReference", pageReference);

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
      } else {
        component.set("v.spinner", false);
        navService.navigate(pageReference, true);
      }
    });

    $A.enqueueAction(fetchRTs);
  }
});

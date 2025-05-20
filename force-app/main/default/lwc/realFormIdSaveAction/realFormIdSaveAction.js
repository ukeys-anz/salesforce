import { LightningElement } from "lwc";
import { updateRecord } from "lightning/uiRecordApi";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { handleErrorShowToast } from "c/utils";
import { showToast } from "c/utils";
import REALFORMREQ_FIELD from "@salesforce/schema/Case.IDR_Real_Form_Req__c";
import REALEVENTID_FIELD from "@salesforce/schema/Case.IDR_Real_Form_Ref_No__c";
import CASEID_FIELD from "@salesforce/schema/Case.Id";

export default class realFormIdSaveAction extends OmniscriptBaseMixin(
  LightningElement
) {
  loading = false;
  callSaveRealFormIDDR() {
    this.loading = true;
    if (this.validateRealFormID()) {
      handleErrorShowToast(
        this,
        "Real Form ID Validation",
        undefined,
        "Please Validate Real Form ID."
      );
      this.loading = false;
      return;
    }
    if (
      this.omniJsonData.EditRealFormID.RealFormRequired === "No" &&
      this.omniJsonData.EditRealFormID.RealFormID
    ) {
      this.omniJsonData.EditRealFormID.RealFormID = "";
    }
    if (
      this.omniJsonData.EditRealFormID.RealFormRequired_OLD ===
        this.omniJsonData.EditRealFormID.RealFormRequired &&
      (this.omniJsonData.EditRealFormID.RealFormID !== undefined ||
        this.omniJsonData.EditRealFormID.RealFormID !== null) &&
      (this.omniJsonData.EditRealFormID.RealFormID_OLD !== undefined ||
        this.omniJsonData.EditRealFormID.RealFormID_OLD !== null) &&
      this.omniJsonData.EditRealFormID.RealFormID ===
        this.omniJsonData.EditRealFormID.RealFormID_OLD
    ) {
      handleErrorShowToast(
        this,
        "Please make any Updates",
        undefined,
        "Please make any update to Risk Event ID and Validate."
      );
      this.loading = false;
      return;
    }
    if (
      this.omniJsonData.EditRealFormID.RealFormRequired === "Y_EXI" &&
      this.omniJsonData.validatedEventNumber !==
        this.omniJsonData.EditRealFormID.RealFormID
    ) {
      handleErrorShowToast(
        this,
        "Real Form ID Validation",
        undefined,
        "Revalidate Risk Event ID"
      );
      this.loading = false;
      return;
    }
    if (
      this.omniJsonData.EditRealFormID.RealFormRequired === undefined ||
      this.omniJsonData.EditRealFormID.RealFormRequired === null
    ) {
      handleErrorShowToast(
        this,
        "Is a REaL Form Required - Mandatory",
        undefined,
        "Please select a value for this field - Is a REaL Form Required"
      );
      this.loading = false;
      return;
    }
    this.handleSave(this.omniJsonData);
  }

  handleSave(data) {
    const fields = {};
    // Map the user input to the fields
    if (data?.EditRealFormID.RealFormRequired !== "Y_NEW") {
      fields[REALEVENTID_FIELD.fieldApiName] = data?.EditRealFormID.RealFormID;
    }
    fields[REALFORMREQ_FIELD.fieldApiName] =
      data?.EditRealFormID.RealFormRequired;
    fields[CASEID_FIELD.fieldApiName] = data.recordId;
    const recordInput = { fields };
    updateRecord(recordInput)
      .then(() => {
        this.loading = false;
        let url = window.location.origin + "/" + data.recordId;
        window.open(url, "_self");
      })
      .catch((err) => {
        let msg = err?.body?.output?.errors[0]?.message;
        if (
          msg.includes("You are not authorized to make updates to this field.")
        ) {
          showToast(this, "Error Updating Real Form ID", msg, "", "error");
        } else {
          handleErrorShowToast(
            this,
            "Error Updating Real Form ID",
            err,
            "System Exception: Error Updating Real Form Id"
          );
        }
        this.loading = false;
      });
  }

  validateRealFormID() {
    if (
      this.omniJsonData.EditRealFormID.RealFormRequired === "Y_EXI" &&
      (this.omniJsonData.EditRealFormID.RealFormID !== undefined ||
        this.omniJsonData.EditRealFormID.RealFormID !== null) &&
      this.omniJsonData.EditRealFormID.RealFormID !==
        this.omniJsonData.EditRealFormID.RealFormID_OLD &&
      !(
        this.omniJsonData.apiRun &&
        this.omniJsonData.apiSuccess &&
        this.omniJsonData.RiskFormIDValid
      )
    ) {
      return true;
    }
    return false;
  }
}

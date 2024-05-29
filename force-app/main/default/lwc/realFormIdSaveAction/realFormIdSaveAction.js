import { LightningElement } from "lwc";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import util from "omnistudio/utility";
import { handleErrorShowToast } from "c/utils";
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
      this.omniJsonData.EditRealFormID.RealFormRequired === "Yes" &&
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
        "Is a REAL Form Required - Mandatory",
        undefined,
        "Please select a value for this field - Is a REAL Form Required"
      );
      this.loading = false;
      return;
    }
    let request_data = {
      type: "DataRaptor",
      value: {
        bundleName: "DRCaseRealFormIdUpdate2",
        inputMap: "{}",
        optionsMap: "{}"
      }
    };
    request_data.value.inputMap = JSON.stringify(this.omniJsonData);
    util
      .getDataHandler(JSON.stringify(request_data))
      .then((result) => {
        const jsonResult = JSON.parse(result);
        this.omniApplyCallResp({ jsonNodeName: jsonResult });
        this.loading = false;
        let url = window.location.origin + "/" + this.omniJsonData.recordId;
        window.open(url, "_self");
      })
      .catch((err) => {
        handleErrorShowToast(
          this,
          "Error Updating Real Form ID",
          err,
          "System Exception: Error Updating Real Form Id"
        );
        this.loading = false;
      });
  }

  validateRealFormID() {
    if (
      this.omniJsonData.EditRealFormID.RealFormRequired === "Yes" &&
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

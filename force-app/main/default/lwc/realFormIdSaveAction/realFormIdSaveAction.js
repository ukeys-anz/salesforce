import { LightningElement } from "lwc";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import util from "omnistudio/utility";
import { handleErrorShowToast } from "c/utils";
export default class realFormIdSaveAction extends OmniscriptBaseMixin(
  LightningElement
) {
  loading = false;
  connectedCallback() {
    console.log("Real form save cmp");
  }
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
    console.log(JSON.stringify(this.omniJsonData));
    if (
      this.omniJsonData.EditRealFormID.RealFormRequired_OLD ===
        this.omniJsonData.EditRealFormID.RealFormRequired &&
      this.omniJsonData.EditRealFormID.RealFormID ===
        this.omniJsonData.EditRealFormID.RealFormID_OLD
    ) {
      handleErrorShowToast(
        this,
        "Please make some changes",
        undefined,
        "Please make any changes to above field and Validate Real Form ID."
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
        console.log(jsonResult);
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
    console.log(this.omniJsonData);
    if (
      this.omniJsonData.EditRealFormID.RealFormRequired === "Yes" &&
      (this.omniJsonData.EditRealFormID.RealFormID !== undefined ||
        this.omniJsonData.EditRealFormID.RealFormID !== null) &&
      this.omniJsonData.EditRealFormID.RealFormID !==
        this.omniJsonData.EditRealFormID.RealFormID_OLD
    ) {
      if (
        this.omniJsonData.apiRun &&
        this.omniJsonData.apiSuccess &&
        this.omniJsonData.RiskFormIDValid
      ) {
        return false;
      }
      return true;
    }
    return false;
  }
}

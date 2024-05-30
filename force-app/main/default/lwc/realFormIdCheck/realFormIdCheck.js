import { LightningElement, api, wire } from "lwc";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import getSNOWEventInfoLWC from "@salesforce/apex/IDRAPIRepository.getSNOWEventInfoLWC";
import { getRecord } from "lightning/uiRecordApi";
import REAL_FORM_REQUIRED from "@salesforce/schema/Case.IDR_Real_Form_Req__c";
import REAL_FORM_ID from "@salesforce/schema/Case.IDR_Real_Form_Ref_No__c";
import { handleErrorShowToast, showToast } from "c/utils";
import { CloseActionScreenEvent } from "lightning/actions";

export default class RealFormIdCheck extends OmniscriptBaseMixin(
  LightningElement
) {
  loading = false;
  iconName;
  apiRun = false;
  @api
  showButton = false;
  @api
  recordId;
  realFormId;
  callFromOmni = false;
  realFormRequired;
  @wire(getRecord, {
    recordId: "$recordId",
    fields: [REAL_FORM_REQUIRED, REAL_FORM_ID]
  })
  wiredProject({ data }) {
    if (data) {
      this.realFormId = data.fields[REAL_FORM_ID.fieldApiName].value;
      this.realFormRequired =
        data.fields[REAL_FORM_REQUIRED.fieldApiName].value;
      if (!this.showButton) {
        this.runDirectValidation();
      }
    }
  }
  closeAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
  runDirectValidation() {
    if (
      this.realFormRequired === "Yes" &&
      !(this.realFormId === null || this.realFormId === undefined)
    ) {
      this.callAPI(this.realFormId);
    }
  }
  startValidation() {
    this.callFromOmni = true;
    if (this.omniJsonData.Case) {
      if (
        this.omniJsonData.Case.ResolutionInformation &&
        this.omniJsonData.Case.ResolutionInformation.realFormRequired ===
          "Yes" &&
        !(
          this.omniJsonData.Case.ResolutionInformation.realFormMAXId === null ||
          this.omniJsonData.Case.ResolutionInformation.realFormMAXId ===
            undefined
        )
      ) {
        this.callAPI(
          this.omniJsonData.Case.ResolutionInformation.realFormMAXId
        );
      }
      if (this.omniJsonData.Case.REALFormMAXID) {
        this.callAPI(this.omniJsonData.Case.REALFormMAXID);
      }
    } else if (
      this.omniJsonData.EditRealFormID &&
      this.omniJsonData.EditRealFormID.RealFormRequired === "Yes" &&
      !(
        this.omniJsonData.EditRealFormID.RealFormID === null ||
        this.omniJsonData.EditRealFormID.RealFormID === undefined
      )
    ) {
      this.callAPI(this.omniJsonData.EditRealFormID.RealFormID);
    }
  }
  callAPI(riskEventId) {
    riskEventId = riskEventId.trim();
    this.loading = true;
    getSNOWEventInfoLWC({
      riskEventId: riskEventId
    })
      .then((result) => {
        this.showValidations(result, undefined, riskEventId);
        this.loading = false;
      })
      .catch((error) => {
        this.showValidations(undefined, error, undefined);
        this.loading = false;
      });
  }
  showValidations(result, error, riskEventId) {
    this.apiRun = true;
    let data = {
      apiRun: false,
      apiSuccess: false,
      RiskFormIDValid: false,
      validatedEventNumber: undefined
    };
    this.iconName = "action:close";
    if (result) {
      data.apiRun = true;
      data.apiSuccess = true;
      if (result.result.length > 0) {
        let firstResponse = result.result[0];
        if (firstResponse.eventNumber === riskEventId) {
          this.iconName = "action:approval";
          data.RiskFormIDValid = true;
          data.validatedEventNumber = firstResponse.eventNumber;
          showToast(
            this,
            "Real Form ID Valid",
            "Real Form ID is Validated from SNOW.",
            undefined,
            "success",
            undefined
          );
        } else {
          this.showError();
        }
      } else {
        this.showError();
      }
    }
    if (error) {
      data.apiRun = true;
      data.apiSuccess = false;
      this.showError();
    }
    if (this.callFromOmni) {
      this.omniApplyCallResp(data);
    } else {
      this.closeAction();
    }
  }
  showError() {
    handleErrorShowToast(
      this,
      "Real Form ID Invalid",
      undefined,
      "Please enter a valid Risk Event ID to continue."
    );
  }
}

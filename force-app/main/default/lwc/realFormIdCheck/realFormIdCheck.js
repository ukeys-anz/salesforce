import { LightningElement, api } from "lwc";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { NavigationMixin } from "lightning/navigation";
import getSNOWEventInfoLWC from "@salesforce/apex/IDRAPIRepository.getSNOWEventInfoLWC";
import { handleErrorShowToast, showToast } from "c/utils";
import { CloseActionScreenEvent } from "lightning/actions";
import SNOW_URL from "@salesforce/label/c.IDR_ServiceNow_env_url";

export default class RealFormIdCheck extends OmniscriptBaseMixin(
  NavigationMixin(LightningElement)
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
  _showCreate = false;
  showValidate = false;
  _selectedOption;
  snowUrlJson = JSON.parse(SNOW_URL);

  showError() {
    handleErrorShowToast(
      this,
      "Real Form ID Invalid",
      undefined,
      "Please enter a valid Risk Event ID to continue."
    );
  }

  @api set selectedOption(value) {
    this._showCreate = value === "Y_NEW" ? true : false;
    this._selectedOption = value;
  }
  get selectedOption() {
    return this._selectedOption;
  }

  closeAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
  showResponseFailError() {
    handleErrorShowToast(
      this,
      "Unable to Validate",
      undefined,
      "CMOS is unable to validate the Risk Event ID at this time, please try again later"
    );
  }
  startValidation() {
    let data = {};
    this.callFromOmni = true;
    if (
      this.omniJsonData.EditRealFormID?.RealFormRequired === "Y_EXI" &&
      !(
        this.omniJsonData.EditRealFormID?.RealFormID === null ||
        this.omniJsonData.EditRealFormID?.RealFormID === undefined
      )
    ) {
      data.EditRealFormID = {
        RealFormID: this.omniJsonData.EditRealFormID.RealFormID.trim()
      };
      this.callAPI(this.omniJsonData.EditRealFormID.RealFormID);
    } else {
      if (
        this.omniJsonData.Case?.ResolutionInformation?.realFormRequired ===
          "Y_EXI" &&
        !(
          this.omniJsonData.Case?.ResolutionInformation?.realFormMAXId ===
            null ||
          this.omniJsonData.Case?.ResolutionInformation?.realFormMAXId ===
            undefined
        )
      ) {
        data.Case = {
          ResolutionInformation: {
            realFormMAXId:
              this.omniJsonData.Case.ResolutionInformation.realFormMAXId.trim()
          }
        };
        this.callAPI(
          this.omniJsonData.Case.ResolutionInformation.realFormMAXId
        );
      }
      if (this.omniJsonData.Case?.REALFormMAXID) {
        data.Case = {
          REALFormMAXID: this.omniJsonData.Case.REALFormMAXID.trim()
        };
        this.callAPI(this.omniJsonData.Case.REALFormMAXID);
      }
    }
    this.omniApplyCallResp(data);
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
      this.showResponseFailError();
    }
    if (this.callFromOmni) {
      this.omniApplyCallResp(data);
    } else {
      this.closeAction();
    }
  }

  redirectToForm() {
    let domainName = window.location.host.split(".")[0];
    let snowInstanceUrl = this.snowUrlJson[domainName] ?? "";
    if (!snowInstanceUrl) {
      handleErrorShowToast(
        this,
        "Unable to fetch a valid url",
        undefined,
        "Please contact your system administrator to set the required redirection url."
      );
    } else {
      let redirectionUrl = snowInstanceUrl
        .replace("CASEID", encodeURIComponent(this.omniJsonData.recordId))
        .replace(
          "CASENUMBER",
          encodeURIComponent(this.omniJsonData.Case.CaseNumber)
        );

      this[NavigationMixin.Navigate]({
        type: "standard__webPage",
        attributes: {
          url: redirectionUrl
        }
      });
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
}

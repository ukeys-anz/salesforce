import { LightningElement, api } from "lwc";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { NavigationMixin } from "lightning/navigation";
import getSNOWEventInfoLWC from "@salesforce/apex/IDRAPIRepository.getSNOWEventInfoLWC";
import { handleErrorShowToast, showToast, navigate } from "c/utils";
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
  _showCreate = false;
  _selectedOption;
  snowUrlJson = JSON.parse(SNOW_URL);

  @api set selectedOption(value) {
    this._showCreate = value === "Y_NEW" ? true : false;
    this._selectedOption = value;
  }
  get selectedOption() {
    return this._selectedOption;
  }

  startValidation() {
    let reaFormId =
      this.omniJsonData?.EditRealFormID?.RealFormID ??
      this.omniJsonData?.Case?.ResolutionInformation?.realFormMAXId ??
      this.omniJsonData.Case?.REALFormMAXID;

    let isRealFormRequired =
      this.omniJsonData.EditRealFormID?.RealFormRequired ??
      this.omniJsonData.Case?.ResolutionInformation?.realFormRequired ??
      this.omniJsonData.Case?.realFormRequired;

    if (!reaFormId || isRealFormRequired !== "Y_EXI") {
      return;
    }

    if (this.omniJsonData?.EditRealFormID?.RealFormID) {
      this.callAPI(this.omniJsonData.EditRealFormID.RealFormID);
      this.omniApplyCallResp({
        EditRealFormID: {
          RealFormID: this.omniJsonData.EditRealFormID.RealFormID.trim()
        }
      });
      return;
    }

    if (this.omniJsonData?.Case?.ResolutionInformation?.realFormMAXId) {
      this.callAPI(this.omniJsonData.Case.ResolutionInformation.realFormMAXId);
      this.omniApplyCallResp({
        Case: {
          ResolutionInformation: {
            realFormMAXId:
              this.omniJsonData.Case.ResolutionInformation.realFormMAXId.trim()
          }
        }
      });
      return;
    }

    this.callAPI(this.omniJsonData.Case?.REALFormMAXID);
    this.omniApplyCallResp({
      Case: {
        REALFormMAXID: this.omniJsonData.Case?.REALFormMAXID.trim()
      }
    });
  }

  showValidations(result, error, riskEventId) {
    this.apiRun = true;
    let data = {
      apiRun: false,
      apiSuccess: false,
      RiskFormIDValid: false,
      validatedEventNumber: null
    };
    this.iconName = "action:close";
    if (error) {
      handleErrorShowToast(
        this,
        "Unable to Validate",
        null,
        "CMOS is unable to validate the Risk Event ID at this time, please try again later"
      );
      this.omniApplyCallResp({ ...data, apiRun: true });
      return;
    }
    let eventId = result.result?.[0]?.eventNumber;

    if (eventId !== riskEventId) {
      handleErrorShowToast(
        this,
        "Real Form ID Invalid",
        null,
        "Please enter a valid Risk Event ID to continue."
      );
      this.omniApplyCallResp({ ...data, apiRun: true, apiSuccess: true });
      return;
    }
    this.iconName = "action:approval";
    showToast(
      this,
      "Real Form ID Valid",
      "Real Form ID is Validated from SNOW.",
      null,
      "success",
      null
    );
    this.omniApplyCallResp({
      apiRun: true,
      apiSuccess: true,
      RiskFormIDValid: true,
      validatedEventNumber: eventId
    });
  }

  redirectToForm() {
    let domainName = window.location.host.split(".")[0];
    let snowInstanceUrl = this.snowUrlJson[domainName] ?? "";
    if (!snowInstanceUrl) {
      handleErrorShowToast(
        this,
        "Unable to fetch a valid url",
        null,
        "Please contact your system administrator to set the required redirection url."
      );
      return;
    }
    snowInstanceUrl = snowInstanceUrl
      .replace("CASEID", encodeURIComponent(this.omniJsonData.recordId))
      .replace(
        "CASENUMBER",
        encodeURIComponent(this.omniJsonData.Case.CaseNumber)
      );

    navigate(this, "standard__webPage", { url: snowInstanceUrl });
  }

  callAPI(riskEventId) {
    this.loading = true;
    riskEventId = riskEventId.trim();
    getSNOWEventInfoLWC({
      riskEventId
    })
      .then((result) => {
        this.showValidations(result, null, riskEventId);
      })
      .catch((error) => {
        this.showValidations(null, error, null);
      })
      .finally(() => {
        this.loading = false;
      });
  }
}

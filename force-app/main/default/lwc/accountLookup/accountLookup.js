import { LightningElement } from "lwc";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
export default class AccountLookup extends OmniscriptBaseMixin(
  LightningElement
) {
  recId;
  isDisabled = false;

  get accountIdStr() {
    try {
      if (this.recId) {
        return this.recId;
      }
      const inContextVal = this.getURLParameterByName("inContextOfRef");
      const context = JSON.parse(window.atob(inContextVal));
      let recordIdFromURL = context.attributes.recordId;
      let objectName = context.attributes.objectApiName;
      if (objectName === "Account") {
        this.recId = recordIdFromURL;
        this.isDisabled = true;
        this.setCaseAccountId();
      }
    } catch (err) {
      this.recId = "";
    }
    return this.recId;
  }

  handleChange(event) {
    this.recId = event.target.value;
    this.setCaseAccountId();
  }

  setCaseAccountId() {
    let Case = JSON.parse(JSON.stringify(this.omniJsonData.Case));
    Case.AccountId = this.recId;
    this.omniApplyCallResp({ Case });
  }

  getURLParameterByName(name) {
    var regex, results, url;
    url = window.location.href;
    name = name.replace(/[[\]]/g, "$&");
    regex = new RegExp("[?&]" + name + "(=1.([^&#]*)|&|#|$)");
    results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return "";
    return decodeURIComponent(results[2].replace(/\+/g, " "));
  }
}

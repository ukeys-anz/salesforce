import { LightningElement, api, track } from "lwc";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";

export default class CustomRadiobuttonWithIcon extends OmniscriptBaseMixin(
  LightningElement
) {
  // api variables are used to accept data from Omniscript
  @api arrayValue;
  @api userSelection;
  @track _buttonList = [];

  gridSize;
  isFirstRun = true;

  @api set buttonList(arr) {
    // if a single JSON object is passed instead of array, convert it to an array
    this._buttonList = Array.isArray(arr) ? arr : new Array(arr);
    this.gridSize =
      this._buttonList.length > 5
        ? "slds-size_1-of-" + this._buttonList.length
        : "slds-size_1-of-5";
  }
  get buttonList() {
    return this._buttonList;
  }

  get colSizeCss() {
    return "slds-p-right_small slds-col " + this.gridSize + " buttonblock";
  }

  // renderedCallback is used to show user's selected button or default selection for a screen
  renderedCallback() {
    if (!this.isFirstRun) return;

    if (!this._buttonList || !this._buttonList.length) return;

    let showSelectedButton = this.userSelection
      ? this.userSelection
      : this._buttonList[0].name;

    let defaultButton = this.template.querySelector(
      `input[name="customRadio"][value="${showSelectedButton}"]`
    );

    if (!defaultButton) return;

    defaultButton.checked = true;
    let updateDefault = {
      selectedButtonName: showSelectedButton
    };
    // highlight the selected button and update the data json
    this.omniUpdateDataJson(updateDefault);
    this.isFirstRun = false;
  }

  // update the data json on change of radio button
  handleChange(event) {
    let selectedButton = event.target.value;
    let talkTrack = {
      selectedButtonName: selectedButton
    };
    this.omniUpdateDataJson(talkTrack);
  }
}

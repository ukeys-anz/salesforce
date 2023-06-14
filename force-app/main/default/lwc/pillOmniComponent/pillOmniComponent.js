/**
 * Created by Nagendra on 02-06-2023.
 */

import { api, track, LightningElement } from "lwc";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";

export default class PillOmniComponent extends OmniscriptBaseMixin(
  LightningElement
) {
  @track _allValues;
  @api elementName;

  @api
  get allValues() {
    return this._allValues;
  }

  set allValues(value) {
    console.log("value -> " + JSON.stringify(value));
    this._allValues = value;
  }

  handleRemoveTags(event) {
    const valueToRemove = event.target.name;
    this._allValues = this.deselectValue(this._allValues, valueToRemove);

    if (
      this.omniJsonData &&
      this.omniJsonData.basenode &&
      this.elementName === "pillForReason"
    ) {
      let makeBaseNodeBlank = {
        basenode: this._allValues
      };
      this.omniApplyCallResp(makeBaseNodeBlank);
    }

    if (
      this.omniJsonData &&
      this.omniJsonData.basenodeForReasonForCV &&
      this.elementName === "pillForTopic"
    ) {
      let makeBaseNodeBlank = {
        basenodeForReasonForCV: this._allValues
      };
      this.omniApplyCallResp(makeBaseNodeBlank);
    }
    if (
      this.omniJsonData &&
      this.omniJsonData.productbasenode &&
      this.elementName === "pillForProduct"
    ) {
      let makeBaseNodeBlank = {
        productbasenode: this._allValues
      };
      this.omniApplyCallResp(makeBaseNodeBlank);
    }
  }

  deselectValue(listval, val) {
    let lstValues = [];
    for (let eachItem of listval) {
      if (eachItem.value === val) {
        lstValues.push({
          value: eachItem.value,
          label: eachItem.label,
          selected: false
        });
      } else {
        lstValues.push({
          value: eachItem.value,
          label: eachItem.label,
          selected: eachItem.selected
        });
      }
    }
    return lstValues;
  }
}

/**
 * Created by Nagendra on 02-06-2023.
 */

import { api, LightningElement } from "lwc";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";

export default class PillOmniComponent extends OmniscriptBaseMixin(
  LightningElement
) {
  @api allValues;
  @api elementName;

  handleRemoveTags(event) {
    const valueToRemove = event.target.name;
    // eslint-disable-next-line @lwc/lwc/no-api-reassignments
    this.allValues = this.deselectValue(this.allValues, valueToRemove);
    //this.allValues = this.allValues.filter(item => item.value === valueToRemove);
    if (
      this.omniJsonData &&
      this.omniJsonData.basenode &&
      this.elementName === "CustomLWC2"
    ) {
      //let basenodeList = this.omniJsonData.basenode;
      //let newBase = this.handleRemoveMatching(basenodeList, this.allValues);

      let makeBaseNodeBlank = {
        basenode: this.allValues
      };
      this.omniApplyCallResp(makeBaseNodeBlank);
    }

    if (
      this.omniJsonData &&
      this.omniJsonData.basenodeForReasonForCV &&
      this.elementName === "CustomLWC3"
    ) {
      //let basenodeList = this.omniJsonData.basenodeForReasonForCV;
      //let newBase = this.handleRemoveMatching(basenodeList, this.allValues);

      let makeBaseNodeBlank = {
        basenodeForReasonForCV: this.allValues
      };
      this.omniApplyCallResp(makeBaseNodeBlank);
    }
    if (
      this.omniJsonData &&
      this.omniJsonData.productbasenode &&
      this.elementName === "CustomLWC7"
    ) {
      //let basenodeList = this.omniJsonData.productbasenode;
      //let newBase = this.handleRemoveMatching(basenodeList, this.allValues);

      let makeBaseNodeBlank = {
        productbasenode: this.allValues
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

  handleRemoveMatching(list1, list2) {
    if (list2.length === 0) {
      return [];
    }
    const list2Values = list2.map((item) => item.value);

    list1 = list1.filter((item) => !list2Values.includes(item.value));

    return list1;
  }
}

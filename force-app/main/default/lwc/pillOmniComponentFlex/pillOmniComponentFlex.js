/**
 * Created by Nagendra on 05-06-2023.
 */

import { LightningElement, track, api } from "lwc";
import { FlexCardMixin } from "omnistudio/flexCardMixin";

export default class PillOmniComponentFlex extends FlexCardMixin(
  LightningElement
) {
  @track _allValuesReason;
  @track _allValuesTopic;
  @track _allValuesProduct;
  @track _allValues;
  recordTypeName;
  isCallRecordType;
  isStoreRecordType;

  @api
  get allValues() {
    return this._allValues;
  }
  set allValues(value) {
    this._allValues = value.JunctionObject;
    this.recordTypeName = value.RecordTypeName;
    this.isCallRecordType = this.recordTypeName === "Call";
    this.isStoreRecordType = this.recordTypeName === "In Person";
    let allJunctionData = this._allValues;

    // Detect if all Junction data is array if not, convert it into array
    if (allJunctionData && !Array.isArray(allJunctionData)) {
      allJunctionData = [allJunctionData];
    }

    // Segregate Reason for Vist, Product and Actual Topics and append it to it's respective array.
    if (allJunctionData && allJunctionData.length > 0) {
      let newArray = [];
      for (let index = 0; index < allJunctionData.length; index++) {
        const eachJunctinData = allJunctionData[index];
        newArray.push({
          label: eachJunctinData.TagName,
          value: eachJunctinData.Id,
          type: eachJunctinData.Type
        });
      }
      this._allValues = newArray;
      let map = new Map();
      newArray.forEach((i) => {
        if (!map.has(i.type)) {
          map.set(i.type, [i]);
        } else {
          map.get(i.type).push(i);
        }
      });
      this._allValuesReason = map.get("Reason");
      this._allValuesTopic = map.get("Topic");
      this._allValuesProduct = map.get("Product");
    }
  }
}
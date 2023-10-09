import OmniscriptSelect from "omnistudio/omniscriptSelect";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import { getElementValue } from "omnistudio/omniscriptInternalUtils";
import { wire } from "lwc";

export default class OmniSelectElementOverride extends OmniscriptSelect {
  mapControllingWithDependentList = {};
  dependentSourceSelect;
  recordTypeIdFromWiredMethod;
  isOverridenWithCustomLwc;

  // wired method to extract recordTypeId from lightning uiObjectInfoApi
  @wire(getObjectInfo, { objectApiName: "Interaction" })
  objectInfo({ data }) {
    if (data) {
      const recordTypeIds = data.recordTypeInfos;
      this.recordTypeIdFromWiredMethod = Object.keys(recordTypeIds).find(
        (fetchedRecordTypeId) =>
          recordTypeIds[fetchedRecordTypeId].name ===
          this.jsonData.RecordTypeName
      );
    }
  }
  // wired method to extract getPicklistValues from lightning uiObjectInfoApi
  /**
   * Purpose of this method is to set dependent picklist values based on the controlling picklist
   * mapControllingValueWithIndex holds the map values of controlling picklists
   * mapControllingWithDependentList holds the map values of dependent picklists
   */
  @wire(getPicklistValues, {
    recordTypeId: "$recordTypeIdFromWiredMethod",
    fieldApiName: "$dependentSourceSelect"
  })
  wiredValues({ data }) {
    if (data) {
      let root = data;
      let mapControllingValueWithIndex = {};
      let result = {};
      let pValues = root.values;

      if (root.controllerValues) {
        let controllingValues = root.controllerValues;
        for (let cValue in controllingValues) {
          if (Object.prototype.hasOwnProperty.call(controllingValues, cValue)) {
            mapControllingValueWithIndex[controllingValues[cValue]] = cValue;
          }
        }
      }
      if (!root.values) {
        return;
      }
      for (let pValue of pValues) {
        result[pValue.value] = pValue.label;
        for (let validfor of pValue.validFor) {
          if (mapControllingValueWithIndex[validfor]) {
            if (
              !this.mapControllingWithDependentList[
                mapControllingValueWithIndex[validfor]
              ]
            ) {
              this.mapControllingWithDependentList[
                mapControllingValueWithIndex[validfor]
              ] = [
                {
                  value: "",
                  label: "-- Clear --"
                }
              ];
            }
            this.mapControllingWithDependentList[
              mapControllingValueWithIndex[validfor]
            ].push({
              value: pValue.value,
              label: pValue.label
            });
          }
        }
      }
      this.generateRealTimeOptions();
    }
  }
  // conditional element overriding in hook
  connectedCallback() {
    super.connectedCallback();
    this.isOverridenWithCustomLwc = this._propSetMap.overridewithcustomlwc;
    if (this.isOverridenWithCustomLwc) {
      this.dependentSourceSelect = this._propSetMap.optionSource.source;
    }
  }
  // conditional element overriding in hook
  combinedWatch() {
    super.combinedWatch();
    if (this.isOverridenWithCustomLwc) {
      this.generateRealTimeOptions();
    }
  }
  // to build the dropdown menu data [_realtimeOptions is an array which holds the picklist values]
  generateRealTimeOptions() {
    let controllingElement = this._propSetMap.controllingField.element;
    let controllingFieldValue = getElementValue(
      controllingElement,
      this.jsonData,
      this.scriptHeaderDef.labelMap,
      this.jsonDef.JSONPath || null
    );
    if (controllingFieldValue !== null) {
      this._realtimeOptions = this.mapControllingWithDependentList[
        controllingFieldValue
      ];
    }
  }
}

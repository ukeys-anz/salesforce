import OmniscriptSelect from "omnistudio/omniscriptSelect";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getElementValue } from "omnistudio/omniscriptInternalUtils";
import { wire } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";

export default class OmniSelectElementOverride extends OmniscriptSelect {
  mapControllingWithDependentList = {};
  dependentSourceSelect;
  recordTypeIdFromOS;
  recordTypeName;
  recordTypeIdFromWiredMethod;

  @wire(getObjectInfo, { objectApiName: "Interaction" })
  objectInfo({ data }) {
    if (data) {
      const recordTypeIds = data.recordTypeInfos;
      this.recordTypeName = this.jsonData.RecordTypeName;
      this.recordTypeIdFromWiredMethod = Object.keys(recordTypeIds).find(
        (rti) => recordTypeIds[rti].name === this.recordTypeName
      );
      this.recordTypeIdFromOS = this.recordTypeIdFromWiredMethod;
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "$recordTypeIdFromOS",
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
          mapControllingValueWithIndex[controllingValues[cValue]] = cValue;
        }
      }
      if (!root.values) {
        console.log(this.mapControllingWithDependentList);
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
      this.getrealTimeOptions();
    }
  }

  connectedCallback() {
    super.connectedCallback();
    if (this._propSetMap.overridewithcustomlwc) {
      this.dependentSourceSelect = this._propSetMap.optionSource.source;
    }
  }

  combinedWatch() {
    super.combinedWatch();
    if (this._propSetMap.overridewithcustomlwc) {
      this.getrealTimeOptions();
    }
  }

  getrealTimeOptions() {
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

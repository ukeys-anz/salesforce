import { LightningElement, api } from "lwc";
import {
  convertProtoBuffTimestampToISOString,
  parseJsonString
} from "c/genericUtils";

export default class GenericFieldContainer extends LightningElement {
  //We need this as local property to make it reactive
  _value; //Should contain the data set
  _objectConfig; //should contain the mapping to retrieve the data
  _parsedData; // combined filed and data
  activeSections = [];
  _hasError = false;
  _errorMessage = "";
  filterValue;

  @api hasSectionHeader;
  @api recordId;

  get _paddingSize() {
    return this._objectConfig?.layoutconfig?.paddingSizeOverride;
  }

  @api
  get value() {
    return this._value;
  }
  set value(value) {
    this._value = value;
    if (!this._parsedData) {
      this.initialise();
    }
  }

  @api
  get objectConfig() {
    return this._objectConfig;
  }
  set objectConfig(value) {
    try {
      this._objectConfig = value;
      if (this._objectConfig && this._objectConfig.title) {
        if (!this.activeSections.includes(this._objectConfig.title)) {
          this.activeSections = [
            ...this.activeSections,
            this._objectConfig.title
          ];
        }
      }
      if (!this._parsedData) {
        this.initialise();
      }
    } catch (error) {
      this._hasError = true;
      this._errorMessage = `GenericFieldContainer - Failed to process object configuration: ${error.message}`;
      this.dispatchErrorEvent(this._errorMessage);
    }
  }

  connectedCallback() {
    //fallback on component completion
    if (!this._parsedData) {
      this.initialise();
    }
  }
  //This needs to be called on each setter of the properties
  initialise() {
    try {
      if (this._value && this._objectConfig) {
        this._hasError = false;
        this._errorMessage = "";
        this._parsedData = [];
        // Find the field in the schema that has attributes.filterField
        const filterFieldWithAttr = this._objectConfig.schema.find(
          (f) => f.attributes && f.attributes.filterField
        );
        const filterFieldColumnFromAttr = filterFieldWithAttr
          ? filterFieldWithAttr.attributes.filterField
          : null;

        // Handle both array and object inputs
        if (Array.isArray(this._value)) {
          this._value.forEach((row, ind) => {
            this._objectConfig.schema.forEach((field) => {
              let fldCol = this.getFieldColumn(field.fieldColumn);
              let keyS = fldCol + "_" + ind;
              let dtVal = this.getDataFromColumn(row, field);

              // Use the new method to resolve dynamic params
              let fieldCopy = this.resolveDynamicParams(field, row);

              // Get the filter value for this row, or empty string if not present
              let filterValue = filterFieldColumnFromAttr
                ? this.getFilterValueByPath(row, filterFieldColumnFromAttr)
                : "";

              this._parsedData.push({
                value: dtVal,
                key: keyS,
                data: parseJsonString(
                  JSON.stringify(row),
                  "fieldContainer array data from genericFieldContainer"
                ),
                ...fieldCopy,
                filterValue: filterValue
              });
            });
          });
        } else {
          // Handle single object case
          this._objectConfig.schema.forEach((field, ind) => {
            let fldCol = this.getFieldColumn(field.fieldColumn);
            let keyS = fldCol + "_" + ind;
            let dtVal = this.getDataFromColumn(this._value, field);

            // Use the new method to resolve dynamic params
            let fieldCopy = this.resolveDynamicParams(field, this._value);

            let filterValue = filterFieldColumnFromAttr
              ? this.getFilterValueByPath(
                  this._value,
                  filterFieldColumnFromAttr
                )
              : "";

            this._parsedData.push({
              value: dtVal,
              key: keyS,
              data: parseJsonString(
                JSON.stringify(this._value),
                "fieldContainer object data from genericFieldContainer"
              ),
              ...fieldCopy,
              filterValue: filterValue
            });
          });
        }
      }
    } catch (error) {
      this._hasError = true;
      this._errorMessage = `GenericFieldContainer - Failed to initialize field data processing for ${Array.isArray(this._value) ? "array" : "object"} with ${this._objectConfig?.schema?.length || 0} fields: ${error.message}`;
      this._parsedData = null;
      this.dispatchErrorEvent(this._errorMessage);
    }
  }
  getFieldColumn(colParam) {
    let cp = colParam;
    if (colParam && colParam.includes(".")) {
      cp = colParam.replaceAll(".", "_");
    }
    return cp;
  }
  getDataFromColumn(data, column) {
    try {
      const fieldValue = column.fieldColumn
        .split(".")
        .reduce((acc, part) => acc && acc[part], data);
      if (column.isDate) {
        return this.formatDateValue(fieldValue);
      }
      if (typeof fieldValue === "boolean") {
        return fieldValue.toString();
      }

      return fieldValue;
    } catch (error) {
      // Return null for invalid field paths instead of breaking
      return null;
    }
  }

  formatDateValue(value) {
    if (!value) return null;

    if (typeof value === "object") {
      const seconds = "seconds" in value ? value.seconds : 0;
      const nanoseconds = "nanos" in value ? value.nanos : 0;
      return convertProtoBuffTimestampToISOString(seconds, nanoseconds);
    }
    if (typeof value === "string") {
      return value;
    }
  }

  resolveDynamicParams(field, row) {
    // Deep clone to avoid mutating the original field config
    let fieldCopy = JSON.parse(JSON.stringify(field));
    // Check if this field is a record link and has attributes with params
    if (fieldCopy.isRecordLink && fieldCopy.attributes?.params?.args) {
      Object.keys(fieldCopy.attributes.params.args).forEach((paramKey) => {
        const paramVal = fieldCopy.attributes.params.args[paramKey];
        // If the param value is a string placeholder (e.g., "{party_id} or {completedBy.id}"),
        if (
          typeof paramVal === "string" &&
          paramVal.startsWith("{") &&
          paramVal.endsWith("}")
        ) {
          const fieldPath = paramVal.slice(1, -1); // e.g., "completedBy.id"
          // Use reduce to support dot notation
          const value = fieldPath
            ? fieldPath
                .split(".")
                .reduce((acc, part) => (acc ? acc[part] : undefined), row)
            : undefined;
          fieldCopy.attributes.params.args[paramKey] = value;
        }
      });
    }
    return fieldCopy;
  }

  handleSectionToggle(event) {
    const openSections = event.detail.openSections;
  }

  /**
   * Dispatch error event to parent component
   * @param {string} errorMessage - Error message to propagate
   */
  dispatchErrorEvent(errorMessage) {
    this.dispatchEvent(
      new CustomEvent("childerror", {
        detail: {
          errorMessage,
          componentType: "genericFieldContainer"
        },
        bubbles: true,
        composed: true
      })
    );
  }

  //Used to retrieve the filter value specific in attributes for filtering
  getFilterValueByPath(obj, path) {
    if (!obj || !path) return "";
    return (
      path.split(".").reduce((acc, part) => (acc ? acc[part] : ""), obj) ?? ""
    );
  }
}

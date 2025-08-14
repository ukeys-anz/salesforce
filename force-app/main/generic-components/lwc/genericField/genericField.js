import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class GenericField extends NavigationMixin(LightningElement) {
  @api field;
  @api value;
  @api recordId; //Used for record links
  @api filterValue;

  _paddingSize;
  _hasError = false;
  _errorMessage = "";

  @api
  get paddingSize() {
    return this._paddingSize;
  }
  set paddingSize(value) {
    try {
      if (
        this.field &&
        Object.hasOwn(this.field, "isStacked") &&
        this.field.isStacked
      ) {
        this._paddingSize = {
          fieldLabel: "12",
          fieldValue: "12"
        };
      } else {
        this._paddingSize = {
          fieldLabel: value?.fieldLabel || "2",
          fieldValue: value?.fieldValue || "10"
        };
      }
    } catch (error) {
      this._hasError = true;
      console.error(
        `GenericField - Failed to calculate padding size for field '${this.field?.fieldLabel || "unknown"}': ${error.message}`
      );
      this.dispatchErrorEvent(
        `GenericField - Grid sizing error: ${error.message}`
      );
    }
  }

  get _fieldLabel() {
    if (this.field && Object.hasOwn(this.field, "fieldLabel")) {
      return this.field.fieldLabel;
    }
    return "";
  }
  get _fieldColumn() {
    if (this.field && Object.hasOwn(this.field, "fieldColumn")) {
      return this.field.fieldColumn;
    }
    return "";
  }
  get _helpText() {
    if (this.field && Object.hasOwn(this.field, "helpText")) {
      return this.field.helpText;
    }
    return "";
  }
  get _dataValue() {
    if (this.field?.fieldtype === "checkbox") {
      return this.value === "true" || this.value === true;
    }
    if (this.value) {
      return this.field.stringify ? JSON.stringify(this.value) : this.value;
    }
    return "";
  }
  get _fieldCompCss() {
    if (this.field && Object.hasOwn(this.field, "isStacked")) {
      if (this.field.isStacked) {
        return "fieldContentStacked";
      }
    }
    return "fieldContent";
  }
  //Local helpers to control rendered component and attributes
  get isNumber() {
    if (this.field && Object.hasOwn(this.field, "fieldtype")) {
      return this.field.fieldtype == "lightning-formatted-number";
    }
    return false;
  }
  get isEmail() {
    if (this.field && Object.hasOwn(this.field, "fieldtype")) {
      return this.field.fieldtype == "lightning-formatted-email";
    }
    return false;
  }
  get isUrl() {
    if (this.field && Object.hasOwn(this.field, "fieldtype")) {
      return this.field.fieldtype == "lightning-formatted-url";
    }
    return false;
  }
  get isDate() {
    if (this.field && Object.hasOwn(this.field, "isDate")) {
      return true;
    }
    return false;
  }
  get isText() {
    if (this.field && Object.hasOwn(this.field, "fieldtype")) {
      return this.field.fieldtype == "lightning-formatted-text";
    }
    return false;
  }
  get isCheckBox() {
    if (this.field && Object.hasOwn(this.field, "fieldtype")) {
      return this.field.fieldtype == "checkbox";
    }
    return false;
  }
  get isRecordUrl() {
    if (this.field && Object.hasOwn(this.field, "fieldtype")) {
      return this.field.isRecordUrl == true;
    }
    return false;
  }

  get isRecordLink() {
    if (this.field && Object.hasOwn(this.field, "isRecordLink")) {
      return true;
    }
    return false;
  }

  get _attributes() {
    if (this.field && Object.hasOwn(this.field, "attributes")) {
      return this.field.attributes;
    }
    //Return an empty object to spread
    return {};
  }

  handleNavToDetail(event) {
    try {
      const compDefinition = {
        c__apexController: this._attributes.apexController,
        c__configName: this._attributes.configName,
        c__defaultOpen: this._attributes.defaultOpen || true,
        c__filterValue: this.field?.filterValue
          ? this.field.filterValue
          : this.value,
        c__dataPath: this._attributes.dataPath,
        c__useControllerData: this._attributes.useControllerData || "true",
        c__controllerParams: { recordId: this.recordId },
        c__filterField: this._attributes.filterField || "id",
        c__tabName: this.value
      };

      this[NavigationMixin.Navigate]({
        type: "standard__component",
        attributes: {
          componentName: this._attributes.componentName || "c__genericCard"
        },
        state: compDefinition
      });
    } catch (error) {
      this._hasError = true;
      console.error(
        `GenericField - Navigation failed for field '${this.field?.fieldLabel || "unknown"}' to component '${this._attributes?.componentName || "unknown"}': ${error.message}`
      );
      this.dispatchErrorEvent(
        `GenericField - Navigation failed: ${error.message}`
      );
    }
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
          componentType: "genericField"
        },
        bubbles: true,
        composed: true
      })
    );
  }
}

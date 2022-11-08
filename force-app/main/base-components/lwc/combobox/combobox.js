/*
 * Copyright (c) 2019, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: MIT
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/MIT
 */

import labelRequired from "@salesforce/label/c.lightning_LightningControl_required";
import labelPlaceholder from "@salesforce/label/c.lightning_LightningCombobox_placeholder";
import { LightningElement, api, track } from "lwc";
import { classSet } from "c/utils";
import {
  normalizeBoolean,
  normalizeArray,
  synchronizeAttrs,
  classListMutation
} from "c/utilsPrivate";
import {
  isEmptyString,
  InteractingState,
  FieldConstraintApi,
  normalizeVariant,
  VARIANT
} from "c/inputUtils";

const i18n = {
  required: labelRequired,
  placeholder: labelPlaceholder
};

export default class cCombobox extends LightningElement {
  static delegatesFocus = true;

  @track _ariaLabelledBy = "";
  @track _ariaDescribedBy = "";
  @track _fieldLevelHelp = "";
  @track _selectedLabel = "";
  @track _disabled = false;
  @track _readOnly = false;
  @track _spinnerActive = false;
  @track _required = false;
  @track _multiSelect = false;
  @track _showItemCountInLabel = false;
  @track _showSelections = false;

  @api label;

  @api dropdownAlignment = "left";

  @api placeholder = i18n.placeholder;

  @api messageWhenValueMissing;

  @api name;

  @track _items = [];
  @track _selectedItems = [];
  @track _variant;
  @track _helpMessage;

  _labelForId;

  renderedCallback() {
    this.synchronizeA11y();
  }

  connectedCallback() {
    this.classList.add("slds-form-element");
    this.updateClassList();
    this.interactingState = new InteractingState();
    this.interactingState.onleave(() => this.showHelpMessageIfInvalid());

    this.connected = true;

    this._items = this.generateItems(this.options);

    if (this.options && this.selectedValue !== undefined) {
      this.updateSelectedOptions();
    }
  }

  updateClassList() {
    classListMutation(this.classList, {
      "slds-form-element_stacked": this.variant === VARIANT.LABEL_STACKED,
      "slds-form-element_horizontal": this.variant === VARIANT.LABEL_INLINE
    });
  }

  disconnectedCallback() {
    this.connected = false;
  }

  @api deselectAll() {
    if (this._multiSelect) {
      this._items.forEach((item) => {
        item.iconName = undefined;
        item.highlight = false;
        item.checked = false;
      });
      this._selectedItems = [];
      this.selectedValue = "";

      this.dispatchEvent(
        new CustomEvent("change", {
          composed: true,
          bubbles: true,
          detail: {
            value: this.selectedValue,
            values: this._selectedItems
          }
        })
      );
    }
  }
  @api get ariaLabelledBy() {
    return this._ariaLabelledBy;
  }

  set ariaLabelledBy(labelledBy) {
    this._ariaLabelledBy = labelledBy;
  }

  @api get ariaDescribedBy() {
    return this._ariaDescribedBy;
  }

  set ariaDescribedBy(describedBy) {
    this._ariaDescribedBy = describedBy;
  }

  @api get fieldLevelHelp() {
    return this._fieldLevelHelp;
  }

  set fieldLevelHelp(value) {
    this._fieldLevelHelp = value;
  }

  @api get multiSelect() {
    return this._multiSelect;
  }

  set multiSelect(value) {
    this._multiSelect = normalizeBoolean(value);
  }

  @api get showItemCountInLabel() {
    return this._showItemCountInLabel;
  }

  set showItemCountInLabel(value) {
    this._showItemCountInLabel = normalizeBoolean(value);
  }

  @api get showSelections() {
    return this._showSelections;
  }

  set showSelections(value) {
    this._showSelections = normalizeBoolean(value);
  }

  @api get variant() {
    return this._variant || (this._multiSelect ? "lookup" : VARIANT.STANDARD);
  }

  set variant(value) {
    this._variant = normalizeVariant(value);
    this.updateClassList();
  }

  @api get value() {
    return this.selectedValue;
  }

  set value(newValue) {
    if (newValue !== this.selectedValue) {
      this.selectedValue = newValue;
      if (this.connected && this.options) {
        this.updateSelectedOptions();
      }
    }
  }

  @api get options() {
    return this._options || [];
  }

  set options(newValue) {
    this._options = normalizeArray(newValue);

    if (
      this.connected &&
      (!this._multiSelect || this._selectedItem === undefined)
    ) {
      // only disable this code if MultiSelect is true
      this._items = this.generateItems(this._options);
      this.updateSelectedOptions();
    }
  }

  @api get disabled() {
    return this._disabled || this._readOnly || false;
  }

  set disabled(value) {
    this._disabled = normalizeBoolean(value);
  }

  @api get readOnly() {
    return this.disabled;
  }

  set readOnly(value) {
    this._readOnly = normalizeBoolean(value);
  }

  @api get required() {
    return this._required;
  }

  set required(value) {
    this._required = normalizeBoolean(value);
  }

  @api get spinnerActive() {
    return this._spinnerActive;
  }

  set spinnerActive(value) {
    this._spinnerActive = normalizeBoolean(value);
  }

  @api
  focus() {
    if (this.connected) {
      this.getBaseComboboxElement().focus();
    }
  }

  @api
  blur() {
    if (this.connected) {
      this.getBaseComboboxElement().blur();
    }
  }

  @api get validity() {
    return this._constraint.validity;
  }

  @api
  checkValidity() {
    return this._constraint.checkValidity();
  }

  @api
  reportValidity() {
    return this._constraint.reportValidity((message) => {
      this._helpMessage = message;
    });
  }

  @api selectAll(config) {
    if (this._multiSelect) {
      this._items.forEach((item) => {
        if (
          config === undefined ||
          !Array.isArray(config.exclude) ||
          !config.exclude.includes(item.value)
        ) {
          item.iconName = "utility:check";
          item.highlight = true;
          item.checked = true;
        }
      });
      this._selectedItems = this._items.filter((item) => item.checked);
      this.updateSelectedLabelFromValue(null);

      this.dispatchEvent(
        new CustomEvent("change", {
          composed: true,
          bubbles: true,
          detail: {
            value: this.selectedValue,
            values: this._selectedItems
          }
        })
      );
    }
  }

  @api
  setCustomValidity(message) {
    this._constraint.setCustomValidity(message);
  }

  @api
  showHelpMessageIfInvalid() {
    this.reportValidity();
  }

  handleComboboxReady(e) {
    this._labelForId = e.detail.id;
  }

  synchronizeA11y() {
    synchronizeAttrs(this.template.querySelector("label"), {
      for: this._labelForId
    });

    const baseCombobox = this.template.querySelector("c-base-combobox");

    baseCombobox.inputLabelledByElement = this.ariaLabelledBy;
    baseCombobox.inputDescribedByElements = this.computedAriaDescribedBy;
  }

  get i18n() {
    return i18n;
  }

  get isLabelHidden() {
    return this.variant === VARIANT.LABEL_HIDDEN;
  }

  get computedLabelClass() {
    return classSet("slds-form-element__label")
      .add({ "slds-assistive-text": this.isLabelHidden })
      .toString();
  }

  get computedAriaDescribedBy() {
    const describedByElements = [];

    if (this._helpMessage) {
      const helpText = this.template.querySelector("[data-help-text]");
      describedByElements.push(helpText);
    }

    if (typeof this.ariaDescribedBy === "string") {
      describedByElements.push(this.ariaDescribedBy);
    }

    return describedByElements;
  }

  handleSelect(event) {
    if (!this._multiSelect && event.detail.value === this.selectedValue) {
      return;
    }
    this.selectedValue = event.detail.value;
    this.updateSelectedOptions();

    this.dispatchEvent(
      new CustomEvent("change", {
        composed: true,
        bubbles: true,
        detail: {
          value: this.selectedValue,
          values: this._selectedItems
        }
      })
    );
  }

  handleFocus() {
    this.interactingState.enter();

    this.dispatchEvent(new CustomEvent("focus"));
  }

  handleBlur() {
    this.interactingState.leave();

    this.dispatchEvent(new CustomEvent("blur"));
  }

  handleDropdownOpen() {
    this.dispatchEvent(new CustomEvent("open"));
  }

  updateSelectedOptions() {
    this.markOptionSelectedFromValue(this.selectedValue);
    this.updateSelectedLabelFromValue(this.selectedValue);
  }

  markOptionSelectedFromValue(value) {
    if (this._items) {
      const selectedItem = this._items.find((item) => item.value === value);

      // deselect current item if not using multi-select
      if (this._selectedItem && !this.multiSelect) {
        this._selectedItem.checked = false;
        this._selectedItem.iconName = undefined;
        this._selectedItem.highlight = false;
      }
      this._selectedItem = selectedItem;
      if (selectedItem) {
        if (this.multiSelect && selectedItem.checked) {
          selectedItem.checked = false;
          selectedItem.iconName = undefined;
          selectedItem.highlight = false;
        } else {
          selectedItem.iconName = "utility:check";
          this._selectedItem.highlight = true;
          this._selectedItem.checked = true;
        }
      }
      if (this._multiSelect) {
        this._selectedItems = this._items.filter((item) => item.checked);
      }

      this._items = this._items.slice();
    }
  }

  removePill(event) {
    if (!this.disabled) {
      event.detail.value = event.detail.name;
      this.handleSelect(event);
    }
  }

  updateSelectedLabelFromValue(newValue) {
    if (this._multiSelect) {
      if (this._showItemCountInLabel) {
        const itemCount = this._items.reduce(
          (prevCount, currentItem) => prevCount + (currentItem.checked ? 1 : 0),
          0
        );
        this._selectedLabel = itemCount + " items selected.";
      }
    } else {
      this._selectedLabel = this.getOptionLabelByValue(newValue);
    }
  }

  getOptionLabelByValue(value) {
    const foundOption = this.options.find((option) => option.value === value);
    if (foundOption) {
      return foundOption.label;
    }
    return "";
  }

  generateItems(options) {
    return options.map((option) => {
      const type = option.description ? "option-card" : "option-inline";
      return {
        type,
        text: option.label,
        subText: option.description,
        highlight: this.value === option.value,
        iconSize: "x-small",
        value: option.value
      };
    });
  }

  getBaseComboboxElement() {
    return this.template.querySelector("c-base-combobox");
  }

  get _constraint() {
    if (!this._constraintApi) {
      this._constraintApi = new FieldConstraintApi(() => this, {
        valueMissing: () =>
          !this.disabled && this.required && isEmptyString(this.selectedValue)
      });
    }
    return this._constraintApi;
  }
}

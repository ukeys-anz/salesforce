import { LightningElement, track, api } from "lwc";

export default class MultiSelectCombobox extends LightningElement {
  @api options;
  @api selectedValue;
  @api selectedValues = [];
  @api label;
  @api minChar = 2;
  @api disabled = false;
  @track value;
  @track values = [];
  @track optionData;
  @track searchString;
  @track message;
  @track showDropdown = false;

  connectedCallback() {
    this.showDropdown = false;
    let optionData = this.options
      ? JSON.parse(JSON.stringify(this.options))
      : null;
    let value = this.selectedValue
      ? JSON.parse(JSON.stringify(this.selectedValue))
      : null;
    let values = this.selectedValues
      ? JSON.parse(JSON.stringify(this.selectedValues))
      : null;
    if (value || values) {
      let count = 0;
      for (let i = 0; i < optionData.length; i++) {
        if (values.includes(optionData[i].value)) {
          optionData[i].selected = true;
          count++;
        }
      }
      this.searchString = count + " Option(s) Selected";
    }
    this.value = value;
    this.values = values;
    this.optionData = optionData;
  }

  filterOptions(event) {
    this.searchString = event.target.value;
    if (this.searchString && this.searchString.length > 0) {
      this.message = "";
      if (this.searchString.length >= this.minChar) {
        let flag = true;
        for (let i = 0; i < this.optionData.length; i++) {
          if (
            this.optionData[i].label
              .toLowerCase()
              .trim()
              .startsWith(this.searchString.toLowerCase().trim())
          ) {
            this.optionData[i].isVisible = true;
            flag = false;
          } else {
            this.optionData[i].isVisible = false;
          }
        }
        if (flag) {
          this.message = "No results found for '" + this.searchString + "'";
        }
      }
      this.showDropdown = true;
    } else {
      this.showDropdown = false;
    }
  }

  selectItem(event) {
    var selectedVal = event.currentTarget.dataset.id;
    if (selectedVal) {
      let count = 0;
      let options = JSON.parse(JSON.stringify(this.optionData));
      for (let i = 0; i < options.length; i++) {
        if (options[i].value === selectedVal) {
          if (this.values.includes(options[i].value)) {
            this.values.splice(this.values.indexOf(options[i].value), 1);
          } else {
            this.values.push(options[i].value);
          }
          options[i].selected = options[i].selected ? false : true;
        }
        if (options[i].selected) {
          count++;
        }
      }
      this.optionData = options;
      this.searchString = count + " Option(s) Selected";
      event.preventDefault();
    }
  }

  showOptions() {
    if (this.disabled === false && this.options) {
      this.message = "";
      this.searchString = "";
      let options = JSON.parse(JSON.stringify(this.optionData));
      for (let i = 0; i < options.length; i++) {
        options[i].isVisible = true;
      }
      if (options.length > 0) {
        this.showDropdown = true;
      }
      this.optionData = options;
    }
  }

  removePill(event) {
    var value = event.currentTarget.name;
    var count = 0;
    var options = JSON.parse(JSON.stringify(this.optionData));
    for (let i = 0; i < options.length; i++) {
      if (options[i].value === value) {
        options[i].selected = false;
        this.values.splice(this.values.indexOf(options[i].value), 1);
      }
      if (options[i].selected) {
        count++;
      }
    }
    this.optionData = options;
    this.searchString = count + " Option(s) Selected";
  }

  blurEvent() {
    var count = 0;
    for (let i = 0; i < this.optionData.length; i++) {
      if (this.optionData[i].value === this.value) {
        previousLabel = this.optionData[i].label;
      }
      if (this.optionData[i].selected) {
        count++;
      }
    }
    this.searchString = count + " Option(s) Selected";

    this.showDropdown = false;

    this.dispatchEvent(
      new CustomEvent("select", {
        detail: {
          payloadType: "multi-select",
          payload: {
            value: this.value,
            values: this.values
          }
        }
      })
    );
  }
}

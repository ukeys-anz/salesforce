import { LightningElement, api } from "lwc";
import getConfig from "@salesforce/apex/GenericController.getConfig";
import getData from "@salesforce/apex/GenericController.getData";
import {
  extractValuesByPaths,
  applyEnumMappings,
  parseJsonString,
  formatObject
} from "c/genericUtils";
import { loadStyle } from "lightning/platformResourceLoader";
import styling from "@salesforce/resourceUrl/genericRelatedListStyling";

export default class GenericRelatedList extends LightningElement {
  @api ApexController; // Instantiate Apex class that extends GenericClass
  @api SchemaConfig; //Schema Name to retrieve via Apex
  @api RelatedListTitle; // Title to display for related list
  @api TargetKey; // Data set to extract
  @api titleIcon; // Icon to display with title for related list

  @api recordId; // Record Id

  //We need this as local property to make it reactive
  _schemaConfig; //should contain the mapping to retrieve the data
  _parsedData;
  _isLoading;
  _hasError = false;
  _errorMessage;

  connectedCallback() {
    this.initialise();
    Promise.all([loadStyle(this, styling)]);

    // Listen for child component errors
    this.addEventListener("childerror", this.handleChildError.bind(this));
  }

  async initialise() {
    this._isLoading = true;
    this._hasError = false;

    try {
      if (!(await this.initialiseObject())) return;
      if (!(await this.initialiseListData())) return;
    } finally {
      this._isLoading = false;
    }
  }

  async initialiseObject() {
    this._schemaConfig = {};
    if (!this.SchemaConfig) {
      return true; // Success - no schema needed
    }

    try {
      const tmpschemaConfig = await getConfig({
        configName: this.SchemaConfig
      });

      const errorHandler = {
        setError: (hasError, error) => {
          this._hasError = hasError;
          console.error(
            `GenericRelatedList - Failed to format schema configuration "${this.SchemaConfig}":`,
            error.message
          );
        }
      };

      this._schemaConfig = formatObject(
        tmpschemaConfig,
        `schemaConfig from ${this.ApexController ? `controller: ${this.ApexController}` : "direct assignment"}`,
        errorHandler
      );

      // Check if formatObject returned null (indicating an error occurred)
      if (this._hasError || this._schemaConfig === null) {
        return false; // formatObject set the error via errorHandler or returned null
      }

      return true; // Success
    } catch (error) {
      this._hasError = true;
      console.error(
        `GenericRelatedList - Failed to load schema configuration "${this.SchemaConfig}":`,
        error
      );
      return false; // Failure
    }
  }

  async initialiseListData() {
    if (!this.ApexController) {
      return true; // Success - no controller needed
    }

    try {
      let responseData = await getData({
        apexController: this.ApexController,
        param: JSON.stringify({ recordId: this.recordId })
      });

      // Check for malformed JSON first
      const parsedData = parseJsonString(
        responseData,
        "relatedListData from " +
          (this.ApexController
            ? `controller: ${this.ApexController}`
            : "direct assignment")
      );

      let targetData = parsedData;

      //extract specific data set
      if (this.TargetKey) {
        targetData = extractValuesByPaths(parsedData, this.TargetKey);
      }

      let enumValueArray = Array.isArray(targetData)
        ? targetData
        : this.formatData(targetData);

      if (this._hasError) {
        return false; // formatData set the error
      }

      const schema = this._schemaConfig?.sections?.[0]?.schema || [];
      this._parsedData = applyEnumMappings(enumValueArray, schema);
      return true; // Success
    } catch (error) {
      this._hasError = true;
      console.error(
        `GenericRelatedList - Failed to retrieve and process list data from controller "${this.ApexController}" for recordId "${this.recordId}" with targetKey "${this.TargetKey}":`,
        error
      );
      return false; // Failure
    }
  }

  formatData(data) {
    try {
      //Get keys from array
      let keys = Object.keys(data);
      let dArray = [];
      //Loop through array keys
      keys.forEach((key) => {
        data[key].forEach((el) => {
          if (typeof el === "object" && Array.isArray(el) == true) {
            dArray.push(...el);
          }
          if (typeof el === "object" && Array.isArray(el) == false) {
            //convert data structure object to array
            dArray.push({ ...el });
          }
        });
      });
      return dArray;
    } catch (error) {
      this._hasError = true;
      console.error(
        `GenericRelatedList - Failed to format/transform data structure from controller "${this.ApexController}":`,
        error
      );
      return [];
    }
  }

  handleChildError(event) {
    const { errorMessage, componentType } = event.detail;
    this._hasError = true;
    console.error(
      `GenericRelatedList - Child component error from ${componentType}: ${errorMessage}`
    );
    this._isLoading = false;

    // Stop event propagation to prevent bubbling to other parents
    event.stopPropagation();
  }
}

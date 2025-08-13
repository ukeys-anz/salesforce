import { LightningElement, api } from "lwc";
import getConfig from "@salesforce/apex/GenericController.getConfig";
import getData from "@salesforce/apex/GenericController.getData";
import {
  applyEnumMappings,
  parseJsonString,
  formatObject
} from "c/genericUtils";
import { loadStyle } from "lightning/platformResourceLoader";
import styling from "@salesforce/resourceUrl/genericRecordDetailStyling";
export default class GenericRecordDetail extends LightningElement {
  @api ApexController; // Instantiate Apex class that extends GenericClass
  @api SchemaConfig; // JSON Schema mapping configuration retrieved via apex

  @api recordId; // Record Id

  _isLoading = true; // loading spinner
  _schemaConfig; // container for schema configuration
  _parsedData; // container for data
  _hasError = false;
  _errorMessage;

  connectedCallback() {
    if (this.ApexController && this.SchemaConfig) {
      this.initialise();
    }
    Promise.all([loadStyle(this, styling)]);

    // Listen for child component errors
    this.addEventListener("childerror", this.handleChildError.bind(this));
  }
  //helps chain the async calls
  async initialise() {
    this._isLoading = true;
    this._hasError = false;

    try {
      if (!(await this.initialiseObject())) return;
      if (!(await this.initialiseRecordData())) return;
    } finally {
      this._isLoading = false;
    }
  }
  async initialiseObject() {
    this._schemaConfig = {};
    if (!this.SchemaConfig) {
      return true;
    }

    try {
      const tmpObjectConfig = await getConfig({
        configName: this.SchemaConfig
      });

      const errorHandler = {
        setError: (hasError, error) => {
          this._hasError = hasError;
          console.error(
            `GenericRecordDetail - Failed to format configuration "${this.SchemaConfig}":`,
            error.message
          );
        }
      };

      this._schemaConfig = formatObject(
        tmpObjectConfig,
        `schemaConfig from ${this.ApexController ? `controller: ${this.ApexController}` : "direct assignment"}`,
        errorHandler
      );

      if (this._hasError) {
        return false; // formatObject set the error via errorHandler
      }

      return true; // Success
    } catch (error) {
      this._hasError = true;
      console.error(
        `GenericRecordDetail - Failed to load configuration "${this.SchemaConfig}":`,
        error.message
      );
      return false; // Failure
    }
  }
  async initialiseRecordData() {
    if (!this.ApexController) {
      return true; // Success - no controller needed
    }

    try {
      let tmpData = await getData({
        apexController: this.ApexController,
        param: JSON.stringify({ recordId: this.recordId })
      });

      let processedData = parseJsonString(
        tmpData,
        "recordData from " +
          (this.ApexController
            ? `controller: ${this.ApexController}`
            : "direct assignment")
      );

      const errorHandler = {
        setError: (hasError, error) => {
          this._hasError = hasError;
          console.error(
            `GenericRecordDetail - Failed to format record data from controller "${this.ApexController}":`,
            error.message
          );
        }
      };

      let formattedData = formatObject(
        processedData,
        `recordData from ${this.ApexController ? `controller: ${this.ApexController}` : "direct assignment"}`,
        errorHandler
      );

      if (this._hasError) {
        return false; // formatObject set the error via errorHandler
      }

      const schema = this._schemaConfig?.sections?.[0]?.schema || [];
      this._parsedData = applyEnumMappings(formattedData, schema);
      return true; // Success
    } catch (error) {
      this._hasError = true;
      console.error(
        `GenericRecordDetail - Failed to retrieve and process record data from controller "${this.ApexController}" for recordId "${this.recordId}":`,
        error.message
      );
      return false; // Failure
    }
  }

  handleChildError(event) {
    const { errorMessage, componentType } = event.detail;
    this._hasError = true;
    console.error(
      `GenericRecordDetail - Child component error from ${componentType}: ${errorMessage}`
    );
    this._isLoading = false;

    // Stop event propagation to prevent bubbling to other parents
    event.stopPropagation();
  }
}

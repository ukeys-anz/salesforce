import { LightningElement, api } from "lwc";
import getConfig from "@salesforce/apex/GenericController.getConfig";
import getData from "@salesforce/apex/GenericController.getData";
import { extractValuesByPaths, applyEnumMappings } from "c/genericUtils";

export default class GenericCardArray extends LightningElement {
  @api recordId;
  @api title;
  @api configName;
  @api apexController;
  @api controllerParams;
  @api apiData;
  @api apiConfig;
  @api useControllerData = false;

  isLoading = false;
  _hasError = false;
  _errorMessage;
  cardArrayData;
  cardArrayConfig;
  _enumData;

  async connectedCallback() {
    await this.initialise();

    // Listen for child component errors
    this.addEventListener("childerror", this.handleChildError.bind(this));
  }

  async initialise() {
    this.isLoading = true;
    this._hasError = false;
    this._errorMessage = undefined;

    try {
      if (!(await this.initialiseConfig())) return;
      await this.initialiseData();
    } finally {
      this.isLoading = false;
    }
  }

  async initialiseConfig() {
    if (this.configName) {
      try {
        const result = await getConfig({ configName: this.configName });
        this.cardArrayConfig = JSON.parse(result);
        return true; // Success
      } catch (error) {
        this._hasError = true;
        console.error(
          `Failed to load configuration "${this.configName}": ${error.message}`
        );
        return false; // Failure
      }
    }

    if (this.apiConfig) {
      this.cardArrayConfig = this.apiConfig;
      return true; // Success
    }

    this._hasError = true;
    console.error("Configuration not found or invalid");
    return false; // Failure
  }

  async initialiseData() {
    if (this.useControllerData === true || this.useControllerData === "true") {
      return this.getDataFromController();
    }

    if (!this.apiData) {
      this._hasError = true;
      console.error("API data is required when useControllerData is false");
      return false; // Failure
    }

    try {
      this.cardArrayData =
        typeof this.apiData === "string"
          ? JSON.parse(this.apiData)
          : this.apiData;
      return true; // Success
    } catch (error) {
      this._hasError = true;
      console.error(`Failed to parse API data: ${error.message}`);
      return false; // Failure
    }
  }

  async getDataFromController() {
    if (!this.apexController) {
      this._hasError = true;
      console.error(
        "Apex controller is required when useControllerData is true"
      );
      return false; // Failure
    }

    const param = {
      recordId: this.recordId,
      controllerParams: this.controllerParams
    };

    try {
      const result = await getData({
        apexController: this.apexController,
        param: JSON.stringify(param)
      });
      this.cardArrayData = result;
      return true; // Success
    } catch (error) {
      this._hasError = true;
      console.error(
        `Failed to retrieve data from controller "${this.apexController}": ${error.message}`
      );
      return false; // Failure
    }
  }

  get dataPath() {
    return this.cardArrayConfig?.dataPath;
  }

  get titleField() {
    return this.cardArrayConfig?.titleField;
  }

  get cardConfig() {
    return this.cardArrayConfig?.cardConfig;
  }

  get cardItems() {
    if (!this.cardArrayData) {
      return [];
    }

    try {
      const parsedData =
        typeof this.cardArrayData === "string"
          ? JSON.parse(this.cardArrayData)
          : this.cardArrayData;
      let dataItems = parsedData;

      if (this.dataPath) {
        const extractedData = extractValuesByPaths(parsedData, this.dataPath);
        if (!extractedData[this.dataPath]) {
          console.error(`Data path "${this.dataPath}" not found in data`);
          return [];
        }
        dataItems = extractedData[this.dataPath];
      }

      if (!Array.isArray(dataItems)) {
        console.error(`Data at path "${this.dataPath}" is not an array`);
        return [];
      }

      const schema = this.cardArrayConfig?.cardConfig?.fieldConfig?.schema;
      const mappedItems = applyEnumMappings(dataItems, schema);
      return mappedItems.map((item, index) => ({
        id: item.id || index,
        title: extractValuesByPaths(item, this.titleField)[this.titleField],
        useControllerData: false,
        apiData: item,
        apiConfig: this.cardConfig,
        recordId: this.recordId
      }));
    } catch (error) {
      console.error("Failed to process card items:", error);
      return [];
    }
  }

  handleError(error) {
    this.isLoading = false;
    this._hasError = true;
    this._errorMessage = error.message || "An unexpected error occurred";
    console.error("GenericCardArray Error:", error);
    // Note: Toast removed as we're now showing errors via c-error component
  }

  handleChildError(event) {
    const { errorMessage, componentType } = event.detail;
    this._hasError = true;
    console.error(componentType + " : " + errorMessage);
    this.isLoading = false;

    // Stop event propagation to prevent bubbling to other parents
    event.stopPropagation();
  }
}

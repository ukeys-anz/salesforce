import { LightningElement, api, wire, track } from "lwc";
import getData from "@salesforce/apex/GenericController.getData";
import getConfig from "@salesforce/apex/GenericController.getConfig";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import {
  getFocusedTabInfo,
  setTabLabel,
  setTabIcon
} from "lightning/platformWorkspaceApi";
import {
  extractValuesByPaths,
  applyEnumMappings,
  parseJsonString
} from "c/genericUtils";
import { loadStyle } from "lightning/platformResourceLoader";
import styling from "@salesforce/resourceUrl/genericCardStyling";
/**
 * Generic component for displaying api data with configurable fields and datatable
 * Can be used standalone or as a child component of genericCardArray
 * @component
 */
export default class GenericCard extends NavigationMixin(LightningElement) {
  @api recordId;
  @api tabName;
  @api title;
  @api apiData;
  @api apexController;
  @api controllerParams;
  @api useControllerData = false;
  @api apiConfig;
  @api configName;
  @api filterCondition;

  _isLoading = false;
  _hasError = false;
  _errorMessage;
  cardData;
  cardConfig;
  @track activeSection = "";
  @wire(CurrentPageReference) currentPageRef;

  get isLoading() {
    return this._isLoading;
  }

  set isLoading(value) {
    this._isLoading = value;
  }

  async connectedCallback() {
    await this.initialise();
    Promise.all([loadStyle(this, styling)]);

    // Listen for child component errors
    this.addEventListener("childerror", this.handleChildError.bind(this));
  }

  async initialise() {
    this.isLoading = true;
    this._hasError = false;

    try {
      if (!(await this.initialiseConfig())) return;
      if (!(await this.initialiseData())) return;
      await this.handleOpen();
    } finally {
      this.isLoading = false;
    }
  }

  async initialiseConfig() {
    const configName = this.resolvedConfigName;

    if (configName) {
      try {
        const result = await getConfig({ configName });
        this.cardConfig = JSON.parse(result);
        return true; // Success
      } catch (error) {
        this._hasError = true;
        console.error(
          `Failed to load configuration "${configName}": ${error.message}`
        );
        return false; // Failure
      }
    }

    if (this.apiConfig) {
      this.cardConfig = this.apiConfig;
      return true; // Success
    }

    this._hasError = true;
    console.error(
      `No configuration found: configName="${configName}", apiConfig=${!!this.apiConfig}`
    );
    return false; // Failure
  }

  async initialiseData() {
    const useControllerData =
      this.currentPageRef.state.c__useControllerData === "true" ||
      this.useControllerData === "true";

    if (!useControllerData) {
      if (!this.apiData) {
        this._hasError = true;
        console.error("API data is required when useControllerData is false");
        return false; // Failure
      }
      try {
        this.cardData =
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

    const apexController =
      this.currentPageRef?.state?.c__apexController || this.apexController;
    if (!apexController) {
      this._hasError = true;
      console.error(
        "Apex controller is required when useControllerData is true"
      );
      return false; // Failure
    }

    let controllerParams = this.currentPageRef?.state?.c__controllerParams
      ? this.currentPageRef?.state?.c__controllerParams
      : this.controllerParams;
    controllerParams = parseJsonString(
      controllerParams,
      "generic card controllerParams"
    );

    if (!Object.hasOwn(controllerParams, "recordId")) {
      controllerParams = { recordId: this.recordId, ...controllerParams };
    }

    try {
      const result = await getData({
        apexController,
        param: JSON.stringify(controllerParams)
      });

      const filterCondition = this.resolvedFilterCondition;
      if (!this._extractAndSetCardData(result, filterCondition)) {
        return false; // Failure already handled in _extractAndSetCardData
      }
      return true; // Success
    } catch (error) {
      this._hasError = true;
      console.error(
        `Failed to retrieve data from controller "${apexController}": ${error.message}`
      );
      return false; // Failure
    }
  }

  _extractAndSetCardData(apiResponse, filterCondition) {
    try {
      const processedData =
        typeof apiResponse === "string" ? JSON.parse(apiResponse) : apiResponse;
      const extractedData = extractValuesByPaths(
        processedData,
        filterCondition.dataPath
      );
      const dataAtPath = filterCondition.dataPath
        ? extractedData[filterCondition.dataPath]
        : extractedData;

      if (!dataAtPath) {
        this._hasError = true;
        console.error(`No data found at path: ${filterCondition.dataPath}`);
        return false; // Failure
      }

      if (filterCondition.filterField && filterCondition.filterValue) {
        const filteredItem = this._filterItemsInArray(
          dataAtPath,
          filterCondition
        );
        if (filteredItem === null) {
          return false; // Failure already handled in _filterItemsInArray
        }
        this.cardData = filteredItem;
      } else {
        this.cardData = dataAtPath;
      }
      const schema = this.cardConfig?.fieldConfig?.schema || [];
      this.cardData = applyEnumMappings(this.cardData, schema);
      return true; // Success
    } catch (error) {
      this._hasError = true;
      console.error(
        `Failed to extract and process card data: ${error.message}`
      );
      return false; // Failure
    }
  }

  _filterItemsInArray(dataArray, filterCondition) {
    if (
      !dataArray ||
      !Array.isArray(dataArray) ||
      !filterCondition.filterField ||
      !filterCondition.filterValue
    ) {
      return dataArray;
    }

    try {
      const matchingItem = dataArray.find((item) => {
        const fieldValues = extractValuesByPaths(
          item,
          filterCondition.filterField
        );
        const actualValue = fieldValues[filterCondition.filterField];

        return actualValue === filterCondition.filterValue;
      });

      return matchingItem;
    } catch (error) {
      this._hasError = true;
      console.error(`Failed to filter array data: ${error.message}`);
      return null; // Failure
    }
  }

  get resolvedConfigName() {
    return this.currentPageRef?.state?.c__configName || this.configName;
  }

  get resolvedFilterCondition() {
    const pageRefState = this.currentPageRef?.state || {};
    const filterCondition = this.filterCondition || {};
    return {
      dataPath: pageRefState.c__dataPath || filterCondition.dataPath || "",
      filterValue:
        pageRefState.c__filterValue || filterCondition.filterValue || "",
      filterField:
        pageRefState.c__filterField || filterCondition.filterField || ""
    };
  }

  async handleOpen() {
    const tabNameValue =
      this.currentPageRef?.state?.c__tabName || this.tabName || "Tab";

    const { tabId, title } = await getFocusedTabInfo();
    if (!title || title == "Loading...") {
      setTabLabel(tabId, tabNameValue);
      setTabIcon(tabId, "standard:record");
    }
  }

  handleError(error) {
    this.isLoading = false;
    this._hasError = true;
    this._errorMessage = error.message || "An unexpected error occurred";
    console.error("GenericCard Error:", error);
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

  get fieldConfig() {
    return this.cardConfig?.fieldConfig;
  }

  get hasFields() {
    return this.fieldConfig && Object.keys(this.fieldConfig).length > 0;
  }

  get componentTitle() {
    return this.currentPageRef?.state?.c__title || this.title;
  }

  get tableConfigs() {
    return this.cardConfig?.tableConfig ? this.cardConfig.tableConfig : [];
  }

  get hasTable() {
    return this.tableConfigs.length > 0;
  }

  _extractTableData(config) {
    try {
      if (config.dataPath && this.cardData) {
        const extracted = extractValuesByPaths(this.cardData, config.dataPath);
        const dataAtPath = extracted[config.dataPath];

        if (dataAtPath && Array.isArray(dataAtPath)) {
          return extracted;
        } else return { [config.dataPath]: [] };
      }
      return {};
    } catch (error) {
      console.error(
        `Failed to extract table data for path "${config.dataPath}":`,
        error
      );
      return { [config.dataPath]: [] };
    }
  }

  get tableDataSets() {
    if (!this.hasTable || !this.cardData) return [];

    try {
      return this.tableConfigs.map((config, index) => {
        const tableData = this._extractTableData(config);

        return {
          id: `table-${index}`,
          title: config.title,
          config: config,
          data: tableData,
          sectionName: `tableSection-${index}`,
          hasData: tableData && Array.isArray(tableData) && tableData.length > 0
        };
      });
    } catch (error) {
      console.error("Failed to generate table data sets:", error);
      return [];
    }
  }

  get tableTitle() {
    return this.hasTable ? this.tableConfigs[0].title || "" : "";
  }

  handleSectionToggle(event) {
    const openSections = event.detail.openSections;
    this.activeSection = openSections.length === 0 ? "" : openSections;
  }
}

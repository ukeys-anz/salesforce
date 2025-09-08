import { LightningElement, api, wire } from "lwc";
import { subscribe, MessageContext } from "lightning/messageService";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import dataProviderChannel from "@salesforce/messageChannel/lmsDataProviderChannel__c";
import getData from "@salesforce/apex/GenericController.getData";
import getConfig from "@salesforce/apex/GenericController.getConfig";
import { extractValuesByPaths, parseJsonString } from "c/genericUtils";
import {
  getFocusedTabInfo,
  setTabLabel,
  setTabIcon
} from "lightning/platformWorkspaceApi";

/**
 * Generic data table component that supports multiple data sources and configurations
 * @component
 */
export default class GenericDataTable extends NavigationMixin(
  LightningElement
) {
  // Public API properties
  @api recordId;
  @api title;
  @api iconName;
  @api apexController;
  @api controllerParams;
  @api configName;
  @api keyField;
  @api showRowNumberColumn;
  @api hideCheckboxColumn;
  @api hideTableHeader;
  @api columnWidthsMode;
  @api showActionsMenu;
  @api lmsTopic;

  _extractPath;
  _filterField;
  _filterValue;
  _apexcontroller;
  _keyField;
  _recordId;
  _iconName;
  _title;
  _configName;
  _hideCheckboxColumn;

  @api
  get extractPath() {
    return this._extractPath;
  }
  set extractPath(value) {
    this._extractPath = value;
  }

  @api
  get filterField() {
    return this._filterField;
  }
  set filterField(value) {
    this._filterField = value;
  }

  @api
  get filterValue() {
    return this._filterValue;
  }
  set filterValue(value) {
    this._filterValue = value;
  }

  // Private properties

  // Component state
  _columns = [];
  _tableData = [];
  _tableConfig;
  _isLoading = true;
  _hasError = false;
  _errorMessage;
  _subscription = null;

  // Sort properties
  defaultSortDirection = "asc";
  sortDirection = "asc";
  sortedBy;

  @wire(MessageContext) messageContext;
  @wire(CurrentPageReference) currentPageRef;

  // Getters for template usage
  get isLoading() {
    return this._isLoading;
  }

  set isLoading(value) {
    this._isLoading = value;
  }

  get error() {
    return this._errorMessage;
  }

  @api
  get tableData() {
    return this._tableData;
  }
  set tableData(value) {
    this.processTableData(value);
  }

  @api
  get tableConfig() {
    return this._tableConfig;
  }
  set tableConfig(value) {
    this.processTableConfig(value);
  }

  processTableData(value) {
    try {
      const parsedData = parseJsonString(
        value,
        "tableData from " +
          (this._apexController
            ? `controller: ${this._apexController}`
            : this.lmsTopic
              ? `LMS topic: ${this.lmsTopic}`
              : "direct assignment")
      );
      const extractedData = this._extractData(parsedData);
      this._tableData = this._setTableData(extractedData);
    } catch (error) {
      this._hasError = true;
      console.error(`Failed to process table data: ${error.message}`);
      this._tableData = [];
    }
  }

  processTableConfig(value) {
    try {
      const parsedConfig = parseJsonString(
        value,
        "tableConfig from " +
          (this._configName
            ? `config file: ${this._configName}`
            : "direct assignment")
      );

      // Validate the configuration
      if (parsedConfig.columns) {
        const validationResult = this.validateTableConfig(parsedConfig.columns);
        if (!validationResult.isValid) {
          this._hasError = true;
          console.error(
            "Invalid table configuration. Check browser console for details:",
            validationResult.errors
          );
          return;
        }
      }

      // Set properties from config if not already set via attributes
      if (parsedConfig.dataPath && !this._extractPath) {
        this._extractPath = parsedConfig.dataPath;
      }
      if (parsedConfig.filterField && !this._filterField) {
        this._filterField = parsedConfig.filterField;
      }
      if (parsedConfig.filterValue && !this._filterValue) {
        this._filterValue = parsedConfig.filterValue;
      }

      this._tableConfig = parsedConfig;
    } catch (error) {
      this._hasError = true;
      console.error(`Failed to process table configuration: ${error.message}`);
    }
  }

  async connectedCallback() {
    await this.initialise();

    // Listen for child component errors
    this.addEventListener("childerror", this.handleChildError.bind(this));
  }

  disconnectedCallback() {
    this.unsubscribeFromMessageChannel();
  }

  async initialise() {
    this._isLoading = true;
    this._hasError = false;

    if (this.currentPageRef?.state?.c__fromViewAll) {
      this._apexController = this.currentPageRef?.state?.c__apexController;
      this._recordId = this.currentPageRef?.state?.c__recordId;
      this._title = this.currentPageRef?.state?.c__title;
      this._iconName = this.currentPageRef?.state?.c__iconName;
      this._configName = this.currentPageRef?.state?.c__configName;
      this._keyField = this.currentPageRef?.state?.c__keyField;
      this._hideCheckboxColumn =
        this.currentPageRef?.state?.c__hideCheckboxColumn;
    } else {
      this._apexController = this.apexController;
      this._recordId = this.recordId;
      this._title = this.title;
      this._iconName = this.iconName;
      this._configName = this.configName;
      this._keyField = this.keyField;
      this._hideCheckboxColumn = this.hideCheckboxColumn;
    }

    try {
      if (this.lmsTopic) {
        this.subscribeToMessageChannel();
      }
      if (!(await this.initialiseConfig())) return;
      if (!(await this.initialiseData()));
    } finally {
      this._isLoading = false;
      const { tabId, title } = await getFocusedTabInfo();
      const tabNameValue = this._extractPath || "Related List";
      if (!title || title === "Loading...") {
        setTabLabel(tabId, tabNameValue);
        setTabIcon(tabId, this._iconName);
      }
    }
  }

  async initialiseData() {
    if (this._apexController) {
      try {
        const result = await getData({
          apexController: this._apexController,
          param: JSON.stringify({
            recordId: this._recordId,
            ...(this.controllerParams || {})
          })
        });
        if (result) {
          this.processTableData(result);
        }
        return true; // Success
      } catch (error) {
        this._hasError = true;
        console.error(
          `Failed to retrieve data from controller "${this._apexController}": ${error.message}`
        );
        return false; // Failure
      }
    }
    return true; // Success (no controller data to load)
  }

  async initialiseConfig() {
    if (this._configName) {
      try {
        const config = await getConfig({ configName: this._configName });
        if (config) {
          this.processTableConfig(config);
          return true;
        }
      } catch (error) {
        this._hasError = true;
        console.error(
          `Failed to load configuration "${this._configName}": ${error.message}`
        );
        return false; // Failure
      }
    }
    return true; // Success (no config to load)
  }

  // Message Channel handling
  subscribeToMessageChannel() {
    if (!this._subscription) {
      this._subscription = subscribe(
        this.messageContext,
        dataProviderChannel,
        (message) => this.handleMessage(message)
      );
    }
  }

  unsubscribeFromMessageChannel() {
    this._subscription = null;
  }

  handleMessage(message) {
    if (!this.isValidMessage(message)) return;

    this._hasError = false;
    this._isLoading = false;
    this.processTableData(message.message);
  }

  isValidMessage(message) {
    return (
      message.isResponse &&
      this.lmsTopic &&
      message.controllerClassName === this.lmsTopic
    );
  }

  _extractData(parsedData) {
    try {
      if (!parsedData) {
        return [];
      }

      let extractedData = parsedData;

      if (this._extractPath) {
        const pathExtracted = extractValuesByPaths(
          parsedData,
          this._extractPath
        );
        const dataAtPath = pathExtracted[this._extractPath];

        if (!dataAtPath) {
          console.warn(
            `GenericDataTable: No data found at path: ${this._extractPath}`
          );
          return [];
        }

        extractedData = dataAtPath;
      }

      if (!Array.isArray(extractedData)) {
        console.warn(
          "GenericDataTable: Extracted data is not an array, type:",
          typeof extractedData
        );
        return [];
      }

      if (this._filterField && this._filterValue) {
        extractedData = this._filterData(extractedData);
      }

      if (!extractedData.length) {
        return [];
      }

      return extractedData;
    } catch (error) {
      console.error("Failed to extract data:", error);
      return [];
    }
  }

  _setTableData(extractedData) {
    try {
      if (!extractedData.length) {
        return [];
      }

      const processedData = extractedData.map((item, index) => {
        // Create processed item (integrated createProcessedItem logic)
        const processedItem = {
          rawData: item, // Store raw data for row actions
          id: (this._keyField && item[this._keyField]) || `row_${index}`
        };

        // Process columns (integrated processColumns logic)
        if (this.tableConfig?.columns) {
          this.tableConfig.columns.forEach((column) => {
            if (column.type === "action") return;
            const fieldName = column.fieldName;
            const fieldPath = column.originalField || fieldName;
            const valueMap = extractValuesByPaths(item, fieldPath);
            const value = valueMap[fieldPath];
            processedItem[fieldName] = this.formatFieldValue(value, column);
          });
        }

        return processedItem;
      });

      return processedData;
    } catch (error) {
      console.error("Failed to process table data:", error);
      return [];
    }
  }

  formatFieldValue(value, column) {
    if (column.isEnum && column.enumValues) {
      value = column.enumValues[value] ?? value;
    }
    switch (column.type) {
      case "date":
        return this.formatDateValue(value);
      case "currency":
        return this.formatCurrencyValue(value);
      default:
        return value;
    }
  }

  _filterData(dataArray) {
    if (!this._filterField || !this._filterValue) {
      return dataArray;
    }

    try {
      const matchingItem = dataArray.find((item) => {
        const fieldValues = extractValuesByPaths(item, this._filterField);
        const actualValue = fieldValues[this._filterField];
        return actualValue === this._filterValue;
      });

      return matchingItem || [];
    } catch (error) {
      console.error("Failed to filter data:", error);
      return [];
    }
  }

  formatDateValue(value) {
    if (!value) return null;

    if (typeof value === "object" && value.seconds) {
      const milliseconds = parseInt(value.seconds, 10) * 1000;
      if (value.nanos) {
        const nanosToMillis = Math.floor(value.nanos / 1000000);
        return new Date(milliseconds + nanosToMillis);
      }
      return new Date(milliseconds);
    }

    return value;
  }

  formatCurrencyValue(value) {
    if (value && typeof value === "object" && "units" in value) {
      const units = parseInt(value.units, 10) || 0;
      const nanos = value.nanos || 0;
      return units + nanos / 1000000000;
    }
    return value;
  }

  // Event handlers

  handleRowAction(event) {
    const rawData = event.detail.row?.rawData;
    const actionConfig = event.detail.action;

    const navigationConfig =
      actionConfig?.navigationConfig || this._tableConfig?.navigationConfig;

    if (navigationConfig) {
      this.navigateWithConfig(rawData, navigationConfig);
    }
  }

  handleSort(event) {
    const { fieldName, sortDirection } = event.detail;
    this.sortedBy = fieldName;
    this.sortDirection = sortDirection;
    this._tableData = this.sortData(fieldName, sortDirection);
  }

  sortData(fieldName, sortDirection) {
    const clonedData = [...this._tableData];

    return clonedData.sort((a, b) => {
      let valueA = a[fieldName] ?? "";
      let valueB = b[fieldName] ?? "";

      // Handle date fields
      if (valueA instanceof Date && valueB instanceof Date) {
        valueA = valueA.getTime();
        valueB = valueB.getTime();
      }

      const sortResult = valueA > valueB ? 1 : -1;
      return sortDirection === "asc" ? sortResult : -sortResult;
    });
  }

  navigateWithConfig(rawData, navigationConfig) {
    if (!navigationConfig) return;

    const navControllerParams = navigationConfig.controllerParams
      ? extractValuesByPaths(rawData, navigationConfig.controllerParams)
      : null;

    const compDefinition = {
      c__title: navigationConfig.title,
      c__useControllerData: navigationConfig.useControllerData,
      c__apexController: navigationConfig.apexController,
      c__controllerParams: JSON.stringify({
        recordId: this._recordId,
        ...navControllerParams
      }),
      c__tabName: navigationConfig.tabName,
      c__dataPath: navigationConfig.dataPath,
      c__filterField: navigationConfig.filterField,
      c__filterValue: extractValuesByPaths(
        rawData,
        navigationConfig.filterField
      )[navigationConfig.filterField],
      c__configName: navigationConfig.configName,
      c__defaultOpen: navigationConfig.defaultOpen
    };

    this[NavigationMixin.Navigate]({
      type: "standard__component",
      attributes: {
        componentName: navigationConfig.componentName
      },
      state: compDefinition
    });
  }

  // Validation
  validateTableConfig(columnsConfig) {
    if (!columnsConfig || !Array.isArray(columnsConfig)) {
      return {
        isValid: false,
        errors: ["Configuration must contain a columns array"]
      };
    }

    const validationErrors = [];
    const requiredProperties = ["fieldName", "label"];
    const validTypes = [
      "text",
      "number",
      "boolean",
      "currency",
      "date",
      "datetime",
      "email",
      "location",
      "percent",
      "phone",
      "url",
      "action",
      "button"
    ];

    columnsConfig.forEach((col, index) => {
      // Check required properties
      requiredProperties.forEach((prop) => {
        if (!col[prop] && prop !== "type" && col.type !== "action") {
          validationErrors.push(
            `Column ${index + 1} is missing required property: ${prop}`
          );
        }
      });

      // Validate column type
      if (col.type && !validTypes.includes(col.type)) {
        validationErrors.push(
          `Column ${index + 1} has invalid type: ${col.type}. Valid types are: ${validTypes.join(", ")}`
        );
      }

      // Validate action column
      if (col.type === "action") {
        this.validateActionColumn(col, index, validationErrors);
      }

      // Type-specific validations
      if (
        col.type === "currency" &&
        col.typeAttributes &&
        !col.typeAttributes.currencyCode
      ) {
        validationErrors.push(
          `Currency column ${index + 1} should have a currencyCode in typeAttributes`
        );
      }
    });

    return {
      isValid: validationErrors.length === 0,
      errors: validationErrors
    };
  }

  validateActionColumn(col, index, validationErrors) {
    if (
      !col.typeAttributes?.rowActions ||
      !Array.isArray(col.typeAttributes.rowActions)
    ) {
      validationErrors.push(
        `Action column ${index + 1} must have typeAttributes.rowActions array defined`
      );
      return;
    }

    col.typeAttributes.rowActions.forEach((action, actionIndex) => {
      if (!action.label || !action.name) {
        validationErrors.push(
          `Row action ${actionIndex + 1} in column ${index + 1} must have both label and name properties`
        );
      }
    });
  }

  handleError(error) {
    this.isLoading = false;
    this._hasError = true;
    console.error("GenericDataTable Error:", error);
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

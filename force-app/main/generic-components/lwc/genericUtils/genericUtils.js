import { loadStyle } from "lightning/platformResourceLoader";
import styling from "@salesforce/resourceUrl/GenericComponentAssets";
/**
 *
 * @param {this} compRef - Need to set to this from parent level implementation
 * @param {String} filePath - File Path from GenericComponentAssets
 */
export function loadCSSStyling(compRef, filePath) {
  let fpath = styling + "/" + filePath;
  //If filePath is blank set to default Styling
  if (filePath === "") {
    fpath = styling + "/genericComponentDefault.css";
  }
  Promise.all([loadStyle(compRef, fpath)])
    .then(() => {
      console.log("Style Load Complete...");
    })
    .catch((error) => {
      console.error("Style Load Error:", error);
    });
}
/**
 * Extracts values from a dataset using specified paths and returns a path-to-value map
 *
 * @param {Object} dataSet - The source data object or array to extract values from
 * @param {String|Array} paths - Single path or array of dot-notation paths to extract
 * @return {Object} Map of paths to their extracted values
 */
export function extractValuesByPaths(dataSet, paths) {
  // Handle case where dataset is null/undefined
  if (!dataSet) {
    return {};
  }
  if (!paths) {
    return dataSet;
  }
  // Convert single path to array for consistent handling
  const pathsArray = Array.isArray(paths) ? paths : [paths];

  // Initialize result map
  const resultMap = {};

  // Process each path
  pathsArray.forEach((path) => {
    if (!path) return;

    try {
      // Split the path into segments
      const segments = path.split(".");

      // Traverse the data structure using path segments
      let value = dataSet;
      for (const segment of segments) {
        // Handle array indices in path (e.g., "items[0].name")
        const arrayMatch = segment.match(/^(.*)\[(\d+)\]$/);

        if (arrayMatch) {
          // Extract array property name and index
          const arrayName = arrayMatch[1];
          const arrayIndex = parseInt(arrayMatch[2], 10);

          // Access the array and then the specified index
          value = value[arrayName];
          if (Array.isArray(value) && arrayIndex < value.length) {
            value = value[arrayIndex];
          } else {
            value = undefined;
            break;
          }
        } else if (value && typeof value === "object" && segment in value) {
          // Standard object property access
          value = value[segment];
        } else {
          // Property doesn't exist
          value = undefined;
          break;
        }
      }

      // Store the result in the map
      resultMap[path] = value;
    } catch (error) {
      console.error(`Error extracting value for path: ${path}`, error);
      resultMap[path] = undefined;
    }
  });

  return resultMap;
}

/**
 *
 * @author Satish Badiger
 * @since 06/2025
 * @description Utils module which stores methods that can be shared between Lightning Web Components
 */

export function convertProtoBuffTimestampToISOString(seconds, nanoseconds) {
  const millisecondsfromSeconds = seconds * 1000;
  const millisecondsfromNanos = nanoseconds / 1000000;
  const totalMilliseconds = millisecondsfromSeconds + millisecondsfromNanos;
  // After passing totalMilliSeconds with Date obj it returns date in UTC format 2025-04-29T05:48:13.112Z
  const date = new Date(totalMilliseconds).toISOString();
  return date;
}

export function getCustomformatDateTimeValue(computedDate, customDateProperty) {
  let valueBasedonFormat = null;
  let dateDisplayFormat = null;
  const dateDisplayFormatAusWithTime = {
    day: "numeric",
    month: "numeric",
    year: "numeric",
    minute: "2-digit",
    hour: "2-digit",
    second: "2-digit",
    hour12: true,
    timeZone: "Australia/Sydney"
  };

  const dateDisplayFormatUtcWithTime = {
    day: "numeric",
    month: "numeric",
    year: "numeric",
    minute: "2-digit",
    hour: "2-digit",
    second: "2-digit",
    hour12: true,
    timeZone: "UTC"
  };

  const dateDisplayFormatAus = {
    day: "numeric",
    month: "numeric",
    year: "numeric",
    timeZone: "Australia/Sydney"
  };

  const dateDisplayFormatUtc = {
    day: "numeric",
    month: "numeric",
    year: "numeric",
    timeZone: "UTC"
  };

  switch (customDateProperty.dateFormat) {
    case "US":
      // 4/29/2025, 11:18:13 AM
      valueBasedonFormat = "en-US";
      break;
    default:
      // 29/04/2025, 11:18:13 am
      valueBasedonFormat = "en-GB";
  }

  switch (customDateProperty.timeZone) {
    case "UTC":
      dateDisplayFormat =
        customDateProperty.needTime === true
          ? dateDisplayFormatUtcWithTime
          : dateDisplayFormatUtc;
      break;
    default:
      dateDisplayFormat =
        customDateProperty.needTime === true
          ? dateDisplayFormatAusWithTime
          : dateDisplayFormatAus;
  }
  return new Date(computedDate).toLocaleDateString(
    valueBasedonFormat,
    dateDisplayFormat
  );
}

export function isIsoDateString(isoString) {
  if (!/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/.test(isoString)) {
    return false;
  }
  const dateObj = new Date(isoString);
  return !isNaN(dateObj.getTime()) && dateObj.toISOString() === isoString;
}

/**
 * Applies enum label mappings to one or more data records based on a provided schema.
 * @param {Object|Array} data - A single data object or an array of data objects to process.
 * @param {Array} schema - An array of field definitions, each containing:
 * @returns {Object|Array} A new object or array with enum values replaced by their labels.
 */
export function applyEnumMappings(data, schema) {
  if (!Array.isArray(schema)) {
    return data;
  }
  const records = Array.isArray(data) ? data : [data];
  const mappedRecords = records.map((record) => {
    const result = { ...record };
    schema.forEach((field) => {
      if (field.isEnum && field.enumValues && field.fieldColumn) {
        const pathKeys = field.fieldColumn.split(".");
        // Get raw value
        let value = result;
        for (const key of pathKeys) {
          if (!value || value[key] === undefined) return;
          value = value[key];
        }
        const label = field.enumValues[value];
        if (label !== undefined) {
          // Set mapped label
          let targetObj = result;
          for (let i = 0; i < pathKeys.length - 1; i++) {
            if (!targetObj[pathKeys[i]]) return;
            targetObj = targetObj[pathKeys[i]];
          }
          targetObj[pathKeys[pathKeys.length - 1]] = label;
        }
      }
    });
    return result;
  });
  return Array.isArray(data) ? mappedRecords : mappedRecords[0];
}

/**
 * Safely parse JSON string or return the value if it's already an object
 * @param {string|Object} value - The value to parse
 * @param {string} context - Context for error messages
 * @returns {Object} Parsed JSON or original value
 * @throws {Error} If JSON parsing fails
 */
export function parseJsonString(value, context) {
  if (typeof value === "string") {
    try {
      return JSON.parse(value);
    } catch (error) {
      throw new Error(`Invalid JSON in ${context}: ${error.message}`);
    }
  }
  return value;
}

/**
 * Formats and normalizes object values by converting non-array objects to arrays and parsing JSON strings.
 * Error handling: Uses optional errorHandler with setError method to prevent parent components from masking errors.
 * When an error occurs, it calls errorHandler.setError(true, error) to flag the error state for parent handling,
 * then returns null. If no errorHandler is provided, throws the original error to maintain error visibility.
 */
export function formatObject(
  objValue,
  context = "unknown source",
  errorHandler = null
) {
  try {
    if (!objValue) {
      return objValue;
    }

    if (typeof objValue === "object" && Array.isArray(objValue)) {
      return [...objValue];
    }

    if (typeof objValue === "object" && !Array.isArray(objValue)) {
      // Convert data structure object to array
      let tmpobjValue = { ...objValue };
      return new Array(tmpobjValue);
    }

    return parseJsonString(objValue, context);
  } catch (error) {
    if (errorHandler && typeof errorHandler.setError === "function") {
      errorHandler.setError(true, error);
      return null; // Return null to indicate error occurred
    }
    // If no error handler provided, rethrow the error
    throw error;
  }
}

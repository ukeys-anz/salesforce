/**
 *
 * @author Jasmine Nguyen
 * @since 12/2020
 * @description Utils module which stores methods that can be shared between Lightning Web Components
 */

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import IsS2Enabled from "@salesforce/label/c.S2AccountEnabled";
export { classSet } from "./classSet";

// Handle show toast message
export function showToast(
  cmp,
  theTitle,
  theMessage,
  theMessageData,
  theVariant,
  theMode
) {
  const event = new ShowToastEvent({
    title: theTitle,
    message: theMessage,
    variant: theVariant,
    messageData: theMessageData,
    mode: theMode ? theMode : "dismissable"
  });

  cmp.dispatchEvent(event);
}

// Hanlde errors which are returned as stringified json
export function handleStringifiedError(error) {
  try {
    JSON.parse(error);
  } catch (e) {
    return error;
  }
  return JSON.parse(error).message;
}

// Handle error and showToast
export function handleErrorShowToast(
  cmp,
  title,
  error,
  defaultErrorMessage,
  mode
) {
  let errorMessage = defaultErrorMessage;
  if (error && error.body && error.body.message) {
    let message = handleStringifiedError(error.body.message);
    //Catch any system error messages (most readable errors wont be a single word)
    if (message && message.split(" ").length > 1) {
      errorMessage = message;
    }
  }
  cmp.hasError = true;
  showToast(cmp, title, errorMessage, "", "error", mode);
}

export function handleWireError(cmp, title, error) {
  handleErrorShowToast(cmp, title, error, error.body.message, "pester");
}

export function handleErrors(error) {
  var errorMessage = "";
  if (typeof error === "string") {
    errorMessage = error;
  } else if (error.body) {
    if (Array.isArray(error.body)) {
      errorMessage = error.body.map((e) => e.message).join(", ");
    } else if (typeof error.body.message === "string") {
      errorMessage = "Error Message: " + error.body.message;
    } else if (typeof error.body === "object") {
      let fieldErrors = error.body.fieldErrors;
      let pageErrors = error.body.pageErrors;
      let exceptionErrors = error.body.message;
      if (fieldErrors && fieldErrors.length > 0) {
        for (let fieldName in fieldErrors) {
          if (fieldName) {
            let errorList = fieldErrors[fieldName];
            for (let i = 0; i < errorList.length; i++) {
              errorMessage +=
                errorList[i].statusCode +
                " " +
                fieldName +
                " " +
                errorList[i].message +
                "\n ";
            }
          }
        }
      }
      if (pageErrors && pageErrors.length > 0) {
        for (let j = 0; j < pageErrors.length; j++) {
          errorMessage += "\nError Message: " + pageErrors[j].message;
        }
      }
      if (
        exceptionErrors &&
        typeof exceptionErrors === "string" &&
        exceptionErrors.length > 0
      ) {
        errorMessage += exceptionErrors;
      }
    } else {
      errorMessage =
        "Error Message: Something went wrong. Unable to complete the action.";
    }
  }
  return errorMessage;
}

export function getApexError(error, defaultMessage) {
  if (typeof error === "string") {
    return error;
  }
  if (!error.body) {
    return defaultMessage;
  }
  if (Array.isArray(error.body)) {
    return error.body.map((e) => e.message).join(", ");
  }
  if (typeof error.body.message === "string") {
    return error.body.message;
  }
  return defaultMessage;
}

// General navigation function by warapping NavigationMixin.Navigate
export function navigate(cmp, type, attributes) {
  cmp[NavigationMixin.Navigate]({
    type: type,
    attributes: attributes
  });
}

// This method is created to use in FinancialAccount and FinancialAccountHeader LWC to reduce redundant code.
export function handleAccountHeaderData(accountType) {
  const accountHeader = {};
  if (accountType.toLowerCase() === "checking") {
    accountHeader.balanceTitle = "Everyday Funds";
    accountHeader.productTitle = "ANZ Plus";
    accountHeader.titleIcon = "custom:custom51";
    accountHeader.iconColor = "slds-m-right_small";
  } else if (accountType.toLowerCase() === "savingss2") {
    accountHeader.balanceTitle = "Total Saved";
    accountHeader.productTitle = "ANZ Plus Flex Saver";
    accountHeader.titleIcon = "custom:custom17";
    accountHeader.iconColor = "slds-m-right_small cicon";
  } else {
    accountHeader.balanceTitle = "Total Saved";
    accountHeader.productTitle = "ANZ Save";
    accountHeader.titleIcon = "custom:custom17";
    accountHeader.iconColor = "slds-m-right_small cicon";
  }
  return accountHeader;
}

//This method will identify whether the account is S2 or not used in FinancialAccountParent and personAccountFinancialDetails
export function isS2Account(marketingCode) {
  if (!marketingCode) {
    return false;
  }
  return marketingCode.toLowerCase() === "saving02";
}

//This method will identify whether S2 Deliverable is in dormant or not.
export function isS2Enabled() {
  return IsS2Enabled.toLowerCase() === "true";
}
//formats timestap in `25 September 2023 | 11:54 am`
export function setTimestamp(timestamp) {
  let lastModified = new Date(timestamp);
  lastModified =
    lastModified.getDate() +
    " " +
    lastModified.toLocaleString("en-AU", {
      month: "long"
    }) +
    " " +
    lastModified.getFullYear() +
    " | " +
    lastModified.toLocaleString("en-AU", {
      hour: "numeric",
      minute: "numeric",
      hour12: true
    });
  return lastModified;
}

/**
 * @usage
 * export class SomeLwc extends LightningElement {
 *  toast = new SimpleToast(this);
 *  someFunction() {
 *    this.toast.success("Success message");
 *    this.toast.info("Info message");
 *    this.toast.error("Error message");
 *    this.toast.warning("Warning message");
 *  }
 * }
 */
export class SimpleToast {
  constructor(component) {
    this.lwc = component;
  }
  success(message) {
    showToast(this.lwc, message, null, null, "success");
  }
  error(message) {
    showToast(this.lwc, message, null, null, "error");
  }
  info(message) {
    showToast(this.lwc, message, null, null, "info");
  }
  warning(message) {
    showToast(this.lwc, message, null, null, "warning");
  }
}

/**
 * @usage
 * export class SomeLwc extends LightningElement {
 *  nav = new SimpleNav(this);
 *  someFunction() {
 *    this.nav.toRecord("001XXXXXXXXXXXXXXX");
 *  }
 *  otherFunction() {
 *    this.nav.toObject("Account");
 *  }
 * }
 */
export class SimpleNav {
  constructor(component) {
    this.lwc = component;
  }
  toRecord(recordId, replace = true) {
    this.lwc[NavigationMixin.Navigate](
      {
        type: "standard__recordPage",
        attributes: {
          recordId,
          actionName: "view"
        }
      },
      replace
    );
  }
  toObject(objectApiName, replace = true) {
    this.lwc[NavigationMixin.Navigate](
      {
        type: "standard__objectPage",
        attributes: {
          objectApiName,
          actionName: "home"
        }
      },
      replace
    );
  }
}

//Convert Months into years and MonthsAdd commentMore actions
export function transformMonthToYearMonth(months) {
  let yearValue;
  let monthValue;
  yearValue = Math.floor(months / 12); //divide by 12 and round down
  monthValue = months % 12; //get the reminder of month
  if (yearValue === 0) {
    return monthValue + " months";
  } else if (monthValue === 0) {
    return yearValue + " years";
  }
  return yearValue + " years, " + monthValue + " months";
}

// Update timestamp format to numeric style, e.g., '22/11/2024, 6:17 am'
export function setTimestampShorthand(timestamp) {
  let lastUpdated = new Date(timestamp).toLocaleString("en-AU", {
    day: "numeric",
    month: "numeric",
    year: "numeric",
    hour: "numeric",
    minute: "numeric",
    hour12: true
  });
  return lastUpdated;
}

// Converts units and nanos to salesforce decimal
export function handleAmountConversion(units, nanos) {
  let unitValue = isNaN(parseFloat(units)) ? 0 : parseFloat(units);
  let nanosValue = isNaN(parseFloat(nanos)) ? 0 : parseFloat(nanos);
  return (unitValue + nanosValue / 1000000000).toFixed(2);
}

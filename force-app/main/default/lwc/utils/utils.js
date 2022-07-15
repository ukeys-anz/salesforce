/**
 *
 * @author Jasmine Nguyen
 * @since 12/2020
 * @description Utils module which stores methods that can be shared between Lightning Web Components
 */

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";

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

export function handleErrors(error) {
  this.hasError = true;
  this.errorMessage = "";
  if (typeof error === "string") {
    this.errorMessage = error;
  } else if (error.body) {
    if (Array.isArray(error.body)) {
      this.errorMessage = error.body.map((e) => e.message).join(", ");
    } else if (typeof error.body.message === "string") {
      this.errorMessage = "Error Message: " + error.body.message;
    } else if (typeof error.body === "object") {
      let fieldErrors = error.body.fieldErrors;
      let pageErrors = error.body.pageErrors;
      let exceptionErrors = error.body.message;
      if (fieldErrors && fieldErrors.length > 0) {
        for (let fieldName in fieldErrors) {
          if (fieldName) {
            let errorList = fieldErrors[fieldName];
            for (let i = 0; i < errorList.length; i++) {
              this.errorMessage +=
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
          this.errorMessage += "\nError Message: " + pageErrors[j].message;
        }
      }
      if (
        exceptionErrors &&
        typeof exceptionErrors === "string" &&
        exceptionErrors.length > 0
      ) {
        this.errorMessage += exceptionErrors;
      }
    } else {
      this.errorMessage =
        "Error Message: Something went wrong. Unable to complete the action.";
    }
  }
}

// General navigation function by warapping NavigationMixin.Navigate
export function navigate(cmp, type, attributes) {
  cmp[NavigationMixin.Navigate]({
    type: type,
    attributes: attributes
  });
}

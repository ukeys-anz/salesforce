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

// General navigation function by warapping NavigationMixin.Navigate
export function navigate(cmp, type, attributes) {
  cmp[NavigationMixin.Navigate]({
    type: type,
    attributes: attributes
  });
}

export function closeFocusedTab() {
  invokeWorkspaceAPI("isConsoleNavigation").then((isConsole) => {
    if (isConsole) {
      invokeWorkspaceAPI("getFocusedTabInfo").then((response) => {
        if (!response.isSubtab) {
          invokeWorkspaceAPI("closeTab", {
            tabId: response.tabId
          });
        } else {
          invokeWorkspaceAPI("closeTab", {
            tabId: response.parentTabId
          });
        }
      });
    }
  });
}

function invokeWorkspaceAPI(methodName, methodArgs) {
  return new Promise((resolve, reject) => {
    const apiEvent = new CustomEvent("internalapievent", {
      bubbles: true,
      composed: true,
      cancelable: false,
      detail: {
        category: "workspaceAPI",
        methodName: methodName,
        methodArgs: methodArgs,
        callback: (err, response) => {
          if (err) {
            return reject(err);
          }
          return resolve(response);
        }
      }
    });

    window.dispatchEvent(apiEvent);
  });
}

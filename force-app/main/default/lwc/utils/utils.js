/**
 *
 * @author Jasmine Nguyen
 * @since 12/2020
 * @description Utils module which stores methods that can be shared between Lightning Web Components
 */

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import goal_themes from "@salesforce/resourceUrl/goal_themes";

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

//Handle goal theme sorting and total percentage calculations
export function handleGoalThemes(goalList) {
  goalList.account_buckets.forEach((goal) => {
    if (goal.is_default) {
      goal.image = `${goal_themes}/SAVINGS_JAR.png`;
    } else {
      //Check if goal has theme otherwise use default
      if (goal?.goal?.theme && goal.goal.theme !== "GOAL_THEME_CUSTOM") {
        //If goal is unspecified, assign the image of "something else"
        if (goal.goal.theme === "GOAL_THEME_UNSPECIFIED") {
          goal.image = `${goal_themes}/GOAL_THEME_SOMETHING_ELSE.png`;
        } else {
          goal.image = `${goal_themes}/${goal.goal.theme}.png`;
        }
      } else if (goal?.goal?.emoji?.value) {
        goal.emoji = goal.goal.emoji.value;
      } else {
        goal.image = `${goal_themes}/GOAL_THEME_SOMETHING_ELSE.png`;
      }
    }
    //Determine percentage for goal
    if (goal?.goal?.target_amount?.value) {
      //Work out percentage for fill
      goal.fillPercent = Math.floor(
        (goal.balance.value / goal.goal.target_amount.value) * 100
      );
      goal.balanceRemaining =
        goal.goal.target_amount.value - goal.balance.value;
      goal.goal.target_amount = new Intl.NumberFormat("en-AU", {
        style: "currency",
        currency: "AUD"
      }).format(goal.goal.target_amount.value);
    } else {
      goal.fillPercent = goal.balance.value > 0 ? 100 : 0;
      goal.goal.target_amount = "N/A";
    }
  });

  return goalList;
}

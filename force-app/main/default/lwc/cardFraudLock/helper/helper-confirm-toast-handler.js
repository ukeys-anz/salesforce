import { findCardActionKeyFromLabel } from "./model";

const buttonSuccessToastHandler = {
  Fraud_Lock: {
    title: "Card Locked",
    message: "This card has been successfully locked",
    variant: "success"
  },
  Fraud_Unlock: {
    title: "Card Unlocked",
    message: "This card has been successfully unlocked",
    variant: "success"
  },
  Remove_Temporary_Lock: {
    title: "Card Unlocked",
    message: "This card has been successfully unlocked",
    variant: "success"
  },
  Cancel_Card: {
    title: "Card Cancelled",
    message: "This card has been successfully cancelled",
    variant: "success"
  }
};

export function toastSuccessObjectSchema(buttonClicked) {
  const button = findCardActionKeyFromLabel(buttonClicked);
  return buttonSuccessToastHandler[button];
}

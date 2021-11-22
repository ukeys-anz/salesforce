import { STATUS } from "./model";

const noFraudOptionChosenErrorToastSchema = {
  title: "Choose a fraud lock option",
  message:
    "Please select a fraud lock option as no lock status has been selected",
  variant: "error"
};

const sameFraudOptionChosenErrorToastSchema = {
  title: "Choose another fraud lock option",
  message:
    "Please select another fraud lock option as this lock status has been already applied to the card",
  variant: "error"
};

const buttonErrorToastHandler = (chosenStatus, cardStatus) => {
  const fraudOptions = [
    STATUS.Block_ATM_POS_Exclude_CNP,
    STATUS.Block_ATM_POS_CNP_BCH,
    STATUS.Block_CNP
  ];

  const sameFraudCondition =
    (!chosenStatus && fraudOptions.includes(cardStatus)) ||
    chosenStatus === cardStatus;
  return sameFraudCondition
    ? sameFraudOptionChosenErrorToastSchema
    : noFraudOptionChosenErrorToastSchema;
};

export function fraudLockToastErrorObjectSchema(chosenStatus, cardStatus) {
  const toastObjectHandler = buttonErrorToastHandler(chosenStatus, cardStatus);
  return toastObjectHandler;
}

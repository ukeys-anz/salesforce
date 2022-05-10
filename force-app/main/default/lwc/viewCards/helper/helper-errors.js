const ERROR_MESSAGES = {
  invalidCard:
    "Card Information is invalid. Please reach out to your system administrator.",
  cardDetailsError:
    "Failed to retrieve card list. Please refresh and try again. If the problem persists, please contact your System Administrator.",
  requestError:
    "Failed to complete request. Please refresh and try again. If the problem persists, please contact your System Administrator."
};

const toastTitles = {
  subscription: "Card Management",
  cardDetailsError: "Card List Load Failed"
};

function handleErrorJSON(error) {
  try {
    JSON.parse(error);
  } catch (e) {
    return error;
  }
  return JSON.parse(error).error;
}

function errorNotToBeAWord(error, whichError) {
  if (error && error.message) {
    let message = handleErrorJSON(error.message);
    if (message && typeof message === "string") {
      if (message.split(" ").length > 1) {
        return message;
      }
    }
  }
  return whichError;
}

export const errorHandler = {
  invalidCard: ERROR_MESSAGES.invalidCard,

  subscription: function (msg) {
    return {
      title: toastTitles.subscription,
      message: errorNotToBeAWord(msg, ERROR_MESSAGES.requestError),
      variant: msg.success ? "success" : "error"
    };
  },

  cardDetailsError: function (msg) {
    return {
      title: toastTitles.cardDetailsError,
      message: errorNotToBeAWord(msg, ERROR_MESSAGES.cardDetailsError),
      variant: "error"
    };
  }
};

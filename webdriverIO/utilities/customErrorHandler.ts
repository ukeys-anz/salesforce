export default class CustomError {
  constructor(customMessage: string, providedError?: any) {
    const error = Error(customMessage);

    // set immutable object properties
    Object.defineProperty(error, "name", {
      get() {
        return "CustomError";
      }
    });

    Object.defineProperty(error, "message", {
      get() {
        return providedError
          ? customMessage + "\n" + providedError
          : customMessage;
      }
    });

    // capture where error occurred
    Error.captureStackTrace(error, CustomError);
    return error;
  }
}

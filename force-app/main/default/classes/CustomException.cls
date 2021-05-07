/**
 *
 * @author Jasmine Nguyen
 * @since 04/2021
 * @description Custom Exception class with methods to return the Stack Trace
 * as standard getStackTraceString() does not work with custom exception. Known issue: https://trailblazer.salesforce.com/issues_view?id=a1p300000008dVIAAY
 */

public virtual class CustomException extends Exception {
  private String stackTrackString = createStackTraceString();

  private String createStackTraceString() {
    // Create a system exception and get the stack trace string from it (as standard getStackTraceString() does not work with custom exception)
    // DmlException is a random choice of system exceptions
    stackTrackString = new DmlException().getStackTraceString();
    // The first thee lines are this method, the Exception constructor, and the subclass. So, discard them
    return stackTrackString.replaceFirst('(?m)(.*\\n){3}?', '');
  }

  public override String getStackTraceString() {
    return stackTrackString;
  }
}

/**
 * @description check resursion for triggers.
 * Use Static Boolean variable in apex class and check the variable in Apex Trigger IF it is true then execute the logic and make it false so that trigger can not execute Again
 * Recursion is checked based on https://help.salesforce.com/articleView?id=000332407&type=1&mode=1
 * @author Pavan Kumar Ananta
 * @since 02/2020
 */
public with sharing class CheckRecursive {
  public static Boolean firstCall = false;

  /**
   * @description Method to turn the flag on
   *
   */
  public static void run() {
    firstCall = true;
  }
}

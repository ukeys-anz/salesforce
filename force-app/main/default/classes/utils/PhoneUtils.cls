/**
 * @author Greg Shaw
 * @since 28/3/2023.
 * @description Utils for parsing, formatting, validating Phone/Mobile numbers
 * @runTests PhoneUtilsTest
 */

public with sharing class PhoneUtils {
  /**
   * @description Standardise the format for Australian mobile numbers
   * @param strMobileNumber uncleaned mobile phone number
   *
   * @return Validated Australian Mobile Number with spaces and '+' removed.
   */
  public static String cleanupMobile(String strMobileNumber) {
    String strCleanedMobile = strMobileNumber;
    if (String.isNotBlank(strCleanedMobile)) {
      strCleanedMobile = strCleanedMobile.replaceAll(' ', '');
      Matcher mtMatcher = Pattern.compile('^\\+?(61)?0?4([0-9]{1,8}+)$')
        .matcher(strCleanedMobile);
      if (
        mtMatcher.matches() &&
        mtMatcher.hitEnd() &&
        mtMatcher.groupCount() == 2
      ) {
        strCleanedMobile = '614' + mtMatcher.group(2);
      } else if (strCleanedMobile.startsWith('+')) {
        strCleanedMobile = strCleanedMobile.substringAfter('+');
      }
    }
    return strCleanedMobile;
  }
}

/**
 * @author Greg Shaw
 * @since 28/3/2023.
 * @description Utils for parsing, formatting, validating Phone/Mobile numbers
 * @runTests PhoneUtilsTest
 */

public with sharing class PhoneUtils {
  private static final Pattern MOBILE_PATTERN = Pattern.compile(
    '^\\+?(61)?0?4([0-9]{1,8}+)$'
  );

  /**
   * @description Standardise the format for Australian mobile numbers
   * @param strMobileNumber uncleaned mobile phone number
   *
   * @return Validated Australian Mobile Number with spaces and '+' removed.
   */
  public static String cleanupMobile(String strMobileNumber) {
    if (String.isBlank(strMobileNumber)) {
      return strMobileNumber;
    }

    String strCleanedMobile = strMobileNumber.replaceAll(' ', '')
      .replaceAll('-', '');
    Matcher mtMatcher = MOBILE_PATTERN.matcher(strCleanedMobile);

    if (
      mtMatcher.matches() &&
      mtMatcher.hitEnd() &&
      mtMatcher.groupCount() == 2
    ) {
      return '614' + mtMatcher.group(2);
    }
    if (strCleanedMobile.startsWith('+')) {
      return strCleanedMobile.substringAfter('+');
    }
    return '';
  }
}

/**
 * @description TextUtils class contains static utility methods to take some actions related to text.
 * @author Pavan Kumar Ananta
 * @since 01/06/2020
 * @group Utils
 */
public with sharing class TextUtils {
  private static final String ACCOUNT_OR_CARD_REGEX_PATTERN = '[0-9][^a-zA-Z]{6,}[0-9]';
  private static final String TAX_REGEX_PATTERN = '[0-9][^a-zA-Z]{13,}[0-9]';
  private static final Integer UNMASK_LENGTH = 4;
  private static Pattern accountOrCardPattern = Pattern.compile(
    ACCOUNT_OR_CARD_REGEX_PATTERN
  );
  private static Pattern taxPattern = Pattern.compile(TAX_REGEX_PATTERN);

  /**
   * @description general method to mask certain data with a specific pattern and length
   * @param input Input string that needs to be masked if needed
   * @param patToCompile Regex pattern to match the string
   * @param digLength minimum length of digits in order to be masked
   * @return `String` masked string
   */
  public static String maskData(
    String input,
    Pattern patToCompile,
    Integer digLength
  ) {
    if (String.isNotBlank(input)) {
      Matcher matchingPattern = patToCompile.matcher(input);
      while (matchingPattern.find()) {
        String stringToMask = matchingPattern.group(0).trim();
        String digits = stringToMask.replaceAll('[^0-9]', '');
        if (digits.length() >= digLength) {
          String masked = '';
          for (Integer i = 0; i < digits.length() - UNMASK_LENGTH; i++) {
            masked = masked + '*';
          }
          masked = masked + digits.substring(digits.length() - UNMASK_LENGTH);
          input = input.replaceFirst(ACCOUNT_OR_CARD_REGEX_PATTERN, masked);
          matchingPattern = patToCompile.matcher(input);
        }
      }
    }
    return input;
  }

  /**
   * @description maskData(input) method is used to mask if there are any card numbers in the text.
   * This method masks numbers which are 8 digits or more with spaces or dashes example 4564-6742-8732-8763 is masked as ******8763
   * @param input Input string that needs to be masked if needed
   * @return `String` masked string
   */
  public static String maskData(String input) {
    return maskData(input, accountOrCardPattern, 8);
  }

  /**
   * @description maskDataAnzx method is used to mask if there are any tax numbers in the text.
   * @param input Input string that needs to be masked if needed
   * @return `String` masked string
   */
  public static String maskDataAnzx(String input) {
    return maskData(input, taxPattern, 15);
  }
}

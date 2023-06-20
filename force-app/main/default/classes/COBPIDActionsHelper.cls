/**
 * @author Batya Aisman Sufrin
 * @since 05/2023
 * @description Helper class for @link COBPIDActions
 */
public with sharing class COBPIDActionsHelper {
  private static final String SPACE_REG_EXP = '\\s+';
  private static final String SPACE = ' ';

  /**
   * @description Get Middle Names Initials OCR Match
   * @param nonOCR non OCR Value
   * @param serverOCR OCR Server Value
   * @return OCR match
   */
  public static Boolean compareMiddleNamesValues(
    String nonOCR,
    String serverOCR
  ) {
    if (nonOCR == serverOCR) {
      return true;
    }

    List<String> middleNames = nonOcr?.split(SPACE_REG_EXP);
    if (middleNames?.size() > 0) {
      List<String> initials = new List<String>();
      for (String middleName : middleNames) {
        initials.add(middleName.substring(0, 1));
      }
      return String.join(initials, SPACE) == serverOCR;
    }

    return false;
  }
}

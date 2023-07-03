/**
 * @author Batya Aisman Sufrin
 * @date May 2023
 * @description Test class for {@link COBPIDActionsHelper}
 * @group ANZx
 */
@isTest
public with sharing class COBPIDActionsHelperTest {
  private static final String NON_OCR_MIDDLE_NAME_1 = 'Matthew';
  private static final String NON_OCR_MIDDLE_NAME_2 = 'Matthew Jackson';
  private static final String NON_OCR_MIDDLE_NAME_3 = 'Matthew Day Jackson';
  private static final String NON_OCR_MIDDLE_NAME_4 = 'Steven';
  private static final String NON_OCR_MIDDLE_NAME_5 = 'M';
  private static final String NON_OCR_MIDDLE_NAME_6 = 'S';
  private static final String NON_OCR_MIDDLE_NAME_7 = 'M J';
  private static final String NON_OCR_MIDDLE_NAME_8 = 'M D J';
  private static final String NON_OCR_MIDDLE_NAME_9 = ' ';

  private static final String SERVER_OCR_MIDDLE_NAME_1 = 'Matthew';
  private static final String SERVER_OCR_MIDDLE_NAME_2 = 'Matthew Jackson';
  private static final String SERVER_OCR_MIDDLE_NAME_3 = 'Matthew Day Jackson';
  private static final String SERVER_OCR_MIDDLE_NAME_4 = 'M';
  private static final String SERVER_OCR_MIDDLE_NAME_5 = 'M J';
  private static final String SERVER_OCR_MIDDLE_NAME_6 = 'M D J';
  private static final String SERVER_OCR_MIDDLE_NAME_7 = ' ';

  private static final Map<String, List<String>> ACCEPTABLE = new Map<String, List<String>>{
    SERVER_OCR_MIDDLE_NAME_1 => new List<String>{ NON_OCR_MIDDLE_NAME_1 },
    SERVER_OCR_MIDDLE_NAME_2 => new List<String>{ NON_OCR_MIDDLE_NAME_2 },
    SERVER_OCR_MIDDLE_NAME_3 => new List<String>{ NON_OCR_MIDDLE_NAME_3 },
    SERVER_OCR_MIDDLE_NAME_4 => new List<String>{
      NON_OCR_MIDDLE_NAME_1,
      NON_OCR_MIDDLE_NAME_5
    },
    SERVER_OCR_MIDDLE_NAME_5 => new List<String>{
      NON_OCR_MIDDLE_NAME_2,
      NON_OCR_MIDDLE_NAME_7
    },
    SERVER_OCR_MIDDLE_NAME_6 => new List<String>{
      NON_OCR_MIDDLE_NAME_3,
      NON_OCR_MIDDLE_NAME_8
    },
    SERVER_OCR_MIDDLE_NAME_7 => new List<String>{ NON_OCR_MIDDLE_NAME_9 }
  };

  private static final Map<String, List<String>> UNACCEPTABLE = new Map<String, List<String>>{
    SERVER_OCR_MIDDLE_NAME_1 => new List<String>{
      NON_OCR_MIDDLE_NAME_2,
      NON_OCR_MIDDLE_NAME_3,
      NON_OCR_MIDDLE_NAME_4,
      NON_OCR_MIDDLE_NAME_5,
      NON_OCR_MIDDLE_NAME_6,
      NON_OCR_MIDDLE_NAME_7,
      NON_OCR_MIDDLE_NAME_8,
      NON_OCR_MIDDLE_NAME_9
    },
    SERVER_OCR_MIDDLE_NAME_2 => new List<String>{
      NON_OCR_MIDDLE_NAME_1,
      NON_OCR_MIDDLE_NAME_3,
      NON_OCR_MIDDLE_NAME_4,
      NON_OCR_MIDDLE_NAME_5,
      NON_OCR_MIDDLE_NAME_6,
      NON_OCR_MIDDLE_NAME_7,
      NON_OCR_MIDDLE_NAME_8,
      NON_OCR_MIDDLE_NAME_9
    },
    SERVER_OCR_MIDDLE_NAME_3 => new List<String>{
      NON_OCR_MIDDLE_NAME_1,
      NON_OCR_MIDDLE_NAME_2,
      NON_OCR_MIDDLE_NAME_4,
      NON_OCR_MIDDLE_NAME_5,
      NON_OCR_MIDDLE_NAME_6,
      NON_OCR_MIDDLE_NAME_7,
      NON_OCR_MIDDLE_NAME_8,
      NON_OCR_MIDDLE_NAME_9
    },
    SERVER_OCR_MIDDLE_NAME_4 => new List<String>{
      NON_OCR_MIDDLE_NAME_2,
      NON_OCR_MIDDLE_NAME_3,
      NON_OCR_MIDDLE_NAME_4,
      NON_OCR_MIDDLE_NAME_6,
      NON_OCR_MIDDLE_NAME_7,
      NON_OCR_MIDDLE_NAME_8,
      NON_OCR_MIDDLE_NAME_9
    },
    SERVER_OCR_MIDDLE_NAME_5 => new List<String>{
      NON_OCR_MIDDLE_NAME_1,
      NON_OCR_MIDDLE_NAME_3,
      NON_OCR_MIDDLE_NAME_4,
      NON_OCR_MIDDLE_NAME_5,
      NON_OCR_MIDDLE_NAME_6,
      NON_OCR_MIDDLE_NAME_8,
      NON_OCR_MIDDLE_NAME_9
    },
    SERVER_OCR_MIDDLE_NAME_6 => new List<String>{
      NON_OCR_MIDDLE_NAME_1,
      NON_OCR_MIDDLE_NAME_2,
      NON_OCR_MIDDLE_NAME_4,
      NON_OCR_MIDDLE_NAME_5,
      NON_OCR_MIDDLE_NAME_6,
      NON_OCR_MIDDLE_NAME_7,
      NON_OCR_MIDDLE_NAME_9
    },
    SERVER_OCR_MIDDLE_NAME_7 => new List<String>{
      NON_OCR_MIDDLE_NAME_1,
      NON_OCR_MIDDLE_NAME_2,
      NON_OCR_MIDDLE_NAME_3,
      NON_OCR_MIDDLE_NAME_4,
      NON_OCR_MIDDLE_NAME_5,
      NON_OCR_MIDDLE_NAME_6,
      NON_OCR_MIDDLE_NAME_7,
      NON_OCR_MIDDLE_NAME_8
    }
  };

  @isTest
  private static void testCompareMiddleNamesValues() {
    for (String serverOCR : ACCEPTABLE.keySet()) {
      for (String nonOCR : ACCEPTABLE.get(serverOCR)) {
        Boolean matching = COBPIDActionsHelper.compareMiddleNamesValues(
          nonOCR,
          serverOCR
        );
        Assert.isTrue(
          matching,
          'The Non OCR value should match Server OCR value'
        );
      }
    }

    for (String serverOCR : UNACCEPTABLE.keySet()) {
      for (String nonOCR : UNACCEPTABLE.get(serverOCR)) {
        Boolean matching = COBPIDActionsHelper.compareMiddleNamesValues(
          nonOCR,
          serverOCR
        );
        Assert.isFalse(
          matching,
          'The Non OCR value should not match Server OCR value'
        );
      }
    }
  }
}

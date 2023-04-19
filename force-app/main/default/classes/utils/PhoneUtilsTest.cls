/**
 * @author Greg Shaw
 * @since 28/3/2023.
 * @description Test the PhoneUtils class
 */

@IsTest
private class PhoneUtilsTest {
  @IsTest
  static void cleanupMobile() {
    System.assertEquals(
      '61412345678',
      PhoneUtils.cleanupMobile('+61412 345 678'),
      '+ sign not removed'
    );
    System.assertEquals(
      '61412345678',
      PhoneUtils.cleanupMobile('+610412 345 678'),
      '+ sign and 0 not removed'
    );
    System.assertEquals(
      '61412345678',
      PhoneUtils.cleanupMobile('61412 345 678'),
      'spaces not removed'
    );
    System.assertEquals(
      '61412345678',
      PhoneUtils.cleanupMobile('610412 345 678'),
      '0 not removed'
    );
    System.assertEquals(
      '61412345678',
      PhoneUtils.cleanupMobile('0412 345 678'),
      '0 not removed'
    );
    System.assertEquals(
      '61412345678',
      PhoneUtils.cleanupMobile('412 345 678'),
      '614 prefix not added'
    );
    System.assertEquals(
      '910412345678',
      PhoneUtils.cleanupMobile('+910412 345 678'),
      'unmatched numbers blocked'
    );
  }
}

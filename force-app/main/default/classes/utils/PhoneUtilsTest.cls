/**
 * @author Greg Shaw
 * @since 28/3/2023.
 * @description Test the PhoneUtils class
 */
@IsTest
private class PhoneUtilsTest {
  @IsTest
  static void cleanupMobile() {
    Assert.isNull(PhoneUtils.cleanupMobile(null), 'Should return null');
    Assert.areEqual(
      '',
      PhoneUtils.cleanupMobile(''),
      'empty string not returned'
    );
    Assert.areEqual(
      '61412345678',
      PhoneUtils.cleanupMobile('61412-345-678'),
      '- sign not removed'
    );
    Assert.areEqual(
      '61412345678',
      PhoneUtils.cleanupMobile('+61412 345 678'),
      '+ sign not removed'
    );
    Assert.areEqual(
      '61412345678',
      PhoneUtils.cleanupMobile('+610412 345 678'),
      '+ sign and 0 not removed'
    );
    Assert.areEqual(
      '61412345678',
      PhoneUtils.cleanupMobile('61412 345 678'),
      'spaces not removed'
    );
    Assert.areEqual(
      '61412345678',
      PhoneUtils.cleanupMobile('610412 345 678'),
      '0 not removed'
    );
    Assert.areEqual(
      '61412345678',
      PhoneUtils.cleanupMobile('0412 345 678'),
      '0 not removed'
    );
    Assert.areEqual(
      '61412345678',
      PhoneUtils.cleanupMobile('412 345 678'),
      '614 prefix not added'
    );
    Assert.areEqual(
      '910412345678',
      PhoneUtils.cleanupMobile('+910412 345 678'),
      'unmatched numbers blocked'
    );
  }
}

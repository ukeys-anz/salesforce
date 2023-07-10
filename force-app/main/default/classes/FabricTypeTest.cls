/**
 * @author Mani
 * @since July 2023
 * @description Test Class for FabricType class
 */
@isTest
public with sharing class FabricTypeTest {
  @isTest
  static void testMoney() {
    Decimal a = 5.564893768;
    Decimal b = 0.564893768;
    Decimal c = -0.564893768;
    Decimal d = -5.564893768;
    Decimal e = 0.0;
    Decimal f = 0;
    FabricType.FabricMoney a1 = new FabricType.FabricMoney('AUD', a);
    FabricType.Fabric_money a2 = new FabricType.Fabric_money('AUD', a);
    FabricType.FabricMoney b1 = new FabricType.FabricMoney('AUD', b);
    FabricType.FabricMoney c1 = new FabricType.FabricMoney('AUD', c);
    FabricType.FabricMoney d1 = new FabricType.FabricMoney('AUD', d);
    FabricType.FabricMoney e1 = new FabricType.FabricMoney('AUD', e);
    FabricType.FabricMoney f1 = new FabricType.FabricMoney('AUD', f);
    FabricType.FabricMoney g1 = new FabricType.FabricMoney('AUD', '', 478564);
    FabricType.Fabric_money g2 = new FabricType.Fabric_money('AUD', '', 478564);
    FabricType.FabricMoney h1 = new FabricType.FabricMoney('AUD', 1000.478564);
    FabricType.FabricMoney k1 = new FabricType.FabricMoney('AUD', null, null);

    System.assertEquals(a1.units, '5');
    System.assertEquals(b1.nanos, 564893768);
    System.assertEquals(c1.nanos, -564893768);
    System.assertEquals(d1.units, '-5');
    System.assertEquals(e1.units, '0');
    System.assertEquals(e1.nanos, 0);
    System.assertEquals(f1.value(), 0);
    System.assertEquals(g1.currencyCode, 'AUD');
    System.assertEquals(g1.value(), 0.000478564);
    System.assertEquals(k1.value(), null);
  }
  @isTest
  static void testDate() {
    Date today = System.today();
    FabricType.FabricDate a1 = new FabricType.FabricDate(
      today.year(),
      today.month(),
      today.day()
    );
    FabricType.FabricDate b1 = new FabricType.FabricDate(today);
    FabricType.FabricDate c1 = new FabricType.FabricDate(null);

    System.assertEquals(a1.year.value, today.year());
    System.assertEquals(b1.month.value, today.month());
    System.assertEquals(b1.value(), today);
    System.assertEquals(c1.value(), null);
  }

  @isTest
  static void testTimeStamp() {
    DateTime now = System.now();
    FabricType.Timestamp a1 = new FabricType.Timestamp(now);
    FabricType.Timestamp b1 = new FabricType.Timestamp(a1.seconds, a1.nanos);
    FabricType.Timestamp c1 = new FabricType.Timestamp(null);

    System.assertEquals(a1.seconds, b1.seconds);
    System.assertEquals(a1.nanos, b1.nanos);
    System.assertEquals(b1.value(), now);
    System.assertEquals(c1.value(), null);
  }
}

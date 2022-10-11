/**
 * @author Paul Boyington
 * @since May 2022
 * @description test class for PackageClosureModel class
 * @group Models
 */
@isTest
public with sharing class PackageClosureModelTest {
  @isTest
  static void testParse() {
    StaticResource sr = [
      SELECT body
      FROM StaticResource
      WHERE Name = 'mock_packageClosure'
    ];

    PackageClosureModel obj = PackageClosureModel.parse(sr.body.toString());
    System.assert(obj != null);
    System.assertEquals(200, obj.status.code);
    System.assertEquals('SUCCESS', obj.status.description);
    System.assertEquals('none', obj.meta.accountS1.error);
    System.assertEquals('12345678', obj.meta.accountA1.number_id); // Name transformation
    System.assertEquals('200', obj.meta.overall_package.status); // Name transformation
  }
}

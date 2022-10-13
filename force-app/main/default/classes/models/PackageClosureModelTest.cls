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
    System.assert(obj != null, 'Expected response to not be null');
    System.assertEquals(200, obj.status.code, 'Status code 200 was expected');
    System.assertEquals(
      'SUCCESS',
      obj.status.description,
      'Success description was expected'
    );
    System.assertEquals('none', obj.meta.accountS1.error, 'Expected no errors');
    System.assertEquals(
      '12345678',
      obj.meta.accountA1.number_id,
      'Expected account number to match'
    ); // Name transformation
    System.assertEquals(
      '200',
      obj.meta.overall_package.status,
      'Expected status code of 200'
    ); // Name transformation
  }
}

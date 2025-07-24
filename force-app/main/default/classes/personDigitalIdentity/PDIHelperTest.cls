/**
 * @description Test class for {@link PDIHelper}.
 * @author Tan Phan
 * @since 04/2025
 * @group Person Digital Entity
 */
@isTest
public class PDIHelperTest {
  @isTest
  static void testGetCustomerUuidWithExternalId() {
    DataSource.Filter filter = new DataSource.Filter();
    filter.columnName = 'ExternalId';
    filter.columnValue = 'resources/person/12345-abcde-67890/details';

    Test.startTest();
    String result = PDIHelper.getCustomerUuid(filter);
    Test.stopTest();

    Assert.areEqual(
      '12345-abcde-67890',
      result,
      'UUID should be extracted from ExternalId path'
    );
  }

  @isTest
  static void testGetCustomerUuidWithSubfilters() {
    DataSource.Filter mainFilter = new DataSource.Filter();
    DataSource.Filter subFilter = new DataSource.Filter();
    subFilter.columnName = 'PersonId';
    subFilter.columnValue = '12345-abcde-67890';
    mainFilter.subfilters = new List<DataSource.Filter>{ subFilter };

    Test.startTest();
    String result = PDIHelper.getCustomerUuid(mainFilter);
    Test.stopTest();

    Assert.areEqual(
      '12345-abcde-67890',
      result,
      'PersonId should be extracted from subfilter'
    );
  }

  @isTest
  static void testGetCustomerUuidWithInvalidFilter() {
    // Create a filter with invalid column name
    DataSource.Filter filter = new DataSource.Filter();
    filter.columnName = 'InvalidField';
    filter.columnValue = '12345';

    try {
      Test.startTest();
      PDIHelper.getCustomerUuid(filter);
      Test.stopTest();
      Assert.fail('Should have thrown an exception');
    } catch (Exception e) {
      Assert.areEqual(
        'Invalid filter field InvalidField',
        e.getMessage(),
        'Exception message should match'
      );
    }
  }

  @isTest
  static void testParseResourcePathSuccess() {
    String path = 'api/v1/resources/person/abc-123-def/details';

    Test.startTest();
    String result = PDIHelper.parseResourcePath(path, 'person');
    Test.stopTest();

    Assert.areEqual(
      'abc-123-def',
      result,
      'Should extract UUID correctly from path'
    );
  }

  @isTest
  static void testParseResourcePathKeyNotFound() {
    String path = 'api/v1/resources/customer/abc-123-def/details';

    try {
      Test.startTest();
      PDIHelper.parseResourcePath(path, 'person');
      Test.stopTest();
      Assert.fail('Should have thrown an exception');
    } catch (Exception e) {
      Assert.areEqual(
        'person not found in api/v1/resources/customer/abc-123-def/details',
        e.getMessage(),
        'Exception message should match'
      );
    }
  }

  @isTest
  static void testParseResourcePathKeyAtEnd() {
    String path = 'api/v1/resources/customer/abc-123-def/person';

    try {
      Test.startTest();
      PDIHelper.parseResourcePath(path, 'person');
      Test.stopTest();
      Assert.fail('Should have thrown an exception');
    } catch (Exception e) {
      Assert.areEqual(
        'person found at end of api/v1/resources/customer/abc-123-def/person',
        e.getMessage(),
        'Exception message should match'
      );
    }
  }
}

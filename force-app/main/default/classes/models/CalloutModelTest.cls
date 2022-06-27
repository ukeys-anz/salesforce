/**
 * @author Pavan Kumar Ananta
 * @date February 2020
 * @description Test class for {@link CalloutModel}
 * @group Models
 */
@isTest
public inherited sharing class CalloutModelTest {
  static String modelJson = '{"testString":"Test","submodel":{"testSubString":"TestSub"},"currency":"123"}';
  static String modelJsonWithEdgeKey = '{"currency":"123", "testString":"currency"}';
  static FakeModel testModel = new FakeModel(
    'Test',
    '123',
    new FakeSubModel('TestSub')
  );

  @isTest
  static void testSerialization() {
    CalloutModel modelBase = new CalloutModel();
    Test.startTest();
    String result = modelBase.serialize(testModel);
    Test.stopTest();
    System.assertEquals(
      modelJson,
      result,
      'Serialization should work as expected.'
    );
  }

  @isTest
  static void testDeserialization() {
    Test.startTest();
    FakeModel modelResult = (FakeModel) CalloutModel.deserialize(
      modelJsonWithEdgeKey,
      FakeModel.class
    );
    Test.stopTest();
    System.assertEquals(
      'currency',
      modelResult.testString,
      'Deserialization should work as expected.'
    );
    System.assertEquals(
      testModel.currencyCode,
      modelResult.currencyCode,
      'Deserialization should work as expected.'
    );
  }

  /**
   * @description ensure reserved key replacement does not touch the values
   */
  @isTest
  static void testValueReplacement() {
    Test.startTest();
    FakeModel modelResult = (FakeModel) CalloutModel.deserialize(
      modelJson,
      FakeModel.class
    );
    Test.stopTest();
    System.assertEquals(
      testModel.testString,
      modelResult.testString,
      'Replacement should work as expected.'
    );
    System.assertEquals(
      testModel.currencyCode,
      modelResult.currencyCode,
      'Replacement should work as expected.'
    );
    System.assertEquals(
      testModel.submodel.testSubString,
      modelResult.submodel.testSubString,
      'Replacement should work as expected.'
    );
  }

  /**
   * @description sample model for de/serialization
   */
  public class FakeModel {
    /**
     * @param testString a string
     * @param currencyCode a currency code
     * @param submodel a nested object
     * @description sample model for de/serialization
     */
    public FakeModel(
      String testString,
      String currencyCode,
      FakeSubModel submodel
    ) {
      this.testString = testString;
      this.currencyCode = currencyCode;
      this.submodel = submodel;
    }
    String testString;
    String currencyCode;
    FakeSubModel submodel;
  }
  /**
   * @description sample model for de/serialization
   */
  public class FakeSubModel {
    /**
     * @param testSubString a string
     * @description sample model for de/serialization
     */
    public FakeSubModel(String testSubString) {
      this.testSubString = testSubString;
    }
    String testSubString;
  }
}

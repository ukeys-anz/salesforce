/**
 * @author Karen Valeriano
 * @since Jul 2024
 * @description test class for TokenizedValueModel class
 * @group Models
 */
@isTest
private class TokenizedValueTest {
  @isTest
  static void testConstructor() {
    Test.startTest();
    TokenizedValue model = new TokenizedValue(
      'abw939uy',
      'fpe.personal-identifier'
    );
    Test.stopTest();

    Assert.isFalse(
      String.isBlank(model.Tokenized),
      'The Tokenized property should not be blank.'
    );
    Assert.isFalse(
      String.isBlank(model.Transform),
      'The Transform property should not be blank.'
    );
  }
}

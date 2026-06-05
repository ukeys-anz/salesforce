/**
 * @description Utility class for invoking Salesforce Prompt Builder prompts via ConnectApi.
 */
public class PromptUtils {
  // Test hook: when running tests, tests can set this value to short-circuit actual ConnectApi calls.
  @TestVisible
  private static String mockResponseText = null;

  /**
   * @description Invokes a Prompt Builder prompt by its Developer Name and returns the generated text response.
   * @param promptTemplateDeveloperName The Developer Name of the Prompt Builder prompt to invoke.
   * @param inputParams Map of input parameters to pass to the prompt, with keys matching the prompt's input API names.
   * @return String The generated text response from the prompt. Returns the mockResponseText if running in test context and mockResponseText is set.
   */
  public static String invokePrompt(
    String promptTemplateDeveloperName,
    Map<String, ConnectApi.WrappedValue> inputParams
  ) {
    if (Test.isRunningTest() && mockResponseText != null) {
      return mockResponseText;
    }
    // Prepare input for generating prompt template
    ConnectApi.EinsteinPromptTemplateGenerationsInput promptGenerationsInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();

    // Set hyper parameters
    promptGenerationsInput.inputParams = inputParams;
    promptGenerationsInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
    promptGenerationsInput.additionalConfig.numGenerations = 1;
    promptGenerationsInput.additionalConfig.enablePiiMasking = true;
    promptGenerationsInput.additionalConfig.applicationName = 'PromptTemplateGenerationsInvocable';

    // Set if it's a preview or not
    promptGenerationsInput.isPreview = false;

    // Call the service to generate messages for the prompt template
    ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generationsOutput = ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(
      promptTemplateDeveloperName,
      promptGenerationsInput
    );

    // Consume response
    ConnectApi.EinsteinLLMGenerationItemOutput response = generationsOutput.generations[0];
    return response.text;
  }
}

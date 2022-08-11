/**
 * @author Emma Bindi
 * @since  07/2022
 * @description Builder class to generate parameter strings
 */
public with sharing class ParameterBuilder {
  private String paramUrlString = '';

  /**
   * @return ParameterBuilder representing the context of the builder
   * @param paramKey string representing parameter key
   * @param paramValue string representing parameter value
   * @description method avail to append a string key/value pair in param url
   */
  public ParameterBuilder append(String paramKey, String paramValue) {
    if (paramValue != null) {
      appendParamPair(paramKey, paramValue);
    }
    return this;
  }

  /**
   * @return ParameterBuilder representing the context of the builder
   * @param paramKey string representing parameter key
   * @param paramValue integer representing parameter value
   * @description method avail to append a key/value pair in param url
   */
  public ParameterBuilder append(String paramKey, Integer paramValue) {
    if (paramValue != null) {
      appendParamPair(paramKey, String.valueOf(paramValue));
    }
    return this;
  }

  /**
   * @return ParameterBuilder representing the context of the builder
   * @param paramKey string representing parameter key
   * @param paramValue datetime representing parameter value
   * @description method avail to append a key/value pair in param url
   */
  public ParameterBuilder append(String paramKey, DateTime paramValue) {
    if (paramValue != null) {
      appendParamPair(paramKey, String.valueOfGMT(paramValue));
    }
    return this;
  }

  private void appendParamPair(String paramKey, String paramValue) {
    if (String.isBlank(this.paramUrlString)) {
      this.paramUrlString += '?';
    } else {
      this.paramUrlString += '&';
    }
    this.paramUrlString += (paramKey + '=' + paramValue);
  }

  /**
   * @return string representing the paramater string built by this class
   * @description method to return the constructed param string
   */
  public String get() {
    return this.paramUrlString;
  }
}

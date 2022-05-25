/**
 * @description the wrapper schema for Survey Response Id and Case Record
 * @param CaseRecord Case Record returned by the API
 * @param SurveyResId Id of the survey response
 */
export type APIResult = {
  CaseId: string;
  CaseNumber: string;
  SurveyResId: string;
};

/**
 * @description the schema of case record returned by api
 * @param Id Id of the case returned by the api
 * @param CaseNumber Number of the case returned by the api
 */
export type CaseRecord = {
  Id: string;
  CaseNumber: string;
};

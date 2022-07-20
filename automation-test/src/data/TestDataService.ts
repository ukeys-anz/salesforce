import { createANZXLead, convertAccountFromLead } from "./leadData";
import { createSurvey } from "./surveyData";
import * as dataUtils from "./dataUtils";
import { SObjectAPIName } from "./../constants/enums";

class TestDataService {
  init = async () => {
    const args = process.argv.slice(2);

    if (args[0] === "create") {
      await this.create();
    } else if (args[0] === "delete") {
      await this.delete();
    }
  };

  create = async () => {
    await createSurvey();
    await createANZXLead();
    await convertAccountFromLead();
  };

  delete = async () => {
    const allTestUserIds = await dataUtils.allTestUserIdsByProfile();

    if (allTestUserIds.length > 0) {
      const sobjectsToDelete: string[] = [
        SObjectAPIName.Lead,
        SObjectAPIName.Quality_Assessment,
        SObjectAPIName.Survey_Response,
        SObjectAPIName.Case,
        SObjectAPIName.Account
      ];

      await dataUtils.deleteTestData(sobjectsToDelete, allTestUserIds);
    }
  };
}

new TestDataService().init();

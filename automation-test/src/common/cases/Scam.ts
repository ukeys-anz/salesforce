import RecordCreationForm from "pageObjects/recordCreationForm";
import CaseType from "../../constants/case/caseType";
import { OwnerType } from "../../constants/enums";
import Case from "./Case";
import * as faker from "faker";
import * as commonUtils from "../../utils/commonUtils";
import * as creationFormUtils from "../../utils/creationFormUtils";
import * as casePageUtils from "../../utils/casePageUtils";
import { FieldDefinition } from "../../types/field";
import { FieldSectionIndex } from "../../types/layout";
import CaseFields from "../../constants/case/caseFields";
import IAssignNewOwner from "../../interfaces/IAssignNewOwner";

export default class Scam extends Case implements IAssignNewOwner {
  static creationFormFieldIndexMap = new Map<string, number>();

  async create(caseData: any): Promise<void> {
    const recordCreationFormRoot = await utam.load(RecordCreationForm);
    await recordCreationFormRoot.selectCaseRecordType(CaseType.SCAM);
    await browser.pause(2000);

    const fieldsToFill: FieldDefinition[] = [
      {
        label: CaseFields.Channel_Received,
        options: {
          firstFieldIndex: 5,
          picklistDOMIndex: 0,
          picklistOptionIndexRange: [2, 7]
        }
      },
      {
        label: CaseFields.Issue_Type,
        options: {
          picklistDOMIndex: 1,
          picklistOptionIndexRange: [2, 10]
        }
      },
      {
        label: CaseFields.Account_Name,
        options: {
          lookupText: caseData.accountName
        }
      }
    ];

    Scam.creationFormFieldIndexMap = await creationFormUtils.fillInFields(
      this.sobject,
      Scam.creationFormFieldIndexMap,
      fieldsToFill
    );

    // click save button
    await recordCreationFormRoot.saveNew();
    await browser.pause(5000);
  }

  async assignNewOwner(
    newOwnerType: OwnerType,
    newOwnerName: string
  ): Promise<void> {
    // Owner field index on layout
    const ownerFieldIndex: FieldSectionIndex = [2, 6, 2];

    await commonUtils.assignNewOwner(
      this.sobject,
      ownerFieldIndex,
      newOwnerType,
      newOwnerName
    );
  }

  async update(): Promise<void> {
    const baseRecordForm = (await casePageUtils.getRecordForm())!;
    const recordLayout = await baseRecordForm.getRecordLayout();

    // Chat Topic ID
    const chatTopicField = await commonUtils.getFieldFromRecordLayout(
      recordLayout,
      [2, 3, 2]
    );

    const chatTopicId = `CH${faker.datatype.string(32)}`;
    await commonUtils.inputText(chatTopicField, chatTopicId);

    // click save button
    await commonUtils.clickFormFooterButtonByTitle("Save", baseRecordForm);
  }

  async close(): Promise<void> {
    // Status
    // select Closed status
    const statusFieldIndex: FieldSectionIndex = [2, 4, 2];
    const closedOptionIndex = 4;
    await casePageUtils.closeCase(
      statusFieldIndex,
      closedOptionIndex,
      "Resolved"
    );
  }
}

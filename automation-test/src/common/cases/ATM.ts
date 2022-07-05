import RecordCreationForm from "pageObjects/recordCreationForm";
import Case from "./Case";
import * as faker from "faker";
import * as creationFormUtils from "../../utils/creationFormUtils";
import * as commonUtils from "../../utils/commonUtils";
import * as casePageUtils from "../../utils/casePageUtils";
import { FieldDefinition } from "../../types/field";
import CaseFields from "../../constants/case/caseFields";
import { FieldSectionIndex } from "../../types/layout";

export default class ATM extends Case {
  static creationFormFieldIndexMap = new Map<string, number>();

  async create(): Promise<void> {
    const recordCreationFormRoot = await utam.load(RecordCreationForm);

    const fieldsToFill: FieldDefinition[] = [
      {
        label: CaseFields.Dispute_Reason,
        options: {
          firstFieldIndex: 16,
          picklistDOMIndex: 0,
          picklistOptionIndexRange: [2, 4]
        }
      },
      {
        label: CaseFields.Description_of_Issue
      },
      {
        label: CaseFields.Is_The_Card_Lost_Stolen,
        options: {
          picklistDOMIndex: 1,
          picklistOptionIndexRange: [2, 4]
        }
      },
      {
        label: CaseFields.Card_In_Possession_During_Transaction,
        options: {
          picklistDOMIndex: 2,
          picklistOptionIndexRange: [2, 3]
        }
      },
      {
        label: CaseFields.Has_The_Card_Been_Stopped,
        options: {
          picklistDOMIndex: 3,
          picklistOptionIndexRange: [2, 3]
        }
      },
      {
        label: CaseFields.Received_Amount
      },
      {
        label: CaseFields.Channel_Received,
        options: {
          picklistDOMIndex: 4,
          picklistOptionIndexRange: [2, 22]
        }
      }
    ];

    ATM.creationFormFieldIndexMap = await creationFormUtils.fillInFields(
      this.sobject,
      ATM.creationFormFieldIndexMap,
      fieldsToFill
    );

    // click save button
    await recordCreationFormRoot.saveNew();
    await browser.pause(5000);
  }

  async update(): Promise<void> {
    const baseRecordForm = (await casePageUtils.getRecordForm())!;
    const recordLayout = await baseRecordForm.getRecordLayout();

    // External Case ID
    const externalCaseIdField = await commonUtils.getFieldFromRecordLayout(
      recordLayout,
      [4, 7, 1]
    );

    const externalCaseId = `${faker.datatype.string(10)}`;
    await commonUtils.inputText(externalCaseIdField, externalCaseId);

    // External System
    await commonUtils.selectPicklistOnRecordLayout(
      recordLayout,
      [4, 6, 1],
      [2, 4]
    );

    await commonUtils.clickFormFooterButtonByTitle("Save", baseRecordForm);
  }

  async close(): Promise<void> {
    // Status
    // select Closed status
    const statusFieldIndex: FieldSectionIndex = [4, 1, 1];
    const closedOptionIndex = 5;
    await casePageUtils.closeCase(statusFieldIndex, closedOptionIndex);
  }
}

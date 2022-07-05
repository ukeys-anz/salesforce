import RecordCreationForm from "pageObjects/recordCreationForm";
import Case from "./Case";
import * as faker from "faker";
import * as creationFormUtils from "../../utils/creationFormUtils";
import * as commonUtils from "../../utils/commonUtils";
import * as casePageUtils from "../../utils/casePageUtils";
import { FieldDefinition } from "../../types/field";
import CaseFields from "../../constants/case/caseFields";
import { FieldSectionIndex } from "../../types/layout";

export default class DirectEntry extends Case {
  static creationFormFieldIndexMap = new Map<string, number>();

  async create(caseData: any): Promise<void> {
    const recordCreationFormRoot = await utam.load(RecordCreationForm);

    const fieldsToFill: FieldDefinition[] = [
      {
        label: CaseFields.Dispute_Reason,
        options: {
          firstFieldIndex: 10,
          picklistDOMIndex: 0,
          picklistOptionIndexRange: [2, 6]
        }
      },
      {
        label: CaseFields.Description_of_Issue
      },
      {
        label: CaseFields.Amount_Of_Authorised_Transaction
      },
      {
        label: CaseFields.Is_this_a_Business_Customer,
        options: {
          picklistDOMIndex: 1,
          picklistOptionIndexRange: [2, 3]
        }
      },
      {
        label: CaseFields.Intended_Account_BSB,
        options: {
          textContent: caseData.bsb
        }
      },
      {
        label: CaseFields.Intended_Account_Number,
        options: {
          textContent: caseData.checkAccountNumber
        }
      },
      {
        label: CaseFields.Intended_Account_Name,
        options: {
          textContent: caseData.accountName
        }
      },
      {
        label: CaseFields.Channel_Received,
        options: {
          picklistDOMIndex: 2,
          picklistOptionIndexRange: [2, 25]
        }
      }
    ];

    DirectEntry.creationFormFieldIndexMap =
      await creationFormUtils.fillInFields(
        this.sobject,
        DirectEntry.creationFormFieldIndexMap,
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
      [7, 7, 1]
    );

    const externalCaseId = `${faker.datatype.string(10)}`;
    await commonUtils.inputText(externalCaseIdField, externalCaseId);

    // External System
    await commonUtils.selectPicklistOnRecordLayout(
      recordLayout,
      [7, 6, 1],
      [2, 4]
    );

    await commonUtils.clickFormFooterButtonByTitle("Save", baseRecordForm);
  }

  async close(): Promise<void> {
    // Status
    // select Closed status
    const statusFieldIndex: FieldSectionIndex = [7, 1, 1];
    const closedOptionIndex = 5;
    await casePageUtils.closeCase(statusFieldIndex, closedOptionIndex);
  }
}

import RecordCreationForm from "pageObjects/recordCreationForm";
import CaseType from "../../constants/case/caseType";
import { OwnerType } from "../../constants/enums";
import Case from "./Case";
import * as commonUtils from "../../utils/commonUtils";
import * as creationFormUtils from "../../utils/creationFormUtils";
import * as casePageUtils from "../../utils/casePageUtils";
import { FieldDefinition } from "../../types/field";
import { FieldSectionIndex } from "../../types/layout";
import CaseFields from "../../constants/case/caseFields";
import IAssignNewOwner from "../../interfaces/IAssignNewOwner";

export default class Identity extends Case implements IAssignNewOwner {
  static creationFormFieldIndexMap = new Map<string, number>();

  async selectIdentityCase(): Promise<void> {
    const recordCreationFormRoot = await utam.load(RecordCreationForm);
    await recordCreationFormRoot.selectCaseRecordType(CaseType.IDENTITY);
    await browser.pause(2000);
  }

  async verifyIssueType(issueType: string): Promise<void> {
    const selected = await creationFormUtils.selectPicklistByOptionTitle(
      CaseFields.Issue_Type,
      0,
      issueType
    );

    expect(selected).toBeTruthy();
  }

  async create(caseData: any): Promise<void> {
    const recordCreationFormRoot = await utam.load(RecordCreationForm);

    const fieldsToFill: FieldDefinition[] = [
      {
        label: CaseFields.Channel_Received,
        options: {
          picklistDOMIndex: 1,
          picklistOptionIndexRange: [2, 3]
        }
      },
      {
        label: CaseFields.Account_Name,
        options: {
          lookupText: caseData.accountName
        }
      }
    ];

    Identity.creationFormFieldIndexMap = await creationFormUtils.fillInFields(
      this.sobject,
      Identity.creationFormFieldIndexMap,
      fieldsToFill
    );

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
    const baseRecordForm = await casePageUtils.getRecordForm();
    const recordLayout = await baseRecordForm.getRecordLayout();

    // Priority
    await commonUtils.selectPicklistOnRecordLayout(
      recordLayout,
      [2, 1, 2],
      [2, 9]
    );

    await commonUtils.clickFormFooterButtonByTitle("Save", baseRecordForm);
    await browser.pause(2000);
  }

  async close(): Promise<void> {
    // Status
    // select Closed status
    const statusFieldIndex: FieldSectionIndex = [2, 4, 2];
    const closedOptionIndex = 4;
    await casePageUtils.closeCase(statusFieldIndex, closedOptionIndex);
  }
}

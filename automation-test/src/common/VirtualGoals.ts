import RecordPage from "pageObjects/recordPage";
import FinancialAccountTab from "pageObjects/financialAccountTab";
import * as commonUtils from "utils/commonUtils";

export default class VirtualGoals {
  async viewAccountGoals(): Promise<void> {
    // load Account flexi page
    const recordPageRoot = await utam.load(RecordPage);
    const accountRecordPage = await recordPageRoot.getAccountRecordPage();

    // get Person Account Financial Details lwc component
    const financialDetails =
      await accountRecordPage.getPersonAccountFinancialDetails();

    // get Financial Goals Person Account lwc component
    const financialGoals = await financialDetails.getFinancialGoals();

    const goals = await financialGoals.getGoals();

    // assert there are 3 goals on page
    expect(goals.length).toEqual(3);

    for await (const goal of goals) {
      // assert the Total Saved of each goal is Visible
      const totalSaved = await goal.getTotalSaved();
      expect(await totalSaved.isVisible()).toEqual(true);
    }
  }

  async viewFinancialAccountGoals(): Promise<void> {
    // load Financial Account flexi page
    const recordPageRoot = await utam.load(RecordPage);
    const financialAccountRecordPage =
      await recordPageRoot.getFinancialAccountRecordPage();

    const accountTabset = await financialAccountRecordPage.getAccountTabset();
    const accountTab = await commonUtils.clickTabByLabelAndGetContent(
      accountTabset,
      "Account",
      FinancialAccountTab
    );

    if (accountTab instanceof FinancialAccountTab) {
      // get Financial Account Parent lwc component
      const financialAccount = await accountTab.getFinancialAccountParent();

      // get Financial Goals lwc component
      const financialGoals = await financialAccount.getFinancialGoals();

      const goals = await financialGoals.getGoals();

      // assert there are 6 goals on page
      expect(goals.length).toEqual(6);

      for await (const goal of goals) {
        // assert the Target Value of each goal is Visible
        const targetValue = await goal.getTargetValue();
        expect(await targetValue.isVisible()).toEqual(true);

        // assert the Total Saved of each goal is Visible
        const totalSaved = await goal.getTotalSaved();
        expect(await totalSaved.isVisible()).toEqual(true);
      }
    }
  }
}

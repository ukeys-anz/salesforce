import AccountRecordHomeFlexipage from "pageObjects/coachesWorkbenchAccountRecordHomeFlexipage";
import FinancialAccountRecordHomeFlexipage from "pageObjects/coachesWorkbenchFinancialAccountRecordHomeFlexipage";

export default class VirtualGoals {
  async viewAccountGoals(): Promise<void> {
    // load Account flexi page
    const accountRecordHomeFlexipageRoot = await utam.load(
      AccountRecordHomeFlexipage
    );

    // get Person Account Financial Details lwc component
    const financialDetails =
      await accountRecordHomeFlexipageRoot.getFinancialDetails();

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
    const financialAccountRecordHomeFlexipageRoot = await utam.load(
      FinancialAccountRecordHomeFlexipage
    );

    // get Financial Account Parent lwc component
    const financialAccount =
      await financialAccountRecordHomeFlexipageRoot.getFinancialAccount();

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

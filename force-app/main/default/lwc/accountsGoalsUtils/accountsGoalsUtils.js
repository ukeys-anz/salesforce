import goal_themes from "@salesforce/resourceUrl/goal_themes";

//Handle goal theme sorting and total percentage calculations
export function handleGoalThemes(goalList) {
  goalList.account_buckets.forEach((goal) => {
    if (goal.is_default) {
      goal.image = `${goal_themes}/SAVINGS_JAR.png`;
    } else {
      //Check if goal has theme otherwise use default
      if (goal?.goal?.theme && goal.goal.theme !== "GOAL_THEME_CUSTOM") {
        //If goal is unspecified, assign the image of "something else"
        if (goal.goal.theme === "GOAL_THEME_UNSPECIFIED") {
          goal.image = `${goal_themes}/GOAL_THEME_SOMETHING_ELSE.png`;
        } else {
          goal.image = `${goal_themes}/${goal.goal.theme}.png`;
        }
      } else if (goal?.goal?.emoji?.value) {
        goal.emoji = goal.goal.emoji.value;
      } else {
        goal.image = `${goal_themes}/GOAL_THEME_SOMETHING_ELSE.png`;
      }
    }
    //Determine percentage for goal
    if (goal?.goal?.target_amount?.value) {
      //Work out percentage for fill
      goal.fillPercent = Math.ceil(
        (goal.balance.value / goal.goal.target_amount.value) * 100
      );
      goal.fillPercentValue = goal.fillPercent > 100 ? 100 : goal.fillPercent;
      goal.balanceRemaining =
        goal.goal.target_amount.value - goal.balance.value;
      goal.goal.target_amount = new Intl.NumberFormat("en-AU", {
        style: "currency",
        currency: "AUD"
      }).format(goal.goal.target_amount.value);
    } else {
      goal.fillPercent = goal.fillPercentValue =
        goal.balance.value > 0 ? 100 : 0;
      goal.goal.target_amount = "N/A";
    }
  });

  return goalList;
}

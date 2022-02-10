import goal_themes from "@salesforce/resourceUrl/goal_themes";

export function handleGoalData(goalList) {
  //Sort the goals by oldest
  //This is only a temporary fix until fabric has pagination
  //available to us 02/02/22
  goalList.account_buckets.sort((a, b) => {
    let dateA = new Date(a.created_at);
    let dateB = new Date(b.created_at);
    return dateA - dateB;
  });

  goalList.account_buckets.forEach((goal) => {
    if (goal.is_default) {
      goal.image = `${goal_themes}/SAVINGS_JAR.png`;
    } else {
      //Check if goal has theme otherwise use default
      if (goal?.goal?.theme) {
        //If goal is unspecified, assign the image of "something else"
        if (
          goal.goal.theme === "GOAL_THEME_UNSPECIFIED" ||
          goal.goal.theme === "GOAL_THEME_CUSTOM"
        ) {
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
      goal.fillPercent = Math.floor(
        (goal.balance.value / goal.goal.target_amount.value) * 100
      );
    } else {
      goal.fillPercent = goal.balance.value > 0 ? 100 : 0;
    }
  });

  return goalList;
}

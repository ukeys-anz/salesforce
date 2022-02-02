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
    //Check if goal has theme otherwise use default
    if (goal?.goal?.theme) {
      goal.image = `${goal_themes}/${goal.goal.theme}.png`;
    } else if (goal?.goal?.emoji?.value) {
      goal.emoji = goal.goal.emoji.value;
    } else {
      goal.image = `${goal_themes}/GOAL_THEME_UNSPECIFIED.png`;
    }
    //Determine percentage for goal
    if (goal?.goal?.target_amount?.value) {
      //Work out percentage for fill
      goal.fillPercent = Math.floor(
        (goal.balance.value / goal.goal.target_amount.value) * 100
      );

      goal.balanceRemaining =
        goal.goal.target_amount.value - goal.balance.value;
      goal.goal.target_amount = new Intl.NumberFormat("en-AU", {
        style: "currency",
        currency: "AUD"
      }).format(goal.goal.target_amount.value);
    } else {
      goal.fillPercent = goal.balance.value > 0 ? 100 : 0;
      goal.goal.target_amount = "N/A";
    }

    //Format created date to more readable format
    const createdDate = new Date(goal.created_at);
    goal.created_at =
      createdDate.getDate() +
      " " +
      createdDate.toLocaleString("en-AU", {
        month: "long"
      }) +
      " " +
      createdDate.getFullYear();

    goal.daysRemainingText = "Days remaining: ";
    // Override potential null values with generic values
    if (goal?.goal?.target_date) {
      const targetDate = new Date(
        `${goal.goal.target_date.year.value}-${goal.goal.target_date.month.value}-${goal.goal.target_date.day.value}`
      );
      const today = new Date();

      if (targetDate > today) {
        //Calculate time difference between two dates
        let timeDifference = targetDate.getTime() - today.getTime();

        //Calculate days remaining
        goal.daysRemaining = Math.round(timeDifference / (1000 * 60 * 60 * 24));

        goal.recommendedSavings = goal.balanceRemaining
          ? (goal.balanceRemaining / goal.daysRemaining) * 7
          : "";

        goal.daysRemainingText += goal.daysRemaining;
      } else {
        goal.daysRemainingText = "Target date has passed";
      }

      goal.goal.target_date =
        targetDate.getDate() +
        " " +
        targetDate.toLocaleString("en-AU", {
          month: "long"
        }) +
        " " +
        targetDate.getFullYear();
    } else {
      goal.goal.target_date = "None set";
    }

    //Check fill percent so we dont end up with negative amount
    goal.recommendedSavings =
      goal.recommendedSavings && goal.fillPercent && goal.fillPercent < 100
        ? new Intl.NumberFormat("en-AU", {
            style: "currency",
            currency: "AUD"
          }).format(goal.recommendedSavings)
        : "N/A";
  });

  return goalList;
}

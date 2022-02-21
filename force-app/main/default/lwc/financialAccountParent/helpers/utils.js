import goal_themes from "@salesforce/resourceUrl/goal_themes";
import transaction_logos from "@salesforce/resourceUrl/transaction_logos";
import { handleGoalThemes } from "c/utils";

export function handleGoalData(goalData) {
  let goalList = handleGoalThemes(goalData);
  goalList.account_buckets.forEach((goal) => {
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

export function getImageMap(goals) {
  return new Map(goals.account_buckets.map((goal) => [goal.id, goal.image]));
}

export function getEmojiMap(goals) {
  return new Map(goals.account_buckets.map((goal) => [goal.id, goal.emoji]));
}

export function getGoalMap(goals) {
  return new Map(
    goals.account_buckets.map((goal) => [goal.id, goal.goal.name])
  );
}

export function handleTransactionGoals(transactions, imageMap, emojiMap) {
  transactions.embedded.transactions.forEach((t) => {
    if (t.transfer) {
      // if there is a bucket value for source account prioritise image
      if (t?.transfer?.source_account?.bucket_id?.value) {
        t.source_image = imageMap.get(
          t.transfer.source_account.bucket_id.value
        );
      }
      // if there is a bucket value for source account and no image, check for emoji
      if (t?.transfer?.source_account?.bucket_id?.value && !t?.source_image) {
        t.source_emoji = emojiMap.get(
          t.transfer.source_account.bucket_id.value
        );
      }
      // if there is a bucket value for source account
      // but nothing is mapped for image and emoji, use the default image
      if (
        t?.transfer?.source_account?.bucket_id?.value &&
        !t?.source_image &&
        !t?.source_emoji
      ) {
        t.source_image = `${goal_themes}/GOAL_THEME_SOMETHING_ELSE.png`;
      }
      // if there is a transfer with no source bucket id and has a destination bucket id
      // note: you can only transfer w/ no source bucket from everyday > goal
      if (
        !t?.transfer?.source_account?.bucket_id &&
        t?.transfer?.destination_account?.bucket_id?.value &&
        t?.type === "TRANSACTION_TYPE_TRANSFER"
      ) {
        t.source_image = `${transaction_logos}/EVERYDAY_ACCOUNT.png`;
      }
      // if there is no bucket value for source account
      // but nothing is mapped for image and emoji, use the default image
      if (
        !t?.transfer?.source_account?.bucket_id &&
        t?.transfer?.destination_account?.bucket_id?.value &&
        !t?.source_image &&
        !t?.source_emoji
      ) {
        t.source_image = `${transaction_logos}/TRANSACTION_LOGO_DEFAULT.png`;
      }
      // if there is a bucket value for destination account prioritise image
      if (t?.transfer?.destination_account?.bucket_id?.value) {
        t.destination_image = imageMap.get(
          t.transfer.destination_account.bucket_id.value
        );
      }
      // if there is a bucket value for destination account and no image, check for emoji
      if (
        t?.transfer?.destination_account?.bucket_id?.value &&
        !t?.destination_image
      ) {
        t.destination_emoji = emojiMap.get(
          t.transfer.destination_account.bucket_id.value
        );
      }
      // if there is a bucket value for destination account
      // but nothing is mapped for image and emoji, use the default image
      if (
        t?.transfer?.destination_account?.bucket_id?.value &&
        !t?.destination_image &&
        !t?.destination_emoji
      ) {
        t.destination_image = `${goal_themes}/GOAL_THEME_SOMETHING_ELSE.png`;
      }
      // if there is a transfer with no source bucket id and has a source bucket id
      // note: you can only transfer w/ no destiantion bucket from goal > everyday
      if (
        !t?.transfer?.destination_account?.bucket_id &&
        t?.transfer?.source_account?.bucket_id?.value &&
        t?.type === "TRANSACTION_TYPE_TRANSFER"
      ) {
        t.destination_image = `${transaction_logos}/EVERYDAY_ACCOUNT.png`;
      }
      // if there is no bucket value for destination account
      // but nothing is mapped for image and emoji, use the default image
      if (
        t?.transfer?.source_account?.bucket_id?.value &&
        !t?.transfer?.destination_account?.bucket_id &&
        !t?.destination_image &&
        !t?.destination_emoji
      ) {
        t.destination_image = `${transaction_logos}/TRANSACTION_LOGO_DEFAULT.png`;
      }
    }
    // if there is interest and the account type is savings
    if (
      !t?.transfer &&
      t?.type === "TRANSACTION_TYPE_INTEREST" &&
      t?.interest?.sub_type === "INTEREST_SUB_TYPE_CREDIT_PAID"
    ) {
      t.logo = `${goal_themes}/SAVINGS_JAR.png`;
    }
    // if no transfer set logo as default
    else if (!t?.transfer && !t?.logo) {
      t.logo = `${transaction_logos}/TRANSACTION_LOGO_DEFAULT.png`;
    }
  });
  return transactions;
}

export function handleComponentTitle(goals, goalMap) {
  var title = "Savings Transaction History - Filtered for: ";
  goals.forEach((goal) => {
    title = title + '"' + goalMap.get(goal) + '", ';
  });
  return title.substring(0, title.length - 2);
}

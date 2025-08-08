export function groupGoalsByAccountNumber(accountGoals) {
  const accountMap = new Map();
  accountGoals.forEach((bucket) => {
    const key = `${bucket.account_number}`;
    if (!accountMap.has(key) && bucket.showGoal) {
      accountMap.set(key, {
        account_number: bucket.account_number,
        account_name: bucket.financial_account_name,
        account_id: bucket.financial_account_id,
        ownershipType: bucket.ownershipType,
        sortOrder: bucket.sortOrder,
        product_name: bucket.product_name,
        header_title: bucket.header_title,
        balance_title: bucket.balance_title,
        product_code: bucket.product_code,
        showGoal: bucket.showGoal,
        buckets: []
      });
    }
    if (!bucket.is_default) {
      accountMap?.get(key)?.buckets.push(bucket);
    }
  });
  return Array.from(accountMap.values());
}

export function addFinAccountAndMetaDataToGoals(processedAccounts, goalData) {
  const processedAccount = processedAccounts;
  const accountMap = new Map();
  const goalCopy = structuredClone(goalData);

  Object.values(processedAccount).forEach((product) => {
    Object.values(product.accounts).forEach((acc) => {
      if (acc?.finserv_status != "Closed") {
        accountMap.set(acc.account_number, {
          financial_account_name: acc.account_name,
          ownershipType: acc.finserv_ownership,
          financial_account_id: acc.id,
          sortorder: acc.finserv_sortorder,
          productName: product.productNameTitle,
          headerTitle: product.sectionHeaderTitle,
          balanceTitle: product.balanceTitle,
          productCode: product.productCode,
          showGoal: acc.finserv_showgoal
        });
      }
    });
  });

  goalCopy.account_buckets.forEach((goals) => {
    const matchedData = accountMap.get(goals.account_number);

    if (matchedData) {
      goals.financial_account_name = matchedData.financial_account_name;
      goals.ownershipType = matchedData.ownershipType;
      goals.financial_account_id = matchedData.financial_account_id;
      goals.sortOrder = matchedData.sortorder;
      goals.product_name = matchedData.productName;
      goals.header_title = matchedData.headerTitle;
      goals.balance_title = matchedData.balanceTitle;
      goals.product_code = matchedData.productCode;
      goals.showGoal = matchedData.showGoal;
    } else {
      goals.showGoal = false;
    }
  });

  return goalCopy;
}
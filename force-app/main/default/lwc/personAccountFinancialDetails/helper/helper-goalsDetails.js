export function groupGoalsByAccountNumber(accountGoals) {
  const accountMap = new Map();
  accountGoals.forEach((bucket) => {
    const key = `${bucket.account_number}`;
    if (!accountMap.has(key)) {
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
        buckets: []
      });
    }
    accountMap.get(key).buckets.push(bucket);
  });
  return Array.from(accountMap.values());
}

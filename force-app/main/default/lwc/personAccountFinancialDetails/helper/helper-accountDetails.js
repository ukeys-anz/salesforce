export function updateProductName(financialAccount) {
  let updatedFinancialAccount = {
    ...financialAccount,
    groupedAccounts: financialAccount.groupedAccounts.map((group) => {
      const productName =
        group.accounts?.length > 0
          ? group.accounts[0]?.finserv_product_display_name
          : "";
      return {
        ...group,
        productNameTitle: productName
      };
    })
  };
  return updatedFinancialAccount;
}

/**
 * @author Nagendra Singh
 * @since August 2023
 * @description Model for transaction history API
 */
public with sharing class FinancialAccountModelConverter {
  /**
   * @description FinancialAccountModelConverter converts the v1 response back to v1beta1 response
   * @param sourceModel Holds the values of v1
   * @return FinancialAccountModel which holds the converted value of v1beta1
   */
  public static FinancialAccountModel convertToFinancialAccountModel(
    FinancialAccountModelV1 sourceModel
  ) {
    FinancialAccountModel result = new FinancialAccountModel();
    result.account_list = new List<FinancialAccountModel.AccountList>();

    for (
      FinancialAccountModelV1.Accounts sourceAccount : sourceModel.accounts
    ) {
      FinancialAccountModel.AccountList destAccount = new FinancialAccountModel.AccountList();

      // Direct field mappings
      destAccount.account_number = sourceAccount.account_number;
      destAccount.bsb = sourceAccount.bsb;
      destAccount.name = sourceAccount.account_name;
      destAccount.balance_valid_at = sourceAccount.balances.balance_update_time;
      destAccount.is_balance_current = sourceAccount.balances.balance_up_to_date;
      destAccount.status = sourceAccount.state;
      destAccount.allowed_transact_options = sourceAccount.product_details.transact_options;

      // Balance conversions
      destAccount.balance = convertBalance(sourceAccount.balances.balance);
      destAccount.current_balance = convertCurrentBalance(
        sourceAccount.balances.current_balance
      );

      // MarketingProduct mapping
      destAccount.marketing_product = new FinancialAccountModel.MarketingProduct();
      destAccount.marketing_product.code = sourceAccount.product_details.marketing_code;
      destAccount.marketing_product.name = sourceAccount.product_details.name;

      // Status mapping
      destAccount.status = sourceAccount.state;

      // Opened at mapping - constructing DateTime based on OpenDate
      destAccount.opened_at =
        sourceAccount.open_date.year +
        '-' +
        sourceAccount.open_date.month +
        '-' +
        sourceAccount.open_date.day;

      //Closed at mapping - constructing DateTime based on ClosedDate
      if (
        sourceAccount.close_date != null &&
        sourceAccount.close_date.year != null &&
        sourceAccount.close_date.month != null &&
        sourceAccount.close_date.day != null
      ) {
        destAccount.closed_at =
          sourceAccount.close_date.year +
          '-' +
          sourceAccount.close_date.month +
          '-' +
          sourceAccount.close_date.day;
      }

      // Interest rate - Assuming 'rate_with_margin' represents the interest rate
      if (
        sourceAccount.deposit_details != null &&
        sourceAccount.deposit_details.debit_interest_details != null
      ) {
        destAccount.interest_rate = (Double) sourceAccount.deposit_details.debit_interest_details.interest_rate.rate_with_margin;
      }

      // Bucket count mapping
      if (
        sourceAccount.deposit_details != null &&
        sourceAccount.deposit_details.bucket_count != null
      ) {
        destAccount.bucket_count = sourceAccount.deposit_details.bucket_count;
      }

      // TieredRates mapping
      destAccount.tiered_rates = new List<FinancialAccountModel.TieredRates>();
      if (
        sourceAccount.deposit_details != null &&
        sourceAccount.deposit_details.tiered_rates != null
      ) {
        for (
          FinancialAccountModelV1.TieredRates sourceTieredRate : sourceAccount.deposit_details.tiered_rates
        ) {
          destAccount.tiered_rates.add(convertTieredRates(sourceTieredRate));
        }
      }

      // Adding the transformed account to the result list
      result.account_list.add(destAccount);
    }

    return result;
  }

  private static FinancialAccountModel.Balance convertBalance(
    FinancialAccountModelV1.Balance sourceBalance
  ) {
    FinancialAccountModel.Balance destBalance = new FinancialAccountModel.Balance();

    destBalance.currency_code = sourceBalance.currency_code;
    destBalance.units = sourceBalance.units;
    destBalance.nanos = sourceBalance.nanos;

    return destBalance;
  }

  private static FinancialAccountModel.Balance convertCurrentBalance(
    FinancialAccountModelV1.Current_balance sourceBalance
  ) {
    FinancialAccountModel.Balance destBalance = new FinancialAccountModel.Balance();

    destBalance.currency_code = sourceBalance.currency_code;
    destBalance.units = sourceBalance.units;
    destBalance.nanos = sourceBalance.nanos;

    return destBalance;
  }
  private static FinancialAccountModel.Tiers convertMaxAndMinTiers(
    FinancialAccountModelV1.Max max,
    FinancialAccountModelV1.Min min,
    Double rate
  ) {
    FinancialAccountModel.Tiers tier = new FinancialAccountModel.Tiers();
    FinancialAccountModel.Balance tierMinBalance = new FinancialAccountModel.Balance();
    FinancialAccountModel.Balance tierMaxBalance = new FinancialAccountModel.Balance();
    tierMinBalance.currency_code = min.currency_code;
    tierMinBalance.units = min.units;
    tierMinBalance.nanos = min.nanos;
    tierMaxBalance.currency_code = max.currency_code;
    tierMaxBalance.units = max.units;
    tierMaxBalance.nanos = max.nanos;
    tier.min = tierMinBalance;
    tier.max = tierMaxBalance;
    tier.rate = rate;

    return tier;
  }

  private static FinancialAccountModel.TieredRates convertTieredRates(
    FinancialAccountModelV1.TieredRates sourceTieredRate
  ) {
    FinancialAccountModel.TieredRates destTieredRate = new FinancialAccountModel.TieredRates();
    destTieredRate.tiers = new List<FinancialAccountModel.Tiers>();

    for (FinancialAccountModelV1.Tiers sourceTier : sourceTieredRate.tiers) {
      FinancialAccountModel.Tiers destTier = new FinancialAccountModel.Tiers();
      destTier = convertMaxAndMinTiers(
        sourceTier.max,
        sourceTier.min,
        sourceTier.rate
      );
      destTieredRate.tiers.add(destTier);
    }

    return destTieredRate;
  }
}

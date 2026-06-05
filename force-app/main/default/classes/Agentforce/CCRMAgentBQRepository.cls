/**
 * @author Agentforce
 * @description Repository for querying BQ Data Lake mirrored DL models used by Agentforce features.
 *              Provides read-only accessors for Customer_Insights__dlm, BusinessBankerDesktop__dlm,
 *              WholeOfCustomer__dlm and helper to fetch Account external customer number.
 */
public with sharing class CCRMAgentBQRepository {
  /**
   * @description Queries Customer_Insights__dlm records for the provided customer number,
   *              ordered by quarter and load date, then reduces to one record per quarter.
   * @param customerNumbers Set<String> of customer numbers to filter Customer_Insights__dlm.customer_no__c by.
   * @return List<Customer_Insights__dlm> customer insights records
   */
  public List<Customer_Insights__dlm> fetchCustomerInsights(
    Set<Decimal> customerNumbers
  ) {
    if (customerNumbers == null || customerNumbers.isEmpty()) {
      return new List<Customer_Insights__dlm>();
    }

    List<Customer_Insights__dlm> rawRecords = [
      SELECT
        KYC_FLAG__c,
        pl_ofi_dtl__c,
        cnt_cc_ofi__c,
        tl_ofi_dtl__c,
        industry_division__c,
        InternalOrganization__c,
        cnt_fx_ofi__c,
        od_util__c,
        deposit_cash__c,
        load_date__c,
        ter__c,
        customer_no__c,
        net_prod_hold_l12m__c,
        avg_od_util_l12m__c,
        deposit_both__c,
        industry__c,
        avg_prod_hold__c,
        fx_ofi_dtl__c,
        quick_assist__c,
        avg_cc_util_l12m__c,
        avg_deposit_l12m__c,
        withdrawal_cash__c,
        cnt_pl_ofi__c,
        withdrawal_cheque__c,
        cc_ofi_dtl__c,
        od_limit__c,
        cc_limit__c,
        lo_bal_l12m__c,
        cc_util__c,
        gobiz_elig_cust__c,
        avg_lending_l12m__c,
        avg_deposit__c,
        quarter__c,
        cnt_tl_ofi__c,
        tot_ter_l12m__c,
        hi_mth_bal__c,
        deposit_cheque__c,
        avg_lending__c,
        cnt_merc_ofi__c,
        DataSourceObject__c,
        hi_bal_l12m__c,
        lo_mth_bal__c,
        status__c,
        cnt_hl_ofi__c,
        src_snapshot__c,
        est_turnover__c,
        withdrawal_both__c,
        tot_turnover_l12m__c,
        cnt_af_ofi__c,
        clv__c,
        bus_cust_type__c,
        af_ofi_dtl__c,
        hl_ofi_dtl__c,
        merc_ofi_dtl__c
      FROM Customer_Insights__dlm
      WHERE customer_no__c IN :customerNumbers
      ORDER BY load_date__c DESC
    ];
    return rawRecords;
  }

  /**
   * @description Retrieves BusinessBankerDesktop__dlm insight rows for a banker, filtered by LAN ID.
   *              Returns all matching records as stored in the BQ DL model without additional transformations.
   * @param lanId The LAN ID (username/identifier) used to filter BusinessBankerDesktop__dlm.lanid__c.
   * @return List<BusinessBankerDesktop__dlm> collection of BBD insights for the specified LAN ID; empty list when lanId is null or no data is found.
   */
  public List<BusinessBankerDesktop__dlm> fetchBBDInsights(String lanId) {
    if (String.isBlank(lanId)) {
      return new List<BusinessBankerDesktop__dlm>();
    }

    List<BusinessBankerDesktop__dlm> rawRecords = [
      SELECT
        Id,
        sub_week__c,
        curr_fy_wk__c,
        pstn_end_dt__c,
        ar_nm__c,
        DataSourceObject__c,
        app_type__c,
        latest_application_status__c,
        InternalOrganization__c,
        sub_fy__c,
        approve_week__c,
        curr_fy__c,
        created_dt__c,
        submitted_dt__c,
        lanid__c,
        sub_lastweek__c,
        tpmi_sao__c,
        application_type__c,
        fum__c,
        approve_flag__c,
        submitter_lastname__c,
        application_stage__c,
        DataSource__c,
        assessor_rework__c,
        rl_ttl_cd__c,
        pstn_strt_dt__c,
        approved_originator_number__c,
        record_guid__c,
        role_type__c,
        ast_dt__c,
        app_no__c,
        form_type__c,
        drawn_week__c,
        frontline_rework__c,
        sub_tpmi_number__c,
        is_third_party_originator__c,
        rework_bucket__c,
        total_rework__c,
        drawn_fy__c,
        ast_flag__c,
        st_nm__c,
        version__c,
        pstn_nm__c,
        bu_nm__c,
        approve_fy__c,
        tpmi_business_name__c,
        aged_ast__c,
        approved_dt__c,
        draw_down_dt__c,
        sub_flag__c,
        report_date__c,
        submitter_firstname__c,
        report_name__c,
        drawn_flag__c
      FROM BusinessBankerDesktop__dlm
      WHERE lanid__c = :lanId
    ];

    return rawRecords;
  }

  /**
   * @description Retrieves WholeOfCustomer__dlm insight rows for a customer, filtered by external customer number.
   *              Returns all matching records as stored in the BQ DL model without additional transformations.
   * @param  customerNumbers Set<String> of external customer numbers (WholeOfCustomer__dlm.bus_cust_no__c) to filter by.
   * @return List<WholeOfCustomer__dlm> collection of WOC insights for the specified customer; empty list when customerNumber is null or no data is found.
   */
  public List<WholeOfCustomer__dlm> fetchWOCInsights(
    Set<String> customerNumbers
  ) {
    if (customerNumbers == null || customerNumbers.isEmpty()) {
      return new List<WholeOfCustomer__dlm>();
    }

    List<WholeOfCustomer__dlm> rawRecords = [
      SELECT
        Id,
        cnt_merc_ofi__c,
        cnt_asset_finance__c,
        od_prob_rating__c,
        ar_nm__c,
        transact_prob__c,
        asset_finance_prob__c,
        cnt_tcf_fac__c,
        merchants_prob__c,
        direct_deposit_fum_eop__c,
        DataSourceObject__c,
        cnt_tl_ofi__c,
        cnt_trade__c,
        InternalOrganization__c,
        cpid__c,
        cnt_cbills_fac__c,
        cnt_savings__c,
        cc_uplift__c,
        term_loan_prob_rating__c,
        cnt_fx__c,
        cnt_comm_cards__c,
        cnt_fx_ofi__c,
        max_pred__c,
        churn_prob__c,
        savings_prob__c,
        cnt_cc_ofi__c,
        term_loan_prob__c,
        snapshot_date__c,
        cnt_ig_fac__c,
        DataSource__c,
        hl_ofi_dtl__c,
        cnt_af_ofi__c,
        indstry_spclisation__c,
        comm_cards_prob_rating__c,
        hl_uplift__c,
        record_guid__c,
        run_date__c,
        cnt_term_deposits__c,
        role_type__c,
        cnt_hl_ofi__c,
        total_direct_income_12m__c,
        fx_prob_rating__c,
        buslend_hover__c,
        wow_score__c,
        dep_uplift__c,
        derived_state__c,
        bus_cust_no__c,
        bu_sgmt__c,
        cnt_markets__c,
        cnt_tcf_loan__c,
        home_loan_prob__c,
        version__c,
        pstn_nm__c,
        cc_ofi_dtl__c,
        af_ofi_dtl__c,
        home_loan_prob_rating__c,
        comm_cards_prob__c,
        cnt_merchants__c,
        asset_finance_prob_rating__c,
        buslend_uplift__c,
        cnt_od__c,
        merchant_uplift__c,
        cnt_transact__c,
        od_prob__c,
        wow_ofi_potential_revenue__c,
        merchants_prob_rating__c,
        wow_txn_potential_revenue__c,
        cnt_pl_ofi__c,
        dep_change__c,
        report_date__c,
        fx_prob__c,
        term_deposits_prob__c,
        direct_lending_fum_eop__c,
        transact_prob_rating__c,
        cnt_fmd__c,
        cnt_term_loan__c,
        report_name__c,
        tl_ofi_dtl__c,
        bus_cust_name__c,
        cnt_home_loan__c,
        term_deposits_prob_rating__c,
        savings_prob_rating__c,
        wow_prop_potential_revenue__c
      FROM WholeOfCustomer__dlm
      WHERE bus_cust_no__c IN :customerNumbers
    ];

    return rawRecords;
  }

  /**
   * @description Retrieves a list of Customer_Insights__dlm records for a single customer number. This method is intended for use cases where only one customer number is relevant, such as fetching insights for a specific account. It returns all matching records as stored in the BQ DL model without additional transformations.
   * @param customerNumber Decimal customer number to filter Customer_Insights__dlm.customer_no__c by.
   * @return List<Customer_Insights__dlm> customer insights records
   */
  public List<Customer_Insights__dlm> fetchCustomerInsightsByCustomerNumbers(
    Decimal customerNumber
  ) {
    if (customerNumber == null) {
      return new List<Customer_Insights__dlm>();
    }

    List<Customer_Insights__dlm> rawRecords = [
      SELECT
        quick_assist__c,
        gobiz_elig_cust__c,
        KYC_FLAG__c,
        cnt_af_ofi__c,
        af_ofi_dtl__c,
        cnt_tl_ofi__c,
        tl_ofi_dtl__c,
        cnt_merc_ofi__c,
        merc_ofi_dtl__c,
        cnt_cc_ofi__c,
        cc_ofi_dtl__c,
        cnt_pl_ofi__c,
        pl_ofi_dtl__c,
        cnt_hl_ofi__c,
        hl_ofi_dtl__c,
        cnt_fx_ofi__c,
        fx_ofi_dtl__c,
        load_date__c
      FROM Customer_Insights__dlm
      WHERE customer_no__c = :customerNumber
    ];
    return rawRecords;
  }

  /**
   * @description Retrieves a list of CAZ_Assessment_dlm records for a single customer number (CAP-CIS Id).
   * @param customerNumber Text customer number to filter CAZ_Assessment_dlm.customer_id__c by.
   * @return List<CAZ_Assessment2__dlm> CAZ assessment records
   */
  public List<CAZ_Assessment2__dlm> fetchCAZAssessmentByCustomerNumber(
    String customerNumber
  ) {
    if (customerNumber == null) {
      return new List<CAZ_Assessment2__dlm>();
    }

    List<CAZ_Assessment2__dlm> rawRecords = [
      SELECT
        Id,
        customer_id__c,
        created_date__c,
        /* Business Context */
        tell_me_about_your_business__c,
        /* Personal Finance Goals */
        pbc_tellmeaboutyourpersonalfinancegoals__c,
        pba_tellmeaboutyourpersonalfinancegoals__c,
        /* Personal Banking Context */
        pbc_tellmeaboutyourpersonalbanking__c,
        pba_tellmeaboutyourpersonalbanking__c,
        /* OFI Relationships */
        pbc_otherofirelationship__c,
        pba_otherofirelationship__c,
        /* Cash Flow Insights – Inbound */
        tbc_cashflowsintobusiness__c,
        tba_cashflowsintobusiness__c,
        tbc_cashflowsintobusinesstype__c,
        tba_cashflowsintobusinesstype__c,
        /* Cash Flow Insights – Outbound */
        tbc_cashflowsoutofbusiness__c,
        tba_cashflowsoutofbusiness__c,
        tbc_cashflowsoutofbusinesstype__c,
        tba_cashflowsoutofbusinesstype__c,
        /* Borrowing Entity, Amount & Purpose */
        bc_borrowingentity__c,
        bc_borrowingentityamountrequired__c,
        bc_borrowingpurpose__c,
        bc_borrowingpurposedetails__c
      FROM CAZ_Assessment2__dlm
      WHERE
        customer_id__c = :customerNumber
        AND created_date__c >= N_MONTHS_AGO:24
      ORDER BY created_date__c DESC
      LIMIT 50
    ];
    return rawRecords;
  }
}

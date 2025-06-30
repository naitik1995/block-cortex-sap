view: accounts_payable_v2 {
  sql_table_name: `@{GCP_PROJECT}.@{REPORTING_DATASET}.AccountsPayable`;;

  parameter: Aging_Interval {
    label: "Aging Interval"
    description: "Numeric parameter to define the aging interval in days for overdue calculations. Default is 30 days."
    type: number
    default_value: "30"
    hidden: no
  }

  dimension: key {
    label: "Primary Key"
    description: "Unique identifier for each record, concatenated from client, accounting document number, line item number, company code, and target currency."
    type: string
    primary_key: yes
    hidden: yes
    sql: CONCAT(${client_mandt},${accounting_document_number_belnr},${number_of_line_item_within_accounting_document_buzei},${company_code_bukrs},${target_currency_tcurr});;
  }

  dimension: account_number_of_vendor_or_creditor_lifnr {
    label: "Vendor Account Number"
    description: "The account number assigned to the vendor or creditor."
    type: string
    sql: ${TABLE}.AccountNumberOfVendorOrCreditor_LIFNR ;;
  }

  dimension: account_type_koart {
    label: "Account Type"
    description: "Indicates the type of account (e.g., K for Vendor)."
    type: string
    sql: ${TABLE}.AccountType_KOART ;;
  }

  dimension: accounting_document_number_belnr {
    label: "Accounting Document Number"
    description: "The unique number assigned to an accounting document."
    type: string
    sql: ${TABLE}.AccountingDocumentNumber_BELNR ;;
  }

  dimension: accounting_documenttype_blart {
    label: "Accounting Document Type"
    description: "The type of the accounting document (e.g., KR for Vendor Invoice)."
    type: string
    sql: ${TABLE}.AccountingDocumenttype_BLART ;;
  }

  dimension: amount_in_local_currency_dmbtr {
    label: "Amount in Local Currency"
    description: "The transaction amount in the local currency of the company code, displayed as a negative value for payables."
    type: number
    sql: ${TABLE}.AmountInLocalCurrency_DMBTR * -1;;
  }

  # A measure is a field that uses a SQL aggregate function.
  #Here are defined sum and average
  # measures for this dimension, but you can also add measures of many different aggregates.
# Click on the type parameter to see all the options in the Quick Help panel on the right.
  measure: total_amount_in_local_currency_dmbtr {
    label: "Total Amount in Local Currency"
    description: "The sum of all transaction amounts in the local currency."
    type: sum
    sql: ${amount_in_local_currency_dmbtr} ;;
    value_format_name: Greek_Number_Format
  }

  measure: average_amount_in_local_currency_dmbtr {
    label: "Average Amount in Local Currency"
    description: "The average of all transaction amounts in the local currency."
    type: average
    sql: ${amount_in_local_currency_dmbtr} ;;
    value_format_name: Greek_Number_Format
  }

  dimension: amount_in_target_currency_dmbtr {
    label: "Amount in Target Currency"
    description: "The transaction amount converted to the specified target currency, displayed as a negative value for payables."
    type: number
    hidden: no
    sql: ${TABLE}.AmountInTargetCurrency_DMBTR * -1 ;;
  }

  dimension: amount_of_open_debit_items_in_source_currency {
    label: "Open Debit Items (Source Currency)"
    description: "The amount of open debit items in the original source currency."
    type: number
    sql: ${TABLE}.AmountOfOpenDebitItemsInSourceCurrency ;;
  }

  dimension: amount_of_open_debit_items_in_target_currency {
    label: "Open Debit Items (Target Currency)"
    description: "The amount of open debit items converted to the target currency."
    type: number
    sql: ${TABLE}.AmountOfOpenDebitItemsInTargetCurrency ;;
  }

  dimension: amount_of_return_in_source_currency {
    label: "Return Amount (Source Currency)"
    description: "The amount of returned goods or services in the original source currency."
    type: number
    sql: ${TABLE}.AmountOfReturnInSourceCurrency ;;
  }

  dimension: amount_of_return_in_target_currency {
    label: "Return Amount (Target Currency)"
    description: "The amount of returned goods or services converted to the target currency."
    type: number
    sql: ${TABLE}.AmountOfReturnInTargetCurrency ;;
  }

  dimension: cash_discount_received_in_source_currency {
    label: "Cash Discount Received (Source Currency)"
    description: "The amount of cash discount received in the original source currency."
    type: number
    sql: ${TABLE}.CashDiscountReceivedInSourceCurrency ;;
  }

  dimension: cash_discount_received_in_target_currency {
    label: "Cash Discount Received (Target Currency)"
    description: "The amount of cash discount received converted to the target currency."
    type: number
    sql: ${TABLE}.CashDiscountReceivedInTargetCurrency ;;
  }




  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
# Looker converts dates and timestamps to the specified timeframes within the dimension group.
  dimension_group: clearing_date_augdt {
    label: "Clearing Date"
    description: "The date on which an open item was cleared (paid)."
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.ClearingDate_AUGDT ;;
  }

  dimension: client_mandt {
    label: "Client"
    description: "The client (a self-contained unit in an SAP system with separate master records and its own set of tables)."
    type: string
    sql: ${TABLE}.Client_MANDT ;;
  }

  dimension: company_code_bukrs {
    label: "Company Code"
    description: "The organizational unit representing an independent accounting unit within a client."
    type: string
    sql: ${TABLE}.CompanyCode_BUKRS ;;
  }

  dimension: company_text_butxt {
    label: "Company Name"
    description: "The name of the company code."
    type: string
    sql: ${TABLE}.CompanyText_BUTXT ;;
  }

  dimension: currency_key_waers {
    label: "Document Currency"
    description: "The currency key for the amounts in the document (source currency)."
    type: string
    sql: ${TABLE}.CurrencyKey_WAERS ;;
  }

  dimension: doc_fisc_period {
    label: "Document Fiscal Period"
    description: "The fiscal period in which the document was posted."
    type: string
    sql: ${TABLE}.DocFiscPeriod ;;
  }

  dimension: document_number_of_the_clearing_document_augbl {
    label: "Clearing Document Number"
    description: "The document number that cleared the open item."
    type: string
    sql: ${TABLE}.DocumentNumberOfTheClearingDocument_AUGBL ;;
  }

  dimension: exchange_rate_ukurs {
    label: "Exchange Rate"
    description: "The exchange rate used for currency conversion."
    type: number
    sql: ${TABLE}.ExchangeRate_UKURS ;;
  }

  dimension: fiscal_period_monat {
    label: "Fiscal Period"
    description: "The accounting period within a fiscal year."
    type: string
    sql: ${TABLE}.FiscalPeriod_MONAT ;;
  }

  dimension: fiscal_year_gjahr {
    label: "Fiscal Year"
    description: "The year for which financial statements are prepared."
    type: string
    sql: ${TABLE}.FiscalYear_GJAHR ;;
  }

  dimension: inv_status_rbstat {
    label: "Invoice Status"
    description: "The status of the invoice (e.g., posted, parked)."
    type: string
    sql: ${TABLE}.InvStatus_RBSTAT ;;
  }

  dimension: invoice_documenttype_blart {
    label: "Invoice Document Type"
    description: "The document type specifically for invoices."
    type: string
    sql: ${TABLE}.InvoiceDocumenttype_BLART ;;
  }

  dimension: is_blocked_invoice {
    label: "Is Blocked Invoice"
    description: "Indicates whether the invoice is blocked for payment (Yes/No)."
    type: yesno
    sql: ${TABLE}.IsBlockedInvoice ;;
  }

  measure: blocked_invoice {
    label: "Count of Blocked Invoices"
    description: "The total number of invoices that are currently blocked for payment."
    type: count
    filters: [is_blocked_invoice: "Yes"]
    hidden: no
  }

  measure: blocked_invoice_amount {
    label: "Blocked Invoice Amount (Local Currency)"
    description: "The total amount of blocked invoices in the local currency."
    type: sum
    filters: [is_blocked_invoice: "Yes"]
    sql: ${amount_in_local_currency_dmbtr} ;;
    value_format_name: Greek_Number_Format
    hidden: no
  }


  measure: blocked_invoice_amount_global_currency {
    label: "Blocked Invoice Amount (Target Currency)"
    description: "The total amount of blocked invoices in the target currency."
    type: sum
    filters: [is_blocked_invoice: "Yes"]
    sql: ${amount_in_target_currency_dmbtr};;
    value_format_name: Greek_Number_Format
    hidden: no
  }

  dimension: is_parked_invoice {
    label: "Is Parked Invoice"
    description: "Indicates whether the invoice is parked (saved as incomplete) (Yes/No)."
    type: yesno
    sql: ${TABLE}.IsParkedInvoice ;;
  }

  measure: parked_invoice {
    label: "Count of Parked Invoices"
    description: "The total number of invoices that are currently parked."
    type: count
    filters: [is_parked_invoice: "Yes"]
    hidden: no
  }

  measure: parked_invoice_amount {
    label: "Parked Invoice Amount (Local Currency)"
    description: "The total amount of parked invoices in the local currency."
    type: sum
    filters: [is_parked_invoice: "Yes"]
    sql: ${TABLE}.AmountInLocalCurrency_DMBTR ;;
    value_format_name: Greek_Number_Format
    hidden: no
  }

  measure: parked_invoice_amount_global_currency {
    label: "Parked Invoice Amount (Target Currency)"
    description: "The total amount of parked invoices in the target currency."
    type: sum
    filters: [is_parked_invoice: "Yes"]
    sql: ${TABLE}.AmountInTargetCurrency_DMBTR ;;
    value_format_name: Greek_Number_Format
    hidden: no
  }

  dimension: key_fisc_period {
    label: "Key Fiscal Period"
    description: "A key combining fiscal year and period for unique identification or sorting."
    type: string
    sql: ${TABLE}.KeyFiscPeriod ;;
  }

  dimension: late_payments_in_source_currency {
    label: "Late Payments (Source Currency)"
    description: "The amount of payments that were made after the due date, in source currency."
    type: number
    sql: ${TABLE}.LatePaymentsInSourceCurrency ;;
  }

  dimension: late_payments_in_target_currency {
    label: "Late Payments (Target Currency)"
    description: "The amount of payments that were made after the due date, in target currency, displayed as a negative value."
    type: number
    sql: ${TABLE}.LatePaymentsInTargetCurrency * -1 ;;
  }

  measure: sum_late_payments_in_target_currency {
    label: "Total Late Payments (Target Currency)"
    description: "The sum of all late payment amounts in the target currency."
    type: sum
    sql: ${late_payments_in_target_currency}  ;;
    value_format_name: Greek_Number_Format
    hidden: no
  }

  dimension: month_of_posting_date_in_the_document_budat {
    label: "Month of Posting Date"
    description: "The month number (1-12) from the posting date of the document."
    type: number
    sql: ${TABLE}.MonthOfPostingDateInTheDocument_BUDAT ;;
  }

  dimension: movement_type__inventory_management___bwart {
    label: "Movement Type (Inventory Management)"
    description: "A key identifying the type of material movement (e.g., goods receipt, goods issue)."
    type: string
    sql: ${TABLE}.MovementType__inventoryManagement___BWART ;;
  }

  dimension: name1 {
    label: "Vendor Name"
    description: "The name of the vendor or creditor."
    type: string
    sql: ${TABLE}.NAME1 ;;
    hidden: no

  }

  dimension: is_null_name1 {
    label: "Is Vendor Name Null"
    description: "Checks if the vendor name is null (Yes/No)."
    type: yesno
    sql: ${TABLE}.NAME1 IS NULL ;;
    hidden: no
  }

  dimension_group: net_due {
    label: "Net Due Date"
    description: "The date on which the net payment for an invoice is due."
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.NetDueDate ;;
  }

  dimension: number_of_line_item_within_accounting_document_buzei {
    label: "Line Item Number"
    description: "The sequential number of a line item within an accounting document."
    type: string
    sql: ${TABLE}.NumberOfLineItemWithinAccountingDocument_BUZEI ;;
  }

  dimension: outstanding_but_not_overdue_in_source_currency {
    label: "Outstanding Not Overdue (Source Currency)"
    description: "The amount of open items that are not yet due for payment, in source currency, displayed as a negative value."
    type: number
    sql: ${TABLE}.OutstandingButNotOverdueInSourceCurrency * -1 ;;
    value_format_name: Greek_Number_Format
  }

  dimension: outstanding_but_not_overdue_in_target_currency {
    label: "Outstanding Not Overdue (Target Currency)"
    description: "The amount of open items that are not yet due for payment, in target currency, displayed as a negative value."
    type: number
    sql: ${TABLE}.OutstandingButNotOverdueInTargetCurrency * -1;;
    value_format_name: Greek_Number_Format
  }

  dimension: overdue_amount_in_source_currency {
    label: "Overdue Amount (Source Currency)"
    description: "The amount of open items that are past their due date, in source currency, displayed as a negative value."
    type: number
    sql: ${TABLE}.OverdueAmountInSourceCurrency * -1 ;;
    value_format_name: Greek_Number_Format
  }

  dimension: overdue_amount_in_target_currency {
    label: "Overdue Amount (Target Currency)"
    description: "The amount of open items that are past their due date, in target currency, displayed as a negative value."
    type: number
    sql: ${TABLE}.OverdueAmountInTargetCurrency * -1 ;;
    value_format_name: Greek_Number_Format
  }


  measure: sum_overdue_amount {
    label: "Total Overdue Amount (Target Currency)"
    description: "The sum of all overdue amounts in the target currency."
    type: sum
    sql: ${overdue_amount_in_target_currency} ;;
    value_format_name: Greek_Number_Format
    hidden: no
  }

  dimension: Past_Due_Interval{
    label: "Past Due Interval"
    description: "Categorizes overdue items into aging buckets based on the 'Aging Interval' parameter (e.g., 1-30 Days, 31-60 Days)."
    type: string
    hidden: no
    sql: if((date_diff(cast(current_date() as Date),${TABLE}.NetDueDate, DAY)>0 and date_diff(cast(current_date() as Date),${TABLE}.NetDueDate, DAY)<({% parameter Aging_Interval %}+1)),concat('b1- ',({% parameter Aging_Interval %}),' Days'),
        (if((date_diff(cast(current_date() as Date),${TABLE}.NetDueDate, DAY)<(({% parameter Aging_Interval %}*2)+1)),concat('c31-',({% parameter Aging_Interval %}*2),' Days'),
        (if((date_diff(cast(current_date() as Date),${TABLE}.NetDueDate, DAY)<(({% parameter Aging_Interval %}*3)+1)),concat('d61-',({% parameter Aging_Interval %}*3),' Days'),
        (if((date_diff(cast(current_date() as Date),${TABLE}.NetDueDate, DAY)>(({% parameter Aging_Interval %}*3)+1)),concat('e> ',({% parameter Aging_Interval %}*3),' Days'),'aNot OverDue' ))
)) )) ) ;;
  }

  dimension:  past_overdue_1_to_30day{
    label: "Past Overdue 1-30 Days (Target Currency)"
    description: "Overdue amount in target currency for items past due by 1 to 30 days (or current Aging Interval)."
    type: number
    sql: if(${Past_Due_Interval}='b1- 30 Days',(${overdue_on_past_date_in_target_currency} ),0) ;;
    hidden: no
    value_format_name: Greek_Number_Format
  }

  dimension:  source_past_overdue_1_to_30day{
    label: "Past Overdue 1-30 Days (Source Currency)"
    description: "Overdue amount in source currency for items past due by 1 to 30 days (or current Aging Interval)."
    type: number
    sql: if(${Past_Due_Interval}='b1- 30 Days',(${overdue_on_past_date_in_source_currency} ),0) ;;
    hidden: no
    value_format_name: Greek_Number_Format
  }


  dimension:  past_overdue_31_to_60day{
    label: "Past Overdue 31-60 Days (Target Currency)"
    description: "Overdue amount in target currency for items past due by 31 to 60 days (or current Aging Interval * 2)."
    type: number
    sql: if(${Past_Due_Interval}='c31-60 Days',(${overdue_on_past_date_in_target_currency} ),0) ;;
    hidden: no
    value_format_name: Greek_Number_Format
  }

  dimension:  source_past_overdue_31_to_60day{
    label: "Past Overdue 31-60 Days (Source Currency)"
    description: "Overdue amount in source currency for items past due by 31 to 60 days (or current Aging Interval * 2)."
    type: number
    sql: if(${Past_Due_Interval}='c31-60 Days',(${overdue_on_past_date_in_source_currency} ),0) ;;
    hidden: no
    value_format_name: Greek_Number_Format
  }


  dimension:  past_overdue_61_to_90day{
    label: "Past Overdue 61-90 Days (Target Currency)"
    description: "Overdue amount in target currency for items past due by 61 to 90 days (or current Aging Interval * 3)."
    type: number
    sql: if(${Past_Due_Interval}='d61-90 Days',(${overdue_on_past_date_in_target_currency} ),0) ;;
    hidden: no
    value_format_name: Greek_Number_Format
  }

  dimension:  source_past_overdue_61_to_90day{
    label: "Past Overdue 61-90 Days (Source Currency)"
    description: "Overdue amount in source currency for items past due by 61 to 90 days (or current Aging Interval * 3)."
    type: number
    sql: if(${Past_Due_Interval}='d61-90 Days',(${overdue_on_past_date_in_source_currency} ),0) ;;
    hidden: no
    value_format_name: Greek_Number_Format
  }


  dimension:  past_overdue_greater_than_90day{
    label: "Past Overdue >90 Days (Target Currency)"
    description: "Overdue amount in target currency for items past due by more than 90 days (or current Aging Interval * 3)."
    type: number
    sql: if(${Past_Due_Interval}='e> 90 Days',(${overdue_on_past_date_in_target_currency}),0) ;;
    hidden: no
    value_format_name: Greek_Number_Format
  }


  dimension:  source_past_overdue_greater_than_90day{
    label: "Past Overdue >90 Days (Source Currency)"
    description: "Overdue amount in source currency for items past due by more than 90 days (or current Aging Interval * 3)."
    type: number
    sql: if(${Past_Due_Interval}='e> 90 Days',(${overdue_on_past_date_in_source_currency} ),0) ;;
    hidden: no
    value_format_name: Greek_Number_Format
  }




  dimension:  past_overdue_but_not_overdue{
    label: "Not Overdue Amount (Target Currency)"
    description: "Amount that is outstanding but not yet overdue, in target currency."
    type: number
    sql: if(${Past_Due_Interval}='aNot OverDue',(${outstanding_but_not_overdue_in_target_currency}),0) ;;
    hidden: no
    value_format_name: Greek_Number_Format
  }

  dimension:  source_past_overdue_but_not_overdue{
    label: "Not Overdue Amount (Source Currency)"
    description: "Amount that is outstanding but not yet overdue, in source currency."
    type: number
    sql: if(${Past_Due_Interval}='aNot OverDue',(${outstanding_but_not_overdue_in_source_currency}),0) ;;
    hidden: no
    value_format_name: Greek_Number_Format
  }

  measure:  sum_past_overdue_1_to_30days{
    label: "Sum Past Overdue 1-30 Days (Target Currency)"
    description: "Total overdue amount in target currency for items past due by 1 to 30 days (or current Aging Interval)."
    type: sum
    sql: ${overdue_on_past_date_in_target_currency} ;;
    filters: [Past_Due_Interval: "b1- 30 Days"]
    value_format_name: Greek_Number_Format
    hidden: no
  }

  measure:  sum_past_overdue_1_to_30days_conv_drill{
    label: "Sum Past Overdue 1-30 Days (Target Currency, Drill)"
    description: "Total overdue amount in target currency for items past due by 1 to 30 days (or current Aging Interval), with a drill link to Accounts Payable Aging dashboard."
    type: sum
    sql: ${overdue_on_past_date_in_target_currency} ;;
    filters: [Past_Due_Interval: "b1- 30 Days"]
    value_format_name: Greek_Number_Format
    hidden: no
    link: {
      label: "Accounts Payable Aging"
      url: "/dashboards/cortex_sap_operational::sap_finance_ap_07_a_accounts_payable_aging?Target+Currency={{ _filters['accounts_payable_v2.target_currency_tcurr']| url_encode }}&Vendor+Name={{ _filters['accounts_payable_v2.name1']| url_encode }}&Company+Name={{ _filters['accounts_payable_v2.company_text_butxt']| url_encode }}"
    }
  }

  measure:  sum_past_overdue_31_to_60days{
    label: "Sum Past Overdue 31-60 Days (Target Currency)"
    description: "Total overdue amount in target currency for items past due by 31 to 60 days (or current Aging Interval * 2)."
    type: sum
    sql: ${overdue_on_past_date_in_target_currency} ;;
    filters: [Past_Due_Interval: "c31-60 Days"]
    value_format_name: Greek_Number_Format
    hidden: no
  }

  measure:  sum_past_overdue_31_to_60days_conv_drill{
    label: "Sum Past Overdue 31-60 Days (Target Currency, Drill)"
    description: "Total overdue amount in target currency for items past due by 31 to 60 days (or current Aging Interval * 2), with a drill link to Accounts Payable Aging dashboard."
    type: sum
    sql: ${overdue_on_past_date_in_target_currency} ;;
    filters: [Past_Due_Interval: "c31-60 Days"]
    value_format_name: Greek_Number_Format
    hidden: no
    link: {
      label: "Accounts Payable Aging"
      url: "/dashboards/cortex_sap_operational::sap_finance_ap_07_a_accounts_payable_aging?Target+Currency={{ _filters['accounts_payable_v2.target_currency_tcurr']| url_encode }}&Vendor+Name={{ _filters['accounts_payable_v2.name1']| url_encode }}&Company+Name={{ _filters['accounts_payable_v2.company_text_butxt']| url_encode }}"
    }
  }

  measure:  sum_past_overdue_61_to_90days{
    label: "Sum Past Overdue 61-90 Days (Target Currency)"
    description: "Total overdue amount in target currency for items past due by 61 to 90 days (or current Aging Interval * 3)."
    type: sum
    sql: ${overdue_on_past_date_in_target_currency} ;;
    filters: [Past_Due_Interval: "d61-90 Days"]
    value_format_name: Greek_Number_Format
    hidden: no
  }

  measure:  sum_past_overdue_61_to_90days_conv_drill{
    label: "Sum Past Overdue 61-90 Days (Target Currency, Drill)"
    description: "Total overdue amount in target currency for items past due by 61 to 90 days (or current Aging Interval * 3), with a drill link to Accounts Payable Aging dashboard."
    type: sum
    sql: ${overdue_on_past_date_in_target_currency} ;;
    filters: [Past_Due_Interval: "d61-90 Days"]
    value_format_name: Greek_Number_Format
    hidden: no
    link: {
      label: "Accounts Payable Aging"
      url: "/dashboards/cortex_sap_operational::sap_finance_ap_07_a_accounts_payable_aging?Target+Currency={{ _filters['accounts_payable_v2.target_currency_tcurr']| url_encode }}&Vendor+Name={{ _filters['accounts_payable_v2.name1']| url_encode }}&Company+Name={{ _filters['accounts_payable_v2.company_text_butxt']| url_encode }}"
    }
  }

  measure:  sum_past_overdue_greater_than_90days{
    label: "Sum Past Overdue >90 Days (Target Currency)"
    description: "Total overdue amount in target currency for items past due by more than 90 days (or current Aging Interval * 3)."
    type: sum
    sql: ${overdue_on_past_date_in_target_currency} ;;
    filters: [Past_Due_Interval: "e> 90 Days"]
    value_format_name: Greek_Number_Format
    hidden: no
  }

  measure:  sum_past_overdue_greater_than_90days_conv_drill{
    label: "Sum Past Overdue >90 Days (Target Currency, Drill)"
    description: "Total overdue amount in target currency for items past due by more than 90 days (or current Aging Interval * 3), with a drill link to Accounts Payable Aging dashboard."
    type: sum
    sql: ${overdue_on_past_date_in_target_currency} ;;
    filters: [Past_Due_Interval: "e> 90 Days"]
    value_format_name: Greek_Number_Format
    hidden: no
    link: {
      label: "Accounts Payable Aging"
      url: "/dashboards/cortex_sap_operational::sap_finance_ap_07_a_accounts_payable_aging?Target+Currency={{ _filters['accounts_payable_v2.target_currency_tcurr']| url_encode }}&Vendor+Name={{ _filters['accounts_payable_v2.name1']| url_encode }}&Company+Name={{ _filters['accounts_payable_v2.company_text_butxt']| url_encode }}"
    }
  }

  measure:  sum_past_overdue_not_overdue{
    label: "Sum Not Overdue (Target Currency)"
    description: "Total amount that is outstanding but not yet overdue, in target currency."
    type: sum
    sql: ${outstanding_but_not_overdue_in_target_currency};;
    value_format_name: Greek_Number_Format
    hidden: no
  }

  measure:  sum_past_overdue_not_overdue_drill{
    label: "Sum Not Overdue (Target Currency, Drill)"
    description: "Total amount that is outstanding but not yet overdue, in target currency, with a drill link to Accounts Payable Aging dashboard."
    type: sum
    sql: ${outstanding_but_not_overdue_in_target_currency};;
    value_format_name: Greek_Number_Format
    hidden: no
    link: {
      label: "Accounts Payable Aging"
      url: "/dashboards/cortex_sap_operational::sap_finance_ap_07_a_accounts_payable_aging?Target+Currency={{ _filters['accounts_payable_v2.target_currency_tcurr']| url_encode }}&Vendor+Name={{ _filters['accounts_payable_v2.name1']| url_encode }}&Company+Name={{ _filters['accounts_payable_v2.company_text_butxt']| url_encode }}"
    }
  }


  measure: total_due  {
    label: "Total Due Amount (Target Currency)"
    description: "The sum of all overdue amounts and outstanding but not overdue amounts, in target currency."
    type: sum
    sql: (${overdue_on_past_date_in_target_currency} + ${outstanding_but_not_overdue_in_target_currency});;
    value_format_name: Greek_Number_Format
    hidden: no
  }

  measure: sum_overdue_amount_conv_drill_1  {
    label: "Sum Overdue Amount (Target Currency, Drill 1)"
    description: "Sum of overdue amounts in target currency. (Purpose of multiple identical drills needs clarification for more specific description)."
    type: sum
    sql: ${overdue_amount_in_target_currency};;
    value_format_name: Greek_Number_Format
    hidden: no
  }

  measure: sum_overdue_amount_conv_drill_2 {
    label: "Sum Overdue Amount (Target Currency, Drill 2)"
    description: "Sum of overdue amounts in target currency. (Purpose of multiple identical drills needs clarification for more specific description)."
    type: sum
    sql: ${overdue_amount_in_target_currency};;
    value_format_name: Greek_Number_Format
    hidden: no
  }

  measure: sum_overdue_amount_conv_drill_3 {
    label: "Sum Overdue Amount (Target Currency, Drill 3)"
    description: "Sum of overdue amounts in target currency. (Purpose of multiple identical drills needs clarification for more specific description)."
    type: sum
    sql: ${overdue_amount_in_target_currency};;
    value_format_name: Greek_Number_Format
    hidden: no
  }

  measure: sum_past_overdue_amount_conv_drill {
    label: "Sum Past Overdue Amount (Target Currency, Generic Drill)"
    description: "Sum of past overdue amounts in target currency. (This seems like a generic version of the interval-specific drills)."
    type: sum
    sql: ${overdue_on_past_date_in_target_currency} ;;
    value_format_name: Greek_Number_Format
    hidden: no
  }


  measure: outstanding_but_not_overdue_1_conv_drill  {
    label: "Sum Outstanding Not Overdue (Target Currency, Drill)"
    description: "Sum of amounts outstanding but not yet overdue in target currency. (This might be a duplicate or specific drill context needed)."
    type: sum
    sql: ${outstanding_but_not_overdue_in_target_currency};;
    value_format_name: Greek_Number_Format
    hidden: no
  }


  dimension: overdue_on_past_date_in_source_currency {
    label: "Overdue on Past Date (Source Currency)"
    description: "The amount that was overdue as of a specific past date, in source currency. (The specific past date logic is not defined in this field itself)."
    type: number
    sql: ${TABLE}.OverdueOnPastDateInSourceCurrency ;;
  }

  dimension: overdue_on_past_date_in_target_currency {
    label: "Overdue on Past Date (Target Currency)"
    description: "The amount that was overdue as of a specific past date, in target currency, displayed as a negative value. (The specific past date logic is not defined in this field itself)."
    type: number
    sql: ${TABLE}.OverdueOnPastDateInTargetCurrency * -1 ;;
  }

  dimension: partial_payments_in_source_currency {
    label: "Partial Payments (Source Currency)"
    description: "The amount of any partial payments made, in source currency."
    type: number
    sql: ${TABLE}.PartialPaymentsInSourceCurrency ;;
  }

  dimension: partial_payments_in_target_currency {
    label: "Partial Payments (Target Currency)"
    description: "The amount of any partial payments made, in target currency."
    type: number
    sql: ${TABLE}.PartialPaymentsInTargetCurrency ;;
  }

  dimension: payment_block_key_zlspr {
    label: "Payment Block Key"
    description: "A key indicating if and why an item is blocked for payment."
    type: string
    sql: ${TABLE}.PaymentBlockKey_ZLSPR ;;
  }

  dimension: poorder_history_amount_in_local_currency_dmbtr {
    label: "PO Order History Amount (Local Currency)"
    description: "The amount from the purchase order history in local currency."
    type: number
    sql: ${TABLE}.POOrderHistory_AmountInLocalCurrency_DMBTR ;;
  }

  dimension: poorder_history_amount_in_target_currency_dmbtr {
    label: "PO Order History Amount (Target Currency)"
    description: "The amount from the purchase order history in target currency."
    type: number
    sql: ${TABLE}.POOrderHistory_AmountInTargetCurrency_DMBTR ;;
  }

  dimension_group: posting_date_budat {
    label: "Posting Date"
    description: "The date on which the document is posted in Financial Accounting."
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.PostingDate_BUDAT ;;
  }

  dimension_group: posting_date_in_the_document_budat {
    label: "Document Posting Date"
    description: "The posting date recorded in the document, used for various time-based calculations."
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.PostingDateInTheDocument_BUDAT ;;
  }

  dimension: potential_penalty_in_source_currency {
    label: "Potential Penalty (Source Currency)"
    description: "The potential penalty amount for late payment, in source currency."
    type: number
    sql: ${TABLE}.PotentialPenaltyInSourceCurrency ;;
  }

  dimension: potential_penalty_in_target_currency {
    label: "Potential Penalty (Target Currency)"
    description: "The potential penalty amount for late payment, in target currency, displayed as a negative value."
    type: number
    sql: ${TABLE}.PotentialPenaltyInTargetCurrency * -1;;
  }

  measure: sum_potential_penalty_in_target_currency {
    label: "Total Potential Penalty (Target Currency)"
    description: "The sum of all potential penalty amounts in the target currency."
    type: sum
    sql: ${potential_penalty_in_target_currency} ;;
    value_format_name: Greek_Number_Format
    hidden: no
  }



  dimension: purchase_in_source_currency {
    label: "Purchase Amount (Source Currency)"
    description: "The total purchase amount in the source currency."
    type: number
    sql: ${TABLE}.PurchaseInSourceCurrency ;;
  }

  dimension: purchase_in_target_currency {
    label: "Purchase Amount (Target Currency)"
    description: "The total purchase amount in the target currency."
    type: number
    sql: ${TABLE}.PurchaseInTargetCurrency ;;
  }

  dimension: purchasing_document_number_ebeln {
    label: "Purchasing Document Number (PO)"
    description: "The number of the purchasing document (e.g., Purchase Order)."
    type: string
    sql: ${TABLE}.PurchasingDocumentNumber_EBELN ;;
  }

  dimension: quarter_of_posting_date_in_the_document_budat {
    label: "Quarter of Posting Date"
    description: "The quarter (1-4) from the posting date of the document."
    type: number
    sql: ${TABLE}.QuarterOfPostingDateInTheDocument_BUDAT ;;
  }

  dimension: reason_code_for_payments_rstgr {
    label: "Payment Reason Code"
    description: "A code indicating the reason for a payment or payment difference."
    type: string
    sql: ${TABLE}.ReasonCodeForPayments_RSTGR ;;
  }

  dimension: supplying_country_landl {
    label: "Supplying Country"
    description: "The country from which the goods or services are supplied."
    type: string
    sql: ${TABLE}.SupplyingCountry_LANDL ;;
  }

  dimension: target_cash_discount_in_source_currency {
    label: "Target Cash Discount (Source Currency)"
    description: "The eligible cash discount amount if paid within terms, in source currency."
    type: number
    sql: ${TABLE}.TargetCashDiscountInSourceCurrency ;;
  }

  dimension: target_cash_discount_in_target_currency {
    label: "Target Cash Discount (Target Currency)"
    description: "The eligible cash discount amount if paid within terms, in target currency."
    type: number
    sql: ${TABLE}.TargetCashDiscountInTargetCurrency ;;
  }

  dimension: target_currency_tcurr {
    label: "Target Currency"
    description: "The currency to which amounts are converted for reporting."
    type: string
    sql: ${TABLE}.TargetCurrency_TCURR ;;
  }

  dimension: terms_of_payment_key_zterm {
    label: "Terms of Payment Key"
    description: "A key defining the payment terms (e.g., discount percentages, due dates)."
    type: string
    sql: ${TABLE}.TermsOfPaymentKey_ZTERM ;;
  }

  dimension: upcoming_payments_in_source_currency {
    label: "Upcoming Payments (Source Currency)"
    description: "The amount of payments that are due in the near future, in source currency."
    type: number
    sql: ${TABLE}.UpcomingPaymentsInSourceCurrency ;;
  }

  dimension: upcoming_payments_in_target_currency {
    label: "Upcoming Payments (Target Currency)"
    description: "The amount of payments that are due in the near future, in target currency, displayed as a negative value."
    type: number
    sql: ${TABLE}.UpcomingPaymentsInTargetCurrency * -1 ;;
  }


  measure: sum_upcoming_payments_in_target_currency {
    label: "Total Upcoming Payments (Target Currency)"
    description: "The sum of all upcoming payment amounts in the target currency."
    type: sum
    sql: ${upcoming_payments_in_target_currency} ;;
    value_format_name: Greek_Number_Format
    hidden: no
  }


  dimension: week_of_posting_date_in_the_document_budat {
    label: "Week of Posting Date"
    description: "The week number (1-53) from the posting date of the document."
    type: number
    sql: ${TABLE}.WeekOfPostingDateInTheDocument_BUDAT ;;
  }

  dimension: year_of_posting_date_in_the_document_budat {
    label: "Year of Posting Date"
    description: "The year from the posting date of the document."
    type: number
    sql: ${TABLE}.YearOfPostingDateInTheDocument_BUDAT ;;
  }

  measure: count {
    label: "Count of Records"
    description: "The total number of records in the accounts payable data."
    type: count
    drill_fields: []
  }
}

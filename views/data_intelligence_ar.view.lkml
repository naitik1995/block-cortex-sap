# The name of this view in Looker is "Data Intelligence Ar"
view: data_intelligence_ar {

  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: `@{GCP_PROJECT}.@{REPORTING_DATASET}.AccountingDocumentsReceivable`
    ;;
  # No primary key is defined for this view.
  #In order to join this view in an Explore,
  # define primary_key: yes on a dimension that has no repeated values.

  parameter: Aging_Interval {
    label: "Aging Interval (Days)"
    description: "Enter the number of days for each aging bucket (e.g., 10 for 1-10 days, 11-20 days, etc.)."
    type: number
    default_value: "10"
  }

  parameter: Currency_Required{
    label: "Reporting Currency"
    description: "Select the currency for displaying global (converted) monetary amounts."
    type: string
    allowed_value: {
      label: "USD"
      value: "USD"
    }
    allowed_value: {
      label: "EUR"
      value: "EUR"
    }
    allowed_value: {
      label: "CAD"
      value: "CAD"
    }
    allowed_value: {
      label: "JPY"
      value: "JPY"
    }
  }

  parameter: Day_Sales_Outstanding {
    label: "DSO Calculation Period (Months)"
    description: "Enter the number of past months to be considered for the Days Sales Outstanding (DSO) calculation."
    type: number
    default_value: "2"
  }

  parameter: Key_Date {
    label: "Key Date for Aging"
    description: "Select the reference date for calculating overdue items and aging buckets."
    type: date
  }

  # Here's what a typical dimension looks like in LookML.
# A dimension is a groupable field that can be used to filter query results.
# This dimension will be called "Accounting Document Number Belnr" in Explore.
  dimension: Past_Due_Interval{
    label: "Past Due Interval"
    description: "Categorizes overdue receivables into aging buckets (e.g., '1-10 Days', '11-20 Days') based on the Key Date and Aging Interval."
    type: string
    sql: if((date_diff(cast({% parameter Key_Date %} as Date),${TABLE}.NetDueDate, DAY)>0 and date_diff(cast({% parameter Key_Date %} as Date),${TABLE}.NetDueDate, DAY)<({% parameter Aging_Interval %}+1)),concat('1- ',({% parameter Aging_Interval %}),' Days'),
        (if((date_diff(cast({% parameter Key_Date %} as Date),${TABLE}.NetDueDate, DAY)<(({% parameter Aging_Interval %}*2)+1)),concat(({% parameter Aging_Interval %}+1),'-',({% parameter Aging_Interval %}*2),' Days'),
        (if((date_diff(cast({% parameter Key_Date %} as Date),${TABLE}.NetDueDate, DAY)<(({% parameter Aging_Interval %}*3)+1)),concat(({% parameter Aging_Interval %}*2+1),'-',({% parameter Aging_Interval %}*3),' Days'),
        (if((date_diff(cast({% parameter Key_Date %} as Date),${TABLE}.NetDueDate, DAY)>(({% parameter Aging_Interval %}*3)+1)),concat('> ',({%
parameter Aging_Interval %}*3),' Days'),'Due after Key Date' )) )) )) ) ;;
  }

  dimension: Local_Currency_Key{
    label: "Local Currency"
    description: "The original currency in which the transaction was recorded (e.g., document currency)."
    type: string
    sql: ${TABLE}.CurrencyKey_WAERS ;;
  }

  dimension: Accounts_Receivable_Global_Currency {
    label: "Accts. Receivable (Reporting Curr.)"
    description: "Accounts receivable amount converted to the selected Reporting Currency."
    type: number
    sql: Round(if(${Local_Currency_Key}={% parameter Currency_Required %}  ,${Accounts_Receivable_Local_Currency},`@{GCP_PROJECT}`.@{REPORTING_DATASET}.Currency_Conversion( ${Client_ID},${Exchange_Rate_Type} ,${Local_Currency_Key},{% parameter Currency_Required %},${Posting_date},${Accounts_Receivable_Local_Currency})),ifnull(CAST(`@{GCP_PROJECT}`.@{REPORTING_DATASET}.Currency_Decimal({% parameter Currency_Required %}) AS int),2)) ;;
  }

  dimension: Sold_to_Party_Country {
    label: "Sold-to Party Country"
    description: "Country of the sold-to party (customer)."
    type:  string
    sql: ${TABLE}.CountryKey_LAND1 ;;
  }

  dimension: Sold_to_Party_Name {
    label: "Sold-to Party Name"
    description: "Name of the sold-to party (customer)."
    type:  string
    sql: ${TABLE}.NAME1_NAME1 ;;
  }

  dimension: Sold_to_Party_City {
    label: "Sold-to Party City"
    description: "City of the sold-to party (customer)."
    type:  string
    sql: ${TABLE}.City_ORT01;;
  }

  dimension: Company_City {
    label: "Company City"
    description: "City where the company code is located."
    type:  string
    sql: ${TABLE}.Company_City;;
  }

  dimension: Company_Name {
    label: "Company Name"
    description: "Name of the company code."
    type: string
    sql: ${TABLE}.CompanyText_BUTXT ;;
  }

  dimension: Company_Country {
    label: "Company Country"
    description: "Country where the company code is located."
    type:  string
    sql: ${TABLE}.Company_Country ;;
  }

  dimension: Accounting_Document {
    label: "Accounting Document Number Belnr"
    description: "Unique identifier for the accounting document in SAP (BELNR)."
    type: string
    sql: ${TABLE}.AccountingDocumentNumber_BELNR ;;
  }

  dimension: Accounts_Receivable_Local_Currency{
    label: "Accts. Receivable (Local Curr.)"
    description: "Accounts receivable amount in the original transaction currency."
    type: number
    sql: ${TABLE}.AccountsReceivable ;;
  }

  dimension: Bad_Debt_Local_Currency {
    label: "Bad Debt (Local Curr.)"
    description: "Bad debt amount in the original transaction currency."
    type: number
    sql: ${TABLE}.BadDebt_DMBTR ;;
  }

  dimension: Bad_Debt_Global_Currency {
    label: "Bad Debt (Reporting Curr.)"
    description: "Bad debt amount converted to the selected Reporting Currency."
    type: number
    sql: Round(if(${Local_Currency_Key}={% parameter Currency_Required %}  ,${Bad_Debt_Local_Currency},`@{GCP_PROJECT}`.@{REPORTING_DATASET}.Currency_Conversion( ${Client_ID},${Exchange_Rate_Type} ,${Local_Currency_Key},{% parameter Currency_Required %},${Posting_date},${Bad_Debt_Local_Currency})),ifnull(CAST(`@{GCP_PROJECT}`.@{REPORTING_DATASET}.Currency_Decimal({% parameter Currency_Required %}) AS int),2)) ;;
  }

  dimension: Billing_Document {
    label: "Billing Document Number"
    description: "Unique identifier for the billing document (e.g., invoice number from SD module)."
    type: string
    sql: ${TABLE}.BillingDocument_VBELN ;;
  }

  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
# Looker converts dates and timestamps to the specified timeframes within the dimension group.
  dimension_group: Cash_Discount_1 {
    label: "Cash Discount Date 1"
    description: "Date by which payment must be made to receive the first cash discount percentage."
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
    sql: ${TABLE}.CashDiscountDate1 ;;
  }

  dimension_group: Cash_Discount_2 {
    label: "Cash Discount Date 2"
    description: "Date by which payment must be made to receive the second cash discount percentage."
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
    sql: ${TABLE}.CashDiscountDate2 ;;
  }

  dimension: Cleared_after_Due_date_Local_Currency{
    label: "Cleared After Due Date (Local Curr.)"
    description: "Amount cleared after the payment due date, in local currency."
    type: number
    sql: ${TABLE}.ClearedAfterDueDate ;;
  }

  dimension: Cleared_after_Due_date_Global_Currency {
    label: "Cleared After Due Date (Reporting Curr.)"
    description: "Amount cleared after the payment due date, converted to the selected Reporting Currency."
    type: number
    sql: Round(if(${Local_Currency_Key}={% parameter Currency_Required %}  ,${Cleared_after_Due_date_Local_Currency},`@{GCP_PROJECT}`.@{REPORTING_DATASET}.Currency_Conversion( ${Client_ID},${Exchange_Rate_Type} ,${Local_Currency_Key},{% parameter Currency_Required %},${Posting_date},${Cleared_after_Due_date_Local_Currency})),ifnull(CAST(`@{GCP_PROJECT}`.@{REPORTING_DATASET}.Currency_Decimal({% parameter Currency_Required %}) AS int),2)) ;;
  }

  dimension: Cleared_on_or_before_Due_date_Local_Currency {
    label: "Cleared On/Before Due Date (Local Curr.)"
    description: "Amount cleared on or before the payment due date, in local currency."
    type: number
    sql: ${TABLE}.ClearedOnOrBeforeDueDate ;;
  }

  dimension: Cleared_on_or_before_Due_date_Global_Currency { # Corrected typo from Global__Currency
    label: "Cleared On/Before Due Date (Reporting Curr.)"
    description: "Amount cleared on or before the payment due date, converted to the selected Reporting Currency."
    type: number
    sql: Round(if(${Local_Currency_Key}={% parameter Currency_Required %}  ,${Cleared_on_or_before_Due_date_Local_Currency},`@{GCP_PROJECT}`.@{REPORTING_DATASET}.Currency_Conversion( ${Client_ID},${Exchange_Rate_Type} ,${Local_Currency_Key},{% parameter Currency_Required %},${Posting_date},${Cleared_on_or_before_Due_date_Local_Currency})),ifnull(CAST(`@{GCP_PROJECT}`.@{REPORTING_DATASET}.Currency_Decimal({% parameter Currency_Required %}) AS int),2)) ;;
  }

  dimension: Client_ID {
    label: "Client ID (MANDT)"
    description: "SAP Client ID (Mandant), a self-contained unit in an SAP system."
    type: string
    sql: ${TABLE}.Client_MANDT ;;
  }

  dimension: Company_Code {
    label: "Company Code (BUKRS)"
    description: "SAP Company Code, representing an independent accounting unit."
    type: string
    sql: ${TABLE}.CompanyCode_BUKRS ;;
  }

  dimension: Sold_to_Party_Number {
    label: "Sold-to Party Number (KUNNR)"
    description: "Unique identifier for the sold-to party (customer account number)."
    type: string
    sql: ${TABLE}.CustomerNumber_KUNNR ;;
  }

  dimension_group: Document {
    label: "Document Date (BLDAT)"
    description: "Date on which the original document was issued."
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
    sql: ${TABLE}.DocumentDateInDocument_BLDAT ;;
  }

  dimension: Doubtful_Receivables_Local_Currency {
    label: "Doubtful Receivables (Local Curr.)"
    description: "Portion of accounts receivable considered unlikely to be collected, in local currency."
    type: number
    sql: ${TABLE}.DoubtfulReceivables ;;
  }

  dimension: Doubtful_Receivables_Global_Currency{
    label: "Doubtful Receivables (Reporting Curr.)"
    description: "Portion of accounts receivable considered unlikely to be collected, converted to the selected Reporting Currency."
    type: number
    sql: Round(if(${Local_Currency_Key}={% parameter Currency_Required %}  ,${Doubtful_Receivables_Local_Currency},`@{GCP_PROJECT}`.@{REPORTING_DATASET}.Currency_Conversion( ${Client_ID},${Exchange_Rate_Type} ,${Local_Currency_Key},{% parameter Currency_Required %},${Posting_date},${Doubtful_Receivables_Local_Currency})),ifnull(CAST(`@{GCP_PROJECT}`.@{REPORTING_DATASET}.Currency_Decimal({% parameter Currency_Required %}) AS int),2)) ;;
  }

  dimension: Exchange_Rate_Type {
    label: "Exchange Rate Type (KURST)"
    description: "Type of exchange rate used for currency conversion (e.g., M for average rate)."
    type: string
    sql: ${TABLE}.ExchangeRateType_KURST ;;
  }

  #dimension: Fiscal_Year {
  # type: string
  # sql: ${TABLE}.FiscalYear_GJAHR ;;
#}

  dimension: Invoice_to_which_the_Transaction_belongs {
    label: "Related Invoice Document (REBZG)"
    description: "Reference to the invoice document to which this accounting transaction belongs (e.g., for payments or credit memos)."
    type: string
    sql: ${TABLE}.InvoiceToWhichTheTransactionBelongs_REBZG ;;
  }

  dimension_group: Net_Due {
    label: "Net Due Date"
    description: "Date by which the invoice payment is due after considering payment terms."
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

  dimension: Accounting_Document_Items {
    label: "Accounting Document Line Item (BUZEI)"
    description: "Line item number within an accounting document."
    type: string
    sql: ${TABLE}.NumberOfLineItemWithinAccountingDocument_BUZEI ;;
  }

  dimension: Open_and_Not_Due_Local_Currency {
    label: "Open & Not Due (Local Curr.)"
    description: "Open receivable amount that is not yet due for payment, in local currency."
    type: number
    sql: ${TABLE}.OpenAndNotDue ;;
  }

  dimension: Open_and_Not_Due_Global_Currency{
    label: "Open & Not Due (Reporting Curr.)"
    description: "Open receivable amount that is not yet due for payment, converted to the selected Reporting Currency."
    type: number
    sql: Round(if(${Local_Currency_Key}={% parameter Currency_Required %}  ,${Open_and_Not_Due_Local_Currency},`@{GCP_PROJECT}`.@{REPORTING_DATASET}.Currency_Conversion( ${Client_ID},${Exchange_Rate_Type} ,${Local_Currency_Key},{% parameter Currency_Required %},${Posting_date},${Open_and_Not_Due_Local_Currency})),ifnull(CAST(`@{GCP_PROJECT}`.@{REPORTING_DATASET}.Currency_Decimal({% parameter Currency_Required %}) AS int),2)) ;;
  }

  dimension: Open_and_Over_Due_Local_Currency{
    label: "Open & Overdue (Local Curr.)"
    description: "Open receivable amount that is past its due date, in local currency."
    type: number
    sql: ${TABLE}.OpenAndOverDue ;;
  }

  dimension: Open_and_Over_Due_Global_Currency{
    label: "Open & Overdue (Reporting Curr.)"
    description: "Open receivable amount that is past its due date, converted to the selected Reporting Currency."
    type: number
    sql: Round(if(${Local_Currency_Key}={% parameter Currency_Required %}  ,${Open_and_Over_Due_Local_Currency},`@{GCP_PROJECT}`.@{REPORTING_DATASET}.Currency_Conversion( ${Client_ID},${Exchange_Rate_Type} ,${Local_Currency_Key},{% parameter Currency_Required %},${Posting_date},${Open_and_Over_Due_Local_Currency})),ifnull(CAST(`@{GCP_PROJECT}`.@{REPORTING_DATASET}.Currency_Decimal({% parameter Currency_Required %}) AS int),2)) ;;
  }

  dimension_group: Posting {
    label: "Posting Date (BUDAT)"
    description: "Date on which the document was posted to the General Ledger in SAP."
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

  dimension: Sales_Local_Currency {
    label: "Sales (Local Curr.)"
    description: "Sales revenue amount in the original transaction currency."
    type: number
    sql: ${TABLE}.Sales ;;
  }

  dimension: Sales_Global_Currency{
    label: "Sales (Reporting Curr.)"
    description: "Sales revenue amount converted to the selected Reporting Currency."
    type: number
    sql: Round(if(${Local_Currency_Key}={% parameter Currency_Required %}  ,${Sales_Local_Currency},`@{GCP_PROJECT}`.@{REPORTING_DATASET}.Currency_Conversion( ${Client_ID},${Exchange_Rate_Type} ,${Local_Currency_Key},{% parameter Currency_Required %},${Posting_date},${Sales_Local_Currency})),ifnull(CAST(`@{GCP_PROJECT}`.@{REPORTING_DATASET}.Currency_Decimal({% parameter Currency_Required %}) AS int),2)) ;;
  }

  dimension: Written_off_Amount_Local_Currency {
    label: "Written-off Amount (Local Curr.)"
    description: "Amount that has been written off as uncollectible, in local currency."
    type: number
    sql: ${TABLE}.WrittenOffAmount_DMBTR ;;
  }

  dimension: Written_off_Amount {
    label: "Written-off Amount (Reporting Curr.)"
    description: "Amount that has been written off as uncollectible, converted to the selected Reporting Currency."
    type: number
    sql: Round(if(${Local_Currency_Key}={% parameter Currency_Required %}  ,${Written_off_Amount_Local_Currency},`@{GCP_PROJECT}`.@{REPORTING_DATASET}.Currency_Conversion( ${Client_ID},${Exchange_Rate_Type} ,${Local_Currency_Key},{% parameter Currency_Required %},${Posting_date},${Written_off_Amount_Local_Currency})),ifnull(CAST(`@{GCP_PROJECT}`.@{REPORTING_DATASET}.Currency_Decimal({% parameter Currency_Required %}) AS int),2)) ;;
  }

  dimension: Days_in_Arrear {
    label: "Days in Arrear"
    description: "Number of days an item is past its Net Due Date, calculated against the selected Key Date. Negative values indicate days until due."
    type: number
    sql: date_diff(${Net_Due_date},cast({% parameter Key_Date %} as date),Day) ;;
  }

  # A measure is a field that uses a SQL aggregate function.
  #Here are defined sum and average
  # measures for this dimension, but you can also add measures of many different aggregates.
# Click on the type parameter to see all the options in the Quick Help panel on the right.

  measure: Sales_Total_DSO {
    label: "Sales for DSO Calculation (Hidden)"
    description: "Total sales in Reporting Currency for the period defined by the 'DSO Calculation Period' parameter. Used internally for DSO calculation."
    type: sum
    hidden: yes
    sql:
      CASE
        when CAST(${TABLE}.PostingDateInTheDocument_BUDAT as Date)<= CAST(CURRENT_DATE() as Date) and CAST(${TABLE}.PostingDateInTheDocument_BUDAT as Date)>= DATE_SUB(CAST(CURRENT_DATE() as Date),INTERVAL {% parameter Day_Sales_Outstanding %} MONTH )
      THEN ${Sales_Global_Currency}
      END;;
#sql:
    #CASE
    #when CAST(${TABLE}.PostingDateInTheDocument_BUDAT as Date)<= CAST(CURRENT_DATE() as Date) and CAST(${TABLE}.PostingDateInTheDocument_BUDAT as Date)>= DATE_SUB(${Current_Fiscal_Date_date},INTERVAL {% parameter Day_Sales_Outstanding %} MONTH )
    #THEN ${Sales_Global_Currency}
    #END;;
    }

    measure: AccountsRecievables_Total_DSO {
      label: "Accounts Receivable for DSO Calculation (Hidden)"
      description: "Total accounts receivable in Reporting Currency for the period defined by the 'DSO Calculation Period' parameter. Used internally for DSO calculation."
      type: sum
      hidden: yes
      sql:
      CASE
        when CAST(${TABLE}.PostingDateInTheDocument_BUDAT as Date)<= CAST(CURRENT_DATE() as Date) and CAST(${TABLE}.PostingDateInTheDocument_BUDAT as Date)>= DATE_SUB(CAST(CURRENT_DATE() as Date),INTERVAL {% parameter Day_Sales_Outstanding %} MONTH )
      THEN ${Accounts_Receivable_Global_Currency}
      END;;
#sql:
    #CASE
    #when CAST(${TABLE}.PostingDateInTheDocument_BUDAT as Date)<= CAST(CURRENT_DATE() as Date) and CAST(${TABLE}.PostingDateInTheDocument_BUDAT as Date)>= DATE_SUB(${Current_Fiscal_Date_date},INTERVAL {% parameter Day_Sales_Outstanding %} MONTH )
    #THEN ${Accounts_Receivable_Global_Currency}
    #END;;
      }

      dimension: PeriodCalc {
        label: "Period Calculation (Hidden)"
        description: "Internal field for concatenating fiscal year and period."
        hidden: yes
        type: string
        sql: ${TABLE}.Period ;;
      }

      dimension: Fiscal_Year {
        label: "Fiscal Year"
        description: "Fiscal year extracted from the Period field."
        type: string
        sql: split(Period,'|')[OFFSET(0)] ;;
      }

      dimension: Fiscal_Period {
        label: "Fiscal Period"
        description: "Fiscal period (e.g., month number) extracted from the Period field."
        type: string
        sql: split(Period,'|')[OFFSET(1)] ;;
      }

      dimension_group: Fiscal_Date {
        label: "Fiscal Date (Hidden)"
        description: "Date representation of the fiscal year and period, hidden by default."
        hidden: yes
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
        sql:PARSE_DATE('%m/%Y',  Concat(cast(Cast(split(Period,'|')[OFFSET(1)] as int) as string),'/',split(Period,'|')[OFFSET(0)]));;
      }

      dimension: Current_PeriodCalc {
        label: "Current Period Calculation (Hidden)"
        description: "Internal field for concatenating the current fiscal year and period."
        hidden: yes
        type: string
        sql: ${TABLE}.Current_Period ;;
      }

      dimension: Current_Fiscal_Year {
        label: "Current Fiscal Year (Hidden)"
        description: "Current fiscal year extracted from the Current Period field, hidden by default."
        hidden: yes
        type: string
        sql: split(Current_Period,'|')[OFFSET(0)] ;;
      }

      dimension: Current_Fiscal_Period {
        label: "Current Fiscal Period (Hidden)"
        description: "Current fiscal period (e.g., month number) extracted from the Current Period field, hidden by default."
        hidden: yes
        type: string
        sql: split(Current_Period,'|')[OFFSET(1)] ;;
      }

      dimension_group: Current_Fiscal_Date {
        label: "Current Fiscal Date (Hidden)"
        description: "Date representation of the current fiscal year and period, hidden by default."
        type: time
        hidden: yes
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
        sql:PARSE_DATE('%m/%Y',  Concat(cast(Cast(split(Current_Period,'|')[OFFSET(1)] as int) as string),'/',split(Current_Period,'|')[OFFSET(0)]));;
      }

      dimension: Global_Currency_Key {
        label: "Selected Reporting Currency"
        description: "The currency selected using the 'Reporting Currency' parameter for global amount display."
        type: string
        sql: {% parameter Currency_Required %} ;;
      }

      dimension: Current_Date{
        label: "Current Date"
        description: "The current system date."
        type: date
        sql: cast((CURRENT_TIMESTAMP()) as timestamp) ;;
        html: {{ rendered_value | date: "%m-%d-%Y" }} ;;
      }

      measure: Current {
        label: "Current Date (as Measure)"
        description: "The current system date, presented as a measure for visualization purposes."
        type: date
        sql: ${Current_Date} ;;
      }

      measure: Total_DSO {
        label: "Days Sales Outstanding (DSO)"
        description: "Average number of days it takes to collect payment after a sale. Calculated based on the 'DSO Calculation Period'."
        type: number
        sql: floor(if(${Sales_Total_DSO}=0,0,(${AccountsRecievables_Total_DSO}/${Sales_Total_DSO})*{% parameter Day_Sales_Outstanding %}*30)) ;;
#sql: floor(if(${Sales_Total_DSO}=0,0,(${AccountsRecievables_Total_DSO}/${Sales_Total_DSO})*date_diff(DATE_SUB(${Current_Fiscal_Date_date},INTERVAL {% parameter Day_Sales_Outstanding %} MONTH ),${Current},days))) ;;
        link: {
          label: "Day Sales Outstanding Dashboard"
          url: "/dashboards/cortex_sap_operational_o2c::day_sales_outstanding?"
        }
      }

      measure: DSO{
        label: "DSO (Calculated)"
        description: "Average number of days it takes to collect payment after a sale. Similar calculation to Total_DSO."
        type: number
        sql: floor(if(${Sales_Total_DSO}=0,0,(${AccountsRecievables_Total_DSO}/${Sales_Total_DSO})*{% parameter Day_Sales_Outstanding %}*30)) ;;
      }

      measure: Sum_of_Open_and_Over_Due_Local_Currency{ # Name suggests local, but SQL uses global. Keeping label consistent with SQL.
        label: "Total Open & Overdue (Reporting Curr.)"
        description: "Sum of all open and overdue receivables in the selected Reporting Currency."
        type: sum
        value_format_name: Greek_Number_Format
        sql: ${Open_and_Over_Due_Global_Currency};;
#     html: <a href="#drillmenu" target="_self">
#     {% if value < 0 %}
#     {% assign abs_value = value |
# times: -1.0 %}
#     {% assign pos_neg = '-' %}
#     {% else %}
#     {% assign abs_value = value |
# times: 1.0 %}
#     {% assign pos_neg = '' %}
#     {% endif %}

#     {% if abs_value >=1000000000 %}
#     {{pos_neg}}{{ abs_value |
# divided_by: 1000000000.0 | round: 2 }}B
#     {% elsif abs_value >=1000000 %}
#     {{pos_neg}}{{ abs_value |
# divided_by: 1000000.0 | round: 2 }}M
#     {% elsif abs_value >=1000 %}
#     {{pos_neg}}{{ abs_value |
# divided_by: 1000.0 | round: 2 }}K
#     {% else %}
#     {{pos_neg}}{{ abs_value }}
#     {% endif %}
#     ;;
        link: {
          label: "Overdue Receivables Dashboard"
          url: "/dashboards/cortex_sap_operational::overdue_receivables?"
        }
      }

      measure: Sum_of_Receivables{
        label: "Total Receivables Amount"
        description: "Sum of all accounts receivable in the selected Reporting Currency."
        type: sum
        value_format_name: Greek_Number_Format
        sql: ${Accounts_Receivable_Global_Currency} ;;
#     html: <a href="#drillmenu" target="_self">
#           {% if value < 0 %}
#           {% assign abs_value = value |
# times: -1.0 %}
#           {% assign pos_neg = '-' %}
#           {% else %}
#           {% assign abs_value = value |
# times: 1.0 %}
#           {% assign pos_neg = '' %}
#           {% endif %}

#           {% if abs_value >=1000000000 %}
#           {{pos_neg}}{{ abs_value |
# divided_by: 1000000000.0 | round: 2 }}B
#           {% elsif abs_value >=1000000 %}
#           {{pos_neg}}{{ abs_value |
# divided_by: 1000000.0 | round: 2 }}M
#           {% elsif abs_value >=1000 %}
#           {{pos_neg}}{{ abs_value |
# divided_by: 1000.0 | round: 2 }}K
#           {% else %}
#           {{pos_neg}}{{ abs_value }}
#           {% endif %}
#           ;;
      }

      measure: Sum_of_Sales{
        label: "Total Sales Amount"
        description: "Sum of all sales in the selected Reporting Currency."
        type: sum
        value_format_name: Greek_Number_Format
        sql: ${Sales_Global_Currency} ;;
#     html: <a href="#drillmenu" target="_self">
#           {% if value < 0 %}
#           {% assign abs_value = value |
# times: -1.0 %}
#           {% assign pos_neg = '-' %}
#           {% else %}
#           {% assign abs_value = value |
# times: 1.0 %}
#           {% assign pos_neg = '' %}
#           {% endif %}

#           {% if abs_value >=1000000000 %}
#           {{pos_neg}}{{ abs_value |
# divided_by: 1000000000.0 | round: 2 }}B
#           {% elsif abs_value >=1000000 %}
#           {{pos_neg}}{{ abs_value |
# divided_by: 1000000.0 | round: 2 }}M
#           {% elsif abs_value >=1000 %}
#           {{pos_neg}}{{ abs_value |
# divided_by: 1000.0 | round: 2 }}K
#           {% else %}
#           {{pos_neg}}{{ abs_value }}
#           {% endif %}
#           ;;
      }

      measure: Total_Receivables{
        label: "Total Receivables (Linked)"
        description: "Sum of all accounts receivable in the selected Reporting Currency, with a link to the Total Receivables dashboard."
        type: sum
        value_format_name: Greek_Number_Format
        sql: ${Accounts_Receivable_Global_Currency} ;;
#     html: <a href="#drillmenu" target="_self">
#     {% if value < 0 %}
#     {% assign abs_value = value |
# times: -1.0 %}
#     {% assign pos_neg = '-' %}
#     {% else %}
#     {% assign abs_value = value |
# times: 1.0 %}
#     {% assign pos_neg = '' %}
#     {% endif %}

#     {% if abs_value >=1000000000 %}
#     {{pos_neg}}{{ abs_value |
# divided_by: 1000000000.0 | round: 2 }}B
#     {% elsif abs_value >=1000000 %}
#     {{pos_neg}}{{ abs_value |
# divided_by: 1000000.0 | round: 2 }}M
#     {% elsif abs_value >=1000 %}
#     {{pos_neg}}{{ abs_value |
# divided_by: 1000.0 | round: 2 }}K
#     {% else %}
#     {{pos_neg}}{{ abs_value }}
#     {% endif %}
#     ;;
        link: {
          label: "Total Receivables Dashboard"
          url: "/dashboards/cortex_sap_operational::total_receivable?"
        }
      }

      measure: Total_Doubtful_Receivables{
        label: "Total Doubtful Receivables (Linked)"
        description: "Sum of doubtful receivables in the selected Reporting Currency, with a link to the Doubtful Receivables dashboard."
        type: sum
        value_format_name: Greek_Number_Format
        sql: ${Doubtful_Receivables_Global_Currency} ;;
#     html: <a href="#drillmenu" target="_self">
#     {% if value < 0 %}
#     {% assign abs_value = value |
# times: -1.0 %}
#     {% assign pos_neg = '-' %}
#     {% else %}
#     {% assign abs_value = value |
# times: 1.0 %}
#     {% assign pos_neg = '' %}
#     {% endif %}

#     {% if abs_value >=1000000000 %}
#     {{pos_neg}}{{ abs_value |
# divided_by: 1000000000.0 | round: 2 }}B
#     {% elsif abs_value >=1000000 %}
#     {{pos_neg}}{{ abs_value |
# divided_by: 1000000.0 | round: 2 }}M
#     {% elsif abs_value >=1000 %}
#     {{pos_neg}}{{ abs_value |
# divided_by: 1000.0 | round: 2 }}K
#     {% else %}
#     {{pos_neg}}{{ abs_value }}
#     {% endif %}
#     ;;
        link: {
          label: "Doubtful Receivables Dashboard"
          url: "/dashboards/cortex_sap_operational::doubtful_receivable?"
        }
      }

      measure: Sum_Doubtful_Receivables{
        label: "Total Doubtful Receivables Amount"
        description: "Sum of doubtful receivables in the selected Reporting Currency."
        type: sum
        value_format_name: Greek_Number_Format
        sql: ${Doubtful_Receivables_Global_Currency} ;;
#     html: <a href="#drillmenu" target="_self">
#           {% if value < 0 %}
#           {% assign abs_value = value |
# times: -1.0 %}
#           {% assign pos_neg = '-' %}
#           {% else %}
#           {% assign abs_value = value |
# times: 1.0 %}
#           {% assign pos_neg = '' %}
#           {% endif %}

#           {% if abs_value >=1000000000 %}
#           {{pos_neg}}{{ abs_value |
# divided_by: 1000000000.0 | round: 2 }}B
#           {% elsif abs_value >=1000000 %}
#           {{pos_neg}}{{ abs_value |
# divided_by: 1000000.0 | round: 2 }}M
#           {% elsif abs_value >=1000 %}
#           {{pos_neg}}{{ abs_value |
# divided_by: 1000.0 | round: 2 }}K
#           {% else %}
#           {{pos_neg}}{{ abs_value }}
#           {% endif %}
#           ;;
      }

      measure: OverDue_Amount{
        label: "Overdue Amount"
        description: "Total amount of receivables that are past their due date, in Reporting Currency."
        type: sum
        value_format_name: Greek_Number_Format
        sql: ${Open_and_Over_Due_Global_Currency};;
#     html: <a href="#drillmenu" target="_self">
#     {% if value < 0 %}
#     {% assign abs_value = value |
# times: -1.0 %}
#     {% assign pos_neg = '-' %}
#     {% else %}
#     {% assign abs_value = value |
# times: 1.0 %}
#     {% assign pos_neg = '' %}
#     {% endif %}

#     {% if abs_value >=1000000000 %}
#     {{pos_neg}}{{ abs_value |
# divided_by: 1000000000.0 | round: 2 }}B
#     {% elsif abs_value >=1000000 %}
#     {{pos_neg}}{{ abs_value |
# divided_by: 1000000.0 | round: 2 }}M
#     {% elsif abs_value >=1000 %}
#     {{pos_neg}}{{ abs_value |
# divided_by: 1000.0 | round: 2 }}K
#     {% else %}
#     {{pos_neg}}{{ abs_value }}
#     {% endif %};;
      }

      measure: Over_Due_Amount{ # Duplicate of OverDue_Amount
        label: "Overdue Amount (Alternative)"
        description: "Total amount of receivables that are past their due date, in Reporting Currency (alternative calculation)."
        type: sum
        value_format_name: Greek_Number_Format
        sql: ${Open_and_Over_Due_Global_Currency};;
#     html: <a href="#drillmenu" target="_self">
#     {% if value < 0 %}
#     {% assign abs_value = value |
# times: -1.0 %}
#     {% assign pos_neg = '-' %}
#     {% else %}
#     {% assign abs_value = value |
# times: 1.0 %}
#     {% assign pos_neg = '' %}
#     {% endif %}

#     {% if abs_value >=1000000000 %}
#     {{pos_neg}}{{ abs_value |
# divided_by: 1000000000.0 | round: 2 }}B
#     {% elsif abs_value >=1000000 %}
#     {{pos_neg}}{{ abs_value |
# divided_by: 1000000.0 | round: 2 }}M
#     {% elsif abs_value >=1000 %}
#     {{pos_neg}}{{ abs_value |
# divided_by: 1000.0 | round: 2 }}K
#     {% else %}
#     {{pos_neg}}{{ abs_value }}
#     {% endif %};;
      }

      measure: Due_Amount{
        label: "Due Amount (Not Overdue)"
        description: "Total receivables amount that is not yet overdue (i.e., Total Receivables - Overdue Amount), in Reporting Currency."
        type: number # This is a calculation between two sum measures, so type: number is appropriate.
        value_format_name: Greek_Number_Format
        sql: ${Total_Receivables}-${OverDue_Amount} ;;
#     html: <a href="#drillmenu" target="_self">
#     {% if value < 0 %}
#     {% assign abs_value = value |
# times: -1.0 %}
#     {% assign pos_neg = '-' %}
#     {% else %}
#     {% assign abs_value = value |
# times: 1.0 %}
#     {% assign pos_neg = '' %}
#     {% endif %}

#     {% if abs_value >=1000000000 %}
#     {{pos_neg}}{{ abs_value |
# divided_by: 1000000000.0 | round: 2 }}B
#     {% elsif abs_value >=1000000 %}
#     {{pos_neg}}{{ abs_value |
# divided_by: 1000000.0 | round: 2 }}M
#     {% elsif abs_value >=1000 %}
#     {{pos_neg}}{{ abs_value |
# divided_by: 1000.0 | round: 2 }}K
#     {% else %}
#     {{pos_neg}}{{ abs_value }}
#     {% endif %};;
      }

      measure: count {
        label: "Count of AR Documents"
        description: "Total number of Accounts Receivable documents or line items."
        type: count
        drill_fields: []
      }
    }

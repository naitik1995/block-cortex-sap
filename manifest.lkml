constant: CONNECTION_NAME {
  value: "sap-iac-test-cortex-bq-conn"
  export: override_required
}

constant: GCP_PROJECT {
  value: "sap-iac-test"
  export: override_required
}

constant: REPORTING_DATASET {
  value: "GS4_REPORTING"
  export: override_required
}

constant: CLIENT {
  value: "600"
  export: override_required
}

# application: explore_assistant {
#   label: "Explore Assistant - PSO SAP"
#   url: "https://localhost:8080/bundle.js"
#   #file: "bundle.js"
#   entitlements: {
#     core_api_methods: ["lookml_model_explore","create_sql_query","run_sql_query","run_query","create_query"]
#     navigation: yes
#     use_embeds: yes
#     use_iframes: yes
#     new_window: yes
#     new_window_external_urls: ["https://developers.generativeai.google/*"]
#     local_storage: yes
#     # external_api_urls: ["cloud function url"]
#   }
# }

application: explore_assistant {
  label: "Explore Assistant PSO SAP NEW"
  url: "https://localhost:8080/bundle.js"
  #file: "bundle.js"
  entitlements: {
    core_api_methods: ["lookml_model_explore","create_sql_query","run_sql_query","run_query","create_query"]
    navigation: yes
    use_embeds: yes
    use_iframes: yes
    new_window: yes
    new_window_external_urls: ["https://developers.generativeai.google/*"]
    local_storage: yes
    # external_api_urls: ["cloud function url"]
  }
}

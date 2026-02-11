####################################################################
# BIOS 731: Advanced Statistical Computing
#
# This file aggregates results for a particular simulation scenario
####################################################################

# Calculate bias, coverage
aggregate_results = function(results_df){

  aggregate_df <- results_df %>%
    mutate(coverage = ifelse(true_beta >= ci_lower & true_beta <= ci_upper, 1, 0)) %>%
    group_by(scenario) %>%
    summarise(mean = mean(estimate, na.rm = T),
              bias = mean(estimate, na.rm = T) - first(true_beta),
              variance_bias = var(estimate, na.rm = T),
              coverage_rate = mean(coverage, na.rm = T),
              se_bias = sqrt(variance_bias/n()),
              se_coverage = sqrt(mean(coverage, na.rm = T) * (1 - mean(coverage, na.rm = T))/n())
              )

}

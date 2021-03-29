#!/bin/bash

# <xbar.var>string(XBAR_TEST_EXPLICIT_VAR): An explicit variable</xbar.var>
# <xbar.var>string(XBAR_TEST_DEFAULT_VAR="default-value"): A default variable (from metadata)</xbar.var>
# <xbar.var>string(XBAR_TEST_SET_IN_VARS_JSON): A variable set in the JSON</xbar.var>

echo "XBAR_TEST_EXPLICIT_VAR=${XBAR_TEST_EXPLICIT_VAR}"
echo "XBAR_TEST_SET_IN_VARS_JSON=${XBAR_TEST_SET_IN_VARS_JSON}"
echo "XBAR_TEST_DEFAULT_VAR=${XBAR_TEST_DEFAULT_VAR}"

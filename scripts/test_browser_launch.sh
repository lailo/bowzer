#!/bin/bash

# Test script for browser URL launching
# Each test opens a unique URL to verify it worked

TEST_URL_BASE="https://httpbin.org/anything"

echo "=== Browser Launch Tests ==="
echo ""

# Test Safari
echo "Test 1: Safari with bundle ID"
open -b "com.apple.Safari" "${TEST_URL_BASE}/safari-test-$(date +%s)" 2>&1
if [ $? -eq 0 ]; then
    echo "  ✓ Safari command succeeded"
else
    echo "  ✗ Safari command failed"
fi
sleep 1

# Test Chrome
echo ""
echo "Test 2: Chrome with bundle ID"
open -b "com.google.Chrome" "${TEST_URL_BASE}/chrome-test-$(date +%s)" 2>&1
if [ $? -eq 0 ]; then
    echo "  ✓ Chrome command succeeded"
else
    echo "  ✗ Chrome command failed"
fi
sleep 1

# Test Brave
echo ""
echo "Test 3: Brave with bundle ID"
open -b "com.brave.Browser" "${TEST_URL_BASE}/brave-test-$(date +%s)" 2>&1
if [ $? -eq 0 ]; then
    echo "  ✓ Brave command succeeded"
else
    echo "  ✗ Brave command failed"
fi
sleep 1

echo ""
echo "=== Tests Complete ==="
echo "Check each browser to verify the URL was opened."
echo "Each should show a page with the test name (safari-test, chrome-test, brave-test)"

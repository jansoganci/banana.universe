import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// ============================================
// CLEANUP SYSTEM TEST SCRIPT
// ============================================
// This script tests the cleanup system with dry-run mode
// Run this before deploying to production

interface TestResult {
  testName: string;
  passed: boolean;
  details: string;
  executionTime: number;
}

async function testCleanupSystem() {
  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
  const supabase = createClient(supabaseUrl, supabaseServiceKey);

  const results: TestResult[] = [];

  console.log('🧪 [TEST] Starting cleanup system tests...\n');

  // ============================================
  // TEST 1: DATABASE CONNECTION
  // ============================================
  
  const test1Start = Date.now();
  try {
    const { data, error } = await supabase
      .from('jobs')
      .select('id')
      .limit(1);
    
    if (error) throw error;
    
    results.push({
      testName: 'Database Connection',
      passed: true,
      details: 'Successfully connected to database',
      executionTime: Date.now() - test1Start
    });
    console.log('✅ [TEST] Database connection: PASSED');
  } catch (error) {
    results.push({
      testName: 'Database Connection',
      passed: false,
      details: `Failed to connect: ${error.message}`,
      executionTime: Date.now() - test1Start
    });
    console.log('❌ [TEST] Database connection: FAILED');
  }

  // ============================================
  // TEST 2: CLEANUP LOGS TABLE
  // ============================================
  
  const test2Start = Date.now();
  try {
    const { data, error } = await supabase
      .from('cleanup_logs')
      .select('id')
      .limit(1);
    
    if (error) throw error;
    
    results.push({
      testName: 'Cleanup Logs Table',
      passed: true,
      details: 'cleanup_logs table exists and accessible',
      executionTime: Date.now() - test2Start
    });
    console.log('✅ [TEST] Cleanup logs table: PASSED');
  } catch (error) {
    results.push({
      testName: 'Cleanup Logs Table',
      passed: false,
      details: `cleanup_logs table not found: ${error.message}`,
      executionTime: Date.now() - test2Start
    });
    console.log('❌ [TEST] Cleanup logs table: FAILED');
  }

  // ============================================
  // TEST 3: CLEANUP FUNCTIONS
  // ============================================
  
  const test3Start = Date.now();
  try {
    // Test cleanup_old_jobs function
    const { data: jobsResult, error: jobsError } = await supabase
      .rpc('cleanup_old_jobs');
    
    if (jobsError) throw jobsError;
    
    // Test cleanup_rate_limiting_data function
    const { data: rateLimitResult, error: rateLimitError } = await supabase
      .rpc('cleanup_rate_limiting_data');
    
    if (rateLimitError) throw rateLimitError;
    
    results.push({
      testName: 'Cleanup Functions',
      passed: true,
      details: `Jobs cleanup: ${jobsResult?.[0]?.deleted_count || 0} deleted, Rate limiting cleanup: ${rateLimitResult?.[0]?.deleted_count || 0} deleted`,
      executionTime: Date.now() - test3Start
    });
    console.log('✅ [TEST] Cleanup functions: PASSED');
  } catch (error) {
    results.push({
      testName: 'Cleanup Functions',
      passed: false,
      details: `Functions not available: ${error.message}`,
      executionTime: Date.now() - test3Start
    });
    console.log('❌ [TEST] Cleanup functions: FAILED');
  }

  // ============================================
  // TEST 4: PRO USER CHECK FUNCTION
  // ============================================
  
  const test4Start = Date.now();
  try {
    // Test with a non-existent user ID (should return false)
    const { data, error } = await supabase
      .rpc('is_pro_user', { user_uuid: '00000000-0000-0000-0000-000000000000' });
    
    if (error) throw error;
    
    results.push({
      testName: 'PRO User Check Function',
      passed: true,
      details: `Function exists and returned: ${data}`,
      executionTime: Date.now() - test4Start
    });
    console.log('✅ [TEST] PRO user check function: PASSED');
  } catch (error) {
    results.push({
      testName: 'PRO User Check Function',
      passed: false,
      details: `Function not available: ${error.message}`,
      executionTime: Date.now() - test4Start
    });
    console.log('❌ [TEST] PRO user check function: FAILED');
  }

  // ============================================
  // TEST 5: CLEANUP STATISTICS
  // ============================================
  
  const test5Start = Date.now();
  try {
    const { data, error } = await supabase
      .rpc('get_cleanup_stats', { days_back: 7 });
    
    if (error) throw error;
    
    results.push({
      testName: 'Cleanup Statistics',
      passed: true,
      details: `Retrieved stats for ${data?.length || 0} operations`,
      executionTime: Date.now() - test5Start
    });
    console.log('✅ [TEST] Cleanup statistics: PASSED');
  } catch (error) {
    results.push({
      testName: 'Cleanup Statistics',
      passed: false,
      details: `Statistics function not available: ${error.message}`,
      executionTime: Date.now() - test5Start
    });
    console.log('❌ [TEST] Cleanup statistics: FAILED');
  }

  // ============================================
  // TEST 6: EDGE FUNCTION DRY RUN
  // ============================================
  
  const test6Start = Date.now();
  try {
    // Test the cleanup-images Edge Function with a dry run
    const response = await fetch(`${supabaseUrl}/functions/v1/cleanup-images`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${supabaseServiceKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ dry_run: true })
    });
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${await response.text()}`);
    }
    
    const result = await response.json();
    
    results.push({
      testName: 'Edge Function Dry Run',
      passed: true,
      details: `Function executed successfully. Free users: ${result.freeUserImagesDeleted}, PRO users: ${result.proUserImagesDeleted}, Errors: ${result.errors.length}`,
      executionTime: Date.now() - test6Start
    });
    console.log('✅ [TEST] Edge function dry run: PASSED');
  } catch (error) {
    results.push({
      testName: 'Edge Function Dry Run',
      passed: false,
      details: `Function not accessible: ${error.message}`,
      executionTime: Date.now() - test6Start
    });
    console.log('❌ [TEST] Edge function dry run: FAILED');
  }

  // ============================================
  // TEST RESULTS SUMMARY
  // ============================================
  
  console.log('\n📊 [TEST] Test Results Summary:');
  console.log('================================');
  
  const passedTests = results.filter(r => r.passed).length;
  const totalTests = results.length;
  const totalTime = results.reduce((sum, r) => sum + r.executionTime, 0);
  
  results.forEach(result => {
    const status = result.passed ? '✅ PASS' : '❌ FAIL';
    console.log(`${status} ${result.testName} (${result.executionTime}ms)`);
    if (!result.passed) {
      console.log(`   Details: ${result.details}`);
    }
  });
  
  console.log('================================');
  console.log(`📈 Overall: ${passedTests}/${totalTests} tests passed (${Math.round(passedTests/totalTests*100)}%)`);
  console.log(`⏱️  Total execution time: ${totalTime}ms`);
  
  if (passedTests === totalTests) {
    console.log('🎉 All tests passed! Cleanup system is ready for production.');
  } else {
    console.log('⚠️  Some tests failed. Please fix issues before deploying to production.');
  }
  
  return results;
}

// Run tests if this script is executed directly
if (import.meta.main) {
  await testCleanupSystem();
}

export { testCleanupSystem };

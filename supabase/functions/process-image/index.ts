import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// ============================================
// STEVE JOBS STYLE: SIMPLE, FAST, RELIABLE
// ============================================

interface ProcessImageRequest {
  image_url: string;
  prompt: string;
  device_id?: string; // For anonymous users
  user_type?: 'authenticated' | 'anonymous';
}

interface ProcessImageResponse {
  success: boolean;
  processed_image_url?: string;
  job_id?: string; // Database job ID for tracking
  error?: string;
  rate_limit_info?: {
    requests_today: number;
    limit: number;
    reset_time: string;
  };
}

Deno.serve(async (req: Request) => {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, device-id',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
  };

  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    console.log('🍎 [STEVE-JOBS] Process Image Request Started');
    
    // ============================================
    // 1. PARSE REQUEST
    // ============================================
    
    const requestData: ProcessImageRequest = await req.json();
    const { image_url, prompt, device_id } = requestData;
    
    if (!image_url || !prompt) {
      return new Response(
        JSON.stringify({ success: false, error: 'Missing image_url or prompt' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }
    
    console.log('🔍 [STEVE-JOBS] Processing request:', { image_url, prompt: prompt.substring(0, 50) + '...' });
    
    // ============================================
    // 2. INITIALIZE SUPABASE CLIENT
    // ============================================
    
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: { autoRefreshToken: false, persistSession: false }
    });
    
    // ============================================
    // 3. AUTHENTICATION & USER IDENTIFICATION
    // ============================================
    
    let userIdentifier: string;
    let userType: 'authenticated' | 'anonymous';
    let dailyLimit: number;
    
    // Check for JWT token (authenticated user)
    const authHeader = req.headers.get('authorization');
    if (authHeader && authHeader.startsWith('Bearer ')) {
      try {
        const token = authHeader.split(' ')[1];
        const { data: { user }, error } = await supabase.auth.getUser(token);
        
        if (error || !user) {
          throw new Error('Invalid token');
        }
        
        userIdentifier = user.id;
        userType = 'authenticated';
        dailyLimit = 100; // Paid users get 100 requests/day
        
        console.log('✅ [STEVE-JOBS] Authenticated user:', user.id);
      } catch (error) {
        // If JWT fails, check for device_id (anonymous user)
        if (!device_id) {
          return new Response(
            JSON.stringify({ success: false, error: 'Authentication required' }),
            { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
          );
        }
        
        userIdentifier = device_id;
        userType = 'anonymous';
        dailyLimit = 5; // Free users get 5 requests/day
        
        console.log('🔓 [STEVE-JOBS] Anonymous user:', device_id);
      }
    } else {
      // No auth header, check for device_id (anonymous user)
      if (!device_id) {
        return new Response(
          JSON.stringify({ success: false, error: 'Authentication or device_id required' }),
          { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
      }
      
      userIdentifier = device_id;
      userType = 'anonymous';
      dailyLimit = 5; // Free users get 5 requests/day
      
      console.log('🔓 [STEVE-JOBS] Anonymous user:', device_id);
    }
    
    // ============================================
    // 4. RATE LIMITING CHECK
    // ============================================
    
    const today = new Date().toISOString().split('T')[0]; // YYYY-MM-DD
    const tomorrow = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString().split('T')[0];
    
    // Get today's request count
    const { data: rateLimitData, error: rateLimitError } = await supabase
      .from('daily_request_counts')
      .select('request_count')
      .eq('user_identifier', userIdentifier)
      .eq('request_date', today)
      .single();
    
    const requestsToday = rateLimitData?.request_count || 0;
    
    if (requestsToday >= dailyLimit) {
      console.log(`❌ [STEVE-JOBS] Rate limit exceeded for ${userType} user: ${requestsToday}/${dailyLimit}`);
      
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Daily rate limit exceeded',
          rate_limit_info: {
            requests_today: requestsToday,
            limit: dailyLimit,
            reset_time: tomorrow + 'T00:00:00Z'
          }
        }),
        { status: 429, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }
    
    console.log(`✅ [STEVE-JOBS] Rate limit OK: ${requestsToday + 1}/${dailyLimit} for ${userType} user`);
    
    // ============================================
    // 5. UPDATE RATE LIMIT COUNTER
    // ============================================
    
    await supabase
      .from('daily_request_counts')
      .upsert({
        user_identifier: userIdentifier,
        user_type: userType,
        request_date: today,
        request_count: requestsToday + 1,
        updated_at: new Date().toISOString()
      });
    
    // ============================================
    // 6. GENERATE JOB ID & TRACK START TIME
    // ============================================
    
    // Generate unique job ID for database tracking
    const jobId = crypto.randomUUID();
    const processingStartTime = Date.now();
    
    console.log(`📋 [STEVE-JOBS] Job ID: ${jobId}`);
    
    // ============================================
    // 7. CALL FAL.AI DIRECTLY (STEVE JOBS STYLE!)
    // ============================================
    
    console.log('🤖 [STEVE-JOBS] Calling Fal.AI directly...');
    
    const falAIKey = Deno.env.get('FAL_AI_API_KEY');
    if (!falAIKey) {
      throw new Error('FAL_AI_API_KEY not configured');
    }
    
    // Prepare Fal.AI request
    const falAIRequest = {
      prompt: prompt,
      image_urls: [image_url],
      num_images: 1,
      output_format: 'jpeg'
    };
    
    console.log('📤 [STEVE-JOBS] Fal.AI request:', JSON.stringify(falAIRequest, null, 2));
    
    // Call Fal.AI directly (synchronous)
    const falResponse = await fetch('https://fal.run/fal-ai/nano-banana/edit', {
      method: 'POST',
      headers: {
        'Authorization': `Key ${falAIKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(falAIRequest),
    });
    
    if (!falResponse.ok) {
      const errorText = await falResponse.text();
      console.error('❌ [STEVE-JOBS] Fal.AI error:', falResponse.status, errorText);
      throw new Error(`Fal.AI processing failed: ${falResponse.status}`);
    }
    
    const falResult = await falResponse.json();
    console.log('✅ [STEVE-JOBS] Fal.AI processing completed');
    
    if (!falResult.images || falResult.images.length === 0) {
      throw new Error('No processed images returned from Fal.AI');
    }
    
    const processedImageUrl = falResult.images[0].url;
    
    // ============================================
    // 8. SAVE PROCESSED IMAGE TO STORAGE
    // ============================================
    
    console.log('💾 [STEVE-JOBS] Saving processed image to storage...');
    
    // Download the processed image
    const imageResponse = await fetch(processedImageUrl);
    if (!imageResponse.ok) {
      throw new Error('Failed to download processed image');
    }
    
    const imageBuffer = await imageResponse.arrayBuffer();
    const timestamp = Date.now();
    const storagePath = `processed/${userIdentifier}/${timestamp}-result.jpg`;
    
    // Upload to Supabase Storage
    const { error: uploadError } = await supabase.storage
      .from('noname-banana-images-prod')
      .upload(storagePath, imageBuffer, {
        contentType: 'image/jpeg',
        upsert: true
      });
    
    if (uploadError) {
      throw new Error(`Failed to save processed image: ${uploadError.message}`);
    }
    
    // Generate signed URL for the processed image
    const { data: urlData, error: urlError } = await supabase.storage
      .from('noname-banana-images-prod')
      .createSignedUrl(storagePath, 604800); // 7 days
    
    if (urlError || !urlData?.signedUrl) {
      throw new Error(`Failed to generate signed URL: ${urlError?.message || 'No URL returned'}`);
    }
    
    console.log('✅ [STEVE-JOBS] Processed image saved:', urlData.signedUrl);
    
    // ============================================
    // 9. PERSIST JOB TO DATABASE
    // ============================================
    
    const processingEndTime = Date.now();
    const processingTimeSeconds = Math.floor((processingEndTime - processingStartTime) / 1000);
    const now = new Date().toISOString();
    
    console.log('💾 [STEVE-JOBS] Saving job to database...');
    console.log('🔍 [STEVE-JOBS] User identifier:', userIdentifier);
    console.log('🔍 [STEVE-JOBS] User type:', userType);
    
    // Test database connection and RLS policies
    console.log('🔍 [STEVE-JOBS] Testing database connection...');
    try {
      const { data: testData, error: testError } = await supabase
        .from('jobs')
        .select('id')
        .limit(1);
      
      if (testError) {
        console.error('❌ [STEVE-JOBS] Database connection test failed:', testError);
      } else {
        console.log('✅ [STEVE-JOBS] Database connection test passed');
      }
    } catch (testException) {
      console.error('❌ [STEVE-JOBS] Database connection test exception:', testException);
    }
    
    try {
      const jobRecord = {
        id: jobId,
        user_id: userType === 'authenticated' ? userIdentifier : null,
        device_id: userType === 'anonymous' ? userIdentifier : null,
        model: 'nano-banana-edit',
        status: 'completed',
        input_url: image_url,
        output_url: storagePath,
        options: {
          prompt: prompt,
          timestamp: timestamp,
          fal_image_url: processedImageUrl,
          processing_time_seconds: processingTimeSeconds
        },
        created_at: now,
        completed_at: now,
        updated_at: now,
        processing_time_seconds: processingTimeSeconds
      };
      
      console.log('🔍 [STEVE-JOBS] Job record to insert:', JSON.stringify(jobRecord, null, 2));
      
      const { data: insertData, error: dbError } = await supabase
        .from('jobs')
        .insert(jobRecord)
        .select();
      
      if (dbError) {
        // Log error but don't fail the request - image is already in storage
        console.error('❌ [STEVE-JOBS] Database insert failed:', dbError);
        console.error('❌ [STEVE-JOBS] Database error details:', JSON.stringify(dbError, null, 2));
        console.error('❌ [STEVE-JOBS] Error code:', dbError.code);
        console.error('❌ [STEVE-JOBS] Error message:', dbError.message);
        console.error('❌ [STEVE-JOBS] Error hint:', dbError.hint);
        console.error('⚠️ [STEVE-JOBS] Image saved but not in database. Job ID:', jobId);
        // Consider adding to a retry queue here in production
      } else {
        console.log('✅ [STEVE-JOBS] Job saved to database successfully:', jobId);
        console.log('✅ [STEVE-JOBS] Insert data returned:', JSON.stringify(insertData, null, 2));
        console.log('✅ [STEVE-JOBS] Job record inserted with user_id:', jobRecord.user_id, 'device_id:', jobRecord.device_id);
      }
    } catch (dbException: any) {
      // Catch any unexpected errors during DB insert
      console.error('❌ [STEVE-JOBS] Database exception:', dbException);
      console.error('❌ [STEVE-JOBS] Exception details:', JSON.stringify(dbException, null, 2));
      console.error('⚠️ [STEVE-JOBS] Continuing despite DB error. Job ID:', jobId);
    }
    
    // ============================================
    // 10. RETURN SUCCESS RESPONSE
    // ============================================
    
    const response: ProcessImageResponse = {
      success: true,
      processed_image_url: urlData.signedUrl,
      job_id: jobId,
      rate_limit_info: {
        requests_today: requestsToday + 1,
        limit: dailyLimit,
        reset_time: tomorrow + 'T00:00:00Z'
      }
    };
    
    console.log('🎉 [STEVE-JOBS] Process completed successfully!');
    
    return new Response(
      JSON.stringify(response),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
    
  } catch (error: any) {
    console.error('❌ [STEVE-JOBS] Edge function error:', error);
    
    const response: ProcessImageResponse = {
      success: false,
      error: error.message || 'Internal server error'
    };
    
    return new Response(
      JSON.stringify(response),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});

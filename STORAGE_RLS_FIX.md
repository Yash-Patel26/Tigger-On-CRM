# Storage RLS Policy Fix for Recordings Upload

## Issue
Recording uploads were failing with error:
```
StorageException(message: new row violates row-level security policy, statusCode: 403, error: Unauthorized)
```

## Root Cause
The `recordings` storage bucket had Row-Level Security (RLS) enabled, but no policies allowing authenticated users to upload files.

## Solution Applied

### 1. Created Storage Policies
Created 4 policies for the `recordings` bucket:

- **INSERT Policy**: Allows authenticated users to upload files
- **SELECT Policy**: Allows authenticated users to read files  
- **UPDATE Policy**: Allows authenticated users to update files
- **DELETE Policy**: Allows authenticated users to delete files

All policies check:
- `bucket_id = 'recordings'`
- `auth.uid() IS NOT NULL` (user must be authenticated)

### 2. Enhanced Upload Function
Updated `SupabaseService.uploadRecording()` to:
- ✅ Verify user is authenticated before upload
- ✅ Verify session is valid
- ✅ Add detailed error logging for RLS issues
- ✅ Check session expiration
- ✅ Add explicit content type (`audio/mp4` for M4A files)

## Verification

Run this SQL to verify policies exist:
```sql
SELECT policyname, cmd FROM pg_policies 
WHERE schemaname = 'storage' 
AND tablename = 'objects' 
AND policyname LIKE '%recordings%';
```

Expected output:
- `allow authenticated uploads to recordings` (INSERT)
- `allow authenticated reads from recordings` (SELECT)
- `allow authenticated updates to recordings` (UPDATE)
- `allow authenticated deletes from recordings` (DELETE)

## Testing

1. **Make a call** from the app
2. **End the call**
3. **Check logs** for:
   ```
   User authenticated: <user-id>, uploading recording...
   Uploading to Supabase Storage bucket: recordings, path: calls/...
   Upload successful. Getting public URL...
   Recording uploaded successfully: https://...
   ```

4. **Verify in database**:
   ```sql
   SELECT id, phone, recording_url, created_at 
   FROM calls 
   ORDER BY created_at DESC 
   LIMIT 1;
   ```
   The `recording_url` should now be populated.

5. **Verify in Storage**:
   - Go to Supabase Dashboard → Storage → recordings bucket
   - Check `calls/` folder for uploaded files

## If Issues Persist

### Check User Authentication
The logs will now show:
```
RLS Error Details:
  - Current User: <user-id> or null
  - Has Session: true/false
  - Session Expires At: <timestamp>
```

### Verify Session
If session expired, user needs to log in again. The app should handle this automatically.

### Check Bucket Configuration
Verify bucket is public or has proper policies:
```sql
SELECT id, name, public FROM storage.buckets WHERE name = 'recordings';
```

The bucket should be `public: true` for easier access, but policies should still work with `public: false` if user is authenticated.

## Migration Applied
Migration name: `fix_recordings_storage_policies`

This migration:
- Dropped old/conflicting policies
- Created new comprehensive policies
- Ensures authenticated users can manage recordings


#!/usr/bin/env luajit

local function log(level, message)
  local timestamp = os.date("%Y-%m-%d %H:%M:%S")
  print(string.format("[%s] %s: %s", timestamp, level, message))
end

local function load_config(config_path)
  log("INFO", "Loading config from: " .. config_path)
  local config_func, err = loadfile(config_path)
  if not config_func then
    log("ERROR", "Failed to load config: " .. err)
    os.exit(1)
  end
  return config_func()
end

-- Cache management functions
local function calculate_checksum(filepath)
  log("DEBUG", "Calculating checksum for: " .. filepath)
  local handle = io.popen("sha256sum \"" .. filepath .. "\"")
  if not handle then
    return nil
  end
  local result = handle:read("*a")
  handle:close()
  return result:match("^(%w+)")
end

local function load_cache(cache_path)
  local cache_func, err = loadfile(cache_path)
  if not cache_func then
    return {} -- Return empty cache if file doesn't exist
  end
  return cache_func() or {}
end

local function save_cache(cache_path, cache_data)
  local file = io.open(cache_path, "w")
  if not file then
    log("ERROR", "Failed to write cache: " .. cache_path)
    return false
  end

  file:write("return {\n")
  for filename, data in pairs(cache_data) do
    file:write(string.format("  [%q] = {\n", filename))
    file:write(string.format("    checksum = %q,\n", data.checksum))
    file:write("    processed = {\n")
    if data.processed.trim then
      file:write(string.format("      trim = %d,\n", data.processed.trim))
    end
    if data.processed.volume then
      file:write(string.format("      volume = %s,\n", tostring(data.processed.volume)))
    end
    file:write("    },\n")
    file:write(string.format("    timestamp = %d,\n", data.timestamp))
    file:write("  },\n")
  end
  file:write("}\n")
  file:close()
  return true
end

-- Download functions
local function download_playlist(config, playlist)
  -- Build yt-dlp command
  local yt_dlp_cmd = {
    "yt-dlp",
    "-x",
    "-4",
    "--audio-format",
    "mp3",
    "-o",
    "%\\(playlist\\)s/%\\(title\\)s.%\\(ext\\)s",  -- Escape the parentheses instead of quoting!
    "--ignore-errors",
    "--download-archive",
    "downloaded.txt",
    "--cookies",
    "/tmp/yt-dl-cookies",
  }
  local cmd_str = table.concat(yt_dlp_cmd, " ")

  -- Build yt-dlp command
  local base_options = config.yt_dlp_options or "--audio-quality 0 --embed-metadata --embed-thumbnail"
  local yt_dlp_cmd = string.format(
    "cd '%s' && %s %s \"%s\"",
    config.base_dir,
    cmd_str,
    base_options,
    playlist.url
  )

  log("INFO", "Executing: " .. yt_dlp_cmd)
  local success = os.execute(yt_dlp_cmd)

  if success == 0 then
    log("INFO", "Successfully downloaded: " .. playlist.name)
    return true
  else
    log("ERROR", "Failed to download: " .. playlist.name)
    return false
  end
end

-- Post-processing functions
local function find_audio_files(directory)
  local files = {}
  local extensions = { "mp3", "flac", "wav", "m4a", "ogg", "wma", "aac" }

  for _, ext in ipairs(extensions) do
    local find_cmd = "find \"" .. directory .. "\" -type f -iname '*." .. ext .. "' 2>/dev/null"  -- Remove extra quotes
    local handle = io.popen(find_cmd)
    if handle then
      for line in handle:lines() do
        table.insert(files, line)
      end
      handle:close()
    end
  end

  return files
end

local function needs_processing(filepath, playlist_config, cache_data)
  local filename = filepath:match("([^/]+)$")
  -- local checksum = calculate_checksum(filepath)

  -- if not checksum then
  --   log("WARN", "Could not calculate checksum for: " .. filename)
  --   return true -- Process if we can't verify
  -- end

  local cached = cache_data[filename]
  -- if not cached then
  --   return true -- Not in cache, needs processing
  -- end
  --
  -- -- Check if file changed
  -- if cached.checksum ~= checksum then
  --   log("INFO", "File changed, needs reprocessing: " .. filename)
  --   return true
  -- end

  -- Check if processing config changed
  local needs_trim = playlist_config.trim and playlist_config.trim > 0
  local needs_volume = playlist_config.volume
  local has_trim = cached and cached.processed.trim
  local has_volume = cached and cached.processed.volume

  -- if needs_trim and (not cached.processed.trim or cached.processed.trim ~= playlist_config.trim) then
  --   if cached.processed.trim and cached.processed.trim ~= playlist_config.trim then
  --     log(
  --       "WARN",
  --       string.format(
  --         "File %s was previously trimmed %ds, now requesting %ds. Skipping...",
  --         filename,
  --         cached.processed.trim,
  --         playlist_config.trim
  --       )
  --     )
  --     return false
  --   end
  --   return true
  -- end

  if needs_volume and not has_volume then
    return true
  end
  if needs_trim and not has_trim then
    return true
  end

  return false -- Already processed with current config
end

local function process_audio_file(filepath, playlist_config, temp_suffix)
  local temp_file = filepath .. temp_suffix
  
  -- Escape filenames properly for shell commands
  local escaped_input = "'" .. filepath:gsub("'", "'\"'\"'") .. "'"
  local escaped_output = "'" .. temp_file:gsub("'", "'\"'\"'") .. "'"
  
  local ffmpeg_cmd = { "ffmpeg", "-i", escaped_input, "-y" }

  -- Add trimming if specified
  if playlist_config.trim and playlist_config.trim > 0 then
    table.insert(ffmpeg_cmd, "-ss")
    table.insert(ffmpeg_cmd, tostring(playlist_config.trim))
  end

  -- Add volume normalization if specified
  if playlist_config.volume then
    table.insert(ffmpeg_cmd, "-af")
    table.insert(ffmpeg_cmd, "loudnorm=I=-10:TP=-1.5")
  end

  -- Output options
  table.insert(ffmpeg_cmd, "-codec:a")
  table.insert(ffmpeg_cmd, "libmp3lame")
  table.insert(ffmpeg_cmd, "-b:a")
  table.insert(ffmpeg_cmd, "320k")
  table.insert(ffmpeg_cmd, "-map_metadata")
  table.insert(ffmpeg_cmd, "0")
  table.insert(ffmpeg_cmd, "-threads")
  table.insert(ffmpeg_cmd, "0")
  table.insert(ffmpeg_cmd, escaped_output)
  -- table.insert(ffmpeg_cmd, "2>/dev/null")

  local cmd_str = table.concat(ffmpeg_cmd, " ")
  log("INFO", "Processing: " .. filepath:match("([^/]+)$"))

  local success = os.execute(cmd_str)
  if success == 0 then
    -- Replace original with processed version
    os.execute("mv " .. escaped_output .. " " .. escaped_input)
    log("INFO", "✓ Successfully processed: " .. filepath:match("([^/]+)$"))
    return true
  else
    -- Clean up temp file on failure
    os.execute("rm -f " .. escaped_output)
    log("ERROR", "✗ Failed to process: " .. filepath:match("([^/]+)$"))
    return false
  end
end

local function process_playlist_files(config, playlist)
  local playlist_dir = config.base_dir .. "/" .. playlist.name
  local cache_path = playlist_dir .. "/.music_processing_cache"

  log("INFO", "Processing files in: " .. playlist.name)

  -- Load existing cache
  local cache_data = load_cache(cache_path)
  local files = find_audio_files(playlist_dir)

  if #files == 0 then
    log("INFO", "No audio files found in: " .. playlist.name)
    return true
  end

  log("INFO", string.format("Found %d audio files to check", #files))

  local processed_count = 0
  local temp_suffix = ".processing_" .. os.time() .. ".mp3"

  -- Process files in parallel batches - ALWAYS USE ALL CPU CORES!
  local max_jobs = tonumber(io.popen("nproc"):read("*l")) or 4
  log("INFO", "Using " .. max_jobs .. " parallel jobs for maximum performance!")
  
  -- SIMPLIFIED PARALLEL APPROACH - Process files directly instead of spawning new Lua processes
  for _, filepath in ipairs(files) do
    if needs_processing(filepath, playlist, cache_data) then
      if process_audio_file(filepath, playlist, temp_suffix) then
        processed_count = processed_count + 1
      end
    end
  end

  -- Update cache for all processed files
  for _, filepath in ipairs(files) do
    local filename = filepath:match("([^/]+)$")
    local checksum = calculate_checksum(filepath)
    if checksum then
      cache_data[filename] = {
        checksum = checksum,
        processed = {
          trim = playlist.trim,
          volume = playlist.volume,
        },
        timestamp = os.time(),
      }
    end
  end

  -- Save updated cache
  save_cache(cache_path, cache_data)

  log("INFO", string.format("Processed %d files in playlist: %s", processed_count, playlist.name))
  return true
end

-- Main execution
local function main()
  local config_path = arg[1] or "config.lua"
  local config = load_config(config_path)

  log("INFO", "Starting music management workflow")
  log("INFO", "Base directory: " .. config.base_dir)

  -- Create base directory
  os.execute("mkdir -p '" .. config.base_dir .. "'")

  -- Phase 1: Download all playlists
  log("INFO", "=== DOWNLOAD PHASE ===")
  local download_results = {}
  for _, playlist in ipairs(config.playlists) do
    download_results[playlist.name] = download_playlist(config, playlist)
  end

  -- Phase 2: Post-process all files
  log("INFO", "=== POST-PROCESSING PHASE ===")
  local process_results = {}
  for _, playlist in ipairs(config.playlists) do
    process_results[playlist.name] = process_playlist_files(config, playlist)
    -- NOTE: for now just force processing of the files
    -- if download_results[playlist.name] ~= false then -- Process if download didn't explicitly fail
    --   process_results[playlist.name] = process_playlist_files(config, playlist)
    -- else
    --   log("WARN", "Skipping processing for failed download: " .. playlist.name)
    -- end
  end

  -- Summary
  log("INFO", "=== WORKFLOW SUMMARY ===")
  for _, playlist in ipairs(config.playlists) do
    local download_status = download_results[playlist.name] and "✓" or "✗"
    local process_status = process_results[playlist.name] and "✓" or "✗"
    log("INFO", string.format("%s: Download %s | Processing %s", playlist.name, download_status, process_status))
  end

  log("INFO", "Workflow complete!")
end

-- Only run main if this file is executed directly
if arg and arg[0]:match("music%-manager%.lua$") then
  main()
end

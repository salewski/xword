local P = require 'xword.pkgmgr.updater'
require 'luacurl'
require 'lfs'
local join = require 'pl.path'.join
local basename = require 'pl.path'.basename

-- ----------------------------------------------------------------------------
-- cURL Callbacks
-- ----------------------------------------------------------------------------

-- Write to a file
local function write_to_file(fp)
    return function(str, length)
        fp:write(str)
        return length -- Return length to continue download
    end
end

-- Progress callback function: Post dlnow, dltotal
local function progress(dltotal, dlnow, ultotal, ulnow)
    task.post(P.DL_PROGRESS, dlnow, dltotal)
    -- Check to see if we should abort the download
    if task.check_abort() then return 1 end
    return 0
end

-- ----------------------------------------------------------------------------
-- download the updates
-- ----------------------------------------------------------------------------

-- Make the download folder (temporary)
local dl_dir = join(xword.userdatadir, 'updates')
if not lfs.attributes(dl_dir) then
    lfs.mkdir(dl_dir)
end

-- Parse the http error response message and spit out an error code
local function get_http_error(err)
    return tonumber(err:match("The requested URL returned error: (%d+)"))
end

-- Download each package
for _, pkg in ipairs(arg) do
    local name, download = pkg.name, pkg.download
    local filename = join(dl_dir, basename(download))
    local f = io.open(filename, 'wb')

    if not f then
        task.post(P.DL_START, download)
        task.post(P.DL_END, -1, name, "unable to open file for writing: "..filename )
    else
        -- Setup the cURL object
        local c = curl.easy_init()
        c:setopt(curl.OPT_URL, download)
        c:setopt(curl.OPT_FOLLOWLOCATION, 1)
        c:setopt(curl.OPT_WRITEFUNCTION, write_to_file(f))
        c:setopt(curl.OPT_PROGRESSFUNCTION, progress)
        c:setopt(curl.OPT_NOPROGRESS, 0)
        c:setopt(curl.OPT_FAILONERROR, 1) -- e.g. 404 errors

        -- Run the download
        task.post(P.DL_START, download)
        local rc, msg = c:perform()

        -- Post download end
        if rc == 0 then
            msg = { name, filename }
        else
            if rc == 22 then -- CURLE_HTTP_RETURNED_ERROR
                local code = get_http_error(msg)
                if code == 404 or code == 410 then
                    msg = "URL not found: "..download
                end
            end
            msg = { name, tostring(msg or "Unknown error")}
        end

        task.post(P.DL_END, rc, msg)

        -- Cleanup
        f:close()
        if rc ~= 0 then
            os.remove(filename)
        end
    end
end


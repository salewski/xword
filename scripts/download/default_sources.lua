return {
    {
        name = "NY Times Premium",
        url = "http://select.nytimes.com/premium/xword/%Y/%m/%d/%b%d%y.puz",
        directoryname = "NY Times",
        filename = "nyt%Y%m%d.puz",
        days = { true, true, true, true, true, true, true },
        auth = { url="https://myaccount.nytimes.com/auth/login", user_id="userid", password_id="password"},
    },

    {
        name = "NY Times PDF",
        url = "http://select.nytimes.com/premium/xword/%Y/%m/%d/%b%d%y.pdf",
        directoryname = "NY Times",
        filename = "nyt%Y%m%d.pdf",
        days = { true, true, true, true, true, true, true },
        not_puzzle = true,
    },

    {
        name = "CrosSynergy",
        url = "http://cdn.games.arkadiumhosted.com/washingtonpost/crossynergy/cs%y%m%d.jpz",
        filename = "cs%Y%m%d.jpz",
        days = { true, true, true, true, true, true, true },
    },

    {
        name = "Newsday",
        url = "http://www.brainsonly.com/servlets-newsday-crossword/newsdaycrossword?date=%y%m%d",
        filename = "nd%Y%m%d.puz",
        days = { true, true, true, true, true, true, true },
        func = [[
    assert(curl.get(puzzle.url, puzzle.filename, puzzle.curlopts))
    local success, p = pcall(puz.Puzzle, puzzle.filename, import.Newsday)
    if success then
        p:Save(puzzle.filename) -- Save this as a puz
    end
]]
    },

    {
        name = "LA Times",
        url = "http://www.cruciverb.com/download.php?f=lat%y%m%d.puz",
        filename = "lat%Y%m%d.puz",
        auth = { url="http://www.cruciverb.com/index.php?action=login", user_id="user", password_id="passwrd"},
        curlopts =
        {
            referer = 'http://www.cruciverb.com/',
        },
        days = { true, true, true, true, true, true, true },
    },

    {
        name = "USA Today",
        url = "http://picayune.uclick.com/comics/usaon/data/usaon%y%m%d-data.xml",
        filename = "usa%Y%m%d.xml",
        days = { true, true, true, true, true, false, false },
    },
    {
        name = "Ink Well",
        url = "http://herbach.dnsalias.com/Tausig/vv%y%m%d.puz",
        filename = "tausig%Y%m%d.puz",
        days = { false, false, false, false, true, false, false },
        enddate = date('6/27/2014')
    },

    {
        name = "AV Club",
        url = "http://herbach.dnsalias.com/Tausig/av%y%m%d.puz",
        filename = "av%Y%m%d.puz",
        days = { false, false, true, false, false, false, false },
        enddate = date('12/5/2012')
    },

    {
        name = "Jonesin'",
        url = "http://herbach.dnsalias.com/Jonesin/jz%y%m%d.puz",
        filename = "jones%Y%m%d.puz",
        days = { false, false, false, true, false, false, false },
    },

    {
        name = "Wall Street Journal",
        url = "http://mazerlm.home.comcast.net/wsj%y%m%d.puz",
        filename = "wsj%Y%m%d.puz",
        days = { false, false, false, false, true, false, false },
    },

    {
        name = "Boston Globe",
        url = "http://home.comcast.net/~nshack/Puzzles/bg%y%m%d.puz",
        filename = "bg%Y%m%d.puz",
        days = { false, false, false, false, false, false, true },
        enddate = date('1/13/2013')
    },

    {
        name = "Philadelphia Inquirer",
        url = "http://cdn.games.arkadiumhosted.com/latimes/assets/SundayCrossword/mreagle_%y%m%d.xml",
        filename = "pi%Y%m%d.jpz",
        days = { false, false, false, false, false, false, true },
    },

    {
        name = "The Chronicle of Higher Education",
        url = "http://chronicle.com/items/biz/puzzles/%Y%m%d.puz",
        filename = "che%Y%m%d.puz",
        days = { false, false, false, false, true, false, false },
    },

    {
        name = "Universal",
        url = "http://picayune.uclick.com/comics/fcx/data/fcx%y%m%d-data.xml",
        filename = "univ%Y%m%d.xml",
        days = { true, true, true, true, true, true, true },
    },

    {
        name = "Matt Gaffney's Weekly Crossword Contest",
        filename = "mgwcc%Y%m%d.puz",
        days = { false, false, false, false, true, false, false },
        url = "http://xwordcontest.com/%Y/%m/%d",
        curlopts =
        {
            referer = 'http://icrossword.com/',
        },
        -- Custom download function
        func = [[
    -- Download the page with this week's puzzle
    local page, err = curl.get(puzzle.url)
    -- Try a day before
    if err and err:find('404') then
        puzzle.date:adddays(-1)
        page, err = curl.get(puzzle.date:fmt("http://xwordcontest.com/%Y/%m/%d"))
    end
    if err then return err end

    -- Find the Across Lite applet
    local id = page:match('"http://icrossword.com/embed/%?id=([^"]*%.puz)"')
    if id then
        local url = "http://icrossword.com/publish/server/puzzle/serve.php/?id=" .. id
        return curl.get(url, puzzle.filename)
    else
        return "No puzzle"
    end
]]
    },

    {
        name = "Matt Gaffney's Daily Crossword",
        filename = "mgdc%Y%m%d.puz",
        days = { true, true, true, true, true, false, false },
        url = "http://mattgaffneydaily.blogspot.com/%Y_%m_%d_archive.html",
        -- Custom download function
        func = [[
    -- Download the page with puzzles after today's date
    local archive = assert(curl.get(puzzle.url))

    -- Find the last Across Lite applet
    local id, name
    for a,b in archive:gmatch('"http://icrossword.com/embed/%?id=([^"]*)(mgdc[^"]*)"') do
        id, name = a,b
    end
    if id and name then
        local url = string.format(
            "http://icrossword.com/publish/server/puzzle/index.php/%s?id=%s%s",
            name, id, name
        )
        return curl.get(url, puzzle.filename)
    else
        return "No puzzle"
    end
]]
    },

    {
        name = "Brendan Emmett Quigley",
        url = "http://www.brendanemmettquigley.com/%Y/%m/%d",
        filename = "beq%Y%m%d.jpz",
        days = { true, false, false, true, false, false, false },
        -- Custom download function
        func = [[
            -- Download the page with the puzzle
            local page = assert(curl.get(puzzle.url))

            -- Search for a download link (crossword solver app)
            local name = page:match('src="http://www.brendanemmettquigley.com/javaapp/([^"]-).html"')
            if name then
                -- Download the puzzle as an jpz javascript
                local js = assert(curl.get("http://www.brendanemmettquigley.com/xpuz/" .. name .. ".js"))

                -- Extract the string from this js
                local jpz = js:match("['\"](.+)['\"]")
                local f = assert(io.open(puzzle.filename, 'wb'))
                f:write(jpz:gsub('\\"', '"')) -- Unescape strings
                f:close()
                return
            end

            -- Search for a jpz link
            local jpz_url = page:match('href="(http://www.brendanemmettquigley.com/files/[^"]+%.jpz)"')
            if jpz_url then
                assert(curl.get(jpz_url, puzzle.filename))
                return
            end
            return "No puzzle"
        ]]
    },

    {
        name = "I Swear",
        url = "http://wij.theworld.com/puzzles/dailyrecord/DR%y%m%d.puz",
        filename = "dr%Y%m%d.puz",
        days = { false, false, false, false, true, false, false },
        enddate = date('12/31/2013')
    },

    {
        name = "Washington Post Puzzler",
        url = "http://cdn.games.arkadiumhosted.com/washingtonpost/puzzler/puzzle_%y%m%d.xml",
        filename = "wp%Y%m%d.jpz",
        days = { false, false, false, false, false, false, true },
    },
}
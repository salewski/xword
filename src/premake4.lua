project "XWord"
    -- --------------------------------------------------------------------
    -- General
    -- --------------------------------------------------------------------
    kind "WindowedApp"
    language "C++"

    files { "**.hpp", "**.cpp", "**.h" }

    configuration "windows"
        -- Use WinMain() instead of main() for windows apps
        flags { "WinMain" }

    configuration "macosx"
        files { "**.mm" }
        excludes { "dialogs/wxFB_PreferencesPanels.*" }

    configuration "not macosx"
        excludes { "dialogs/wxFB_PreferencesPanelsOSX.*" }

    -- --------------------------------------------------------------------
    -- wxWidgets
    -- --------------------------------------------------------------------

    dofile "../premake4_wxdefs.lua"
    dofile "../premake4_wxlibs.lua"

    -- --------------------------------------------------------------------
    -- puz
    -- --------------------------------------------------------------------
    includedirs { "../" }
    links { "puz" }
    configuration "windows"
        defines {
            "PUZ_API=__declspec(dllimport)",
            "LUAPUZ_API=__declspec(dllimport)",
        }

    configuration "linux"
        defines { [[PUZ_API=""]] }
        links { "dl" }
    
    configuration "macosx"
        defines {
            [[PUZ_API=""]],
            [[LUAPUZ_API=""]],
            "USE_FILE32API" -- for minizip
        }

    -- Disable some warnings
    configuration "vs*"
        buildoptions {
            "/wd4800", -- implicit conversion to bool
            "/wd4251", -- DLL Exports
        }
    -- --------------------------------------------------------------------
    -- wxLua
    -- --------------------------------------------------------------------

    if not _OPTIONS["disable-lua"] then
        configuration {}
            defines "XWORD_USE_LUA"
    
            includedirs {
                DEPS.lua.include,
                "../lua",
                "../lua/wxbind/setup",
            }

            libdirs { DEPS.lua.lib }
    
            links {
                "lua51",
                "wxlua",
                "wxbindbase",
                "wxbindcore",
                "wxbindadv",
                "wxbindaui",
                "wxbindhtml",
                "wxbindnet",
                "wxbindxml",
                "wxbindxrc",
                "luapuz",
            }

        -- These link options ensure that the wxWidgets libraries are
        -- linked in the correct order under linux.
        configuration "linux"
            linkoptions {
                "-lwxbindxrc",
                "-lwxbindxml",
                "-lwxbindnet",
                "-lwxbindhtml",
                "-lwxbindaui",
                "-lwxbindadv",
                "-lwxbindcore",
                "-lwxbindbase",
                "-lwxlua",
                "-llua5.1",
            }

        -- Postbuild: copy lua51.dll to XWord directory

        configuration { "windows", "Debug" }
           postbuildcommands { DEPS.lua.copydebug }

        configuration { "windows", "Release" }
           postbuildcommands { DEPS.lua.copyrelease }

    else -- disable-lua
        configuration {}
            excludes {
                "xwordbind/*",
                "xwordlua*",
            }
    end

    -- --------------------------------------------------------------------
    -- Resources
    -- --------------------------------------------------------------------
    configuration "windows"
        files { "**.rc" }
        resincludedirs { ".." }

    configuration { "macosx" }
        postbuildcommands {
            "cd $TARGET_BUILD_DIR",
            -- Symlink images and scripts
            "mkdir -p $PLUGINS_FOLDER_PATH",
            "ln -sFh ../../../../../scripts $PLUGINS_FOLDER_PATH/scripts",
            "mkdir -p $UNLOCALIZED_RESOURCES_FOLDER_PATH",
            "ln -sFh ../../../../../images $UNLOCALIZED_RESOURCES_FOLDER_PATH/images",
            -- Copy Info.plist and xword.icns
            "cp ../../src/Info.plist $INFOPLIST_PATH",
            "cp ../../images/xword.icns $UNLOCALIZED_RESOURCES_FOLDER_PATH",
        }
        if not _OPTIONS["disable-lua"] then
            postbuildcommands {
                -- Build the rest of the projects
                "cd ../../build/" .. _ACTION,
                'xcodebuild -project lfs.xcodeproj -configuration "$CONFIGURATION"',
                'xcodebuild -project luacurl.xcodeproj -configuration "$CONFIGURATION"',
                'xcodebuild -project luatask.xcodeproj -configuration "$CONFIGURATION"',
                'xcodebuild -project lxp.xcodeproj -configuration "$CONFIGURATION"',
                'xcodebuild -project luayajl.xcodeproj -configuration "$CONFIGURATION"',
            }
        end

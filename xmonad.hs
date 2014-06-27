import XMonad
import XMonad.Actions.CycleWS
import XMonad.Actions.FloatKeys
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.Gaps
import XMonad.Layout.IM
import XMonad.Layout.Named
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Reflect
import XMonad.Util.EZConfig
import XMonad.Util.Run
import Data.Ratio ((%))
import Text.Printf
import qualified XMonad.StackSet as W
import qualified Data.Map        as M


myModMask = mod4Mask    -- Super.

myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

-- That monster at the bottom allows moving windows with <M-arrows> and resizing
-- them with <M-S-arrows>.
keyBindings = [ ("M-b",          sendMessage ToggleGaps)
              , ("M-p",          spawn "dmenu_run")
              , ("M-S-k",        spawn "keepassx")
              , ("M-S-l",        spawn "xscreensaver-command -lock")
              , ("M-<Delete>",   spawn "suspend-laptop")
              , ("M-S-<Delete>", spawn "xkill")
              ]
              ++
              [(("M-" ++ m ++ [k]), windows $ f i)
                  | (i, k) <- zip myWorkspaces "123456789"
                  , (f, m) <- [(W.view, ""), (W.shift, "S-")]]
              ++
              [(c ++ m ++ k, withFocused $ f (d x))
                  | (d, k) <- zip [\a -> (a, 0), \a -> (0, a), \a -> (0 - a, 0), \a -> (0, 0 - a)]
                                  ["<Right>",    "<Down>",     "<Left>",         "<Up>"]
                  , (f, m) <- zip [keysMoveWindow, \d -> keysResizeWindow d (0, 0)] ["M-", "M-S-"]
                  , (c, x) <- zip ["", "C-"] [20, 2]
              ]

-- Change workspaces by rolling the mousewheel.
myMouseBindings = [ ((mod4Mask, button4), (\_ -> nextWS))
                  , ((mod4Mask, button5), (\_ -> prevWS))
                  ]

-- Give the first desktop a layout that shows a small buddy list.
myLayoutHook = onWorkspace "1" pidginfirst
             $ normallayouts
               where
                   full          = named "F" $ noBorders Full
                   pidgin        = named "P" $ reflectHoriz $ withIM (1%8) pblist $ tiled
                   pblist        = And (ClassName "Pidgin") (Role "buddy_list")
                   tiled         = named "T" $ Tall nmaster delta ratio
                   widetiled     = named "W" $ Mirror tiled
                   nmaster       = 1
                   ratio         = 1/2
                   delta         = 3/100
                   normallayouts = full ||| tiled ||| widetiled
                   pidginfirst   = pidgin ||| normallayouts

-- Windows are floated by default.
myManageHook = composeAll . concat $
    [ [ isFullscreen      --> doFullFloat ]
    , [ className =? name --> doIgnore      | name <- ignoreByClass ]
    , [ resource  =? name --> doIgnore      | name <- ignoreByResource ]
    ]
    where
       ignoreByClass = [ "xfce4-notifyd", "Xfce4-notifyd" ]
       ignoreByResource = [ "desktop_window" ]


------------------------------------------------------------------------
colorFunc = xmobarColor
textBg = "black"

formatFunc = \fg -> colorFunc fg textBg
formatCurrent = formatFunc "#00ffff"           -- "cyan"
formatVisible = formatFunc "#006666"           -- darker cyan
formatHidden = formatFunc "#aaaaaa"            -- "grey"
formatHiddenNoWindows = formatFunc "#444444"   -- darker grey
formatUrgent = formatFunc "#dd0000"            -- slightly darker red
formatTitle = formatCurrent

myPP h = xmobarPP {
           ppOutput = hPutStrLn h,
           ppCurrent = formatCurrent,
           ppVisible = formatVisible,
           ppTitle = formatTitle,
           ppHidden = formatHidden,
           ppHiddenNoWindows = formatHiddenNoWindows,
           ppUrgent = formatUrgent,
           ppSep = " | "
       }

main = do
    h <- spawnPipe "xmobar"
    xmonad $ defaultConfig {
                 modMask            = myModMask,
                 focusFollowsMouse  = False,
                 borderWidth        = 3,
                 terminal           = "terminator",
                 workspaces         = myWorkspaces,
                 normalBorderColor  = "#ddddff",
                 focusedBorderColor = "#4444ff",
                 layoutHook         = gaps [(U, 24)] $ myLayoutHook,
                 manageHook         = manageDocks <+> myManageHook <+> doFloat,
                 logHook            = dynamicLogWithPP $ myPP h
             }
             `additionalKeysP`
             keyBindings
             `additionalMouseBindings`
             myMouseBindings


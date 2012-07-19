import XMonad
import XMonad.Actions.CycleWS
import XMonad.Actions.FloatKeys
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.NoBorders
import XMonad.Util.EZConfig

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

myModMask = mod4Mask

myWorkspaces    = [ "1:chat", "2:web", "3:term", "4:dev", "5:scratch"
                  , "6:scratch", "7:scratch", "8:scratch", "9:scratch" ]

keyBindings = [ ("M-p",        spawn "exec `yeganesh -x`")
              , ("M-S-l",      spawn "xscreensaver-command -lock")
              , ("M-<Delete>", spawn "suspend-laptop")
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

myMouseBindings = [ ((mod4Mask, button4), (\_ -> nextWS))
                , ((mod4Mask, button5), (\_ -> prevWS))
                ]

myLayout = noBorders Full ||| tiled ||| Mirror tiled
  where
     tiled   = Tall nmaster delta ratio
     nmaster = 1
     ratio   = 1/2
     delta   = 3/100

myManageHook = composeAll . concat $
    [ [ className =? name --> doFloat  | name <- floatByClass ]
    , [ className =? name --> doIgnore | name <- ignoreByClass ]
    , [ resource  =? name --> doIgnore | name <- ignoreByResource ]
    , [ fmap not isDialog --> doF avoidMaster ]
    ]
    where
       floatByClass = [ "MPlayer", "Gimp", "vlc" ]
       ignoreByClass = [ "Xfce4-notifyd" ]
       ignoreByResource = [ "desktop_window" ]

avoidMaster :: W.StackSet i l a s sd -> W.StackSet i l a s sd
avoidMaster = W.modify' $ \c -> case c of
     W.Stack t [] (r:rs) -> W.Stack t [r] rs
     otherwise           -> c

------------------------------------------------------------------------
main = xmonad =<< xmobar myConfig
myConfig = defaultConfig {
        modMask            = myModMask,
        focusFollowsMouse  = False,
        borderWidth        = 1,
        terminal           = "terminator",
        workspaces         = myWorkspaces,
        normalBorderColor  = "#ddddff",
        focusedBorderColor = "#0000dd",
        layoutHook         = avoidStruts $ myLayout,
        manageHook         = manageDocks <+> myManageHook <+> doFloat
    }
    `additionalKeysP`
    keyBindings
    `additionalMouseBindings`
    myMouseBindings


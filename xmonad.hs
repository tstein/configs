import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Util.EZConfig
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

myWorkspaces    = [ "1:chat", "2:web", "3:term", "4:dev", "5:scratch"
                  , "6:scratch", "7:scratch", "8:scratch", "9:scratch" ]

keyBindings = [ ("M-p",        spawn "exec `yeganesh -x`")
              , ("M-S-l",      spawn "xscreensaver-command -lock")
              , ("M-<Delete>", spawn "suspend-laptop")
              ]

myLayout = Full ||| tiled ||| Mirror tiled
  where
     tiled   = Tall nmaster delta ratio
     nmaster = 1
     ratio   = 1/2
     delta   = 3/100

myManageHook = composeAll . concat $
    [ [ className =? name --> doFloat  | name <- floatByClass ]
    , [ resource  =? name --> doIgnore | name <- ignoreByResource ]
    , [ fmap not isDialog --> doF avoidMaster ]
    ]
    where
       floatByClass = [ "MPlayer", "Gimp", "vlc" ]
       ignoreByResource = [ "desktop_window" ]

avoidMaster :: W.StackSet i l a s sd -> W.StackSet i l a s sd
avoidMaster = W.modify' $ \c -> case c of
     W.Stack t [] (r:rs) -> W.Stack t [r] rs
     otherwise           -> c

------------------------------------------------------------------------
main = xmonad =<< xmobar myConfig
myConfig = defaultConfig {
        modMask            = mod4Mask,
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


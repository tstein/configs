import XMonad
import XMonad.Actions.CycleWS
import XMonad.Actions.FloatKeys
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.IM
import XMonad.Layout.Named
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Reflect
import XMonad.Util.EZConfig
import Data.Ratio ((%))
import qualified XMonad.StackSet as W
import qualified Data.Map        as M

myModMask = mod4Mask

myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

keyBindings = [ ("M-p",        spawn "exec `yeganesh -x`")
              , ("M-S-k",      spawn "keepassx")
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

myLayoutHook = onWorkspace "1" pidgin
             $ full ||| tiled ||| htiled
               where
                   full    = named "F" $ noBorders Full
                   pidgin  = named "P" $ reflectHoriz $ withIM (1%8) pblist $ tiled
                   pblist  = And (ClassName "Pidgin") (Role "buddy_list")
                   tiled   = named "T" $ Tall nmaster delta ratio
                   htiled  = named "H" $ tiled
                   nmaster = 1
                   ratio   = 1/2
                   delta   = 3/100

myManageHook = composeAll . concat $
    [ [ isFullscreen      --> doFullFloat ]
    , [ className =? name --> doFloat       | name <- floatByClass ]
    , [ className =? name --> doIgnore      | name <- ignoreByClass ]
    , [ resource  =? name --> doIgnore      | name <- ignoreByResource ]
    , [ fmap not isDialog --> doF avoidMaster ]
    ]
    where
       floatByClass = [ "MPlayer", "Gimp", "vlc" ]
       ignoreByClass = [ "xfce4-notifyd", "Xfce4-notifyd" ]
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
        layoutHook         = avoidStruts $ myLayoutHook,
        manageHook         = manageDocks <+> myManageHook <+> doFloat
    }
    `additionalKeysP`
    keyBindings
    `additionalMouseBindings`
    myMouseBindings


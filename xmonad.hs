import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

myWorkspaces    = [ "1:chat", "2:web", "3:term", "4:dev", "5:scratch"
                  , "6:scratch", "7:scratch", "8:scratch", "9:scratch" ]

myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
    -- launch a terminal
    [ ((modMask .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
    -- launcher
    , ((modMask,               xK_p     ), spawn "exec `yeganesh -x`")
    -- close focused window
    , ((modMask .|. shiftMask, xK_c     ), kill)
     -- Rotate through the available layout algorithms
    , ((modMask,               xK_space ), sendMessage NextLayout)
    --  Reset the layouts on the current workspace to default
    , ((modMask .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)
    -- Resize viewed windows to the correct size
    , ((modMask,               xK_n     ), refresh)
    -- Move focus to the next window
    , ((modMask,               xK_Tab   ), windows W.focusDown)
    -- Move focus to the next window
    , ((modMask,               xK_j     ), windows W.focusDown)
    -- Move focus to the previous window
    , ((modMask,               xK_k     ), windows W.focusUp  )
    -- Move focus to the master window
    , ((modMask,               xK_m     ), windows W.focusMaster  )
    -- Swap the focused window and the master window
    , ((modMask,               xK_Return), windows W.swapMaster)
    -- Swap the focused window with the next window
    , ((modMask .|. shiftMask, xK_j     ), windows W.swapDown  )
    -- Swap the focused window with the previous window
    , ((modMask .|. shiftMask, xK_k     ), windows W.swapUp    )
    -- Shrink the master area
    , ((modMask,               xK_h     ), sendMessage Shrink)
    -- Expand the master area
    , ((modMask,               xK_l     ), sendMessage Expand)
    -- Push window back into tiling
    , ((modMask,               xK_t     ), withFocused $ windows . W.sink)
    -- Increment the number of windows in the master area
    , ((modMask              , xK_comma ), sendMessage (IncMasterN 1))
    -- Deincrement the number of windows in the master area
    , ((modMask              , xK_period), sendMessage (IncMasterN (-1)))
    -- Quit xmonad
    , ((modMask .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))
    -- Restart xmonad
    , ((modMask              , xK_q     ), restart "xmonad" True)
    -- Lock the screen
    , ((modMask .|. shiftMask, xK_l     ), spawn "xscreensaver-command -lock")
    -- Suspend the machine
    , ((modMask              , xK_Delete), spawn "suspend-laptop")
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modMask, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

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
        keys               = myKeys,
        layoutHook         = avoidStruts $ myLayout,
        manageHook         = manageDocks <+> myManageHook <+> doFloat
    }


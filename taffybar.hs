import Control.Monad (liftM)

import System.Taffybar

import System.Taffybar.Systray
import System.Taffybar.Pager
import System.Taffybar.TaffyPager
import System.Taffybar.SimpleClock
import System.Taffybar.FreedesktopNotifications
import System.Taffybar.Weather
import System.Taffybar.MPRIS

import System.Taffybar.Widgets.PollingBar
import System.Taffybar.Widgets.PollingGraph

import System.Information.Memory
import System.Information.CPU
import System.Information.StreamInfo (getParsedInfo)

import Graphics.UI.Gtk.General.RcStyle (rcParseString)

font = "Inconsolata 14"


-- The getCPUTemp in System.Information.CPU2 is hard-coded to check
-- /sys/bus/platform/devices/coretemp.0/. This version checks the right file,
-- at least on Fedora.
getCPUTemp :: [String] -> IO [Int]
getCPUTemp cpus = do
    let cpus' = map (\s -> [last s]) cpus
    liftM concat $ mapM (\cpu -> getParsedInfo ("/sys/bus/platform/devices/coretemp.0/hwmon/hwmon2/temp" ++ show ((read cpu::Int) + 1) ++ "_input") (\s -> [("temp", [(read s::Int) `div` 1000])]) "temp") cpus'


memCallback = do
  mi <- parseMeminfo
  return [memoryUsedRatio mi]

cpuCallback = do
  (userLoad, systemLoad, totalLoad) <- cpuLoad
  return [totalLoad, systemLoad]

-- Translate temp to [0, 1] between lower and upper.
normalizeTemp :: Double -> Double -> Double -> Double
normalizeTemp lower upper temp = (temp - lower) / (upper - lower)

tempCallback = do
  (commonTemp) <- getCPUTemp ["cpu0"]
  return [normalizeTemp 40 90 $ fromIntegral $ head commonTemp]

myBlue = "#54D4FF"

myPagerConfig :: PagerConfig
myPagerConfig = PagerConfig
  { activeWindow = colorize myBlue "" . shorten 90 . escape
  , activeLayout = colorize "#dddddd" ""
  , activeWorkspace = colorize myBlue "" . escape
  , hiddenWorkspace = colorize "#777777" "" . escape
  , emptyWorkspace = colorize "#333333" "" . escape
  , visibleWorkspace = colorize "#dddddd" "" . escape
  , urgentWorkspace = colorize "red" "" . escape
  , widgetSep = " | "
  }

main = do
  let memCfg = defaultGraphConfig { graphDataColors = [(0, 0, 1, 1)]
                                  , graphLabel = Just "mem"
                                  }
      cpuCfg = defaultGraphConfig { graphDataColors = [ (0, 1, 0, 1)
                                                      , (1, 0, 1, 0.5)
                                                      ]
                                  , graphLabel = Just "cpu"
                                  }
      tempCfg = defaultGraphConfig { graphDataColors = [(1, 0, 0, 1)]
                                  , graphLabel = Just "temp"
                                  }
  let clock = textClockNew Nothing ("<span fgcolor='" ++ myBlue ++ "'>%a %b %_d %H:%M</span>") 1
      pager = taffyPagerNew myPagerConfig
      note = notifyAreaNew defaultNotificationConfig
      mpris = mprisNew defaultMPRISConfig
      mem = pollingGraphNew memCfg 1 memCallback
      cpu = pollingGraphNew cpuCfg 0.5 cpuCallback
      temp = pollingGraphNew tempCfg 0.5 tempCallback
      tray = systrayNew


  rcParseString $ ""
    ++ "style \"default\" {"
    ++ " font_name = \"" ++ font ++ "\""
    ++ "}"

  defaultTaffybar defaultTaffybarConfig {
      barHeight = 48
    , startWidgets = [ pager ]
    , endWidgets = [ clock, mem, cpu, temp, tray, mpris ]
  }

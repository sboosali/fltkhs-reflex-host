{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE RankNTypes, OverloadedStrings #-}
module Reflex.FLTK.Example where

import Reflex as Reflex
import Reflex.Host.Class (EventTrigger, MonadReflexCreateTrigger, newEventWithTriggerRef, runHostFrame, fireEvents)
import Data.Dependent.Sum (DSum ((:=>)))
import Control.Monad.Ref (MonadRef(..))

import qualified Graphics.UI.FLTK.LowLevel.FL              as FL
import qualified Graphics.UI.FLTK.LowLevel.FLTKHS          as FL 
import qualified Graphics.UI.FLTK.LowLevel.Fl_Types        as FL
import qualified Graphics.UI.FLTK.LowLevel.Fl_Enumerations as FL

import Graphics.UI.FLTK.LowLevel.Fl_Types hiding (Ref)
import Graphics.UI.FLTK.LowLevel.FLTKHS as FL hiding (Ref)
import Graphics.UI.FLTK.LowLevel.Fl_Enumerations as FL

import Data.Text as T
import Control.Monad.Fix (MonadFix)
import Control.Monad.Identity (Identity(..))
import Control.Monad.IO.Class (MonadIO,liftIO)
import Data.IORef (IORef,readIORef)
import Control.Arrow
import Data.Function

import Prelude.Spiros
import qualified Prelude

----------------------------------------

-- nothing = return ()

----------------------------------------

type TypingApp t m = (Reflex t, MonadHold t m, MonadFix m)
                  => Reflex.Event t Char
                  -> m (Behavior t String)

type FLTKWindowHandler 
   = FL.Ref DoubleWindow 
  -> FL.Event 
  -> IO (Either UnknownEvent ())

type FLTKWidgetHandler
   = FL.Ref DoubleWindow 
  -> FL.Event 
  -> IO (Either UnknownEvent ())

----------------------------------------

main :: IO ()
-- main = host guest
main = nothing

----------------------------------------

guest :: TypingApp t m
guest e = do
  d <- foldDyn (:) [] e
  return $ fmap Prelude.reverse $ (current d)

----------------------------------------

{-| forward char-keydown events from fltk to reflex. 

-}

forwardCharPresses = makeWidgetHandlerForReflex handleCharPresses

----------------------------------------

-- newEventWithTriggerRef :: (MonadReflexCreateTrigger t m, MonadRef m, Ref m ~ Ref IO) => m (Event t a, Ref m (Maybe (EventTrigger t a)))

{-| 
@handle@
* returns Nothing to handle an fltk event via the widget's superclass handler.  
* returns @Just x@ to (1) handle the event and (2) transform the value to an @x@, which signals 
handled events can be then dropped via @reflex@, for example with 'fmapMaybe'. 
If this is inefficient, we can distinguish the failure cases (like with @Either Bool a@). 
-}
-- makeWindowHandlerForReflex

{-| 

@handle@

* returns Nothing to handle an fltk event via the widget's superclass handler.  
* returns @Just x@ to (1) handle the event and (2) transform the value to an @x@, which signals 

handled events can be then dropped via @reflex@, for example with 'fmapMaybe'. 
If this is inefficient, we can distinguish the failure cases (like with @Either Bool a@). 

-}
-- makeWidgetHandlerForReflex
 -- :: ( )
 -- -- :: ( MonadReflexCreateTrigger t m
 -- --    , MonadRef m, Ref m ~ IORef
 -- --    , MonadIO m
 -- --    ) 
 -- => (FL.Ref DoubleWindow -> FL.Event -> IO (Maybe a))
 -- -> IORef (Maybe (EventTrigger t a)) 
 -- -> FLTKWidgetHandler

makeWidgetHandlerForReflex handle eTriggerRef = \window fltkEvent -> do
  let

      noWasntHandled _window _fltkEvent = do
        handleSuper _window _fltkEvent

      yesWasHandled triggerReference x = do
        fireEvent triggerReference x 
        Right <$> nothing

      handleOrDefault triggerReference _window _fltkEvent =
        handle _window _fltkEvent >>= maybe (noWasntHandled _window _fltkEvent) (yesWasHandled triggerReference)
--        handle >=> maybe (noWasntHandled _fltkEvent) (yesWasHandled triggerReference)        

      fltkhs2reflex = 
        handleOrDefault eTriggerRef window 

  -- consume an FLTK event,
  -- producing a Reflex event.
  fltkhs2reflex fltkEvent

  where

  noListeners = do
      nothing

  someListeners x reflexEventTrigger = do
      fireEvents [reflexEventTrigger :=> Identity x]
      nothing

  -- EventTrigger t a
  fireEvent triggerReference x = runSpiderHost $ do
      trigger <- liftIO $ readIORef triggerReference
      trigger & maybe noListeners (someListeners x)

-- runSpiderHost $ do

----------------------------------------

-- |
-- loses information. 
-- e.g. returns Keydown, 
-- but can't tell you which key was pressed, or whether the key was a character, or any other predicate

handleEveryEvent :: FL.Ref FL.DoubleWindow ->  FL.Event -> IO (Maybe (FL.Event))
handleEveryEvent _ = Just >>> return

-- |
handleCharPresses :: FL.Ref FL.DoubleWindow -> FL.Event -> IO (Maybe Char)
handleCharPresses _ = \case 

  Keydown -> do
       keyPressed <- FL.eventText
       let charPressed = firstChar keyPressed & maybe noIsntChar yesIsChar
       return charPressed

  _ -> do 
      return Nothing

  where
  firstChar = T.uncons > fmap fst
  -- `maybe` is redundant, but it's explicit
  noIsntChar = Nothing
  yesIsChar  = Just


{-

  let fltk2reflex 
     = handleOrDefault window fltkEvent
     & maybe nothing fireEvent
  mX <- handleOrDefault window fltkEvent
-}

----------------------------------------

makeWindow :: (FL.Ref DoubleWindow -> FL.Event -> IO (Either UnknownEvent ())) -> IO (FL.Ref DoubleWindow)
makeWindow handler = do
  w <- doubleWindowCustom
         (toSize (538,413))
         (Just (toPosition (113,180)))
         (Just "FLTKHS Reflex Host Port")
         Nothing
         (defaultCustomWidgetFuncs
          {
            handleCustom = Just handler
          })
         defaultCustomWindowFuncs
  setColor w whiteColor
  setLabelfont w helveticaBold
  setVisible w
  return w

makeDescription :: IO ()
makeDescription = do
  description <- textDisplayNew (toRectangle (30,35,478,90)) Nothing
  setLabel description "Reflex Host Example"
  setBox description NoBox
  setLabelfont description helveticaBold
  setWhen description [WhenNever]
  setTextfont description courier
  setTextsize description (FontSize 12)
  wrapMode description WrapAtBounds
  dBuffer <- textBufferNew Nothing Nothing
  setText dBuffer "\n\nThis is a port of the 'host' example that ships with 'try-reflex'.\n\nType anywhere and the accumulated output will show up below."
  setBuffer description (Just dBuffer)

makeOutput :: IO (FL.Ref TextBuffer, FL.Ref TextDisplay)
makeOutput = do
  o <- textDisplayNew (toRectangle (30,144,478,236)) Nothing
  setLabel o "Output:"
  setBox o BorderFrame
  setTextfont o courier
  setTextsize o (FontSize 12)
  setWhen o [WhenNever]
  b <- textBufferNew Nothing Nothing
  setBuffer o (Just b)
  return (b,o)

outputChanged :: FL.Ref TextBuffer -> T.Text -> IO Bool
outputChanged buffer newText = do
  oldText <- getText buffer
  if (not (T.null oldText))
    then do
      let oldLastLine = Prelude.head (Prelude.reverse (T.lines oldText))
      return (newText /= oldLastLine)
    else return (not (T.null newText))

withWindow :: FL.Ref DoubleWindow -> (FL.Ref DoubleWindow -> IO a) -> IO a
withWindow w k = do
      begin w
      x <- k w
      end w
      return x

----------------------------------------

{-

host :: (forall t m. TypingApp t m) -> IO ()
host myGuest =
  runSpiderHost $ do

    (e, eTriggerRef) <- newEventWithTriggerRef

    let windowHandler :: FL.Ref DoubleWindow -> FL.Event -> IO (Either UnknownEvent ())
        windowHandler window fltkEvent =
          case fltkEvent of
            Keydown -> do
              keyPressed <- FL.eventText
              eventTrigger <- liftIO (readIORef eTriggerRef)
              if (not (T.null keyPressed))
                then runSpiderHost $
                       case eventTrigger of
                          Nothing -> return ()
                          Just event ->
                            fireEvents [event :=> Identity (Prelude.head (T.unpack keyPressed))] >>
                            liftIO (return ())
                else return ()
              return (Right ())
            _ -> handleSuper window fltkEvent
    b <- runHostFrame (myGuest e)
    liftIO $ do
      w <- makeWindow windowHandler

      (buffer,o) <- withWindow w $ \_ -> do
          makeDescription
          makeOutput

      setResizable w (Just o)
      showWidget w
      go (do
           leftTodo <- FL.wait
           return (leftTodo >= 1)
         )
         (runSpiderHost $ do
            output <- runHostFrame (sample b)
            liftIO $ do
              newOutput <- outputChanged buffer (T.pack output)
              if newOutput
                then do
                  emptyBuffer <- getText buffer >>= return . T.null
                  appendToBuffer buffer (T.pack (if emptyBuffer then output else ("\n" ++ output)))
                else return ())
  where
    go :: IO Bool -> IO ()  -> IO ()
    go predicateM action = do
      predicate <- predicateM
      if predicate
        then action >> go predicateM action
        else return ()

-}


----------------------------------------

{-

makeWidgetHandlerForReflex
 :: ()
 -- :: ( MonadReflexCreateTrigger t m
 --    , MonadRef m, Ref m ~ IORef
 --    , MonadIO m
 --    ) 
 => (FL.Ref DoubleWindow -> FL.Event -> IO (Maybe a))
 -> IORef (Maybe (EventTrigger t a)) 
 -> FLTKWidgetHandler


-}

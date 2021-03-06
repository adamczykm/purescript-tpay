module Integration.Main where

import Prelude

import API.Tpay.Request (prepareRequest, defaultRequest)
import API.Tpay.Response (validateResponse)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Data.Maybe (Maybe(..))
import Data.Record.ShowRecord (showRecord)
import Node.Buffer (BUFFER)
import Node.Crypto (CRYPTO)
import Node.HTTP (HTTP)
import Polyform.Validation (V(..), runValidation)
import QuickServe (POST, RequestBody(..), quickServe)

type Effs r = (console :: CONSOLE, buffer :: BUFFER, crypto :: CRYPTO | r)

server2 :: forall r. RequestBody String -> POST (Effs r) String
server2 (RequestBody s) = do
  liftEff $ log s
  val <- liftEff $ runValidation (validateResponse "demo") s
  case val of
    Invalid e -> liftEff $ log (show e)
    Valid e r -> liftEff $ log (showRecord r)
  pure "TRUE"

main
  :: forall eff
  .  Eff (Effs (http :: HTTP | eff)) Unit
main = do
  req <- prepareRequest "" $ defaultRequest { id: 12, amount: 17.1, description: "asdf" }
  log $ show req
  let opts = { hostname: "localhost", port: 3000, backlog: Nothing }
  quickServe opts server2

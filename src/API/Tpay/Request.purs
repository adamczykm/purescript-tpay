module API.Tpay.Request where

import Prelude

import API.Tpay.Serialize (serialize, serializeVal)
import Control.Monad.Eff (Eff)
import Data.Foldable (fold)
import Data.Maybe (Maybe(..))
import Data.StrMap (StrMap)
import Data.StrMap as StrMap
import Node.Buffer (BUFFER)
import Node.Crypto (CRYPTO)
import Node.Crypto.Hash as Hash

type RequestBase r =
  ( id :: Int
  , amount :: Number
  , description :: String
  | r
  )

type RequestOptional r =
  ( crc :: Maybe String
  , online :: Maybe Int
  , group :: Maybe Int
  , result_url :: Maybe String
  , result_email :: Maybe String
  , merchant_description :: Maybe String
  , custom_description :: Maybe String
  , return_url :: Maybe String
  , return_error_url :: Maybe String
  , language :: Maybe String
  , email :: Maybe String
  , name :: Maybe String
  , address :: Maybe String
  , city :: Maybe String
  , zip :: Maybe String
  , country :: Maybe String
  , phone :: Maybe String
  , accept_tos :: Maybe Int
  , expiration_date :: Maybe String
  , timehash :: Maybe String
  | r
  )

type Request = Record (RequestBase (RequestOptional ()))
type RequestInternal = Record (RequestBase (RequestOptional (md5sum :: String )))

defaultRequest :: Record (RequestBase ()) -> Request
defaultRequest { id, amount, description } =
  { id
  , amount
  , description
  , crc: Nothing
  , online: Nothing
  , group: Nothing
  , result_url: Nothing
  , result_email: Nothing
  , merchant_description: Nothing
  , custom_description: Nothing
  , return_url: Nothing
  , return_error_url: Nothing
  , language: Nothing
  , email: Nothing
  , name: Nothing
  , address: Nothing
  , city: Nothing
  , zip: Nothing
  , country: Nothing
  , phone: Nothing
  , accept_tos: Nothing
  , expiration_date: Nothing
  , timehash: Nothing
  }

prepareRequest
  :: forall e
  .  String
  -> Request
  -> Eff (buffer :: BUFFER, crypto :: CRYPTO | e) (StrMap (Array String))
prepareRequest code (r@{ id, amount, description, crc }) =
  let
    strs :: Array String
    strs = serializeVal id <> serializeVal amount <> serializeVal crc <> [ code ]
    str :: String 
    str = fold strs
  in do
    md5 <- Hash.hex Hash.MD5 str
    pure $ StrMap.insert "md5sum" [md5] (serialize r)

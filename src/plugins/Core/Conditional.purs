module Hello.Plugins.Core.Conditional (ifelse, (?)) where

-- | ** (install package when available with "psc-package")**
-- |
-- | https://github.com/purescripters/purescript-conditional
ifelse :: forall a. Boolean -> a -> a -> a
ifelse p a b = if (p) then a else b

infixl 1 ifelse as ?

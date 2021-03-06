{-# OPTIONS --type-in-type --without-K #-}

open import lib.Prelude 

open Int
open Truncation

module homotopy.Pi1S2 where

  private 
    module S² = S²1
  open S² using (S² ; S²-rec ; S²-elim ; S²-fibration)

  Codes = S²-fibration Unit (λ _ → id)

  Codes-Contractible : {x : S²} -> NType -2 (Codes x)
  Codes-Contractible {x} = (S²-elim (\ x -> NType -2 (Codes x))
                                    (ntype (<> , (λ _ → id)))
                                    (HSet-UIP (increment-level (NType-is-HProp _)) _ _ _ _)
                                    x)
  
  Codes-HSet : (x : S²) -> HSet (Codes x)
  Codes-HSet x = increment-level (increment-level (Codes-Contractible{x}))

  P = τ₀ o Path{S²} S².base

  encode : {x : S²} → P x → Codes x
  encode {x} tα = Trunc-rec (Codes-HSet x) 
                            (λ α → transport Codes α <>)
                            tα

  decode' : Codes S².base → τ₀ (Path {S²} S².base S².base)
  decode' _ = [ id ]

  encode-decode' : (x : Codes S².base) → encode (decode' x) ≃ x
  encode-decode' _ = id -- η

  decode : {x : S²} → Codes x → P x
  decode {x} = S²-elim (λ x' → Codes x' → P x') 
                       decode'
                       (HSet-UIP (Πlevel (λ _ → Trunc-level)) _ _ _ _)
                       x
       
  decode-encode : {x : S²} (α : P x) → decode (encode α) ≃ α
  decode-encode{x} α = Trunc-elim (λ α' → decode {x} (encode {x} α') ≃ α')
                                  (λ x' → path-preserves-level Trunc-level)
                                  case-for-[]
                                  α
    where 
      case-for-[] : {x : S²} (α : Path S².base x) → decode (encode [ α ]) ≃ [ α ]
      case-for-[] id = id

  π₁[S²]-is-1 : HEquiv (τ₀ (Path S².base S².base)) Unit
  π₁[S²]-is-1 = hequiv encode decode decode-encode encode-decode'
  

{-# OPTIONS --type-in-type --without-K #-}

open import lib.Prelude 


module computational-interp.JFromSubst where

  j-transport : {A : Set} {M : A} (C : (x : A) -> Path M x -> Set)
       -> {N : A} -> (P : Path M N)
       -> (C M id)
       -> C N P
  j-transport {A}{M}C {N} α = 
    transport (\ (p : Σ \ y -> Path M y) -> C (fst p) (snd p))
          (pair≃ α (transport-Path-right α id))

-- need:
-- Id {Id {A} M N}
--    (transport (λ y → Id {A} M y) α (id {_} {M}))
--    α
  
  j-transport-compute : {A : Set} {M : A} (C : (x : A) -> Path M x -> Set)
       -> (M0 : C M id)
       -> j-transport C id M0 ≃ M0
  j-transport-compute {A}{M} C M0 = 
    transport (λ (p : Σ (λ y → Path M y)) → C (fst p) (snd p))
          (pair≃ id (transport-Path-right id id)) M0           ≃〈 id 〉 -- transport-Path-post id id ≡ id
    transport (λ (p : Σ (λ y → Path M y)) → C (fst p) (snd p)) 
          (pair≃ id id) M0                                ≃〈 id 〉 -- pair≃ id id ≃ id
    transport (λ (p : Σ (λ y → Path M y)) → C (fst p) (snd p)) 
          id M0                                             ≃〈 id 〉
    M0 ∎ 

  FibMap : {A : Type} (P Q : A → Type) → Type
  FibMap {A} P Q = (x : A) → P x → Q x

  -- free fibration  over A generated by a point r over M
  FreeFib : (A : Type) (M : A) → (P : A → Type) (r : P M) → Type
  FreeFib A M P r = Σ \ (tr : (Q : A → Type) → Q M → FibMap P Q) → 
                    Σ \ (β : (Q : A → Type) (r' : Q M) → tr Q r' M r == r') → 
                    Σ \ (η : (Q : A → Type) (r' : Q M) (f : FibMap P Q) → f M r == r' → f == tr Q r') → 
                      {!coherence between β and η!}

  Path-free : (A : Type) (M : A) → FreeFib A M (Path M) id 
  Path-free A M = (λ Q b _ p → transport Q p b) , 
                  (\ Q r' → id) , 
                  (λ Q r' f → path-induction (λ r'' p → Id f (λ z p₁ → transport Q p₁ r'')) (λ≃ (λ z → λ≃ (path-induction (\ z p -> Id (f z p) (transport Q p (f M id))) id)))) , 
                  {!!}

  module JFromFree (A : Type) (M : A) (P : A → Type) (r : P M) (f : FreeFib A M P r) where
    tr = fst f
    β = fst (snd f)
    fullη = fst (snd (snd f))

    simpleη : tr P r == (\ N α → α)
    simpleη = ! (fullη P r (λ N₁ α₁ → α₁) id)

    -- need ap fst
    movefst : {B : A → Type} {C : (x : A) → B x → Type}   
              (b : B M) (c : C M b) → 
              (\ N α → fst (tr (\ x -> Σ \ (b : B x) → C x b) (b , c) N α)) == 
              tr B b 
    movefst {B}{C} b c = fullη B b _ (ap fst (β (λ x → Σe (B x) (C x)) (b , c)))

    -- need ap≃ FIXME: or could state η not as path between functions
    j : (C : (y : A) → P y → Type) (N : A) (α : P N) 
        → C M r → C N α
    j C N α b = transport (C N) (ap≃ (ap≃ simpleη {N}) {α} ∘ ap≃ (ap≃ (movefst {B = P} {C = C} r b) {N}) {α}) (snd (tr (λ y → Σ (λ (α' : P y) → C y α')) (r , b) N α))
       
    -- FIXME : check computation rule; presumably need coherence between β and η
  

       

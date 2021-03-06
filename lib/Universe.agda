{-# OPTIONS --type-in-type --without-K #-}

open import lib.First
open import lib.Paths 
open import lib.AdjointEquiv
open import lib.Prods
open import lib.Functions
open import lib.NType

module lib.Universe where

  -- comparison with VV version

  pathToEquiv : ∀ {A B} → Path A B → Equiv A B
  pathToEquiv {A} α = transport(\ x -> Equiv A x) α id-equiv

  pathToEquiv' : ∀ {A B} → Path A B → Equiv A B
  pathToEquiv' = coe-equiv

  -- really the same thing
  pathToEquiv-is-' : ∀ {A B} (α : Path A B) → pathToEquiv α ≃ pathToEquiv' α
  pathToEquiv-is-' id = id


  -- useful lemmas

  type≃-ext : ∀ {A B} (p q : Path A B) → ((x : A) -> coe p x ≃ coe q x) -> p ≃ q
  type≃-ext p q α = type≃η q ∘ ap ua (pair≃ (λ≃ α) (HProp-unique (IsEquiv-HProp (coe q)) _ _)) ∘ ! (type≃η p)

  -- true but don't need it right now
  -- transport-Equiv-post : ∀ {A B C} {b : Equiv B C} {a : Equiv A B} -> Path (transport (\ X -> Equiv A X) (ua b) a) (b ∘equiv a)
  
  !-ua : {A B : Type} (e : Equiv A B) → (! (ua e)) ≃ (ua (!equiv e))
  !-ua e = type≃-ext (! (ua e)) (ua (!equiv e)) (λ x → ap≃ (! (type≃β (!equiv e)) ∘ type≃β! e)) 

  ∘-ua : {A B C : Type} (e : Equiv B C)(e' : Equiv A B) → (ua e) ∘ (ua e') ≃ ua (e ∘equiv e')
  ∘-ua e e' = type≃-ext _ _ (λ x → ((! (ap≃ (type≃β (e ∘equiv e'))) ∘ ap (fst e) (ap≃ (type≃β e'))) ∘ ap≃ (type≃β e)) ∘ ap≃ (transport-∘ (λ x' → x') (ua e) (ua e')))

  univalence≃-id : ∀ {A} → coe (univalence≃ {A} {A}) id ≃ id-equiv
  univalence≃-id {A} = ap≃ (type≃β (pathToEquiv' , univalence)) {id}

  Path-equiv : ∀ {A B} (α : Path A B) {x y : A} 
             -> Path (Path{A} x y) (Path{B} (coe α x) (coe α y))
  Path-equiv α = ap (λ (p : Σ (λ (A : Type) → A × A)) → Path (fst (snd p)) (snd (snd p)))
                    (pair≃ α (pair×≃ (ap fst (ap≃ (transport-× α (λ x → x) (λ x → x))))
                                     (ap snd (ap≃ (transport-× α (λ x → x) (λ x → x))))))

  run-Path-equiv : ∀ {A B} (α : Path A B) 
                         {x y : A} -> Path{(Path{A} x y) → (Path{B} (coe α x) (coe α y))}
                                          (coe (Path-equiv α))
                                          (ap (coe α))
  run-Path-equiv id = ! (λ≃ ap-id)

  -- special case of λt and apt from LoopSpace
  loop-family->id-equiv-loop : {A : Type} 
                             → ((x : A) → Path x x)
                             → Path {Equiv A A} id-equiv id-equiv
  loop-family->id-equiv-loop α = (pair≃ (λ≃ α) (fst (use-level (use-level (IsEquiv-HProp _) _ _))))
 
  loop-family->id-loop : {A : Type} 
                       → ((x : A) → Path x x)
                       → Path {Path{Type} A A} id id
  loop-family->id-loop α = (type≃η id) ∘ (ap ua (loop-family->id-equiv-loop α)) ∘ ! (type≃η id)


  
  -- ----------------------------------------------------------------------
  -- subuniverse of all N-types

  NTypes : TLevel -> Type
  NTypes n = Σ \ (A : Type) → NType n A

  abstract
    Path-Type-level-loop : ∀ n → {B : Type}
                          → NType n B
                          → NType n (Path B B)
    Path-Type-level-loop -2 nB = ntype (transport Contractible (! univalence≃) (id-equiv , (λ y → coe (ΣSubsetPath (λ y' → IsEquiv-HProp _)) (λ≃ (λ x → HProp-unique (increment-level nB) _ _)))))
    Path-Type-level-loop (S n) nB = transport (NType (S n)) (! univalence≃) (Σlevel (Πlevel (λ _ → nB)) (λ x → raise-HProp (IsEquiv-HProp _)))

    Path-Type-level : ∀ n → {A B : Type}
                          → NType (S n) B
                          → NType (S n) (Path A B)
    Path-Type-level n nB = transport (NType (S n)) (! univalence≃) (Σlevel (Πlevel (λ _ → nB)) (λ x → raise-HProp (IsEquiv-HProp _)))
  
    NTypes-level : ∀ n → NType (S n) (NTypes n)
    NTypes-level -2 = increment-level (ntype ((Unit , ntype Contractible-Unit) ,
                                              (λ y → coe (ΣSubsetPath NType-is-HProp) (! (Contractible≃Unit (use-level (snd y)))))))
    NTypes-level (S n) = ntype (λ An Bn → transport (NType (S n)) (ΣSubsetPath (λ _ → NType-is-HProp _))
                                          (Path-Type-level n (snd Bn)))

    Path-NTypes : ∀ n {A1 A2} → Path (fst A1) (fst A2) ≃ Path{NTypes n} A1 A2
    Path-NTypes n = (ΣSubsetPath (λ a → NType-is-HProp _))

    Path-NTypesβ : ∀ n {A1 A2 : NTypes n} (α : Path (fst A1) (fst A2)) → (fst≃ (coe (Path-NTypes n {A1}{A2}) α)) ≃ α
    Path-NTypesβ n = (ΣSubsetPathβ (λ a → NType-is-HProp _))

    Path2-NTypes : ∀ n {A1 A2} (p q : Path{NTypes n} A1 A2) -> Path p q ≃ (Path (fst≃ p) (fst≃ q))
    Path2-NTypes n p q = apPath≃ (! (Path-NTypes n)) (ΣSubsetPathβ! (λ _ → NType-is-HProp _) p) (ΣSubsetPathβ! (λ _ → NType-is-HProp _) q)

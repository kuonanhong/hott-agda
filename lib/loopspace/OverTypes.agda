
{-# OPTIONS --type-in-type --without-K #-}

open import lib.First
open import lib.Paths
open Paths
open import lib.Functions
open import lib.Int
open Int
open import lib.AdjointEquiv
open import lib.Univalence
open import lib.Truncations
open Truncation
open import lib.WrappedPath

open import lib.loopspace.Basics
open import lib.loopspace.Groupoid
open import lib.loopspace.Types
open import lib.loopspace.Truncation

module lib.loopspace.OverTypes where

  postulate
    add-!-≃ : ∀ {A} {M : A} (p : Path M M) → (! p ≃ id) ≃ (p ≃ id)
  {-
  add-!-≃ {A} {M} p = ua (improve (hequiv (λ α → ap ! α ∘ ! (!-invol p))
                                            (λ β → ap ! β) 
                                            (λ x → ap ! (ap ! x ∘ ! (!-invol p)) ≃〈 {!!} 〉
                                                   ap ! (ap ! x) ∘ ap ! (! (!-invol p)) ≃〈 {!!} 〉 
                                                   ap (! o !) x ∘ ap ! (! (!-invol p)) ≃〈 ap (λ y → y ∘ ap ! (! (!-invol p))) (ap-by-id (λ x' → ! (!-invol x')) x) 〉 
                                                   (! (!-invol id) ∘ x ∘ ! (! (!-invol (! p)))) ∘ ap ! (! (!-invol p)) ≃〈 {!! (!-invol id)!} 〉 
                                                   (id ∘ x ∘ ! (! (!-invol (! p)))) ∘ ap ! (! (!-invol p)) ≃〈 {!!} 〉 
                                                   (x ∘ ! (! (!-invol (! p)))) ∘ ap ! (! (!-invol p)) ≃〈 {!!} 〉 
                                                   (x ∘ (! (! (!-invol (! p))) ∘ ap ! (! (!-invol p)))) ≃〈 ap (λ y → x ∘ y ∘ ap ! (! (!-invol p))) coh 〉 
                                                   (x ∘ (! (ap ! (! (!-invol p))) ∘ ap ! (! (!-invol p)))) ≃〈 ap (λ y → x ∘ y) (!-inv-l (ap ! (! (!-invol p)))) 〉 
                                                   (x ∎))
                                            {!probably similar!})) where
          coh : ∀ {A} {M N : A} {p : Path M N} → ! (! (!-invol (! p))) ≃ ! (ap ! (! (!-invol p)))
          coh {p = id} = id
  -}

  LoopOverS :  (n : Positive) {A : Type} {a : A} (α : Loop (S n) A a) 
             → (B : A -> Type) (b : B a) → Type
  LoopOverS n {A}{a} α B b = 
    Path{Loop n (B a) b} 
        (apt n (ap^ (S n) B α) b)
        (id^ n)

  postulate
    LoopOver-is-S : (n : Positive) {A : Type} {a : A} (α : Loop (S n) A a) → (B : A -> Type) (b : B a) 
                    → LoopOver (S n) α B b ≃ LoopOverS n α B b 
    {- One case should be done
    LoopOver-is-S One α B b = add-!-≃
                                (apt One (id ∘ ap (λ l → ap B l) α) b)
                                ∘ ap (λ x → Id x id) 
                                     (transport (λ x → Id (transport B x b) b) α id ≃〈 {!!} 〉
                                      ap (\_ -> b) α ∘ id ∘ ! (ap (\ x -> transport B x b) α) ≃〈 {!!} 〉 
                                      id ∘ id ∘ ! (ap (\ x -> transport B x b) α) ≃〈 {!!} 〉 
                                      ! (ap (\ x -> transport B x b) α) ≃〈 {!!} 〉
                                      ! (ap (\ x -> coe (ap B x) b) α) ≃〈 {!!} 〉  
                                      ! (ap (\ x -> coe x b) (ap (ap B) α)) ≃〈 {!!} 〉 
                                      ! (ap (\ x -> coe x b) (coe (LoopPath One) (ap (ap B) α))) ≃〈 id 〉 
                                      ! (ap^ One (\ x -> coe x b) (coe (LoopPath One) (ap (ap B) α))) ≃〈 {!!} 〉 
                                      ! ((apt One (ap (ap B) α) b)) ≃〈 {!!} 〉 
                                      (! (apt One (id ∘ ap (ap B) α) b) ∎))
    LoopOver-is-S (S n) α B b = {!!} 
    -}

  LoopType→ : ∀ n {A B} → (Loop (S n) Type A) -> Loop (S n) Type B -> Loop (S n) Type (A → B)
  LoopType→ n {A} {B} lA lB = λt n (λ (f : A → B) →
                                      λl n (λ (x : A) →
                                              ∘^ n (apt n lB (f x)) 
                                                   (ap^ n f (apt n (!^ (S n) lA) x))))

  postulate
    ap^→ : ∀ {A} → (n : _) → (C D : A → Type) → {base : A} {α : Loop (S n) A base} →
           ap^ (S n) (\ x -> C x → D x) α 
         ≃ LoopType→ n (ap^ (S n) C α) (ap^ (S n) D α)

  postulate
   Loop→OverS : (n : Positive) {A : Type} {a : A} (α : Loop (S n) A a) 
              → {B C : A → Type} (f : B a → C a)
              →   Path {Loop n (B a → C a) f}
                    (λl n
                     (λ x →
                        ∘^ n (apt n (ap^ (S n) C α) (f x))
                             (ap^ n f (apt n (!^ (S n) (ap^ (S n) B α)) x))))
                    (λl n (λ x → id^ n))
                ≃ (LoopOver (S n) α (\ x -> B x → C x) f)

  -- postulate
  --   ap^Loop : ∀ n k {A} {a : A} (α : Loop (S n) A a) → ap^ (S n) (λ x → Loop k A x) α ≃ λt n (λ x → rebase n (ap≃ (rebase-idpath k)) (ap^ n (λ p → rebase k p x) (coe (LoopPath {n}) α)))
--  ap^Loop n k α = {!!}
  {-
  Loop→OverS n {A} {a} α {B}{C} f = 
    ! ((LoopOver (S n) α (\ x -> B x → C x) f) ≃〈 {!!} 〉 
       LoopOverS n α (\ x -> B x → C x) f ≃〈 id 〉 
       Path{Loop n (B a → C a) f} 
           (apt n (ap^ (S n) (\ x → B x → C x) α) f)
           (id^ n) ≃〈 {!!} 〉 
       Path{Loop n (B a → C a) f} 
           (apt n (LoopType→ n (ap^ (S n) B α) (ap^ (S n) C α)) f)
           (id^ n) ≃〈 {!!} 〉 
       Path{Loop n (B a → C a) f} 
           (λl n (λ x → ∘^ n (apt n (ap^ (S n) C α) (f x)) 
                            (ap^ n f (apt n (!^ (S n) (ap^ (S n) B α)) x))))
           (id^ n) ≃〈 eta 〉 
       Path{Loop n (B a → C a) f} 
           (λl n (λ x → ∘^ n (apt n (ap^ (S n) C α) (f x)) 
                            (ap^ n f (apt n (!^ (S n) (ap^ (S n) B α)) x))))
           (λl (\ _ -> id^ n))
    ∎)
  -}

  -- note: non-dependent 
  postulate
   LoopPathOver : (n : Positive) {A : Type} {a : A} (α : Loop n A a) 
                → {B : Type} (f g : A → B) (β : Path {B} (f a) (g a))
                →   (Path {Loop n B (g a)} (rebase n β (ap^ n f α)) (ap^ n g α))
                  ≃ (LoopOver n α (\ x -> f x ≃ g x) β) 
  {-
  LoopPathOver n {A}{a} α B f g β = ua (improve (hequiv (i n α) {!!} {!!} {!!})) where
   mutual
    i : ∀ n (α : Loop n A a) 
          → (Path {Loop n B (g a)} (rebase n β (ap^ n f α)) (ap^ n g α))
          → (LoopOver n α (\ x -> f x ≃ g x) β) 
    i One α p = {!!}
    i (S n) α p = transport (λ x → LoopOver n x (λ x' → Id (f x') (g x')) β) α (idOver n (λ x → Id (f x) (g x)) β) ≃〈 {!!} 〉 
                  (i n _
                   (transport (\ x -> (Path {Loop n B (g a)} (rebase n β (ap^ n f x)) (ap^ n g x)))
                            α 
                            (e n _ (idOver n (λ x → Id (f x) (g x)) β)))) ≃〈 {!transport-by (i n)!} 〉 
                  (i n _
                   (ap (ap^ n g) α ∘
                    (e n _ (idOver n (λ x → Id (f x) (g x)) β)) ∘ 
                    ! (ap (\ x -> rebase n β (ap^ n f x)) α))) ≃〈 {!p!} 〉 
                  (i n _
                   (ap (ap^ n g) α ∘
                    (e n _ (idOver n (λ x → Id (f x) (g x)) β)) ∘ 
                    ! (ap (\ x -> rebase n β (ap^ n f x)) α))) ≃〈 {!e-id!} 〉 
                  (idOver n (λ x → Id (f x) (g x)) β ∎) where
     p' :  ap ((rebase n β) o (ap^ n f)) α 
         ≃ ! (rebase-id n β ∘ ap (rebase n β) (ap^-id n f)) 
         ∘ (ap^-id n g ∘ ap (ap^ n g) α ∘ ! (ap^-id n g) 
         ∘ ((rebase-id n β) ∘ (ap (rebase n β) (ap^-id n f))))
     p' = {!rearrange p!}

    e : ∀ n (α : Loop n A a) 
          → (LoopOver n α (\ x -> f x ≃ g x) β) 
          → (Path {Loop n B (g a)} (rebase n β (ap^ n f α)) (ap^ n g α))
    e = {!!}
  -}


  -- FIXME: should be able to derive these compositionally from a rule for 
  -- truncation and a rule for Path in general

  -- intended to to be "α ∘ β"
  LoopTypeTruncPathPost : ∀ n {A} {a : A} (α : Loop (S n) A a) (a0 : A) 
                   → Loop (S n) Type (Trunc (tlp n)(Path{A} a0 a))
  LoopTypeTruncPathPost n α a0 = λt n (Trunc-elim (λ tβ → Loop n (Trunc (tlp n) (Path a0 _)) tβ) 
                                                  (λ _ → IsNTrunc-Loop n Trunc-is) 
                                                  (λ β → ap^ n [_]
                                                        (rebase n (∘-unit-l β)
                                                           (ap^ n (λ x → x ∘ β) (loopSN1 n α)))))

  postulate
    ap^TruncPathPost : ∀ n {A} {a : A} (α : Loop (S n) A a) (a0 : A)
                → 
                Path{Loop (S n) Type (Trunc (tlp n) (Path{A} a0 a))}
                    (ap^ (S n) (\ x -> Trunc (tlp n) (Path a0 x)) α)
                    (LoopTypeTruncPathPost n α a0)


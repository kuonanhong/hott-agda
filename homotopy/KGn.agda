
{-# OPTIONS --type-in-type --without-K #-}

open import lib.Prelude
open Truncation
open Int
open LoopSpace
open Suspension
open import homotopy.Freudenthal
import homotopy.FreudenthalIteratedSuspension1
open import homotopy.HStructure
open import homotopy.PiLessOfConnected
open import homotopy.Pi2HSusp
open import homotopy.KG1

module homotopy.KGn where

  -- KGn when G is π1(A)
  module N+1 (A : Type) 
             (a0 : A)
             (A-Connected : Connected (S (S -2)) A)
             (A-level : NType (tl 1) A)
             (H-A : H-Structure A a0) where
  
      module FS = homotopy.FreudenthalIteratedSuspension1 A a0 A-Connected 
    
      KG : Positive → Type
      KG n = Trunc (tlp n) (FS.Susp'^ n)

      KG-Connected : ∀ (i : Nat) → Connected (tl i) (KG (i +1np))
      KG-Connected n = Connected.Trunc-connected _ _ _ (FS.Susp'^-Connected n)
  
      KG-Connected'' : (n : Positive) → Connected (tlp n) (KG (n +1))
      KG-Connected'' n = coe (ap (NType -2) (ap2 Trunc (tl-pos2nat-tlp n) (ap KG (pos2nat-+1np n)))) (KG-Connected (pos2nat n))
  
      base^ : ∀ n → KG n
      base^ n = [ FS.base'^ n ]

      module Stable (k : Positive)
                    (n : Positive) 
                    (indexing : Either (tlp k <tl tlp n) ((tlp k ≃ tlp n) × (tl 1 <tl tlp n))) where

        stable : π k (KG n) (base^ n) ≃ π (k +1) (KG (n +1)) (base^ (n +1))
        stable = π k (KG n) (base^ n)                           ≃〈 π<=Trunc k n (lte indexing) (FS.base'^ n) 〉 
                 π k (FS.Susp'^ n) (FS.base'^ n)                ≃〈 FS.Stable.stable k n (k<=n->k<=2n-2 k n indexing) 〉 
                 π (k +1) (FS.Susp'^ (n +1)) (FS.base'^ (n +1)) ≃〈 ! (π<=Trunc (k +1) (n +1) (<=SCong (lte indexing)) (FS.base'^ (n +1))) 〉 
                 π (k +1) (KG (n +1)) (base^ (n +1)) ∎ where
            lte : (indexing : Either (tlp k <tl tlp n) ((tlp k ≃ tlp n) × (tl 1 <tl tlp n))) → tlp k <=tl tlp n
            lte (Inl lt) = Inl lt
            lte (Inr (eq , _)) = Inr eq

        -- for talk

        KG1 = A

        stable2 : π (k +1) (KG (n +1)) (base^ (n +1)) ≃ π k (KG n) (base^ n) 
        stable2 = π (k +1) (KG (n +1)) (base^ (n +1))                 ≃〈 (π<=Trunc (k +1) (n +1) (<=SCong (lte indexing)) (FS.base'^ (n +1))) 〉
                  π (k +1) (Susp^ (S n -1pn) KG1) (FS.base'^ (n +1))  ≃〈 ! (FS.Stable.stable k n (k<=n->k<=2n-2 k n indexing)) 〉 
                  π k (Susp^ (n -1pn) KG1) (FS.base'^ n)              ≃〈 ! (π<=Trunc k n (lte indexing) (FS.base'^ n)) 〉        
                  π k (KG n) (base^ n) ∎ 
            where
            lte : (indexing : Either (tlp k <tl tlp n) ((tlp k ≃ tlp n) × (tl 1 <tl tlp n))) → tlp k <=tl tlp n
            lte (Inl lt) = Inl lt
            lte (Inr (eq , _)) = Inr eq

        -- end for talk

      module BelowDiagonal where
      
        π1 : (n : Positive) → (π One (KG (n +1)) (base^ (n +1))) ≃ Unit
        π1 n = π1Connected≃Unit (tlp n) _ (base^ (n +1)) (KG-Connected'' n) (1<=pos n)
  
        πk : (k n : Positive) → (tlp k <tl tlp n) → π k (KG n) (base^ n) ≃ Unit
        πk One One (ltSR (ltSR (ltSR ())))
        πk One (S n) lt = π1 n
        πk (S k) One lt = Sums.abort (pos-not-<=0 k (Inl (lt-unS lt)))
        πk (S k) (S n) lt = π (k +1) (KG (n +1)) (base^ (n +1)) ≃〈 ! (Stable.stable k n (Inl (lt-unS lt))) 〉
                            π k (KG n) (base^ n) ≃〈 πk k n (lt-unS lt) 〉
                            Unit ∎ 
  
      module OnDiagonal where
      
        π1 : π One (KG One) (base^ One)  ≃  π One A a0
        π1 = τ₀ (Path {Trunc (tl 1) A} [ a0 ] [ a0 ]) ≃〈 ap τ₀ (ap-Loop≃ One (UnTrunc.path _ _ A-level) (ap≃ (type≃β (UnTrunc.eqv _ _ A-level)))) 〉
             τ₀ (Path {A} a0 a0) ∎
  
        Two : Positive 
        Two = S One
  
        π2 : π Two (KG Two) (base^ Two) ≃ π One A a0
        π2 = π Two (KG Two) (base^ Two) ≃〈 id 〉 
             Trunc (tl 0) (Loop Two (Trunc (tl 2) (Susp A)) [ No ]) ≃〈 ap (Trunc (tl 0)) (Loop-Trunc0 Two) 〉 
             Trunc (tl 0) (Trunc (tl 0) (Loop Two (Susp A) No)) ≃〈 FuseTrunc.path (tl 0) (tl 0) _ 〉 
             Trunc (tl 0) (Loop Two (Susp A) No) ≃〈 π2Susp A a0 A-level A-Connected H-A 〉 
             Trunc (tl 0) (Loop One A a0) ≃〈 id 〉 
             π One A a0 ∎ 
  
        πn : (n : Positive) → π n (KG n) (base^ n) ≃ π One A a0
        πn One = π1
        πn (S One) = π2
        πn (S (S n)) = πn (S n) ∘ ! (Stable.stable (S n) (S n) (Inr (id , >pos->1 n (S n) ltS))) 
  
      module AboveDiagonal where
  
        πabove : (k n : Positive) → tlp n <tl tlp k → π k (KG n) (base^ n)  ≃  Unit
        πabove k n lt = Contractible≃Unit (use-level { -2} (Trunc-level-better (Loop-level-> (tlp n) k Trunc-level lt))) 


  module Explicit (G : AbelianGroup) where

    module KG1 = K1 (fst G)
    module KGn = N+1 (KG1.KG1) KG1.base KG1.Pi0.KG1-Connected KG1.level (H-on-KG1.H-KG1 G)

    KG : Positive -> Type
    KG One = KG1.KG1
    KG (S n) = KGn.KG (S n)

    KGbase : ∀ n → KG n
    KGbase One = KG1.base
    KGbase (S n) = KGn.base^ (S n)

    πn-KGn-is-G : ∀ n → π n (KG n) (KGbase n) ≃ (Group.El (fst G))
    πn-KGn-is-G One = KG1.Pi1.π1[KGn]-is-G
    πn-KGn-is-G (S n) = KG1.Pi1.π1[KGn]-is-G ∘ KGn.OnDiagonal.πn (S n)

    πk-KGn-trivial : ∀ k n → Either (tlp k <tl tlp n) (tlp n <tl tlp k) 
                   → π k (KG n) (KGbase n) ≃ Unit
    πk-KGn-trivial k One (Inl k<n) with pos-not-<=0 k (lt-unS-right k<n)
    ... | ()
    πk-KGn-trivial k (S n) (Inl k<n) = KGn.BelowDiagonal.πk k (S n) k<n
    πk-KGn-trivial k One (Inr n<k) = Contractible≃Unit (use-level { -2} (Trunc-level-better (Loop-level-> (tlp One) k KG1.level n<k)))
    πk-KGn-trivial k (S n) (Inr n<k) = KGn.AboveDiagonal.πabove k (S n) n<k


  -- todo: 
  -- spectrum:
  --   Path (KG n+1) No No ≃ KG n
  -- set k = n, and cancel redundant truncations


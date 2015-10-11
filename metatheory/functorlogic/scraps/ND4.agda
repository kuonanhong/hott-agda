
-- functoriality admissible

open import functorlogic.Lib
open import functorlogic.Modes

module functorlogic.ND4 where

  data Tp : Mode → Set where
    P : ∀ {m} → Tp m
    Q : ∀ {m} → Tp m
    F : ∀ {p q} (α : q ≥ p) → Tp q → Tp p
    _⊃_ : ∀ {p} → Tp p → Tp p → Tp p

  data Ctx (p : Mode) : Set where
    ·     : Ctx p
    _,_[_] : {q : Mode} → Ctx p → Tp q → q ≥ p → Ctx p

  _∘c_ : ∀ {p q} → Ctx p → p ≥ q → Ctx q
  · ∘c α = ·
  (Γ , A [ α ]) ∘c β = (Γ ∘c β) , A [ α ∘1 β ]

  ∘c-assoc : ∀ {p q r} (Γ : Ctx p) (α : p ≥ q) (β : q ≥ r) 
           → ((Γ ∘c α) ∘c β) == (Γ ∘c (α ∘1 β))
  ∘c-assoc · α β = id
  ∘c-assoc (Γ , A [ α1 ]) α β = ap (λ x → x , _ [ _ ]) (∘c-assoc Γ α β)

  -- eh why not... just lifting ∘-assoc to lists
  {-# REWRITE ∘c-assoc #-}

  data _[_]∈_ : {q p : Mode} → Tp q → q ≥ p → Ctx p → Set where
    i0 : {p q : Mode} {Γ : Ctx p} {A : Tp q} {α : q ≥ p} → A [ α ]∈ (Γ , A [ α ])
    iS : {p q r : Mode} {Γ : Ctx p} {A : Tp q} {α : q ≥ p} {B : Tp r} {β : r ≥ p}
       → A [ α ]∈ Γ 
       → A [ α ]∈ (Γ , B [ β ])

  ∈∘ : ∀ {p q r} {Γ : Ctx p} {α : p ≥ q}
         {A : Tp r} {β : r ≥ p}
         → A [ β ]∈ Γ → A [ β ∘1 α ]∈ (Γ ∘c α)
  ∈∘ i0 = i0
  ∈∘ (iS i) = iS (∈∘ i)

  _⊇_ : ∀ {p} → Ctx p → Ctx p → Set 
  Γ ⊇ Γ' = {q : Mode} {A : Tp q} {α : q ≥ _} → A [ α ]∈ Γ' → A [ α ]∈ Γ

  ⊇∘c : ∀ {p q} {Γ Γ' : Ctx p} {α : p ≥ q} → Γ ⊇ Γ' → (Γ ∘c α) ⊇ (Γ' ∘c α)
  ⊇∘c {Γ' = ·} w ()
  ⊇∘c {Γ' = Γ' , A [ α ]} w i0 = ∈∘ (w i0)
  ⊇∘c {Γ' = Γ' , A [ α ]} w (iS x) = ⊇∘c {Γ' = Γ'} (λ y → w (iS y)) x

  mutual 
    data _⊢⇓_[_] {p : Mode} (Γ : Ctx p) : {q : Mode} → Tp q -> q ≥ p → Set where
      v : {q : Mode} {A : Tp q} {α : q ≥ p} 
        → A [ α ]∈ Γ 
        → Γ ⊢⇓ A [ α ]
      FE : {q r : Mode} {A : Tp r} {β : q ≥ p} {α : r ≥ q} {γ : _} 
        → Γ ⊢⇓ F α A [ β ] → (e : γ ⇒ (α ∘1 β))
        → Γ ⊢⇓ A [ γ ]
      App : {q : Mode} {A B : Tp q} {α : q ≥ p} 
        → Γ ⊢⇓ (A ⊃ B) [ α ]
        → Γ ⊢⇑ A [ α ]
        → Γ ⊢⇓ B [ α ]
  
    data _⊢⇑_[_] {p : Mode} (Γ : Ctx p) : {q : Mode} → Tp q -> q ≥ p → Set where
      ⇓⇑ : {q : Mode} {A : Tp q} {α α' : q ≥ p} 
         → (D : Γ ⊢⇓ A [ α ]) → (e : α' ⇒ α)
         → Γ ⊢⇑ A [ α' ]
      FI : {q r : Mode} {A : Tp r} {β : q ≥ p} {α : r ≥ q}
         → Γ ⊢⇑ A [ α ∘1 β ]
         → Γ ⊢⇑ F α A [ β ]
      Lam : {q : Mode} {Γ' : Ctx q}  {A B : Tp q} {α β : q ≥ p} 
          → Γ' , A [ 1m ] ⊢⇑ B [ 1m ]
          → Γ ⊇ (Γ' ∘c α) 
          → (e : β ⇒ α)
          → Γ ⊢⇑ (A ⊃ B) [ β ]

  mutual
    func⇓ : {p q r : Mode} {Γ : Ctx p} {A : Tp q} {α : q ≥ p} {β : p ≥ r}
          → Γ ⊢⇓ A [ α ]
          → (Γ ∘c β) ⊢⇓ A [ α ∘1 β ]
    func⇓ (v x) = v (∈∘ x)
    func⇓ {β = β} (FE D e) = {!!} -- FE (func⇓ {β = β} D) 
    func⇓ (App D E) = App (func⇓ D) (func⇑ E)
  
    func⇑ : {p q r : Mode} {Γ : Ctx p} {A : Tp q} {α : q ≥ p} {β : p ≥ r}
          → Γ ⊢⇑ A [ α ]
          → (Γ ∘c β) ⊢⇑ A [ α ∘1 β ]
    func⇑ {β = β} (⇓⇑ D e) = ⇓⇑ (func⇓ {β = β} D) (e ∘1cong 1⇒)
    func⇑ (FI D) = FI (func⇑ D)
    func⇑ {β = β} (Lam D w e) = Lam D (λ x → ⊇∘c {α = β} w x) (e ∘1cong 1⇒)
      
  nat⇑ : {p q : Mode} {Γ : Ctx p} {A : Tp q} {α α' : q ≥ p} 
       → Γ ⊢⇑ A [ α ] → (e : α' ⇒ α)
       → Γ ⊢⇑ A [ α' ]
  nat⇑ (⇓⇑ D e') e = ⇓⇑ D (e ·2 e')
  nat⇑ (FI D) e = FI (nat⇑ D (1⇒ ∘1cong e))
  nat⇑ (Lam D w e) e' = Lam D w (e' ·2 e)

  mutual
    substca : {p q r : Mode} {Γ : Ctx p} {A : Tp q} {α : q ≥ p} 
              {A0 : Tp r} {α0 : r ≥ p}
            → Γ ⊢⇑ A0 [ α0 ]
            → (Γ , A0 [ α0 ]) ⊢⇓ A [ α ]
            → Γ ⊢⇑ A [ α ]
    substca D (v i0) = D
    substca D (v (iS x)) = ⇓⇑ (v x) 1⇒
    substca D (FE E e) with substca D E 
    substca D (FE E e) | ⇓⇑ D' e' = {!!} -- ⇓⇑ (FE D') (1⇒ ∘1cong e)
    substca D (FE E e) | FI D' = {!!} -- D'
    substca {α = α} {α0 = α0} D (App E E') with substca D E | substcc1 D E'
    substca {α = α} {α0 = α0} D (App E E') | ⇓⇑ {α = α'} E1 e | E1' = {!App E1 (nat⇑ E1' e)!} -- ⇓⇑ {!!} {!!}
    substca {α = α} {α0 = α0} D (App E E') | Lam {Γ' = Γ'} {α = α'} E1 w e | E1' = substcc1 E1' {!(func⇑ {β = α} E1)!}
  
    substcc1 : {p q r : Mode} {Γ : Ctx p} {A : Tp q} {α : q ≥ p} 
              {A0 : Tp r} {α0 : r ≥ p}
            → Γ ⊢⇑ A0 [ α0 ]
            → (Γ , A0 [ α0 ]) ⊢⇑ A [ α ]
            → Γ ⊢⇑ A [ α ]
    substcc1 D E = {!!}

/-
nea_k_equation_first_order.lean

K 方程的时间一阶性。
区分三个概念：
  - IsMemoryless：无历史依赖（马尔可夫性）
  - IsFirstOrderInTime：时间一阶差分
  - 两者关系：前者是后者的推论
-/

import Mathlib

namespace NEA.KEquationFirstOrder

axiom Tick : Type
axiom tick_linear : LinearOrder Tick
attribute [instance] tick_linear

axiom next : Tick → Tick
axiom next_strict_mono : ∀ t, t < next t

-- ============================================================
-- 三个定义
-- ============================================================

/-- 无记忆性：φ 的下一个值只依赖当前值 -/
def IsMemoryless (φ : Tick → ℝ) : Prop :=
  ∀ t₁ t₂ : Tick, φ t₁ = φ t₂ → φ (next t₁) = φ (next t₂)

/-- 时间一阶性：演化方程只含一阶时间差分 -/
def IsFirstOrderInTime (φ : Tick → ℝ) (g : ℝ → ℝ) : Prop :=
  ∀ t : Tick, φ (next t) - φ t = g (φ t)

/-- 时间二阶性：演化方程含二阶时间差分 -/
def IsSecondOrderInTime (φ : Tick → ℝ) (g : ℝ → ℝ → ℝ) : Prop :=
  ∀ t : Tick,
    (φ (next (next t)) - φ (next t)) - (φ (next t) - φ t)
      = g (φ t) (φ (next t) - φ t)

-- ============================================================
-- 定理级：时间一阶 → 无记忆
-- ============================================================

theorem first_order_implies_memoryless
    (φ : Tick → ℝ) (g : ℝ → ℝ)
    (h : IsFirstOrderInTime φ g) :
    IsMemoryless φ := by
  intro t₁ t₂ h_eq
  have h1 : φ (next t₁) - φ t₁ = g (φ t₁) := h t₁
  have h2 : φ (next t₂) - φ t₂ = g (φ t₂) := h t₂
  rw [h_eq] at h1
  linarith

-- ============================================================
-- 结构级：K 方程满足时间一阶
-- ============================================================

/--
⚠️ 结构级假设（第五级证据）。

从 B 原语（Tick + B=1）推出"时间一阶差分"需要论证
"无历史依赖"，这一步是 OP-Y 的目标。

当前标为 axiom。
-/
axiom k_equation_is_first_order_in_time :
    ∃ (φ : Tick → ℝ) (g : ℝ → ℝ), IsFirstOrderInTime φ g

/-- K 方程是时间一阶的（从结构级假设继承） -/
theorem k_equation_first_order :
    ∃ (φ : Tick → ℝ) (g : ℝ → ℝ), IsFirstOrderInTime φ g :=
  k_equation_is_first_order_in_time

/-- 无记忆性（从时间一阶推） -/
theorem k_equation_memoryless :
    ∃ (φ : Tick → ℝ), IsMemoryless φ := by
  obtain ⟨φ, g, h⟩ := k_equation_is_first_order_in_time
  exact ⟨φ, first_order_implies_memoryless φ g h⟩

end NEA.KEquationFirstOrder

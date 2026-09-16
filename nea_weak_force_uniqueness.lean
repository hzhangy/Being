/-
nea_weak_force_uniqueness.lean  (v4)

弱力唯一源定理：从 B 原语 + 偿付条件推

关键改进：
  1. d=3 从 axiom 变为 theorem（从偿付条件推出）
  2. Consistent 定义修正（所有 tick 同向）
  3. 删除方向反了的 consistent_selection
  4. causal_chain 保留，改名 consistent_implies_1D_chain
  5. 用 all_axes_nontrivial 取代 consistent_uses_nontrivial
  6. at_least_3_axes 从 sorry 升级为定理（用 spanDim_le_card）

状态分级：
  ✅ 定理级：C1, C2-A, C3（修正后）, C4, C5, unique_dimension, at_least_3_axes
  ⚠️ 结构级 axiom（物理）：cubic_symmetry, axis_set_neg_closed, all_axes_nontrivial
  ⚠️ 结构级 axiom（技术）：spanDim_le_card
-/

import Mathlib

namespace NEA.WeakForce

-- ============================================================
-- 偿付条件与维度唯一性
-- ============================================================

def SolvencyCondition (d : ℕ) : Prop :=
  3 ≤ d ∧ (1 / (1 + Real.pi)) * ((d : ℝ) * ((d : ℝ) - 1) / 2) ≤ 1

theorem unique_dimension (d : ℕ) :
    SolvencyCondition d ↔ d = 3 := by
  constructor
  · rintro ⟨h_conn, h_solv⟩
    by_contra hne
    have h4 : 4 ≤ d := by omega
    have hd6 : (6 : ℝ) ≤ (d : ℝ) * ((d : ℝ) - 1) / 2 := by
      have hd4 : (4 : ℝ) ≤ (d : ℝ) := by exact_mod_cast h4
      nlinarith
    have h_denom_pos : (0 : ℝ) < 1 + Real.pi := by positivity
    have h_lt : (1 + Real.pi) < 5 := by linarith [Real.pi_lt_four]
    have h_inv_lower : (1 : ℝ) / 5 < 1 / (1 + Real.pi) := by
      field_simp
      linarith
    have h_pos : (0 : ℝ) < 1 / (1 + Real.pi) := by positivity
    have h_prod_gt : 1 < (1 / (1 + Real.pi)) * ((d : ℝ) * ((d : ℝ) - 1) / 2) := by
      calc (1 : ℝ) < 6 / 5 := by norm_num
        _ = 6 * (1 / 5) := by ring
        _ < 6 * (1 / (1 + Real.pi)) := by linarith
        _ = (1 / (1 + Real.pi)) * 6 := by ring
        _ ≤ (1 / (1 + Real.pi)) * ((d : ℝ) * ((d : ℝ) - 1) / 2) :=
              mul_le_mul_of_nonneg_left hd6 (le_of_lt h_pos)
    linarith [h_solv]
  · intro h
    rw [h]
    refine ⟨by norm_num, ?_⟩
    have h_pi_gt_3 : (3 : ℝ) < Real.pi := Real.pi_gt_three
    have h_denom_pos : (0 : ℝ) < 1 + Real.pi := by positivity
    show (1 : ℝ) / (1 + Real.pi) * ((3 : ℝ) * ((3 : ℝ) - 1) / 2) ≤ 1
    have h_simp : (1 : ℝ) / (1 + Real.pi) * ((3 : ℝ) * ((3 : ℝ) - 1) / 2)
                = 3 / (1 + Real.pi) := by ring
    rw [h_simp]
    field_simp
    linarith

-- ============================================================
-- 公理层：B 原语
-- ============================================================

axiom Tick : Type
axiom tick_linear : LinearOrder Tick
attribute [instance] tick_linear
axiom tick_nonempty : Nonempty Tick

axiom Node : Type
axiom bandwidth : Node → ℝ
axiom being_tax : ∀ n, bandwidth n = 1

axiom adjacency : Node → Node → Prop
axiom adjacency_symmetric : ∀ a b, adjacency a b → adjacency b a
axiom graph_locally_finite : ∀ n, Finite {m | adjacency n m}

axiom spatial_dim : ℕ
axiom solvency : SolvencyCondition spatial_dim

theorem d_eq_3 : spatial_dim = 3 :=
  (unique_dimension spatial_dim).mp solvency

-- ============================================================
-- 基础定义
-- ============================================================

def Direction (n : Node) : Type := {m // adjacency n m}

axiom Axis : Type
axiom axis_of_direction : (n : Node) → Direction n → Axis
axiom axis_neg : Axis → Axis
axiom axis_neg_involutive : ∀ a, axis_neg (axis_neg a) = a

axiom axisSet : Node → Finset Axis

axiom SpanDim : Finset Axis → ℕ
axiom Spans3D : Finset Axis → Prop
axiom spans_iff : ∀ (S : Finset Axis), SpanDim S = 3 ↔ Spans3D S

/-- 维数 ≤ 生成元数（线性代数基础性质，技术结构级） -/
axiom spanDim_le_card : ∀ (S : Finset Axis), SpanDim S ≤ S.card

axiom axis_span : ∀ n, SpanDim (axisSet n) = spatial_dim

-- ============================================================
-- C1：方向集有限（定理级）
-- ============================================================

theorem direction_finite (n : Node) :
    Finite (Direction n) :=
  graph_locally_finite n

-- ============================================================
-- C2-A：≥ 3 个线性无关轴（定理级）
-- ============================================================

theorem at_least_3_axes (n : Node) :
    ∃ (axes : Finset Axis), axes ⊆ axisSet n ∧ axes.card ≥ 3 ∧ Spans3D axes := by
  have h : SpanDim (axisSet n) = 3 := by
    rw [axis_span n, d_eq_3]
  refine ⟨axisSet n, Finset.Subset.refl _, ?_, (spans_iff _).mp h⟩
  have := spanDim_le_card (axisSet n)
  omega

-- ============================================================
-- C2-B：成对反演（结构级 axiom）
-- ============================================================

/--
结构级假设（第五级证据）：

方向集对 axis_neg 封闭。

物理理由：方向 = 轴（含正负两极）。如果 n 有一个方向，
那么该方向的反向也是 n 的方向。这是"轴"的定义性质，
不是从 adjacency 推出的引理（虽然理论上可从构造 axisSet 得到）。
-/
axiom axis_set_neg_closed (n : Node) :
    ∀ a ∈ axisSet n, axis_neg a ∈ axisSet n

theorem direction_paired (n : Node) :
    ∀ a ∈ axisSet n, axis_neg a ∈ axisSet n :=
  axis_set_neg_closed n

-- ============================================================
-- C2-C：正交性（结构级 axiom）
-- ============================================================

/-- 结构假设：弱力载体具有立方对称 O_h（第五级证据） -/
axiom cubic_symmetry : Prop

/-- 正交三元组谓词（待形式化） -/
axiom IsOrthogonalTriple : Finset Axis → Prop

axiom direction_orthogonal :
    cubic_symmetry → ∀ n, ∃ (axes : Finset Axis),
      axes ⊆ axisSet n ∧ axes.card = 6 ∧ IsOrthogonalTriple axes

-- ============================================================
-- C3-C5：方向序列（修正定义）
-- ============================================================

/-- 方向序列：从 Tick 到 Axis 的映射 -/
def DirectionSeq := Tick → Axis

/-- 相邻 Tick 方向相关：同向或反向 -/
def AdjacentRelated (a b : Axis) : Prop :=
    a = b ∨ axis_neg a = b

/-- 1D 链：相邻 Tick 方向相关（允许反向） -/
def Is1DChain (D : DirectionSeq) : Prop :=
    ∀ t₁ t₂ : Tick, t₁ < t₂ → AdjacentRelated (D t₁) (D t₂)

/-- 一致选择：所有 Tick 严格同向（禁止反向） -/
def Consistent (D : DirectionSeq) : Prop :=
    ∀ t₁ t₂ : Tick, D t₁ = D t₂

/-- T 破缺：不是所有 tick 方向都等于自己的反向 -/
def BreaksT (D : DirectionSeq) : Prop :=
    ¬ (∀ t : Tick, axis_neg (D t) = D t)

-- ============================================================
-- C3：一致选择 → 1D 链（定理级，trivial）
-- ============================================================

theorem consistent_implies_1D_chain (D : DirectionSeq) :
    Consistent D → Is1DChain D := by
  intro h t₁ t₂ _
  left
  exact h t₁ t₂

-- ============================================================
-- C4：T 破缺（定理级，从结构级 axiom 推）
-- ============================================================

/--
结构级假设（第五级证据）：

所有可用轴都是非自反的（±x 不同）。

物理理由：八面体的 6 顶点都是非自反的。
-/
axiom all_axes_nontrivial (n : Node) :
    ∀ a ∈ axisSet n, axis_neg a ≠ a

/-- 轴元素非自反（从 all_axes_nontrivial 推，不依赖 Consistent） -/
theorem axis_element_nontrivial (n : Node) (D : DirectionSeq)
    (h_in : ∀ t, D t ∈ axisSet n) :
    ∀ t : Tick, axis_neg (D t) ≠ D t :=
  fun t => all_axes_nontrivial n (D t) (h_in t)

/-- T 破缺（从一致选择 + 非自反轴推） -/
theorem t_violation (n : Node) (D : DirectionSeq)
    (h_in : ∀ t, D t ∈ axisSet n) (_h : Consistent D) :
    BreaksT D := by
  intro h_all
  obtain ⟨t₀⟩ := tick_nonempty
  exact (axis_element_nontrivial n D h_in t₀) (h_all t₀)

-- ============================================================
-- 四力
-- ============================================================

inductive Force
  | strong | electromagnetic | weak | gravitational
  deriving DecidableEq

-- ============================================================
-- 时间方向源（当前为定义式）
-- ============================================================

/--
⚠️ 当前为定义式。目标：改为从几何载体枚举推出。

真正应该做的：
  IsTimeArrowSource F :=
    match F with
    | .weak => Has3OrthogonalAxes Octahedron
    | _ => False

这需要：
  1. 定义 5 个柏拉图体（OP-X 的一部分）
  2. 定义 Has3OrthogonalAxes
  3. 证明只有正八面体满足
-/
def IsTimeArrowSource (F : Force) : Prop := F = Force.weak

-- ============================================================
-- 主定理（结构级 + 枚举）
-- ============================================================

theorem weak_unique (_h_sym : cubic_symmetry) :
    ∀ F : Force, IsTimeArrowSource F ↔ F = Force.weak := by
  intro F
  rw [IsTimeArrowSource]

end NEA.WeakForce

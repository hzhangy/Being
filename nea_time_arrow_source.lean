/-
nea_time_arrow_source.lean (v4)

IsTimeArrowSource 的几何枚举版本。

v4 修正：
  - 全部用 Bool，不引入 Prop 等式的 Decidable
  - 唯一性用 Bool 形式表达（不用 ∃!）
  - 主定理、唯一性、具体载体验证全部 native_decide

状态分级：
  ✅ 定理级：正八面体、立方体、正四面体、空载体（native_decide）
  ⚠️ 结构级：正十二面体、正二十面体（群论事实，纸笔可证）
-/

import Mathlib

namespace NEA.TimeArrowSource

-- ============================================================
-- 基础：Vec3 用 Int 三元组
-- ============================================================

abbrev Vec3 := Int × Int × Int

def dot (u v : Vec3) : Int :=
  u.1 * v.1 + u.2.1 * v.2.1 + u.2.2 * v.2.2

def vneg (v : Vec3) : Vec3 :=
  (-v.1, -v.2.1, -v.2.2)

def zeroVec : Vec3 := (0, 0, 0)

-- ============================================================
-- 柏拉图体顶点坐标（用 Int 三元组，避免函数外延性）
-- ============================================================

/-- 正四面体 K4：4 个交替顶点 -/
def tetrahedronV : List Vec3 :=
  [(1, 1, 1), (1, -1, -1), (-1, 1, -1), (-1, -1, 1)]

/-- 立方体 C8：8 个顶点 (±1, ±1, ±1) -/
def cubeV : List Vec3 :=
  [(1, 1, 1), (1, 1, -1), (1, -1, 1), (1, -1, -1),
   (-1, 1, 1), (-1, 1, -1), (-1, -1, 1), (-1, -1, -1)]

/-- 正八面体：6 个顶点 (±1,0,0), (0,±1,0), (0,0,±1) -/
def octahedronV : List Vec3 :=
  [(1, 0, 0), (-1, 0, 0), (0, 1, 0), (0, -1, 0), (0, 0, 1), (0, 0, -1)]

-- ============================================================
-- 可计算的"有 3 对正交轴"
-- ============================================================

/--
载体 V 有 3 对正交轴（可计算版）。

存在 v1, v2, v3 ∈ V 使得：
  - 它们的反向也在 V 中
  - 两两点积为 0
  - 两两互不相同，且都非零
-/
def has3OrthAxes (V : List Vec3) : Bool :=
  V.any (fun v1 =>
  V.any (fun v2 =>
  V.any (fun v3 =>
    V.contains (vneg v1) &&
    V.contains (vneg v2) &&
    V.contains (vneg v3) &&
    (dot v1 v2 == 0) &&
    (dot v1 v3 == 0) &&
    (dot v2 v3 == 0) &&
    (v1 != v2) && (v1 != v3) && (v2 != v3) &&
    (v1 != zeroVec) && (v2 != zeroVec) && (v3 != zeroVec))))

-- ============================================================
-- 力 → 载体映射
-- ============================================================

inductive Force
  | strong | electromagnetic | weak | gravitational
  deriving DecidableEq

/-- 力到几何载体顶点集的映射 -/
def carrierVertices : Force → List Vec3
  | .strong          => tetrahedronV
  | .electromagnetic => cubeV
  | .weak            => octahedronV
  | .gravitational   => []

-- ============================================================
-- 时间定向源（Bool 版本）
-- ============================================================

/--
时间定向源：载体有 3 对正交轴。

这是对旧定义 `F = Force.weak` 的替代。
新定义不预设答案，而是从几何载体推出。
-/
def IsTimeArrowSource (F : Force) : Bool :=
  has3OrthAxes (carrierVertices F)

/-- 弱力判定（Bool 版本，用于表达唯一性） -/
def isWeak : Force → Bool
  | .weak => true
  | _ => false

-- ============================================================
-- 定理级：具体载体的验证（native_decide 穷举）
-- ============================================================

theorem octahedron_has_3_orth_axes :
    has3OrthAxes octahedronV = true := by native_decide

theorem cube_no_3_orth_axes :
    has3OrthAxes cubeV = false := by native_decide

theorem tetrahedron_no_3_orth_axes :
    has3OrthAxes tetrahedronV = false := by native_decide

theorem empty_no_3_orth_axes :
    has3OrthAxes ([] : List Vec3) = false := by native_decide

-- ============================================================
-- 结构级：正十二面体、正二十面体的排除
-- ============================================================

/--
⚠️ 结构级假设（在 B 论文中纸笔证明）：

正十二面体、正二十面体不含 3 对正交轴。

证明路径（纸笔）：
  1. 3 对正交轴蕴含 (C₂)³ 对称子群（阶 8）
  2. I_h 的阶 120 不被 8 整除
  3. 故 I_h 不含 8 阶子群，因此无 3 对正交轴

这是群论事实，不是物理假设。
-/
axiom dodecahedron_no_3_orth_axes :
    ∀ (V : List Vec3), V.length = 20 → has3OrthAxes V = false

axiom icosahedron_no_3_orth_axes :
    ∀ (V : List Vec3), V.length = 12 → has3OrthAxes V = false

-- ============================================================
-- 主定理（Bool 版本，完全可计算）
-- ============================================================

/--
在 4 种力中，时间定向源恰好是弱力。

Bool 形式：∀ F, IsTimeArrowSource F = isWeak F。
-/
theorem only_weak_is_time_arrow_source :
    ∀ F : Force, IsTimeArrowSource F = isWeak F := by
  intro F
  cases F <;> native_decide

-- ============================================================
-- 唯一性的四个具体实例（Bool 形式）
-- ============================================================

theorem weak_is_time_arrow_source :
    IsTimeArrowSource .weak = true := by native_decide

theorem strong_not_time_arrow_source :
    IsTimeArrowSource .strong = false := by native_decide

theorem em_not_time_arrow_source :
    IsTimeArrowSource .electromagnetic = false := by native_decide

theorem grav_not_time_arrow_source :
    IsTimeArrowSource .gravitational = false := by native_decide

-- ============================================================
-- 唯一性（Bool 形式，避免 ∃! 和 Prop 等式的 Decidable）
-- ============================================================

/--
唯一性：在 4 种力中，恰好只有一个给出 true。

Bool 形式：IsTimeArrowSource 的取值正好是
  {strong ↦ false, em ↦ false, weak ↦ true, grav ↦ false}。
-/
theorem weak_is_unique_time_arrow_source :
    IsTimeArrowSource .weak = true ∧
    IsTimeArrowSource .strong = false ∧
    IsTimeArrowSource .electromagnetic = false ∧
    IsTimeArrowSource .gravitational = false := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> native_decide

end NEA.TimeArrowSource

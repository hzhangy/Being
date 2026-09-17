/-
  nea_cp_violation_from_octahedron.lean
  Volume B', Section 8.5.  Zero sorry.
-/

import Mathlib.Data.Matrix.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Tactic

set_option linter.unusedSimpArgs false

namespace NEA.CPViolation

open Matrix

/-- R_ABC: rotation matrix for cycle A -> B -> C -> A. -/
def R_ABC : Matrix (Fin 3) (Fin 3) ℝ
  | 0, 2 => 1
  | 1, 0 => 1
  | 2, 1 => 1
  | _, _ => 0

/-- R_ACB: conjugate cycle A -> C -> B -> A. -/
def R_ACB : Matrix (Fin 3) (Fin 3) ℝ
  | 0, 1 => 1
  | 1, 2 => 1
  | 2, 0 => 1
  | _, _ => 0

/-- The unnormalized body diagonal (1, 1, 1). -/
def bodyDiagonal : Fin 3 → ℝ := fun _ => 1

theorem R_ABC_fixes_bodyDiagonal :
    R_ABC.mulVec bodyDiagonal = bodyDiagonal := by
  ext i
  fin_cases i <;>
    simp [R_ABC, bodyDiagonal, Matrix.mulVec, dotProduct,
          Fin.sum_univ_three]

theorem trace_R_ABC : Matrix.trace R_ABC = 0 := by
  simp [R_ABC, Matrix.trace, Fin.sum_univ_three]

theorem cos_theta_R_ABC :
    (Matrix.trace R_ABC - 1) / 2 = -(1 / 2 : ℝ) := by
  rw [trace_R_ABC]; norm_num

theorem R_ACB_eq_transpose :
    R_ACB = R_ABC.transpose := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [R_ABC, R_ACB, Matrix.transpose]

theorem R_ABC_mul_R_ACB :
    R_ABC * R_ACB = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [R_ABC, R_ACB, Matrix.mul_apply, Fin.sum_univ_three]

theorem trace_R_ACB : Matrix.trace R_ACB = 0 := by
  simp [R_ACB, Matrix.trace, Fin.sum_univ_three]

theorem projection_factor_sq :
    (1 / Real.sqrt 3 : ℝ) * (1 / Real.sqrt 3) = 1 / 3 := by
  have h3 : (0 : ℝ) < 3 := by norm_num
  have hsqrt : Real.sqrt 3 * Real.sqrt 3 = 3 := Real.mul_self_sqrt h3.le
  rw [div_mul_div_comm, one_mul, hsqrt]

theorem delta_CP_formula :
    (2 * Real.pi / 3) * (1 / Real.sqrt 3)
    = 2 * Real.pi * Real.sqrt 3 / 9 := by
  have h3 : (0 : ℝ) < 3 := by norm_num
  have hsqrt_ne : Real.sqrt 3 ≠ 0 := ne_of_gt (Real.sqrt_pos.mpr h3)
  have hsqrt_sq : Real.sqrt 3 * Real.sqrt 3 = 3 := Real.mul_self_sqrt h3.le
  field_simp
  nlinarith [hsqrt_sq]

theorem delta_CP_bounds :
    0 < 2 * Real.pi * Real.sqrt 3 / 9 ∧
    2 * Real.pi * Real.sqrt 3 / 9 < Real.pi / 2 := by
  constructor
  · positivity
  · have h3pos : (0 : ℝ) < 3 := by norm_num
    have hsqrt_lt_two : Real.sqrt 3 < 2 := by
      have h : Real.sqrt 3 < Real.sqrt 4 := by
        apply Real.sqrt_lt_sqrt <;> norm_num
      have h4 : Real.sqrt 4 = 2 := by
        rw [show (4 : ℝ) = 2^2 by norm_num]
        rw [Real.sqrt_sq (by norm_num : (0 : ℝ) ≤ 2)]
      linarith
    have hpi : 0 < Real.pi := Real.pi_pos
    have hsqrt_pos : 0 < Real.sqrt 3 := Real.sqrt_pos.mpr h3pos
    nlinarith

theorem cp_violation_geometric_summary :
    R_ABC.mulVec bodyDiagonal = bodyDiagonal ∧
    (Matrix.trace R_ABC - 1) / 2 = -(1 / 2 : ℝ) ∧
    (1 / Real.sqrt 3 : ℝ) * (1 / Real.sqrt 3) = 1 / 3 ∧
    (2 * Real.pi / 3) * (1 / Real.sqrt 3)
      = 2 * Real.pi * Real.sqrt 3 / 9 :=
  ⟨R_ABC_fixes_bodyDiagonal, cos_theta_R_ABC,
   projection_factor_sq, delta_CP_formula⟩

end NEA.CPViolation

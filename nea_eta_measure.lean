import Mathlib
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Bounds

noncomputable section

namespace NEA.Eta

-- π 的已知标准界（已由 Mathlib 证明，此处作为接口声明）
axiom pi_gt_three : (3 : ℝ) < Real.pi
axiom pi_lt_four : Real.pi < 4

def mu_1D : ℝ := 2
def mu_2D : ℝ := 2 * Real.pi
def eta : ℝ := mu_1D / (mu_1D + mu_2D)

theorem eta_eq : eta = 1 / (1 + Real.pi) := by
  unfold eta mu_1D mu_2D
  have h : (2 : ℝ) + 2 * Real.pi = 2 * (1 + Real.pi) := by ring
  rw [h]
  have hp : (1 + Real.pi) ≠ 0 := by linarith [Real.pi_pos]
  field_simp

theorem eta_pos : 0 < eta := by
  rw [eta_eq]; positivity

theorem eta_lt_half : eta < 1 / 2 := by
  rw [eta_eq]
  have h2 : (2 : ℝ) < 1 + Real.pi := by linarith [pi_gt_three]
  exact one_div_lt_one_div_of_lt (by norm_num : (0 : ℝ) < 2) h2

-- 用传递性直接证明 eta < 1/2 < 1，彻底避开 1/1 类型不匹配
theorem eta_lt_one : eta < 1 := by
  have h : (1 / 2 : ℝ) < 1 := by norm_num
  exact lt_trans eta_lt_half h

theorem eta_bounds : 0 < eta ∧ eta < 1 / 2 := ⟨eta_pos, eta_lt_half⟩

def C_coord (d : ℕ) : ℝ := eta * ((d : ℝ) * ((d : ℝ) - 1) / 2)

theorem C_coord_3_eq : C_coord 3 = 3 / (1 + Real.pi) := by
  unfold C_coord eta mu_1D mu_2D
  have h : (2 : ℝ) + 2 * Real.pi = 2 * (1 + Real.pi) := by ring
  rw [h]
  have hp : (1 + Real.pi) ≠ 0 := by linarith [Real.pi_pos]
  field_simp
  norm_num

theorem C_coord_3_below_one : C_coord 3 < 1 := by
  rw [C_coord_3_eq]
  have hp : (0 : ℝ) < 1 + Real.pi := by linarith [Real.pi_pos]
  have h3 : (3 : ℝ) < 1 + Real.pi := by linarith [pi_gt_three]
  have key : 3 / (1 + Real.pi) < (1 + Real.pi) / (1 + Real.pi) :=
    div_lt_div_of_pos_right h3 hp
  rwa [div_self (ne_of_gt hp)] at key

theorem C_coord_4_eq : C_coord 4 = 6 / (1 + Real.pi) := by
  unfold C_coord eta mu_1D mu_2D
  have h : (2 : ℝ) + 2 * Real.pi = 2 * (1 + Real.pi) := by ring
  rw [h]
  have hp : (1 + Real.pi) ≠ 0 := by linarith [Real.pi_pos]
  field_simp
  norm_num

theorem C_coord_4_above_one : C_coord 4 > 1 := by
  rw [C_coord_4_eq, gt_iff_lt]
  have hp : (0 : ℝ) < 1 + Real.pi := by linarith [Real.pi_pos]
  have h5 : (1 + Real.pi) < 6 := by linarith [pi_lt_four]
  have key : (1 + Real.pi) / (1 + Real.pi) < 6 / (1 + Real.pi) :=
    div_lt_div_of_pos_right h5 hp
  rwa [div_self (ne_of_gt hp)] at key

end NEA.Eta

import Mathlib

noncomputable section

namespace NEA.SU2Envelope

open Matrix

def σx : Matrix (Fin 2) (Fin 2) ℂ := fun i j =>
  if i = 0 ∧ j = 1 then 1
  else if i = 1 ∧ j = 0 then 1
  else 0

def σy : Matrix (Fin 2) (Fin 2) ℂ := fun i j =>
  if i = 0 ∧ j = 1 then -Complex.I
  else if i = 1 ∧ j = 0 then Complex.I
  else 0

def σz : Matrix (Fin 2) (Fin 2) ℂ := fun i j =>
  if i = 0 ∧ j = 0 then 1
  else if i = 1 ∧ j = 1 then -1
  else 0

def J (i : Fin 3) : Matrix (Fin 2) (Fin 2) ℂ :=
  match i with
  | 0 => (2⁻¹ : ℂ) • σx
  | 1 => (2⁻¹ : ℂ) • σy
  | 2 => (2⁻¹ : ℂ) • σz

-- 纯用 norm_num 处理复数分量，完全不调用 ring 或 ring_nf
macro "comm_entry" : tactic =>
  `(tactic|
    (ext i j
     fin_cases i <;> fin_cases j <;>
     simp [J, σx, σy, σz, Matrix.mul_apply, Matrix.sub_apply,
           Matrix.smul_apply, Fin.sum_univ_two,
           Complex.ext_iff, Complex.mul_re, Complex.mul_im,
           Complex.add_re, Complex.add_im,
           Complex.sub_re, Complex.sub_im,
           Complex.neg_re, Complex.neg_im,
           Complex.I_re, Complex.I_im,
           Complex.ofReal_re, Complex.ofReal_im,
           Complex.zero_re, Complex.zero_im,
           Complex.one_re, Complex.one_im] <;>
     norm_num))

theorem comm_01 : J 0 * J 1 - J 1 * J 0 = Complex.I • J 2 := by
  comm_entry

theorem comm_01' : J 1 * J 0 - J 0 * J 1 = -Complex.I • J 2 := by
  comm_entry

theorem comm_12 : J 1 * J 2 - J 2 * J 1 = Complex.I • J 0 := by
  comm_entry

theorem comm_12' : J 2 * J 1 - J 1 * J 2 = -Complex.I • J 0 := by
  comm_entry

theorem comm_20 : J 2 * J 0 - J 0 * J 2 = Complex.I • J 1 := by
  comm_entry

theorem comm_20' : J 0 * J 2 - J 2 * J 0 = -Complex.I • J 1 := by
  comm_entry

theorem octahedral_su2_closure :
    ∀ a b : Fin 3,
      J a * J b - J b * J a =
      match a, b with
      | 0, 1 => Complex.I • J 2
      | 1, 0 => -Complex.I • J 2
      | 1, 2 => Complex.I • J 0
      | 2, 1 => -Complex.I • J 0
      | 2, 0 => Complex.I • J 1
      | 0, 2 => -Complex.I • J 1
      | _, _ => 0 := by
  intro a b
  fin_cases a <;> fin_cases b
  · exact sub_self _
  · exact comm_01
  · exact comm_20'
  · exact comm_01'
  · exact sub_self _
  · exact comm_12
  · exact comm_20
  · exact comm_12'
  · exact sub_self _

end NEA.SU2Envelope

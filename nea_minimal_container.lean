/-
  nea_minimal_container.lean
  ============================================================
  Formalization of the combinatorial theorem underlying the
  identification of N = 8 = 2^3 as the vertex count of the
  unique zero-rent bookkeeping structure C_8.

  Volume B, Section 6 (C_8 Uniqueness Theorem).

  Author: Yu Zhang
  Date: September 2026
  Repository: github.com/hzhangy/Being
-/

import Mathlib.Data.Finset.Card
import Mathlib.Data.Fintype.Basic
import Mathlib.Data.Finset.Image
import Mathlib.Tactic

noncomputable section

namespace NEA.MinimalContainer

-- ============================================================
-- Section 1: The hypercube vertex set
-- ============================================================

/-- The vertex set of the d-dimensional hypercube: all sign
    patterns, represented as functions Fin d → Bool. -/
def hypercube_vertices (d : ℕ) : Finset (Fin d → Bool) :=
  Finset.univ

/-- The hypercube has exactly 2^d vertices. -/
theorem hypercube_card (d : ℕ) :
    (hypercube_vertices d).card = 2 ^ d := by
  unfold hypercube_vertices
  rw [Finset.card_univ, Fintype.card_fun]
  rw [Fintype.card_bool, Fintype.card_fin]

-- ============================================================
-- Section 2: The sign-flip involution
-- ============================================================

/-- The sign-flip involution on the hypercube. -/
def sign_flip {d : ℕ} (v : Fin d → Bool) : Fin d → Bool :=
  fun i => !v i

/-- The sign-flip is an involution. -/
theorem sign_flip_involutive (d : ℕ) :
    Function.Involutive (@sign_flip d) := by
  intro v
  funext i
  simp [sign_flip]

-- ============================================================
-- Section 3: Positive axis vertices
-- ============================================================

/-- The positive axis vertices: for each coordinate i, the
    vector with v i = true and all other coordinates false. -/
def positive_axis_vertices (d : ℕ) : Finset (Fin d → Bool) :=
  Finset.univ.image (fun i : Fin d =>
    (fun j => decide (i = j) : Fin d → Bool))

/-- There are exactly d positive axis vertices. -/
theorem positive_axis_card (d : ℕ) :
    (positive_axis_vertices d).card = d := by
  unfold positive_axis_vertices
  rw [Finset.card_image_of_injective]
  · exact Finset.card_univ.trans (Fintype.card_fin d)
  · intro i j h
    have h_at_i := congr_fun h i
    simp at h_at_i
    exact h_at_i.symm

-- ============================================================
-- Section 4: The d = 3 minimal container theorem
-- ============================================================

/-- The octahedral vertex set in d = 3: the six vertices
    ±e_x, ±e_y, ±e_z, represented as subsets of {Fin 3 → Bool}. -/
def octahedral_vertices_3 : Finset (Fin 3 → Bool) :=
  positive_axis_vertices 3 ∪
  (positive_axis_vertices 3).image (@sign_flip 3)

/-- The octahedral vertex set in d = 3 has exactly 6 elements. -/
theorem octahedral_vertices_3_card :
    octahedral_vertices_3.card = 6 := by
  unfold octahedral_vertices_3 positive_axis_vertices sign_flip
  native_decide

/-- **Main theorem for d = 3.**
    Any vertex set V ⊆ {Fin 3 → Bool} that
      (a) contains all three positive axis vertices, and
      (b) is closed under sign-flip,
    has at least 6 elements. -/
theorem minimal_container_d3 :
    ∀ (V : Finset (Fin 3 → Bool)),
      positive_axis_vertices 3 ⊆ V →
      (∀ v ∈ V, sign_flip v ∈ V) →
      V.card ≥ 6 := by
  intro V h_pos h_sym
  have h_sub : octahedral_vertices_3 ⊆ V := by
    intro v hv
    unfold octahedral_vertices_3 at hv
    rw [Finset.mem_union] at hv
    rcases hv with h | h
    · exact h_pos h
    · rw [Finset.mem_image] at h
      obtain ⟨u, hu, rfl⟩ := h
      exact h_sym u (h_pos hu)
  calc V.card
      ≥ octahedral_vertices_3.card := Finset.card_le_card h_sub
    _ = 6 := octahedral_vertices_3_card

/-- The cube (full hypercube) in d = 3 has 8 vertices. -/
theorem cube_card_d3 :
    (hypercube_vertices 3).card = 8 := by
  rw [hypercube_card 3]
  norm_num

end NEA.MinimalContainer

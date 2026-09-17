"""
nea_cp_violation_octahedron.py

Verification of Candidate 1 for the geometric origin of CP violation
in the N.E.A. framework.

Claim: The CP-violating phase is the projection of the octahedral
three-cycle rotation (120 degrees) onto the equatorial plane:

    delta_CP = (2*pi/3) * (1/sqrt(3)) = 2*pi*sqrt(3)/9 ~= 69.28 deg

which agrees with the observed CKM phase (~68.8 deg) to 0.7%.

Repository: github.com/hzhangy/Being (B' supplementary)
"""

import numpy as np

np.set_printoptions(precision=12, suppress=True, linewidth=120)

# ---------------------------------------------------------------------------
# 1. Octahedral direction set
# ---------------------------------------------------------------------------

DIRECTIONS = {
    '+x': np.array([ 1.0,  0.0,  0.0]),
    '-x': np.array([-1.0,  0.0,  0.0]),
    '+y': np.array([ 0.0,  1.0,  0.0]),
    '-y': np.array([ 0.0, -1.0,  0.0]),
    '+z': np.array([ 0.0,  0.0,  1.0]),
    '-z': np.array([ 0.0,  0.0, -1.0]),
}

AXIAL_POSITIVE = ['+x', '+y', '+z']

# ---------------------------------------------------------------------------
# 2. Three inversion pairs
# ---------------------------------------------------------------------------

PAIRS = {
    'A': ('+x', '-x'),
    'B': ('+y', '-y'),
    'C': ('+z', '-z'),
}

# ---------------------------------------------------------------------------
# 3. Construct the two three-cycles
# ---------------------------------------------------------------------------

def cycle_to_perm(cycle):
    """Convert a 3-cycle of pair labels into a permutation of the 6 directions."""
    perm = {}
    n = len(cycle)
    for i, lbl in enumerate(cycle):
        src = PAIRS[lbl]
        dst = PAIRS[cycle[(i + 1) % n]]
        perm[src[0]] = dst[0]
        perm[src[1]] = dst[1]
    return perm

def perm_to_rotation(perm):
    """Build the 3x3 orthogonal matrix realizing the permutation on positive axes."""
    R = np.zeros((3, 3))
    for j, src in enumerate(AXIAL_POSITIVE):
        R[:, j] = DIRECTIONS[perm[src]]
    return R

perm_ABC = cycle_to_perm(['A', 'B', 'C'])
perm_ACB = cycle_to_perm(['A', 'C', 'B'])

R_ABC = perm_to_rotation(perm_ABC)
R_ACB = perm_to_rotation(perm_ACB)

# ---------------------------------------------------------------------------
# 4. Extract rotation axis and signed angle
# ---------------------------------------------------------------------------

def extract_axis_angle(R):
    cos_theta = (np.trace(R) - 1.0) / 2.0
    cos_theta = np.clip(cos_theta, -1.0, 1.0)
    theta = np.arccos(cos_theta)
    evals, evecs = np.linalg.eig(R)
    idx = int(np.argmin(np.abs(evals - 1.0)))
    axis = np.real(evecs[:, idx])
    axis = axis / np.linalg.norm(axis)
    for c in axis:
        if abs(c) > 1e-10:
            if c < 0:
                axis = -axis
            break
    K_vec = np.array([
        R[2, 1] - R[1, 2],
        R[0, 2] - R[2, 0],
        R[1, 0] - R[0, 1],
    ]) / 2.0
    sin_theta_signed = np.dot(K_vec, axis)
    signed_angle = np.arctan2(sin_theta_signed, cos_theta)
    return axis, signed_angle

axis_ABC, angle_ABC = extract_axis_angle(R_ABC)
axis_ACB, angle_ACB = extract_axis_angle(R_ACB)

# ---------------------------------------------------------------------------
# 5. Verify the rotation is an octahedral automorphism
# ---------------------------------------------------------------------------

def is_octahedral_automorphism(R):
    for _, v in DIRECTIONS.items():
        w = R @ v
        ok = any(np.allclose(w, u, atol=1e-10) for u in DIRECTIONS.values())
        if not ok:
            return False
    return True

auto_ABC = is_octahedral_automorphism(R_ABC)
auto_ACB = is_octahedral_automorphism(R_ACB)

# ---------------------------------------------------------------------------
# 6. Projection factor and delta_CP
# ---------------------------------------------------------------------------

TIME_AXIS = np.array([0.0, 0.0, 1.0])
BODY_DIAG = np.array([1.0, 1.0, 1.0]) / np.sqrt(3.0)

cos_alpha = abs(float(np.dot(BODY_DIAG, TIME_AXIS)))   # = 1/sqrt(3)

theta_rad = abs(angle_ABC)                              # = 2*pi/3
delta_cp_rad = theta_rad * cos_alpha
delta_cp_deg = np.degrees(delta_cp_rad)

delta_cp_exact = 2.0 * np.pi * np.sqrt(3.0) / 9.0
delta_cp_exact_deg = np.degrees(delta_cp_exact)

delta_cp_exp_deg = 68.8
rel_dev = abs(delta_cp_deg - delta_cp_exp_deg) / delta_cp_exp_deg * 100.0

# ---------------------------------------------------------------------------
# 7. Report
# ---------------------------------------------------------------------------

def line(title):
    print("\n" + "=" * 72)
    print(title)
    print("=" * 72)

line("N.E.A. CP-Violation Candidate 1: Verification Report")

print("\n[1] Octahedral direction set")
for name in ['+x', '-x', '+y', '-y', '+z', '-z']:
    print(f"    {name} = {DIRECTIONS[name]}")

print("\n[2] Inversion pairs")
for lbl, (p, m) in PAIRS.items():
    print(f"    {lbl} = ({p}, {m})")

print("\n[3] Three-cycle A -> B -> C -> A")
print("    Permutation:")
for k in ['+x', '-x', '+y', '-y', '+z', '-z']:
    print(f"        {k} -> {perm_ABC[k]}")
print("    Rotation matrix R_ABC:")
print(R_ABC)
print(f"    Is octahedral automorphism: {auto_ABC}")

print("\n[4] Three-cycle A -> C -> B -> A")
print("    Permutation:")
for k in ['+x', '-x', '+y', '-y', '+z', '-z']:
    print(f"        {k} -> {perm_ACB[k]}")
print("    Rotation matrix R_ACB:")
print(R_ACB)
print(f"    Is octahedral automorphism: {auto_ACB}")

print("\n[5] Rotation axis and angle")
print(f"    R_ABC: axis = {axis_ABC}, signed angle = {np.degrees(angle_ABC):+.6f} deg")
print(f"    R_ACB: axis = {axis_ACB}, signed angle = {np.degrees(angle_ACB):+.6f} deg")
print(f"    (1,1,1)/sqrt(3) = {BODY_DIAG}")
print(f"    R_ACB == R_ABC^(-1): {np.allclose(R_ACB, R_ABC.T, atol=1e-12)}")
print(f"    R_ABC is a 120-deg rotation: {np.isclose(np.degrees(theta_rad), 120.0, atol=1e-9)}")

print("\n[6] Projection factor")
print(f"    Time axis m = {TIME_AXIS}")
print(f"    Rotation axis n = {BODY_DIAG}")
print(f"    n . m          = {cos_alpha:.12f}")
print(f"    1/sqrt(3)      = {1.0/np.sqrt(3.0):.12f}")

print("\n[7] delta_CP computation")
print(f"    Full rotation angle:    {np.degrees(theta_rad):.6f} deg  (= 120 deg)")
print(f"    Projection factor:      {cos_alpha:.12f}  (= 1/sqrt(3))")
print(f"    delta_CP (numeric):     {delta_cp_deg:.6f} deg  =  {delta_cp_rad:.12f} rad")
print(f"    delta_CP (exact):       {delta_cp_exact_deg:.6f} deg  =  {delta_cp_exact:.12f} rad")
print(f"    Experimental (CKM fit): {delta_cp_exp_deg:.6f} deg")
print(f"    Relative deviation:     {rel_dev:.4f}%")

print("\n[8] Robustness checks")
for axis_name, axis_vec in [('+x', np.array([1., 0., 0.])),
                             ('+y', np.array([0., 1., 0.])),
                             ('+z', np.array([0., 0., 1.]))]:
    c = abs(float(np.dot(BODY_DIAG, axis_vec)))
    d_deg = np.degrees((2.0 * np.pi / 3.0) * c)
    print(f"    Time axis {axis_name}: |n.m| = {c:.12f}, delta_CP = {d_deg:.6f} deg")

print(f"    Conjugate cycle A -> C -> B -> A gives: {-delta_cp_deg:+.6f} deg")
print(f"    Sign of delta_CP is fixed by the choice of time axis (+z, not -z).")

line("End of report")
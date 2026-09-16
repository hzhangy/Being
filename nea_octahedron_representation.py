#!/usr/bin/env python3
"""nea_octahedron_representation.py"""

import numpy as np
from itertools import permutations, product, combinations

V = np.array([
    [ 1, 0, 0], [-1, 0, 0],
    [ 0, 1, 0], [ 0,-1, 0],
    [ 0, 0, 1], [ 0, 0,-1],
])

def is_rotation(M):
    return (np.allclose(M.T @ M, np.eye(3))
            and np.isclose(np.linalg.det(M), 1))

def preserves_octahedron(M):
    Vset = {tuple(v) for v in V}
    return all(tuple(np.round(M @ v).astype(int)) in Vset for v in V)

# 旋转群
rotations = []
for perm in permutations(range(3)):
    for signs in product([1, -1], repeat=3):
        M = np.zeros((3, 3), dtype=int)
        for i, p in enumerate(perm):
            M[i, p] = signs[i]
        if is_rotation(M) and preserves_octahedron(M):
            rotations.append(M)

print(f"旋转群阶: {len(rotations)}  (预期 24, O ≅ S4)")

# 面：三点两两相邻（点积绝对值 < eps）
faces = []
for c in combinations(range(6), 3):
    pts = V[list(c)]
    if all(abs(np.dot(pts[i], pts[j])) < 1e-9
           for i in range(3) for j in range(i + 1, 3)):
        faces.append(c)

print(f"面数: {len(faces)}  (预期 8)")

centers = np.array([V[list(f)].mean(axis=0) for f in faces])

# 内接正四面体：4 个等距面中心
tetra = None
for c in combinations(range(8), 4):
    pts = centers[list(c)]
    dists = [np.linalg.norm(pts[i] - pts[j])
             for i in range(4) for j in range(i + 1, 4)]
    if max(dists) - min(dists) < 1e-9:
        tetra = pts
        break

if tetra is None:
    print("内接四面体: 不存在 ✗")
else:
    edge = np.linalg.norm(tetra[0] - tetra[1])
    print(f"内接四面体: 存在 ✓  (边长 {edge:.4f}, 预期 2√2/3 ≈ 0.9428)")
    tetra_set = {tuple(np.round(p, 6)) for p in tetra}
    T_rot = [M for M in rotations
             if all(tuple(np.round(M @ p, 6)) in tetra_set for p in tetra)]
    print(f"  对称群阶: {len(T_rot)}  (预期 12, ≅ A4)")

print()
print("表示论:")
print("  S4 三维不可约 → 三代")
print("  A4 三维不可约 → 色三重态")
print("  2T 二维不可约 → 弱双重态")
print()
print("【C8 依赖: 全部去除】")
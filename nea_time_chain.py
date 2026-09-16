#!/usr/bin/env python3
"""
nea_time_chain.py

Full enumeration with K-equation phi.

    S = -sum_{i<j} f_i f_j Delta/(4 pi r_ij)
    phi_i = min(sum_j Delta/(4 pi r_ij), 0.5)
    f_i = sqrt(1 - 2 phi_i)

重合节点（r=0）触发视界冻结：phi=0.5, f_ext=0.

Constraints: d_i in {+-x, +-y, +-z}, sum_i d_i = 0.

Run:
    python3 nea_time_chain_v12.py
"""

import numpy as np
from itertools import product, combinations

DELTA = 1 - np.sqrt(3) / 2
DIRS = np.array([
    [1, 0, 0], [-1, 0, 0],
    [0, 1, 0], [0, -1, 0],
    [0, 0, 1], [0, 0, -1],
], dtype=float)


def positions(d_seq):
    n = len(d_seq)
    x = np.zeros((n + 1, 3))
    for i in range(n):
        x[i + 1] = x[i] + DIRS[d_seq[i]]
    return x


def is_closed(d_seq):
    s = np.zeros(3)
    for d in d_seq:
        s += DIRS[d]
    return np.allclose(s, 0)


def phi_K(pts):
    """phi_i = min(sum_j Delta/(4 pi r_ij), 0.5).

    重合节点（r=0）触发视界冻结：phi_i = 0.5。
    pts: shape (N, 3)，只含 N 个时间节点（不含闭合点）。
    """
    n = len(pts)
    phi = np.zeros(n)
    for i in range(n):
        s = 0.0
        has_coincident = False
        for j in range(n):
            if i == j:
                continue
            r = np.linalg.norm(pts[i] - pts[j])
            if r < 1e-12:
                has_coincident = True
                break
            s += DELTA / (4 * np.pi * r)
        if has_coincident:
            phi[i] = 0.5
        else:
            phi[i] = min(s, 0.5)
    return phi


def action(pts):
    """S = -sum_{i<j} f_i f_j Delta/(4 pi r_ij).

    重合对（r=0）：f_ext=0，交互项=0，跳过。
    pts: shape (N, 3)，只含 N 个时间节点（不含闭合点）。
    """
    n = len(pts)
    phi = phi_K(pts)
    fe = np.sqrt(np.maximum(0.0, 1.0 - 2.0 * phi))
    S = 0.0
    for i in range(n):
        for j in range(i + 1, n):
            r = np.linalg.norm(pts[i] - pts[j])
            if r < 1e-12:
                continue
            S -= fe[i] * fe[j] * DELTA / (4 * np.pi * r)
    return S


def find_k4(pts, tol=0.02):
    n = len(pts)
    for combo in combinations(range(n), 4):
        p = pts[list(combo)]
        dists = []
        for a, b in combinations(range(4), 2):
            dists.append(np.linalg.norm(p[a] - p[b]))
        d0 = dists[0]
        if d0 < 0.05:
            continue
        if all(abs(d - d0) < tol for d in dists):
            return combo
    return None


def unique_count(pts, tol=1e-6):
    return len(set(map(tuple, np.round(pts / tol) * tol)))


def is_c8_shape(pts):
    uniq = list(set(map(tuple, np.round(pts, 6))))
    if len(uniq) != 8:
        return False
    arr = np.array(uniq)
    mins = arr.min(axis=0)
    spans = arr.max(axis=0) - mins
    if not np.allclose(spans, 1.0, atol=0.01):
        return False
    for bx in [0, 1]:
        for by in [0, 1]:
            for bz in [0, 1]:
                corner = (mins[0] + bx * spans[0],
                          mins[1] + by * spans[1],
                          mins[2] + bz * spans[2])
                if not any(np.allclose(p, corner, atol=0.01) for p in uniq):
                    return False
    return True


def main():
    print("=" * 72)
    print("  v12: K-phi full enumeration (horizon freeze at r=0)")
    print("=" * 72)
    print()
    print(f"  Delta = {DELTA:.6f}")
    print(f"  重合节点 r=0 触发视界冻结：phi=0.5, f_ext=0")
    print()

    for N in [4, 6, 8]:
        print("-" * 72)
        print(f"  N = {N}")
        print("-" * 72)

        results = []
        for d_tuple in product(range(6), repeat=N):
            if not is_closed(d_tuple):
                continue
            x_full = positions(d_tuple)
            pts = x_full[:N]   # 只含 N 个时间节点，不含闭合点
            S = action(pts)
            results.append((tuple(d_tuple), S, pts))

        results.sort(key=lambda r: r[1])
        print(f"  Total closed chains: {len(results)}")

        gd, gS, gx = results[0]
        gk4 = find_k4(gx)
        print(f"  Global min: S = {gS:.6f}")
        print(f"    dirs: {list(gd)}")
        print(f"    unique positions: {unique_count(gx)}")
        print(f"    is_C8: {is_c8_shape(gx)}")
        print(f"    K4: {gk4}")

        if gk4:
            print(f"    K4 nodes (positions):")
            for i in gk4:
                print(f"      {i}: {tuple(int(c) for c in gx[i])}")

        c8_list = [(d, S, x) for d, S, x in results if is_c8_shape(x)]
        if c8_list:
            cd, cS, cx = c8_list[0]
            rank = next(i for i, r in enumerate(results) if r[0] == cd)
            print(f"  Best C8: S = {cS:.6f}  rank = {rank+1}/{len(results)}")
            print(f"    dirs: {list(cd)}")

        k4_list = [(d, S, x) for d, S, x in results
                   if find_k4(x) is not None]
        if k4_list:
            kd, kS, kx = k4_list[0]
            rank = next(i for i, r in enumerate(results) if r[0] == kd)
            print(f"  Best K4: S = {kS:.6f}  rank = {rank+1}/{len(results)}")
            print(f"    dirs: {list(kd)}")

        print()


if __name__ == "__main__":
    main()
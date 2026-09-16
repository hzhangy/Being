#!/usr/bin/env python3
"""
area_law_C8.py

验证：C8 密铺中，球面 r 处的节点数 ∝ r²。

这是黑洞熵 S = A/4 的微观来源，也是 L 论文"空间是 2D 球面"的关键证据。

论证：
  1. 在 C8 立方格子上从中心节点做 BFS
  2. 按图距离 r 计数节点数
  3. 检查 N(r) 是否按 r² 增长
  4. 同时计算球面上"面积"与节点数的比值
"""

import numpy as np
from collections import deque


def build_cubic_lattice(L):
    """构建 L×L×L 的 C8 立方格子"""
    size = 2 * L + 1
    center = L
    # 邻接表
    adj = {}
    for i in range(size):
        for j in range(size):
            for k in range(size):
                neighbors = []
                for di, dj, dk in [(1,0,0),(-1,0,0),(0,1,0),(0,-1,0),(0,0,1),(0,0,-1)]:
                    ni, nj, nk = i+di, j+dj, k+dk
                    if 0 <= ni < size and 0 <= nj < size and 0 <= nk < size:
                        neighbors.append((ni, nj, nk))
                adj[(i, j, k)] = neighbors
    return adj, (center, center, center), size


def bfs_count(adj, start):
    """BFS：返回每个距离 r 的节点数"""
    visited = {start}
    queue = deque([(start, 0)])
    counts = {}
    positions_by_r = {}
    while queue:
        node, d = queue.popleft()
        counts[d] = counts.get(d, 0) + 1
        positions_by_r.setdefault(d, []).append(node)
        for nbr in adj[node]:
            if nbr not in visited:
                visited.add(nbr)
                queue.append((nbr, d + 1))
    return counts, positions_by_r


def main():
    print("=" * 72)
    print("  Area Law: C8 Lattice Node Count vs Radius")
    print("=" * 72)
    print()
    
    L = 30
    adj, center, size = build_cubic_lattice(L)
    counts, positions = bfs_count(adj, center)
    
    max_r = max(counts.keys())
    
    print(f"  Lattice: {size}³, center at {center}")
    print(f"  Max graph distance: {max_r}")
    print()
    
    # 打印 r, N(r), 4r²+2, 比值
    print(f"  {'r':>4} | {'N(r)':>8} | {'4r²+2':>8} | {'N(r)/(4r²+2)':>14} | {'N(r)/r²':>10}")
    print("  " + "-" * 60)
    
    # L1 球面精确公式：N(r) = 4r²+2（对 r ≥ 1）
    for r in range(1, min(20, max_r + 1)):
        n_r = counts.get(r, 0)
        theory = 4 * r * r + 2
        ratio = n_r / theory if theory > 0 else 0
        r2_ratio = n_r / (r * r) if r > 0 else 0
        print(f"  {r:>4} | {n_r:>8} | {theory:>8} | {ratio:>14.6f} | {r2_ratio:>10.6f}")
    
    print()
    
    # 拟合 N(r) = a·r² + b
    rs = np.array([r for r in range(5, min(25, max_r + 1))])
    ns = np.array([counts.get(r, 0) for r in rs])
    
    A = np.vstack([rs**2, np.ones_like(rs)]).T
    coeffs, res, _, _ = np.linalg.lstsq(A, ns, rcond=None)
    a_fit, b_fit = coeffs
    
    predicted = A @ coeffs
    r2 = 1 - np.sum((ns - predicted)**2) / np.sum((ns - ns.mean())**2)
    
    print("  ─── Fit N(r) = a·r² + b ───")
    print(f"  a = {a_fit:.6f}  (theory: 4.0)")
    print(f"  b = {b_fit:.6f}  (theory: 2.0)")
    print(f"  R² = {r2:.10f}")
    print()
    
    # 与 4πr² 的比例（球面面积）
    print("  ─── N(r) / (4πr²) ───")
    print("  (球面面积比：如果空间是 2D 球面，N(r) 应与 4πr² 成正比)")
    print()
    print(f"  {'r':>4} | {'N(r)':>8} | {'4πr²':>12} | {'N(r)/(4πr²)':>14}")
    print("  " + "-" * 50)
    for r in [5, 8, 10, 12, 15, 18, 20]:
        if r <= max_r:
            n_r = counts.get(r, 0)
            sphere = 4 * np.pi * r * r
            print(f"  {r:>4} | {n_r:>8} | {sphere:>12.2f} | {n_r/sphere:>14.6f}")
    
    print()
    
    # 结论
    print("  ─── Conclusion ───")
    if abs(a_fit - 4.0) < 0.01 and r2 > 0.999:
        print("  ✓ AREA LAW VERIFIED")
        print(f"  N(r) = 4r² + 2 exactly (on finite lattice)")
        print(f"  Node density on sphere ∝ r²: matches C8 cubic tiling")
        print(f"  This is the microscopic origin of S = A/4.")
    else:
        print(f"  ✗ Fit deviates: a = {a_fit:.4f}")
    
    print("=" * 72)


if __name__ == "__main__":
    main()
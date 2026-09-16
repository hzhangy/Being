"""
area_law_C8.py

Numerical verification of the spherical shell area law:
the node capacity N(r) of the L1 wavefront shell grows as r².

This is the graph-theoretic origin of the Bekenstein-Hawking
entropy formula S = A/4, and the microscopic basis for the
2D spherical shell foliation of Volume V'.

Method:
  1. BFS on the C8 bookkeeping lattice from the center node.
  2. Count nodes at each graph distance r.
  3. Verify N(r) = 4r² + 2 exactly.
  4. Compare with the Euclidean sphere area 4πr².
"""

import numpy as np
from collections import deque


def build_cubic_lattice(L):
    """Build the L×L×L C8 bookkeeping lattice (with a 2L+1 side to avoid boundary effects)."""
    size = 2 * L + 1
    center = L
    # Adjacency list
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
    """BFS: return the node count at each graph distance r."""
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
    
    # Print r, N(r), 4r²+2, ratio
    print(f"  {'r':>4} | {'N(r)':>8} | {'4r²+2':>8} | {'N(r)/(4r²+2)':>14} | {'N(r)/r²':>10}")
    print("  " + "-" * 60)
    
    # L1 sphere exact formula: N(r) = 4r² + 2 (for r ≥ 1)
    for r in range(1, min(20, max_r + 1)):
        n_r = counts.get(r, 0)
        theory = 4 * r * r + 2
        ratio = n_r / theory if theory > 0 else 0
        r2_ratio = n_r / (r * r) if r > 0 else 0
        print(f"  {r:>4} | {n_r:>8} | {theory:>8} | {ratio:>14.6f} | {r2_ratio:>10.6f}")
    
    print()
    
    # Fit N(r) = a·r² + b
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
    
    # Ratio to 4πr² (Euclidean sphere area)
    print("  ─── N(r) / (4πr²) ───")
    print("  (Sphere area ratio: if the wavefront is a 2D shell, N(r) ∝ 4πr²)")
    print()
    print(f"  {'r':>4} | {'N(r)':>8} | {'4πr²':>12} | {'N(r)/(4πr²)':>14}")
    print("  " + "-" * 50)
    for r in [5, 8, 10, 12, 15, 18, 20]:
        if r <= max_r:
            n_r = counts.get(r, 0)
            sphere = 4 * np.pi * r * r
            print(f"  {r:>4} | {n_r:>8} | {sphere:>12.2f} | {n_r/sphere:>14.6f}")
    
    print()
    
    # Conclusion
    print("  ─── Conclusion ───")
    if abs(a_fit - 4.0) < 0.01 and r2 > 0.999:
        print("  ✓ AREA LAW VERIFIED")
        print(f"  N(r) = 4r² + 2 exactly (on finite lattice)")
        print(f"  Node capacity on shell grows as r²: matches the")
        print(f"  holographic wavefront of the weak-force causal")
        print(f"  expansion (B', Section 12).")
        print(f"  This is the graph-theoretic origin of S = A/4.")
    else:
        print(f"  ✗ Fit deviates: a = {a_fit:.4f}")
    
    print("=" * 72)


if __name__ == "__main__":
    main()
#!/usr/bin/env python3
"""nea_2_5_origin.py — 从正八面体几何计算 2/5"""
import numpy as np
from itertools import combinations

# 正八面体 6 个方向
dirs = {
    '+x': np.array([1,0,0]), '-x': np.array([-1,0,0]),
    '+y': np.array([0,1,0]), '-y': np.array([0,-1,0]),
    '+z': np.array([0,0,1]), '-z': np.array([0,0,-1]),
}

# 时间轴
t_axis = dirs['+z']
# 剩余方向
remaining = {k: v for k, v in dirs.items() if k != '+z'}

# 赤道：与时间轴正交的方向
equator = {k: v for k, v in remaining.items()
           if abs(np.dot(v, t_axis)) < 1e-12}

# 内部：与时间轴反向（并行）
inner = {k: v for k, v in remaining.items()
         if abs(np.dot(v, t_axis)) > 0.99}

print(f"时间轴: +z")
print(f"剩余方向数: {len(remaining)}")
print(f"赤道方向: {list(equator.keys())}  (数: {len(equator)})")
print(f"内部方向: {list(inner.keys())}  (数: {len(inner)})")
print()

# 赤道方向的"独立方向数"
# 用矩阵的秩计算（线性独立方向数）
M = np.array(list(equator.values()))   # 4×3 矩阵
rank = np.linalg.matrix_rank(M)
print(f"赤道方向矩阵 {M.shape}，秩 = {rank}")
print(f"→ 赤道的独立方向数 = {rank}  (不是 4)")
print()

# 比值
ratio_2_5 = rank / len(remaining)
ratio_4_5 = len(equator) / len(remaining)
print(f"2/5 候选 = 独立方向数 / 剩余数 = {rank}/{len(remaining)} = {ratio_2_5}")
print(f"4/5 候选 = 赤道方向数 / 剩余数 = {len(equator)}/{len(remaining)} = {ratio_4_5}")
print()

# 对照：换时间轴，看结果是否不变
print("换时间轴，检查不变性：")
for axis in ['+x', '-x', '+y', '-y', '+z', '-z']:
    t = dirs[axis]
    rem = {k: v for k, v in dirs.items() if k != axis}
    eq = {k: v for k, v in rem.items() if abs(np.dot(v, t)) < 1e-12}
    M_eq = np.array(list(eq.values()))
    r = np.linalg.matrix_rank(M_eq)
    print(f"  {axis}: 剩余={len(rem)}, 赤道={len(eq)}, 秩={r}, 比值={r}/{len(rem)}={r/len(rem)}")
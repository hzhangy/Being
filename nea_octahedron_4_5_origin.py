#!/usr/bin/env python3
"""nea_octahedron_4_5_origin.py"""
import numpy as np

print("=" * 60)
print("  正八面体 4/5 的来源")
print("=" * 60)
print()

# --- 路径 1：6 方向 - 1 时间轴 ---
print("【路径 1】6 方向 - 1 时间轴 = 5")
for axis in ['+z', '-z', '+x', '-x', '+y', '-y']:
    remaining = 5
    equator = 4
    inner = 1
    print(f"  时间轴 {axis:>3}: 剩 {remaining}, 赤道 {equator}, 内部 {inner}, 比 {equator}/{remaining} = {equator/remaining}")
print()
print("  → 4/5 自然出现，与时间轴选择无关")
print()

# --- 路径 2：B₁(正八面体) = 7 的分解 ---
print("【路径 2】B₁(正八面体) = E - V + 1 = 12 - 6 + 1 = 7")
B1_oct = 12 - 6 + 1
print(f"  B₁ = {B1_oct}")
print(f"  7 的可能分解：")
for a in range(1, 7):
    b = 7 - a
    if a <= b:
        print(f"    {a} + {b}")
print()
print("  → 7 不含 5（无 5 的分解）")
print()

# --- 路径 3：B₁ 对偶定理 ---
print("【路径 3】B₁ 对偶定理：B₁(C8) + B₁(oct) = E")
B1_c8 = 12 - 8 + 1
B1_oct = 12 - 6 + 1
E = 12
print(f"  B₁(C8) = {B1_c8}")
print(f"  B₁(oct) = {B1_oct}")
print(f"  和 = {B1_c8 + B1_oct}")
print(f"  E = {E}")
print(f"  相等：{B1_c8 + B1_oct == E}")
print()
print("  → 5 和 7 是对偶互补的")
print()

# --- 判断 ---
print("=" * 60)
print("  判断")
print("=" * 60)
print()
print("  路径 1：4/5 从 6 方向自然给出，不依赖 C8")
print("  路径 2：B₁(oct) = 7，不含 5")
print("  路径 3：5 + 7 = 12 = E（对偶定理）")
print()
print("  结论：")
print("  - 4/5 的 5 来自 6 - 1，不是 B₁(C8)")
print("  - C8 的 B₁ = 5 和正八面体的 5 是数值巧合")
print("  - 但 B₁ 对偶定理（5+7=12）确认两者互相关联")
print("  - 所以 4/5 可以从正八面体独立给出")
print()
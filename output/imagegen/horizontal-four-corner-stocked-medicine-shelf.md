# 横向四角柱满药架（原药品精确复用版）

- 最终制作方式：确定性像素合成，不生成或补画药品
- 药架底图：`clinic_medicine_gondola_horizontal_no_center_bar_topdown.png`
- 药品来源：`clinic_medicine_gondola_shelf_topdown_512x512.png`
- 用途：Unity 2D 俯视角医院药品储藏室素材

## 最终处理说明

从原满药架中提取全部 12 件既有药品，保持原来的数量、种类、颜色和相对摆放，不新增、不删除、不替换药品。将这些原始药品像素按原药架与新药架的尺寸比例叠放到横向四角柱空药架上。四个角柱、透明背景、784 像素有效宽度及 Unity PPU 均保持不变。

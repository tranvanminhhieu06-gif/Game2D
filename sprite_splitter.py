"""
=============================================================
  SPRITE SHEET SPLITTER - Tách Sprite Sheet theo Tư Thế
=============================================================
  Hỗ trợ 2 chế độ:
  1. SINGLE: 1 sprite sheet chứa tất cả tư thế (mỗi hàng = 1 tư thế)
  2. MULTI:  Mỗi tư thế là 1 file sprite sheet riêng

  Cắt theo grid đều (các frame cùng kích thước)
=============================================================
"""

import os
import sys
from PIL import Image


# ===================== CẤU HÌNH MẶC ĐỊNH =====================
# Danh sách tên tư thế (thứ tự tương ứng với hàng trong sprite sheet)
DEFAULT_POSES = ["Idle", "Run", "Attack", "Dash"]

# Thư mục xuất mặc định
DEFAULT_OUTPUT_DIR = "Sprites_Output"


def split_single_sheet(
    image_path: str,
    character_name: str,
    cols: int,
    rows: int = None,
    pose_names: list = None,
    output_dir: str = None,
    row_frame_counts: list = None,
):
    """
    Tách 1 sprite sheet lớn chứa nhiều tư thế (mỗi hàng = 1 tư thế).

    Args:
        image_path:      Đường dẫn tới file sprite sheet
        character_name:  Tên nhân vật (dùng đặt tên thư mục/file)
        cols:            Số cột (số frame tối đa trên mỗi hàng)
        rows:            Số hàng (nếu None, tự tính từ số tư thế)
        pose_names:      Danh sách tên tư thế theo thứ tự hàng
        output_dir:      Thư mục xuất
        row_frame_counts: Số frame thực tế cho từng hàng (nếu mỗi hàng
                          có số frame khác nhau). VD: [4, 6, 8, 3]
    """
    if pose_names is None:
        pose_names = DEFAULT_POSES
    if output_dir is None:
        output_dir = DEFAULT_OUTPUT_DIR
    if rows is None:
        rows = len(pose_names)

    # Mở ảnh
    img = Image.open(image_path)
    sheet_w, sheet_h = img.size
    frame_w = sheet_w // cols
    frame_h = sheet_h // rows

    print(f"\n{'='*60}")
    print(f"  SPRITE SHEET SPLITTER")
    print(f"{'='*60}")
    print(f"  Ảnh:           {os.path.basename(image_path)}")
    print(f"  Kích thước:    {sheet_w} x {sheet_h} px")
    print(f"  Grid:          {cols} cột x {rows} hàng")
    print(f"  Frame:         {frame_w} x {frame_h} px")
    print(f"  Nhân vật:      {character_name}")
    print(f"  Tư thế:        {', '.join(pose_names[:rows])}")
    print(f"{'='*60}\n")

    total_saved = 0

    for row_idx in range(rows):
        if row_idx >= len(pose_names):
            pose = f"Pose_{row_idx + 1}"
        else:
            pose = pose_names[row_idx]

        # Số frame cho hàng này
        num_frames = row_frame_counts[row_idx] if row_frame_counts else cols

        # Tạo thư mục: output/CharName/Pose/
        pose_dir = os.path.join(output_dir, character_name, pose)
        os.makedirs(pose_dir, exist_ok=True)

        print(f"  ▸ {pose:12s}  ({num_frames} frames)")

        for col_idx in range(num_frames):
            x = col_idx * frame_w
            y = row_idx * frame_h
            frame = img.crop((x, y, x + frame_w, y + frame_h))

            # Kiểm tra frame có rỗng không (hoàn toàn trong suốt)
            if frame.mode == "RGBA":
                bbox = frame.getbbox()
                if bbox is None:
                    print(f"    ⚠ Frame {col_idx} trống, bỏ qua")
                    continue

            filename = f"{character_name}_{pose}_{col_idx:03d}.png"
            frame.save(os.path.join(pose_dir, filename))
            total_saved += 1

    print(f"\n  ✅ Đã lưu {total_saved} frame vào: {os.path.abspath(output_dir)}/")
    print(f"{'='*60}\n")
    return total_saved


def split_multi_sheets(
    sheet_paths: dict,
    character_name: str,
    cols_per_pose: dict = None,
    default_cols: int = 6,
    output_dir: str = None,
):
    """
    Tách nhiều sprite sheet riêng lẻ (mỗi file = 1 tư thế).

    Args:
        sheet_paths:    Dict {tên_tư_thế: đường_dẫn_file}
                        VD: {"Idle": "idle.png", "Run": "run.png"}
        character_name: Tên nhân vật
        cols_per_pose:  Dict {tên_tư_thế: số_cột} (nếu mỗi tư thế
                        có số frame khác nhau)
        default_cols:   Số cột mặc định nếu không chỉ định riêng
        output_dir:     Thư mục xuất
    """
    if output_dir is None:
        output_dir = DEFAULT_OUTPUT_DIR
    if cols_per_pose is None:
        cols_per_pose = {}

    print(f"\n{'='*60}")
    print(f"  MULTI-SHEET SPLITTER")
    print(f"{'='*60}")
    print(f"  Nhân vật:      {character_name}")
    print(f"  Số tư thế:     {len(sheet_paths)}")
    print(f"{'='*60}\n")

    total_saved = 0

    for pose, path in sheet_paths.items():
        if not os.path.exists(path):
            print(f"  ❌ Không tìm thấy: {path}")
            continue

        img = Image.open(path)
        w, h = img.size

        # Số cột cho tư thế này
        cols = cols_per_pose.get(pose, default_cols)

        # Nếu ảnh chỉ có 1 hàng
        rows = 1
        frame_w = w // cols
        frame_h = h // rows

        pose_dir = os.path.join(output_dir, character_name, pose)
        os.makedirs(pose_dir, exist_ok=True)

        print(f"  ▸ {pose:12s}  {os.path.basename(path):30s}  "
              f"({w}x{h}, {cols} frames, mỗi frame {frame_w}x{frame_h})")

        for col_idx in range(cols):
            x = col_idx * frame_w
            y = 0
            frame = img.crop((x, y, x + frame_w, y + frame_h))

            # Kiểm tra frame rỗng
            if frame.mode == "RGBA":
                bbox = frame.getbbox()
                if bbox is None:
                    continue

            filename = f"{character_name}_{pose}_{col_idx:03d}.png"
            frame.save(os.path.join(pose_dir, filename))
            total_saved += 1

    print(f"\n  ✅ Đã lưu {total_saved} frame vào: {os.path.abspath(output_dir)}/")
    print(f"{'='*60}\n")
    return total_saved


def interactive_mode():
    """Chế độ tương tác - hướng dẫn người dùng từng bước."""

    print(r"""
    ╔══════════════════════════════════════════════════════╗
    ║         🎮 SPRITE SHEET SPLITTER v1.0 🎮            ║
    ║     Tách sprite sheet theo tư thế chuyển động       ║
    ╚══════════════════════════════════════════════════════╝
    """)

    # Chọn chế độ
    print("  Chọn chế độ:")
    print("    [1] SINGLE - 1 sprite sheet chứa tất cả tư thế (mỗi hàng = 1 tư thế)")
    print("    [2] MULTI  - Mỗi tư thế là 1 file sprite sheet riêng")
    print()

    mode = input("  Nhập lựa chọn (1 hoặc 2): ").strip()

    # Tên nhân vật
    character_name = input("  Tên nhân vật: ").strip()
    if not character_name:
        character_name = "Character"

    # Thư mục xuất
    output_input = input(f"  Thư mục xuất (Enter = {DEFAULT_OUTPUT_DIR}): ").strip()
    output_dir = output_input if output_input else DEFAULT_OUTPUT_DIR

    if mode == "1":
        # ===== CHẾ ĐỘ SINGLE =====
        image_path = input("  Đường dẫn sprite sheet: ").strip().strip('"')
        if not os.path.exists(image_path):
            print(f"\n  ❌ Không tìm thấy file: {image_path}")
            return

        cols = int(input("  Số cột (số frame mỗi hàng): ").strip())

        # Tên tư thế
        pose_input = input(
            f"  Tên tư thế theo thứ tự hàng (phẩy ngăn cách)\n"
            f"  (Enter = {', '.join(DEFAULT_POSES)}): "
        ).strip()

        if pose_input:
            pose_names = [p.strip() for p in pose_input.split(",")]
        else:
            pose_names = DEFAULT_POSES

        rows_input = input(
            f"  Số hàng (Enter = {len(pose_names)}): "
        ).strip()
        rows = int(rows_input) if rows_input else len(pose_names)

        # Số frame mỗi hàng (tùy chọn)
        row_fc_input = input(
            "  Số frame mỗi hàng (phẩy ngăn cách, Enter = tất cả bằng nhau): "
        ).strip()
        row_frame_counts = None
        if row_fc_input:
            row_frame_counts = [int(x.strip()) for x in row_fc_input.split(",")]

        split_single_sheet(
            image_path=image_path,
            character_name=character_name,
            cols=cols,
            rows=rows,
            pose_names=pose_names,
            output_dir=output_dir,
            row_frame_counts=row_frame_counts,
        )

    elif mode == "2":
        # ===== CHẾ ĐỘ MULTI =====
        print(f"\n  Nhập đường dẫn cho từng tư thế (Enter để bỏ qua):\n")

        pose_input = input(
            f"  Danh sách tư thế (phẩy ngăn cách)\n"
            f"  (Enter = {', '.join(DEFAULT_POSES)}): "
        ).strip()

        if pose_input:
            poses = [p.strip() for p in pose_input.split(",")]
        else:
            poses = DEFAULT_POSES

        sheet_paths = {}
        cols_per_pose = {}

        for pose in poses:
            path = input(f"    {pose} - đường dẫn file: ").strip().strip('"')
            if path and os.path.exists(path):
                sheet_paths[pose] = path
                c = input(f"    {pose} - số frame (cột): ").strip()
                if c:
                    cols_per_pose[pose] = int(c)
            elif path:
                print(f"    ⚠ Không tìm thấy: {path}, bỏ qua")

        default_cols_input = input(
            "  Số frame mặc định cho các tư thế chưa chỉ định (Enter = 6): "
        ).strip()
        default_cols = int(default_cols_input) if default_cols_input else 6

        if not sheet_paths:
            print("\n  ❌ Không có file nào hợp lệ!")
            return

        split_multi_sheets(
            sheet_paths=sheet_paths,
            character_name=character_name,
            cols_per_pose=cols_per_pose,
            default_cols=default_cols,
            output_dir=output_dir,
        )

    else:
        print("  ❌ Lựa chọn không hợp lệ!")


# ===================== VÍ DỤ SỬ DỤNG =====================
def example_single():
    """Ví dụ: Tách 1 sprite sheet có 4 hàng x 6 cột."""
    split_single_sheet(
        image_path="warrior_spritesheet.png",
        character_name="Warrior",
        cols=6,
        rows=4,
        pose_names=["Idle", "Run", "Attack", "Dash"],
        # Nếu mỗi hàng có số frame khác nhau:
        # row_frame_counts=[4, 6, 8, 3],
    )


def example_multi():
    """Ví dụ: Tách 4 sprite sheet riêng lẻ."""
    split_multi_sheets(
        sheet_paths={
            "Idle":   "warrior_idle.png",
            "Run":    "warrior_run.png",
            "Attack": "warrior_attack.png",
            "Dash":   "warrior_dash.png",
        },
        character_name="Warrior",
        cols_per_pose={
            "Idle":   4,
            "Run":    6,
            "Attack": 8,
            "Dash":   3,
        },
    )


# ===================== MAIN =====================
if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--example":
        print("Chạy ví dụ single sheet...")
        example_single()
    else:
        interactive_mode()

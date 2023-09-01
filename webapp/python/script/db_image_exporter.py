# Warning: mysqlのデータを初期化状態にして(make down-all)から実行してください

import os

import MySQLdb

# データベース接続の設定
db_host = os.environ.get("ISUCONP_DB_HOST", "localhost")
db_user = os.environ.get("ISUCONP_DB_USER", "root")
db_password = os.environ.get("ISUCONP_DB_PASSWORD", None)
db_name = os.environ.get("ISUCONP_DB_NAME", "isuconp")

# 画像を保存するディレクトリのパス
image_dir = "image"
os.makedirs(image_dir, exist_ok=True)


def save_image_from_db(cursor, img_id, img_ext):
    cursor.execute("SELECT `imgdata` FROM `posts` WHERE `id` = %s", (img_id,))
    img_data = cursor.fetchone()["imgdata"]

    # 画像ファイルのパスを組み立て
    img_filename = f"{img_id}{img_ext}"
    img_path = os.path.join(image_dir, img_filename)

    # 画像データをディスクに保存
    with open(img_path, "wb") as img_file:
        img_file.write(img_data)

    print(f"Image saved: {img_path}")


def main():
    # データベース接続
    connection = MySQLdb.connect(
        host=db_host, user=db_user, passwd=db_password, db=db_name
    )
    cursor = connection.cursor(MySQLdb.cursors.DictCursor)

    # データベースから画像データを取得
    # imgdataまで取得するとメモリ不足で落ちる
    cursor.execute("SELECT `id`, `mime` FROM `posts`")
    id_ext_pairs = cursor.fetchall()
    print(f"len(posts): {len(id_ext_pairs)}")

    # 画像を保存
    for pair in id_ext_pairs:
        img_id = pair["id"]

        if pair["mime"] == "image/jpeg":
            img_ext = ".jpg"
        elif pair["mime"] == "image/png":
            img_ext = ".png"
        elif pair["mime"] == "image/gif":
            img_ext = ".gif"

        save_image_from_db(cursor, img_id, img_ext)

    # 接続を閉じる
    cursor.close()
    connection.close()


if __name__ == "__main__":
    main()

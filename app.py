from flask import Flask, render_template, request, redirect
import psycopg2
import os

app = Flask(__name__)


def get_db_connection():
    return psycopg2.connect(
        host=os.getenv("DB_HOST"),
        database=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        port=os.getenv("DB_PORT", "5432")
    )


@app.route("/", methods=["GET", "POST"])
def home():
    if request.method == "POST":
        name = request.form["name"].strip()

        if name:
            conn = get_db_connection()
            cur = conn.cursor()

            cur.execute(
                "INSERT INTO names (name) VALUES (%s)",
                (name,)
            )

            conn.commit()
            cur.close()
            conn.close()

        return redirect("/")

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("SELECT name FROM names ORDER BY id DESC")
    names = cur.fetchall()

    cur.close()
    conn.close()

    client_ip = request.remote_addr

    return render_template(
        "index.html",
        names=names,
        client_ip=client_ip
    )


@app.route("/health")
def health():
    return "OK", 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
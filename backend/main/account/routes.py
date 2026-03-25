from flask import blueprints
from flask import request
from flask import abort

import bcrypt

from main.database import Database
from main.paths import PROJECT_MAIN

account_bp = blueprints.Blueprint('account', __name__)


@account_bp.route('/create-account', methods=['POST'])
def create_account():
    # todo: include dietary preferences
    # Validate form first
    if "user_fname" not in request.form:
        abort(400)

    if "user_lname" not in request.form:
        abort(400)

    if "user_password" not in request.form:
        abort(400)

    if "user_email" not in request.form:
        abort(400)

    user_fname = request.form['user_fname']
    user_lname = request.form['user_lname']
    user_password = request.form['user_password']
    user_email = request.form['user_email']

    password_in_bytes = user_password.encode("UTF-8")

    hashed_password = bcrypt.hashpw(password_in_bytes,bcrypt.gensalt())

    db = Database()
    with db.get_connection() as con:
        cur = con.cursor()
        with open(PROJECT_MAIN / "account/sql/create_user.sql", 'r') as sql_file:
            sql = sql_file.read()
            cur.execute(sql, (user_fname, user_lname,user_email,hashed_password))

        user_id = cur.lastrowid

    return {
        "user_id": user_id
    }, 201

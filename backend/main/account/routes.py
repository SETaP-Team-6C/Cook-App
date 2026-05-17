import re

from flask import blueprints, current_app
from flask import request
from flask import abort

from main.database import Database
from main.paths import PROJECT_MAIN

account_bp = blueprints.Blueprint('account', __name__)

# A local part and a domain separated by '@', neither containing '@' or whitespace
EMAIL_PATTERN = re.compile(r"^[^@\s]+@[^@\s]+$")
MIN_PASSWORD_LENGTH = 6
MAX_EMAIL_LENGTH = 320


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

    user_fname = request.form['user_fname'].strip()
    user_lname = request.form['user_lname'].strip()
    user_password = request.form['user_password']
    user_email = request.form['user_email'].strip()

    # Reject blank fields
    if not user_fname or not user_lname or not user_password or not user_email:
        abort(400, "all fields are required")

    # Validate email length and format
    if len(user_email) > MAX_EMAIL_LENGTH:
        abort(400, "email is too long")
    if not EMAIL_PATTERN.match(user_email):
        abort(400, "email format is invalid")

    # Validate password length
    if len(user_password) < MIN_PASSWORD_LENGTH:
        abort(400, f"password must be at least {MIN_PASSWORD_LENGTH} characters")

    with Database(current_app) as con:
        cur = con.cursor()

        # Reject an email that already belongs to an account
        with open(PROJECT_MAIN / "account/sql/email_exists.sql", 'r') as sql_file:
            cur.execute(sql_file.read(), (user_email,))
            if cur.fetchone() is not None:
                abort(409, "an account with this email already exists")

        with open(PROJECT_MAIN / "account/sql/create_user.sql", 'r') as sql_file:
            sql = sql_file.read()
            cur.execute(sql, (user_fname, user_lname, user_email, user_password))

            con.commit()

        user_id = cur.lastrowid

    return {
        "user_id": user_id
    }, 201

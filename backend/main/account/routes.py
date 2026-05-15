from flask import blueprints, current_app
from flask import request
from flask import abort

from main.database import Database
from main.paths import PROJECT_MAIN

account_bp = blueprints.Blueprint('account', __name__)


@account_bp.route('/create-account', methods=['POST'])
def create_account():
    # todo: include dietary preferences
    # Validate form first
    if not request.form:
        abort(400)

    if not request.form.get("user_fname"):
        abort(400)

    if not request.form.get("user_lname"):
        abort(400)

    if not request.form.get("user_email"):
        abort(400)

    if not request.form.get("user_password"):
        abort(400)

    user_fname = request.form['user_fname']
    user_lname = request.form['user_lname']
    user_password = request.form['user_password']
    user_email = request.form['user_email']

    with Database(current_app) as con:
        cur = con.cursor()
        with open(PROJECT_MAIN / "account/sql/create_user.sql", 'r') as sql_file:
            sql = sql_file.read()
            cur.execute(sql, (user_fname, user_lname, user_email, user_password))
            #added fix

            con.commit()

        user_id = cur.lastrowid

    return {
        "user_id": user_id
    }, 201

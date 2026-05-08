from flask import blueprints, current_app
from flask import request
from flask import abort
from flask import session

from main.database import Database
from main.paths import PROJECT_MAIN

authentication_bp = blueprints.Blueprint('authentication', __name__)


@authentication_bp.route('/authenticate', methods=['POST'])
def authenticate():
    # Validate form first
    if "user_fname" not in request.form:
        abort(400)

    if "user_lname" not in request.form:
        abort(400)

    if "user_password" not in request.form:
        abort(400)

    # Use first and last names to get the user ID from the database
    user_fname = request.form['user_fname']
    user_lname = request.form['user_lname']
    user_password = request.form['user_password']

    with Database(current_app) as con:
        cur = con.cursor()
        with open(PROJECT_MAIN / "authentication/sql/get_user.sql", 'r') as sql_file:
            sql = sql_file.read()
            cur.execute(sql, (user_fname, user_lname))

        user = cur.fetchone()

        if user is None:
            # No user exists or information wrong so return not authenticated
            return {"success": False}, 401

        user = dict(user)

        if user["user_password"] != user_password:
            return {"success": False}, 401

        del user["user_password"]

    session["user_id"] = user["user_id"]
    return {"success": True, "user": user}

from flask import blueprints, jsonify
from flask import request
from flask import abort

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

    db = Database()
    with db.get_connection() as con:
        cur = con.cursor()
        with open(PROJECT_MAIN / "authentication/sql/get_user.sql", 'r') as sql_file:
            sql = sql_file.read()
            cur.execute(sql, (user_fname, user_lname,user_password))

        user = cur.fetchone()

        if user is None:
            # No user exists or information wrong so return not authenticated
            return jsonify({"success": False, "message": "login fail"})
        elif user:
            return jsonify({"success": True, "message": "login success"})

        user_data = dict(user)

    return {
        "user": user_data
    }

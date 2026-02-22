from pathlib import Path
from sqlite3 import Row

from flask import blueprints
from flask import request
from flask import abort

from backend.database import Database

authentication_bp = blueprints.Blueprint('authentication', __name__)

@authentication_bp.route('/authenticate', methods=['POST'])
def authenticate():
    # Validate form first
    if "user_fname" not in request.form:
        abort(400)

    if "user_lname" not in request.form:
        abort(400)

    # Use first and last names to get the user ID from the database
    user_fname = request.form['user_fname']
    user_lname = request.form['user_lname']

    db = Database()
    with db.get_connection() as con:
        con.row_factory = Row
        cur = con.cursor()
        with open(Path('authentication/sql/get_user.sql').absolute(), 'r') as sql_file:
            sql = sql_file.read()
            cur.execute(sql, (user_fname, user_lname))

        user = cur.fetchone()

        if user is None:
            # No user exists or information wrong so return not authenticated
            abort(401)

        user_data = dict(user)

    return {
        "user": user_data
    }

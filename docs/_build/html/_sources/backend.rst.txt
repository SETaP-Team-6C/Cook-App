Backend
=======

This document describes the Python/Flask backend found under `backend/main`. It lists the registered blueprints, the HTTP endpoints exposed by each, the SQL files they use, and example request/response shapes.

Project layout (backend/main)
-----------------------------

- `app.py` — application factory that registers blueprints and initialises the `Database` helper.
- `database.py` — simple SQLite helper that creates/opens the database and initialises schema and test data.
- `paths.py` — helpers for resolving repository paths.
- Blueprints (each module has a `routes.py` and SQL files under `sql/`):
	- `index` — simple health/hello endpoint
	- `authentication` — login/auth endpoints and SQL at `authentication/sql/get_user.sql`
	- `account` — account creation and SQL at `account/sql/create_user.sql`
	- `recipe` — recipe listing, upload, and image serving; (`recipe/sql/` has `get_recipes.sql`, `add_recipe.sql`, `add_ingredient.sql`, `add_step.sql`, `get_main_image.sql`, `get_step_image.sql`)
	- `view_recipe` — endpoints for fetching recipe details and marking steps complete/uncomplete; SQL files in `view_recipe/sql/`
	- `search_recipe` — recipe search endpoint and SQL at `search_recipe/sql/search_recipe.sql` and `recipe_ingredients.sql`

Registered blueprints (application startup)
-------------------------------------------

`create_app()` (in `app.py`) registers these blueprints:

- `recipe_bp` (from `main.recipe.routes`) — recipe CRUD and images
- `authentication_bp` (from `main.authentication.routes`) — `/authenticate`
- `index_bp` (from `main.index.routes`) — `/`
- `account_bp` (from `main.account.routes`) — `/create-account`
- `search_bp` (from `main.search_recipe.routes`) — `/search-recipe`
- `view_recipe_bp` (from `main.view_recipe.routes`) — `/view-recipe/<id>`, `/complete-step`, `/uncomplete-step`

Endpoints, behavior and SQL
---------------------------

Index
~~~~~

- GET `/` — returns a simple JSON hello message. Implemented in `index/routes.py`.

Authentication
~~~~~~~~~~~~~~

- POST `/authenticate` — authenticate user by first+last name and password.
	- Request: form-encoded fields `user_fname`, `user_lname`, `user_password`.
	- SQL: `authentication/sql/get_user.sql` which selects `user_id, user_password` from `user` by `user_fname` and `user_lname` (case-insensitive like).
	- Behavior: returns 401 if no user found or password mismatch; otherwise sets Flask session `user_id` and returns `{"success": true, "user": { ... }}`.

Account
~~~~~~~

- POST `/create-account` — create a new user.
	- Request: form-encoded `user_fname`, `user_lname`, `user_email`, `user_password`.
	- SQL: `account/sql/create_user.sql` — inserts into `user` table and returns the inserted `user_id`.
	- Response: JSON `{"user_id": <int>}` with HTTP 201 on success.

Recipes (listing, upload, images)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- GET `/get-recipes` — returns a JSON list of recipes.
	- SQL: `recipe/sql/get_recipes.sql` selects `recipe_id, recipe_title`.
	- Response: `{"recipes": [ {"recipe_id": ..., "recipe_title": ...}, ... ] }`

- POST `/add-recipe` — create a new recipe (multipart/form-data upload).
	- Request fields (form):
		- `recipe-title` (string)
		- `recipe-time` (string, e.g. PT1H30M)
		- `recipe-difficulty` (string: 'easy'|'medium'|'hard')
		- `recipe-ingredients` (string — JSON encoded list of ingredient objects)
		- `recipe-steps` (string — JSON encoded list of step objects)
	- Files (multipart):
		- Optional `recipe-main-image` — main image binary
		- Any `step-image-<index>` keys for step images
	- Validation: server validates required fields and types (ingredient amounts/calories must be integers; steps must contain `step-description`, `step-duration`, `step-index`).
	- SQL: inserts into `recipe` (uses `recipe/sql/add_recipe.sql`), then loops to insert ingredients (`add_ingredient.sql`) and steps (`add_step.sql`), storing image blobs as needed. Commits transaction and returns `{"recipe-id": <int>}` with HTTP 201.

- GET `/recipe-image/<int:recipe_id>` — serves recipe main image.
	- SQL: `recipe/sql/get_main_image.sql` selects `recipe_main_image` blob; returns binary response with `Content-Type: image/jpeg` and cache headers.

- GET `/step-image/<int:step_id>` — serves a step image (binary) using `recipe/sql/get_step_image.sql`.

View recipe and step completion
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- GET `/view-recipe/<int:recipe_id>?user_id=<id>` — returns full recipe details in JSON.
	- SQL: `view_recipe/sql/get_recipe.sql` returns recipe metadata (id, title, difficulty, time).
	- SQL: `view_recipe/sql/get_recipe_ingredients.sql` returns list of ingredients.
	- SQL: `view_recipe/sql/get_recipe_steps.sql` returns steps; this SQL includes a CASE expression to compute `step-completion` by checking `recipe_step_completion` for the provided `user_id` (query uses two parameters: recipe_id and user_id).
	- Response shape example:

		{
			"recipe-id": 123,
			"recipe-title": "Tomato Pasta",
			"recipe-difficulty": "easy",
			"recipe-time": "PT0H30M",
			"recipe-ingredients": [ {"ingredient-name": "Tomato", "ingredient-amount": 200, ...}, ... ],
			"recipe-steps": [ {"recipe-step-id": 1, "step-description": "Boil water", "step-duration": "PT0H10M", "step-index": "1", "step-completion": 0}, ... ]
		}

- POST `/complete-step` — mark a step complete for a user.
	- Request: JSON { `recipe_step_id`: <int>, `user_id`: <int> }.
	- SQL: `view_recipe/sql/complete_step.sql` inserts into `recipe_step_completion` using `INSERT OR IGNORE`.
- POST `/uncomplete-step` — undo completion.
	- Request: same JSON shape; SQL `view_recipe/sql/uncomplete_step.sql` deletes the row from `recipe_step_completion`.

Search
~~~~~~

- GET `/search-recipe?q=<query>` — search recipes by title.
	- SQL: `search_recipe/sql/search_recipe.sql` selects recipe rows WHERE `recipe_title LIKE ?`.
	- For each matched recipe the handler also fetches ingredients via `recipe_ingredients.sql` and returns `{"recipes": [ { recipe fields, "ingredients": [...] }, ... ] }`.

Database and schema
-------------------

- The `Database` helper in `database.py` initialises `database.db` (or `test_database.db` when `TESTING=True`) by reading SQL from `../database/schema.sql` and `../database/test_data.sql` on first run.
- SQL used by endpoints are stored per-module under `module/sql/*.sql` and read at runtime.

Running and testing the backend
-------------------------------

- To run the Flask app locally (development), set FLASK_APP to `main.app:create_app` and run `flask run` from the `backend` folder. The app will create `database.db` if it does not exist.
- Example (PowerShell):

	```powershell
	Set-Location "C:\Users\shiji\Desktop\setap_project\Cook-App\backend\main"
	$env:FLASK_APP = 'main.app:create_app'
	flask run
	```

- Use the `Database.delete_test_database()` helper in test runs to remove `test_database.db` between runs.

Security and notes
------------------

- The backend uses plain-text password comparison against the `user_password` field. For production, switch to hashed passwords and secure sessions.
- Uploaded images are stored as blobs in the SQLite database. For larger scale, consider storing images in object storage and saving references in the DB.

This overview was generated by reading the Python modules and SQL files under `backend/main` to extract routes, SQL usage and request/response expectations.



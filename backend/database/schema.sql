CREATE TABLE user (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_fname TEXT NOT NULL,
    user_lname TEXT NOT NULL
);

CREATE TABLE recipe (
    recipe_id INTEGER PRIMARY KEY AUTOINCREMENT,
    recipe_title TEXT NOT NULL
);

CREATE TABLE completed_recipe (
    recipe_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    FOREIGN KEY (recipe_id) REFERENCES recipe (recipe_id),
    FOREIGN KEY (user_id) REFERENCES user (user_id)
);

CREATE TABLE recipe_ingredient (
    recipe_ingredient_id INTEGER PRIMARY KEY AUTOINCREMENT,
    recipe_id INTEGER NOT NULL,
    recipe_ingredient_name TEXT NOT NULL,
    FOREIGN KEY (recipe_id) REFERENCES recipe (recipe_id)
);

CREATE TABLE recipe_step (
    recipe_step_id INTEGER PRIMARY KEY AUTOINCREMENT,
    recipe_id INTEGER NOT NULL,
    recipe_step_index TEXT NOT NULL,
    recipe_step_description TEXT NOT NULL,
    recipe_step_duration TEXT,
    FOREIGN KEY (recipe_id) REFERENCES recipe (recipe_id)
);

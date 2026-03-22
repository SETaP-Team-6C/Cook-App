CREATE TABLE user (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_fname TEXT NOT NULL,
    user_lname TEXT NOT NULL,
    user_password TEXT NOT NUll,
    user_gmail TEXT NOT Null
);

CREATE TABLE dietary_requirement (
    dietary_requirement_id INTEGER PRIMARY KEY AUTOINCREMENT,
    dietary_requirement_name TEXT NOT NULL
);

CREATE TABLE user_dietary_requirement (
    user_id INTEGER NOT NULL,
    dietary_requirement_id INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user (user_id),
    FOREIGN KEY (dietary_requirement_id) REFERENCES dietary_requirement (dietary_requirement_id),
    PRIMARY KEY (user_id, dietary_requirement_id)
);

CREATE TABLE recipe (
    recipe_id INTEGER PRIMARY KEY AUTOINCREMENT,
    recipe_title TEXT NOT NULL,
    recipe_time TEXT,
    recipe_difficulty TEXT
);

CREATE TABLE completed_recipe (
    completed_recipe_id INTEGER NOT NULL,
    recipe_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    recipe_completion_date TEXT NOT NULL DEFAULT (current_timestamp),
    completed_recipe_photo BLOB,
    FOREIGN KEY (recipe_id) REFERENCES recipe (recipe_id),
    FOREIGN KEY (user_id) REFERENCES user (user_id)
);

CREATE TABLE recipe_ingredient (
    recipe_ingredient_id INTEGER PRIMARY KEY AUTOINCREMENT,
    recipe_id INTEGER NOT NULL,
    recipe_ingredient_name TEXT NOT NULL,
    recipe_ingredient_amount INTEGER NOT NULL DEFAULT (1),
    recipe_ingredient_unit TEXT,
    recipe_ingredient_calories INTEGER,
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

CREATE TABLE recipe_step_completion (
    recipe_step_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    FOREIGN KEY (recipe_step_id) REFERENCES recipe_step (recipe_id),
    FOREIGN KEY (user_id) REFERENCES user (user_id),
    PRIMARY KEY (recipe_step_id, user_id)
);

CREATE TABLE recipe_dietary_requirement (
    recipe_ingredient_id INTEGER NOT NULL,
    dietary_requirement_id INTEGER NOT NULL,
    FOREIGN KEY (recipe_ingredient_id) REFERENCES recipe_ingredient (recipe_ingredient_id),
    FOREIGN KEY (dietary_requirement_id) REFERENCES dietary_requirement (dietary_requirement_id),
    PRIMARY KEY (recipe_ingredient_id, dietary_requirement_id)
);

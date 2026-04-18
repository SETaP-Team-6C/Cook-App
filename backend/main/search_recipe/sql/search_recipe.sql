SELECT
    recipe_id,
    recipe_title,
    recipe_time,
    recipe_difficulty
FROM recipe
WHERE recipe_title LIKE ?;

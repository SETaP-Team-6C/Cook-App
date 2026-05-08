SELECT
    r.recipe_id AS "recipe-id",
    r.recipe_title AS "recipe-title",
    r.recipe_difficulty AS "recipe-difficulty",
    r.recipe_time AS "recipe-time"
FROM
    recipe r
WHERE
    r.recipe_id = ?
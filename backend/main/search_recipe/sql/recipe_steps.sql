SELECT
    recipe_step_id,
    recipe_step_index,
    recipe_step_description,
    recipe_step_duration
FROM recipe_step
WHERE recipe_id = ?;

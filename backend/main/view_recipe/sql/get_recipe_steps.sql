SELECT
    recipe_step_description AS "step-description",
    recipe_step_duration AS "step-duration",
    recipe_step_index as "step-index"
FROM
    recipe_step
WHERE
    recipe_id = ?
SELECT
    rs.recipe_step_id AS "recipe-step-id",
    rs.recipe_step_description AS "step-description",
    rs.recipe_step_duration AS "step-duration",
    rs.recipe_step_index as "step-index",
    CASE
        WHEN
            (
                SELECT
                    user_id
                FROM
                    recipe_step_completion rsc
                WHERE
                    rsc.recipe_step_id = rs.recipe_step_id
            ) IS NULL THEN 0
            ELSE 1
        END AS "step-completion"
FROM
    recipe_step rs
WHERE
    rs.recipe_id = ?1
